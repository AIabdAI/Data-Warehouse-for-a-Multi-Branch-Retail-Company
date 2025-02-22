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
-- Database: `data_w_h`
--

-- --------------------------------------------------------

--
-- بنية الجدول `dimbranches`
--

CREATE TABLE `dimbranches` (
  `BranchID` int(11) NOT NULL,
  `BranchName` varchar(100) DEFAULT NULL,
  `City` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `dimbranches`
--

INSERT INTO `dimbranches` (`BranchID`, `BranchName`, `City`) VALUES
(1, 'Gaza', 'Gaza City'),
(2, 'Rafah', 'Rafah'),
(3, 'KhanYounis', 'Khan Younis'),
(4, 'DeirAlBalah', 'Deir Al-Balah');

-- --------------------------------------------------------

--
-- بنية الجدول `dimcommodities`
--

CREATE TABLE `dimcommodities` (
  `CommoditieID` int(11) NOT NULL,
  `CommoditieName` varchar(100) DEFAULT NULL,
  `PlaceOfProduction` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `dimdate`
--

CREATE TABLE `dimdate` (
  `DateKey` int(11) NOT NULL,
  `Year` int(11) DEFAULT NULL,
  `Month` int(11) DEFAULT NULL,
  `Day` int(11) DEFAULT NULL,
  `Week` int(11) DEFAULT NULL,
  `Quarter` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `dimdealers`
--

CREATE TABLE `dimdealers` (
  `DealerID` int(11) NOT NULL,
  `FirstName` varchar(50) DEFAULT NULL,
  `LastName` varchar(50) DEFAULT NULL,
  `Phone` varchar(15) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `factsales`
--

CREATE TABLE `factsales` (
  `SalesID` int(11) NOT NULL,
  `SalesNo` int(11) NOT NULL,
  `DateKey` int(11) DEFAULT NULL,
  `CommoditieID` int(11) DEFAULT NULL,
  `BranchID` int(11) DEFAULT NULL,
  `DealerID` int(11) DEFAULT NULL,
  `Quantity` int(11) DEFAULT NULL,
  `SalesPrice` decimal(10,2) DEFAULT NULL,
  `PurchasePrice` decimal(10,2) DEFAULT NULL,
  `Discount` decimal(5,2) DEFAULT NULL,
  `TotalRevenue` decimal(10,2) DEFAULT NULL,
  `TotalCost` decimal(10,2) DEFAULT NULL,
  `Profit` decimal(10,2) DEFAULT NULL,
  `SourceDealerNo` int(11) DEFAULT NULL,
  `SourceCommoditieNo` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `dimbranches`
--
ALTER TABLE `dimbranches`
  ADD PRIMARY KEY (`BranchID`);

--
-- Indexes for table `dimcommodities`
--
ALTER TABLE `dimcommodities`
  ADD PRIMARY KEY (`CommoditieID`);

--
-- Indexes for table `dimdate`
--
ALTER TABLE `dimdate`
  ADD PRIMARY KEY (`DateKey`);

--
-- Indexes for table `dimdealers`
--
ALTER TABLE `dimdealers`
  ADD PRIMARY KEY (`DealerID`);

--
-- Indexes for table `factsales`
--
ALTER TABLE `factsales`
  ADD PRIMARY KEY (`SalesID`),
  ADD KEY `CommoditieID` (`CommoditieID`),
  ADD KEY `BranchID` (`BranchID`),
  ADD KEY `DealerID` (`DealerID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `factsales`
--
ALTER TABLE `factsales`
  MODIFY `SalesID` int(11) NOT NULL AUTO_INCREMENT;

--
-- قيود الجداول المُلقاة.
--

--
-- قيود الجداول `factsales`
--
ALTER TABLE `factsales`
  ADD CONSTRAINT `factsales_ibfk_1` FOREIGN KEY (`CommoditieID`) REFERENCES `dimcommodities` (`CommoditieID`),
  ADD CONSTRAINT `factsales_ibfk_2` FOREIGN KEY (`BranchID`) REFERENCES `dimbranches` (`BranchID`),
  ADD CONSTRAINT `factsales_ibfk_3` FOREIGN KEY (`DealerID`) REFERENCES `dimdealers` (`DealerID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
