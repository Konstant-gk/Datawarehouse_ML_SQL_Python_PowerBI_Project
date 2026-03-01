USE MASTER
GO

ALTER DATABASE ChinookDW SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE IF EXISTS ChinookDW;
GO

CREATE DATABASE ChinookDW;
GO

USE ChinookDW;
GO

DROP TABLE IF EXISTS Dim_Employee;
DROP TABLE IF EXISTS Dim_Customer;
DROP TABLE IF EXISTS Dim_Product_Music;
DROP TABLE IF EXISTS Fact_Sales;
DROP TABLE IF EXISTS Dim_Sales_Info;
DROP TABLE IF EXISTS Dim_Date;


---- DimEmployee dimension will need to include:
CREATE TABLE Dim_Employee (
    Employee_Key INT IDENTITY(1,1) NOT NULL,
	Employee_Id INT NOT NULL,
    Employee_Last_Name VARCHAR(50) NOT NULL,
	Employee_First_Name VARCHAR(50) NOT NULL,
	Employee_Title VARCHAR(50) NOT NULL,
	Employee_Reports_To VARCHAR(50) NOT NULL, 
    Employee_Address VARCHAR(50) NOT NULL,
	Employee_City VARCHAR(50) NOT NULL,
	Employee_State VARCHAR(50) DEFAULT 'NA' NOT NULL,
	Employee_Country VARCHAR(50) NOT NULL,
	Employee_Postal_Code NVARCHAR(30) NOT NULL,
	Employee_Phone NVARCHAR(30) NOT NULL,
	Employee_Fax NVARCHAR(30) DEFAULT 0 NOT NULL,
	Employee_Email VARCHAR(50) NOT NULL,
    Employee_Birth_Date DATE DEFAULT '1899-12-31' NOT NULL,
    Employee_Hire_Date DATE DEFAULT '1899-12-31' NOT NULL,
	CONSTRAINT PK_Employee_Key PRIMARY KEY CLUSTERED (Employee_Key)
);

-- DimCustomer dimension will need to include:
CREATE TABLE Dim_Customer (
    Customer_Key INT IDENTITY(1,1) NOT NULL,
	Customer_Id INT NOT NULL,
	Customer_First_Name VARCHAR(50) NOT NULL,
	Customer_Last_Name VARCHAR(50) NOT NULL,
    Customer_Company VARCHAR(150) NOT NULL,
	Customer_Address VARCHAR(50) NOT NULL,
	Customer_City VARCHAR(50) NOT NULL,
	Customer_State VARCHAR(50) DEFAULT 'NA' NOT NULL,
	Customer_Country VARCHAR(50) NOT NULL,
	Customer_Postal_Code NVARCHAR(30) NOT NULL,
	Customer_Phone NVARCHAR(30) NOT NULL,
	Customer_Fax NVARCHAR(30) DEFAULT 0 NOT NULL,
	Customer_Email VARCHAR(50) NOT NULL,
	Customer_Support_Rep_Id INT NOT NULL,
	CONSTRAINT PK_Customer_Key PRIMARY KEY CLUSTERED (Customer_Key)
);

-- Dim_Sales_Info dimension will need to include:
CREATE TABLE Dim_Sales_Info (
	Invoice_Line_Key INT IDENTITY(1,1) NOT NULL,
	Invoice_Line_Id INT NOT NULL,
	Invoice_Id INT NOT NULL,
	Billing_Address VARCHAR(50) DEFAULT 'NA' NOT NULL,
	Billing_State VARCHAR(50)DEFAULT 'NA' NOT NULL,
	Billing_City VARCHAR(50) DEFAULT 'NA' NOT NULL,
	Billing_Country VARCHAR(50) DEFAULT 'NA' NOT NULL,
	Billing_Postal_Code NVARCHAR(30) DEFAULT 'NA' NOT NULL,
	CONSTRAINT PK_Invoice_Line_Key PRIMARY KEY CLUSTERED (Invoice_Line_Key)
);

-- Dim_Date dimension will need to include:
CREATE TABLE Dim_Date (
    Date_Key INT NOT NULL,
    Full_Date DATE NOT NULL,
	Quarter INT NOT NULL,
    Year INT NOT NULL,
	Month INT NOT NULL,
    MonthName VARCHAR(20) NOT NULL,
	Week INT NOT NULL,
    Day INT NOT NULL,
   	DayName VARCHAR(20) NOT NULL,
    PRIMARY KEY (Date_Key)
);



-- DimProductMusic dimension will need to include:
CREATE TABLE Dim_Product_Music (
	Track_Key INT IDENTITY(1,1) NOT NULL,
	Track_Id INT NOT NULL,
	Track_Name VARCHAR(150) NOT NULL,
	Track_Composer VARCHAR(200) DEFAULT 'NA' NOT NULL,
	Track_Miliseconds INT NOT NULL,
	Track_Bytes INT NOT NULL,
	Track_Unit_Price FLOAT NOT NULL,
	Album_Id INT NOT NULL,
	Album_Title VARCHAR(150) DEFAULT 'NA' NOT NULL,
	Artist_Id INT NOT NULL,
	Artist_Name VARCHAR(150) DEFAULT 'NA' NOT NULL,
	Media_Type_Id INT NOT NULL,
	Media_Type_Name VARCHAR(60) DEFAULT 'NA' NOT NULL,
	Genre_Id INT NOT NULL,
	Genre_Name VARCHAR(60) DEFAULT 'NA' NOT NULL,
	CONSTRAINT PK_Track_Key PRIMARY KEY CLUSTERED (Track_Key)
);


-- Fact_Sales dimension will need to include:
CREATE TABLE Fact_Sales(
	Invoice_Line_Key INT NOT NULL,
	Invoice_Id INT NOT NULL,
	Track_Key INT NOT NULL,
	Employee_Key INT NOT NULL,
	Customer_Key INT NOT NULL,
	Date_Key INT NOT NULL,
	Invoice_Date DATE NOT NULL,
	Quantity SMALLINT NOT NULL,
	Price FLOAT NOT NULL,
	Total FLOAT NOT NULL,
	Extended_Price_Amount FLOAT NOT NULL,
	Discount_Amount FLOAT DEFAULT 0 NOT NULL);

--Specify Start Date and End date here
--Value of Start Date Must be Less than Your End Date

DECLARE @CurrentDate DATETIME = '2005-01-01' --Starting value of Date Range
DECLARE @EndDate DATETIME = '2030-12-31' --End Value of Date Range

WHILE @CurrentDate <= @EndDate
BEGIN
    INSERT INTO Dim_Date (Date_Key, Full_Date, Year, Quarter, Month, MonthName, Week, Day, DayName)
    VALUES (
        CONVERT(INT, FORMAT(@CurrentDate, 'yyyyMMdd')), -- Datekey
        @CurrentDate,                                  -- FullDate
        YEAR(@CurrentDate),                            -- Year
        DATEPART(QUARTER, @CurrentDate),               -- Quarter
        MONTH(@CurrentDate),                           -- Month
        DATENAME(MONTH, @CurrentDate),                 -- MonthName
        DATEPART(WEEK, @CurrentDate),                  -- Week
        DAY(@CurrentDate),                             -- Day
        DATENAME(WEEKDAY, @CurrentDate)               -- DayName
    );

    SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
END;


--add foreign key to fact_sales table

ALTER TABLE Fact_Sales ADD CONSTRAINT FactSales_DimDate_DateKey_FK FOREIGN KEY (Date_Key)
    REFERENCES Dim_Date(Date_Key);

ALTER TABLE Fact_Sales ADD CONSTRAINT FactSales_DimSalesInfo_InvoiceLineKey_FK FOREIGN KEY (Invoice_Line_Key)
    REFERENCES Dim_Sales_Info (Invoice_Line_Key);

ALTER TABLE Fact_Sales ADD CONSTRAINT FactSales_DimCustomer_CustomerKey_FK FOREIGN KEY (Customer_Key)
    REFERENCES Dim_Customer (Customer_Key);

ALTER TABLE Fact_Sales ADD CONSTRAINT FactSales_DimEmployee_EmployeeKey_FK FOREIGN KEY (Employee_Key)
    REFERENCES Dim_Employee (Employee_Key);

ALTER TABLE Fact_Sales ADD CONSTRAINT FactSales_DimProductMusic_TrackKey_FK FOREIGN KEY (Track_Key)
    REFERENCES Dim_Product_Music (Track_Key);



SELECT * FROM Dim_Customer

