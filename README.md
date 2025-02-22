# Data Warehouse for a Multi-Branch Retail Company

## Project Overview

This project involves building a **Data Warehouse** for a company that owns retail stores in various governorates of **Gaza Strip** (Gaza, Deir Al-Balah, Khan Younis, and Rafah). The data warehouse integrates sales and inventory data from multiple branches, enabling **advanced analytics and decision-making**.

## Objectives

1. **Support Decision-Making** – Provide a centralized system for analyzing sales trends.
2. **Improve Business Reporting** – Enable accurate and efficient reporting.
3. **Advanced Analytics** – Facilitate complex queries and data analysis.
4. **Sales Behavior Analysis** – Identify and predict sales patterns.
5. **Discount Impact Analysis** – Measure the effect of discounts on revenue.
6. **Branch Performance Analysis** – Compare performance across different locations.
7. **Product Behavior Analysis** – Evaluate the demand and profitability of products.
8. **Stock Availability Impact** – Understand how inventory levels affect sales.

## Data Sources

Each branch maintains its own **database** containing:

- Product Catalog
- Sales Transactions
- Purchase Records
- Dealer Information

## Data Warehouse Structure

The system follows an **Enterprise Data Warehouse (EDW)** architecture using the **Star Schema** model.

### Schema Design

#### **Dimension Tables:**

- `dimbranch` – Branch information
- `dimcommodities` – Product details
- `dimdate` – Date-related attributes
- `dimdealers` – Supplier details

#### **Fact Table:**

- `factsales`
  - `SalesID, SalesNo, DateKey, CommoditieID, BranchID, DealerID, Quantity, SalesPrice, PurchasePrice, Discount, TotalRevenue, TotalCost, Profit, SourceCommoditieNo, SourceDealerNo`

## Implementation Steps

### **Step 1: Schema Development**

The first step is designing and setting up the **schema** for the data warehouse.

```sql
CREATE TABLE FactSales (
    SalesID INT PRIMARY KEY,
    SalesNo INT,
    DateKey INT,
    CommoditieID INT,
    BranchID INT,
    DealerID INT,
    Quantity INT,
    SalesPrice DECIMAL(10,2),
    PurchasePrice DECIMAL(10,2),
    Discount DECIMAL(10,2),
    TotalRevenue DECIMAL(10,2),
    TotalCost DECIMAL(10,2),
    Profit DECIMAL(10,2),
    SourceCommoditieNo INT,
    SourceDealerNo INT
);
```

### **Step 2: ETL Development (Python Script)**

A **Python-based ETL script** is developed to:

- **Handle database connection errors and retry after one hour in case of failure.**

```python
class DatabaseConnection:
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
```

- **Log errors and events during execution.**

```python
logging.basicConfig(filename='etl_errors.log', level=logging.ERROR,
                    format='%(asctime)s - %(levelname)s - %(message)s')
```

- **Synchronize dimension tables when new products or dealers are added.**

```python
cursor_branch.execute("SELECT DealerNo, FirstName, LastName, Phone FROM Dealer")
dealers = cursor_branch.fetchall()

for dealer in dealers:
    cursor_dw.execute(
        "INSERT IGNORE INTO DimDealers (DealerID, FirstName, LastName, Phone) VALUES (%s, %s, %s, %s)",
        dealer
    )
```

- **Extract data from each branch database.**

```python
def extract_data(self, conn, branch_name, date):
    query = f"""SELECT * FROM Sales WHERE Date = '{date}'"""
    df_sales = pd.read_sql(query, conn)
    return df_sales.drop_duplicates()
```

- **Transform data into a format suitable for the warehouse.**

```python
df_sales['Profit'] = df_sales['SalesPrice'] - df_sales['Discount'] - df_sales['PurchasePrice']
```

- **Maintain foreign key integrity while resolving discrepancies across branches.**

```python
cursor.execute(
    "INSERT INTO FactSales (SalesNo, CommoditieID, DealerID, Quantity, SalesPrice, DateKey, BranchID) "
    "VALUES (%s, (SELECT CommoditieID FROM dimcommodities WHERE CommoditieName = %s), "
    "(SELECT DealerID FROM dimdealers WHERE FirstName = %s AND LastName = %s), %s, %s, "
    "(SELECT DateKey FROM DimDate WHERE Day = %s AND Month = %s AND Year = %s), "
    "(SELECT BranchID FROM dimbranches WHERE BranchName = %s LIMIT 1))",
    params
)
```

- **Calculate profit using the average purchase price method to avoid date inconsistencies.**

```python
query = """WITH AvgPurchases AS (
    SELECT CommoditieNo, AVG(UnitPrice) AS AvgUnitPrice
    FROM Purchases
    WHERE PurchaseDate <= %s
    GROUP BY CommoditieNo
)"""
```

### **Step 3: Scheduling ETL Execution**

The script (`script1.py`) runs periodically via **task scheduling:**

#### **Windows Task Scheduler Command:**

```sh
schtasks /create /tn "RunPythonScript" /tr "C:\path\to\python.exe C:\path\to\script1.py" /sc daily /st 00:00 /f
```

#### **Linux Cron Job Command:**

```sh
(crontab -l 2>/dev/null; echo "0 0 * * * /usr/bin/python3 /path/to/script1.py") | crontab -
```

## Technologies Used

- **Database:** MySQL
- **ETL Processing:** Python (pandas, mysql.connector)
- **Task Scheduling:** Windows Task Scheduler / Linux Cron Jobs
- **Data Modeling:** Star Schema

## Repository Contents

- `store.sql` – Database schema for branch stores.
- `data_w_h.sql` – Schema for the data warehouse.
- `script1.py` – Python script for ETL processing.
- `README.md` – Project documentation.

## Future Enhancements

- Implement **incremental data loading** to optimize performance.
- Integrate **dashboard visualization tools** (e.g., Power BI, Tableau) for real-time analytics.
- Optimize **query performance** using indexing and partitioning techniques.

## Author

Developed by **Abdallah A. M. Iqelan**.

For any inquiries, contact: [**abd.500a2@gmail.com**](mailto\:abd.500a2@gmail.com)

