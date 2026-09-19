/*
=========================================
create database and schemas
=========================================
script purpose:
  This script create a new database named 'DataWarehouse' after checking if it already exists.
  If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas
  within the database: 'bronze' , 'silver' , 'gold'.
Warning:
  Running this script will drop the entire datawarehouse database if it exist.
  All data in the dtabase will be permenantly deleted . Proceed with caution
  and ensure yoy hve proper backup before running this script.
*/

USE master;
GO

--Drop and recreate the 'datawarehouse' database
IF EXISTS(SELECT 1 FROM sys.databases WHERE name ='DataWarehouse')
BEGIN
  ALTER DATABASE Datawarehouse SET SINGLE USER WILL ROLLBACK IMMEDIATE;
  DROP DATABASE DataWarehouse;
END;
GO

--create the 'Datawarehouse' database
CREATE DATABASE DataWarehouse;
GO

USE Datawarehouse;
GO

--create schemas
CREATE SCHEMA Bronze;
GO

CREAATE SCHEMA Silver;
GO

CREATE SCHEMA Gold;
GO
