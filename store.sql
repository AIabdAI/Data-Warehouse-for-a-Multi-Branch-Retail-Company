-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: 22 فبراير 2025 الساعة 12:58
-- إصدار الخادم: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `store`
--

-- --------------------------------------------------------

--
-- بنية الجدول `carts`
--

CREATE TABLE `carts` (
  `CartNo` int(11) NOT NULL,
  `CartDate` date DEFAULT NULL,
  `CartTime` time DEFAULT NULL,
  `Discount` decimal(5,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `carts`
--



-- --------------------------------------------------------

--
-- بنية الجدول `commodities`
--

CREATE TABLE `commodities` (
  `CommoditieNo` int(11) NOT NULL,
  `CommoditieName` varchar(100) DEFAULT NULL,
  `PlaceOfProduction` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `commodities`
--


-- --------------------------------------------------------

--
-- بنية الجدول `purchases`
--

CREATE TABLE `purchases` (
  `TransactionNo` int(11) NOT NULL,
  `CommoditieNo` int(11) DEFAULT NULL,
  `DealerNo` int(11) DEFAULT NULL,
  `Quantity` int(11) DEFAULT NULL,
  `UnitPrice` decimal(10,2) DEFAULT NULL,
  `PurchaseDate` date DEFAULT NULL,
  `PurchaseTime` time DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `purchases`
--


----------------------------------------------------

--
-- بنية الجدول `sales`
--

CREATE TABLE `sales` (
  `SalesNo` int(11) NOT NULL,
  `CommoditieNo` int(11) DEFAULT NULL,
  `CartNo` int(11) DEFAULT NULL,
  `Quantity` int(11) DEFAULT NULL,
  `SalesPrice` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `sales`
--


--
-- Indexes for dumped tables
--

--
-- Indexes for table `carts`
--
ALTER TABLE `carts`
  ADD PRIMARY KEY (`CartNo`);

--
-- Indexes for table `commodities`
--
ALTER TABLE `commodities`
  ADD PRIMARY KEY (`CommoditieNo`);

--
-- Indexes for table `dealer`
--
ALTER TABLE `dealer`
  ADD PRIMARY KEY (`DealerNo`);

--
-- Indexes for table `purchases`
--
ALTER TABLE `purchases`
  ADD PRIMARY KEY (`TransactionNo`),
  ADD KEY `CommoditieNo` (`CommoditieNo`),
  ADD KEY `DealerNo` (`DealerNo`);

--
-- Indexes for table `sales`
--
ALTER TABLE `sales`
  ADD PRIMARY KEY (`SalesNo`),
  ADD KEY `CommoditieNo` (`CommoditieNo`),
  ADD KEY `CartNo` (`CartNo`);

--
-- قيود الجداول المُلقاة.
--

--
-- قيود الجداول `purchases`
--
ALTER TABLE `purchases`
  ADD CONSTRAINT `purchases_ibfk_1` FOREIGN KEY (`CommoditieNo`) REFERENCES `commodities` (`CommoditieNo`),
  ADD CONSTRAINT `purchases_ibfk_2` FOREIGN KEY (`DealerNo`) REFERENCES `dealer` (`DealerNo`);

--
-- قيود الجداول `sales`
--
ALTER TABLE `sales`
  ADD CONSTRAINT `sales_ibfk_1` FOREIGN KEY (`CommoditieNo`) REFERENCES `commodities` (`CommoditieNo`),
  ADD CONSTRAINT `sales_ibfk_2` FOREIGN KEY (`CartNo`) REFERENCES `carts` (`CartNo`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
