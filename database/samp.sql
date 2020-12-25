-- phpMyAdmin SQL Dump
-- version 5.0.4
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Dec 26, 2020 at 02:53 AM
-- Server version: 8.0.21
-- PHP Version: 7.4.10

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `samp`
--

-- --------------------------------------------------------

--
-- Table structure for table `characters`
--

CREATE TABLE `characters` (
  `char_dbid` bigint UNSIGNED NOT NULL,
  `master_id` int NOT NULL,
  `char_name` varchar(255) NOT NULL,
  `pTutorial` tinyint(1) NOT NULL DEFAULT '0',
  `pLevel` int NOT NULL DEFAULT '0',
  `pExp` int NOT NULL DEFAULT '0',
  `pLastSkin` int NOT NULL DEFAULT '264',
  `pFaction` int DEFAULT '0',
  `pCash` int NOT NULL DEFAULT '0',
  `pSpawnPoint` int NOT NULL DEFAULT '0',
  `pSpawnHouse` int NOT NULL DEFAULT '0',
  `pTimeout` int NOT NULL DEFAULT '0',
  `pHealth` float NOT NULL DEFAULT '100',
  `pArmour` float NOT NULL DEFAULT '0',
  `pLastPosX` float NOT NULL DEFAULT '0',
  `pLastPosY` float NOT NULL DEFAULT '0',
  `pLastPosZ` float NOT NULL DEFAULT '0',
  `pLastInterior` int NOT NULL DEFAULT '0',
  `pLastWorld` int NOT NULL DEFAULT '0',
  `pJob` int NOT NULL DEFAULT '0',
  `pSideJob` int NOT NULL DEFAULT '0',
  `pCareer` int NOT NULL DEFAULT '0',
  `pPaycheck` int NOT NULL DEFAULT '0',
  `pFishes` int NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `masters`
--

CREATE TABLE `masters` (
  `acc_dbid` bigint UNSIGNED NOT NULL,
  `acc_name` varchar(64) NOT NULL,
  `acc_pass` varchar(129) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `acc_email` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `admin` int NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `private_car`
--

CREATE TABLE `private_car` (
  `id` bigint UNSIGNED NOT NULL,
  `modelid` int NOT NULL,
  `player_id` bigint UNSIGNED NOT NULL,
  `color1` smallint NOT NULL DEFAULT '0',
  `color2` smallint NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `characters`
--
ALTER TABLE `characters`
  ADD PRIMARY KEY (`char_dbid`);

--
-- Indexes for table `masters`
--
ALTER TABLE `masters`
  ADD PRIMARY KEY (`acc_dbid`);

--
-- Indexes for table `private_car`
--
ALTER TABLE `private_car`
  ADD PRIMARY KEY (`id`),
  ADD KEY `FK_player_car` (`player_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `characters`
--
ALTER TABLE `characters`
  MODIFY `char_dbid` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `masters`
--
ALTER TABLE `masters`
  MODIFY `acc_dbid` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `private_car`
--
ALTER TABLE `private_car`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `private_car`
--
ALTER TABLE `private_car`
  ADD CONSTRAINT `FK_player_car` FOREIGN KEY (`player_id`) REFERENCES `characters` (`char_dbid`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
