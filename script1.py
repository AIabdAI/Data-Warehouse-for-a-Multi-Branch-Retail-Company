import pandas as pd
import mysql.connector
import logging
import time
from datetime import datetime, timedelta

# Error logging setup
log_file = "etl_errors.log"
logging.basicConfig(filename=log_file, level=logging.ERROR, format="%(asctime)s - %(levelname)s - %(message)s")

class DatabaseConnection:
    def __init__(self, db_config):
        self.db_config = db_config
        self.connection = None

    def connect(self):
        while True:
            try:
                self.connection = mysql.connector.connect(**self.db_config)
                print(f"✅ Connected to {self.db_config['database']} on {self.db_config['host']}")
                return self.connection
            except mysql.connector.Error as e:
                logging.error(f"❌ Connection error: {e}")
                print("⚠️ Retrying in 1 hour...")
                time.sleep(3600)

    def close(self):
        if self.connection:
            self.connection.close()
            print(f"🔌 Closed connection to {self.db_config['database']}")

class ETLProcess:
    def __init__(self, branch_databases, data_warehouse_db):
        self.branch_databases = branch_databases
        self.data_warehouse_db = data_warehouse_db

    def sync_dim_tables(self, branch_name, branch_db_config):
        """ مزامنة جداول الأبعاد من `store` إلى `data_w_h` """
        print(f"🔄 مزامنة بيانات الأبعاد للفرع {branch_name}...")

        # الاتصال بقاعدة بيانات `store` لجلب البيانات
        branch_conn = DatabaseConnection(branch_db_config)
        conn_branch = branch_conn.connect()
        cursor_branch = conn_branch.cursor()

        # الاتصال بمستودع البيانات `data_w_h`
        dw_conn = DatabaseConnection(self.data_warehouse_db)
        conn_dw = dw_conn.connect()
        cursor_dw = conn_dw.cursor()

        try:
            # جلب البيانات من `store`
            cursor_branch.execute("SELECT  DealerNo,FirstName, LastName, Phone FROM Dealer")
            dealers = cursor_branch.fetchall()

            cursor_branch.execute("SELECT CommoditieNo, CommoditieName, PlaceOfProduction FROM Commodities")
            commodities = cursor_branch.fetchall()

            # إدخال البيانات إلى `data_w_h` (مستودع البيانات)
            for dealer in dealers:
                cursor_dw.execute(
                    "INSERT IGNORE INTO DimDealers (DealerID, FirstName, LastName, Phone) VALUES (%s, %s, %s, %s)",
                    dealer
                )

            for commodity in commodities:
                cursor_dw.execute(
                    "INSERT IGNORE INTO DimCommodities (CommoditieID, CommoditieName, PlaceOfProduction) VALUES (%s, %s, %s)",
                    commodity
                )

            conn_dw.commit()
            print(f"✅ تمت مزامنة الأبعاد للفرع {branch_name}.")

        except Exception as e:
            logging.error(f"❌ Sync error ({branch_name}): {e}")
            print(f"⚠️ خطأ أثناء مزامنة جداول الأبعاد للفرع {branch_name}.")
        finally:
            cursor_branch.close()
            cursor_dw.close()
            branch_conn.close()
            dw_conn.close()

    def extract_data(self, conn, branch_name, date):
        try:
            query = f"""WITH AvgPurchases AS (
    SELECT 
        CommoditieNo, 
        AVG(UnitPrice) AS AvgUnitPrice
    FROM Purchases
    WHERE PurchaseDate <= '{date}'
    GROUP BY CommoditieNo
)
SELECT 
    s.SalesNo as SalesID , 
    s.CommoditieNo as CommoditieID,
    cm.CommoditieName,  -- إضافة اسم السلعة
    s.CartNo , 
    s.Quantity, 
    s.SalesPrice, 
    c.CartDate, 
    c.Discount, 
    '{branch_name}' AS BranchName,
    d.DealerNo AS DealerID,
    d.FirstName,
    d.LastName,
    SUM(s2.SalesPrice) OVER (PARTITION BY s.CartNo) AS TotalCartSalesPrice,
    ap.AvgUnitPrice AS PurchasePrice,
    s.SalesPrice - (s.SalesPrice / SUM(s2.SalesPrice) OVER (PARTITION BY s.CartNo) * c.Discount) - ap.AvgUnitPrice AS Profit
FROM Sales s
JOIN Carts c ON s.CartNo = c.CartNo
JOIN AvgPurchases ap ON s.CommoditieNo = ap.CommoditieNo
JOIN Sales s2 ON s.CartNo = s2.CartNo
JOIN Purchases p ON s.CommoditieNo = p.CommoditieNo
JOIN Dealer d ON p.DealerNo = d.DealerNo
JOIN Commodities cm ON s.CommoditieNo = cm.CommoditieNo  -- الانضمام إلى جدول Commodities
WHERE c.CartDate = '{date}';

            """
            df_sales = pd.read_sql(query, conn)
            return df_sales.drop_duplicates()
        except Exception as e:
            logging.error(f"❌ Extraction error ({branch_name}, {date}): {e}")
            print(f"⚠️ Extraction error for {branch_name} on {date}.")
            return pd.DataFrame()

    def load_data(self, df,date):
        if df.empty:
            print("⚠️ No data to load.")
            return

        db_conn = DatabaseConnection(self.data_warehouse_db)
        conn_dw = db_conn.connect()
        cursor = conn_dw.cursor()

        try:
            #load_date = datetime.now().strftime('%Y-%m-%d')
            #load_date =date
            #year, month, day = datetime.now().year, datetime.now().month, datetime.now().day
            year, month, day = date.year, date.month, date.day 
            date_key = int(f"{year}{month:02d}{day:02d}")
            week = date.isocalendar()[1]
            quarter = (month - 1) // 3 + 1

            # إدراج تاريخ العملية في DimDate إذا لم يكن موجودًا
            cursor.execute("""
                INSERT IGNORE INTO DimDate ( DateKey,Year, Month, Day, Week, Quarter)
                VALUES ( %s ,%s, %s, %s, %s, %s)
            """, (date_key, year, month, day, week, quarter))
            
            for _, row in df.iterrows():
                print(row)
                #time.sleep(2)
                insert_query = """
                INSERT INTO FactSales (SalesNo, SourceCommoditieNo,SourceDealerNo,CommoditieID, DealerID, Quantity, SalesPrice, DateKey, Discount, BranchID, TotalRevenue, PurchasePrice, Profit,TotalCost)
                VALUES  (%s, %s, %s,(select CommoditieID from dimcommodities where CommoditieName = %s), (select DealerID from dimdealers where  FirstName = %s and LastName= %s), %s, %s, (SELECT DateKey FROM DimDate WHERE Day = %s AND Month = %s AND Year = %s), %s , 
                         (SELECT BranchID FROM dimbranches WHERE BranchName = %s LIMIT 1), %s, %s, %s,%s)
                """
                params = (
                    row["SalesID"], row["CommoditieID"], row["DealerID"],row["CommoditieName"],row["FirstName"],row["LastName"],
                    row["Quantity"], row["SalesPrice"],day ,month,year, row["Discount"],
                    row["BranchName"], row["Profit"] * row["Quantity"], row["PurchasePrice"], row["Profit"], row["Quantity"]* row["PurchasePrice"]
                )
                

                cursor.execute(insert_query, params)

            conn_dw.commit()
            print("✅ Data loaded into warehouse.")
        except Exception as e:
            logging.error(f"❌ Loading error: {e}")
            print("⚠️ Loading error.")
        finally:
            cursor.close()
            db_conn.close()

    def run(self):
        """ تشغيل العملية كاملة: مزامنة الأبعاد ثم معالجة البيانات اليومية """
        start_date = datetime(2024, 10, 1)
        end_date = datetime(2026, 1, 1)
        delta = timedelta(days=1)

        while start_date <= end_date:
            current_date = start_date.strftime('%Y-%m-%d')
            print(f"🔄 Processing {current_date}")
            all_data = pd.DataFrame()

            for branch, db_config in self.branch_databases.items():
                self.sync_dim_tables(branch, db_config)  # 🔄 مزامنة الأبعاد قبل استخراج البيانات

                db_conn = DatabaseConnection(db_config)
                conn = db_conn.connect()
                df_sales = self.extract_data(conn, branch, current_date)
                db_conn.close()

                if not df_sales.empty:
                    all_data = pd.concat([all_data, df_sales], ignore_index=True)

            self.load_data(all_data,start_date)
            start_date += delta

        print("✅ ETL process completed.")

if __name__ == "__main__":
    branch_databases = {
        "Gaza": {"host": "localhost", "user": "root", "password": "", "database": "store"},
        "Rafah": {"host": "localhost", "user": "root", "password": "", "database": "store"},
        "KhanYounis": {"host": "localhost", "user": "root", "password": "", "database": "store"},
        "DeirAlBalah": {"host": "localhost", "user": "root", "password": "", "database": "store"}
    }
    data_warehouse_db = {"host": "localhost", "user": "root", "password": "", "database": "data_w_h"}

    etl = ETLProcess(branch_databases, data_warehouse_db)
    etl.run()
