USE ChinookDW;
GO



--Drop constraints and recreate them after
ALTER TABLE dbo.Fact_Sales DROP CONSTRAINT IF EXISTS FactSales_DimDate_DateKey_FK;
ALTER TABLE dbo.Fact_Sales DROP CONSTRAINT IF EXISTS FactSales_DimProductMusic_TrackKey_FK;
ALTER TABLE dbo.Fact_Sales DROP CONSTRAINT IF EXISTS FactSales_DimEmployee_EmployeeKey_FK;
ALTER TABLE dbo.Fact_Sales DROP CONSTRAINT IF EXISTS FactSales_DimCustomer_CustomerKey_FK;
ALTER TABLE dbo.Fact_Sales DROP CONSTRAINT IF EXISTS FactSales_DimSalesInfo_InvoiceLineKey_FK;
GO

-- Only for the first load
TRUNCATE TABLE dbo.Fact_Sales;
TRUNCATE TABLE dbo.Dim_Product_Music;
TRUNCATE TABLE dbo.Dim_Customer;
TRUNCATE TABLE dbo.Dim_Employee;
TRUNCATE TABLE dbo.Dim_Sales_Info;
GO


-- Load values to Dim_Sales_Info
INSERT INTO Dim_Sales_Info (
	Invoice_Line_Id, 
	Invoice_Id, 
	Billing_Address, 
	Billing_State, 
	Billing_City, 
	Billing_Country, 
	Billing_Postal_Code)
SELECT 
	b.[InvoiceLineId], 
	a.[InvoiceId],
	CASE WHEN a.[BillingAddress] IS NULL THEN 'N/A' ELSE a.[BillingAddress] END,
	CASE WHEN a.[BillingState] IS NULL THEN 'N/A' ELSE a.[BillingState] END, 
	CASE WHEN a.[BillingCity] IS NULL THEN 'N/A' ELSE a.[BillingCity] END,
	CASE WHEN a.[BillingCountry] IS NULL THEN 'N/A' ELSE a.[BillingCountry] END,
	CASE WHEN a.[BillingPostalCode] IS NULL THEN 'N/A' ELSE a.[BillingPostalCode] END
FROM [ChinookStaging].[dbo].[Invoice] a
	INNER JOIN [ChinookStaging].[dbo].[Invoice_Line] b ON a.InvoiceId = b.InvoiceId;



-- Load values to Dim_Employee
INSERT INTO Dim_Employee (
	[Employee_Id],
	[Employee_Last_Name],
	[Employee_First_Name],
	[Employee_Title],
	[Employee_Reports_To],
	[Employee_Address], 
	[Employee_City],
	[Employee_State],
	[Employee_Country],
	[Employee_Postal_Code],
	[Employee_Phone],
	[Employee_Fax],
	[Employee_Email],
	[Employee_Birth_Date],
	[Employee_Hire_Date])
SELECT 
	[EmployeeID],
	[LastName],
	[FirstName],
	[Title],
    CASE WHEN [ReportsTo] IS NULL THEN 0 ELSE [ReportsTo] END,
	CASE WHEN [Address] IS NULL THEN 'N/A' ELSE [Address] END,
    CASE WHEN [City] IS NULL THEN 'N/A' ELSE [City] END,
    CASE WHEN [State] IS NULL THEN 'N/A' ELSE [State] END, 
    CASE WHEN [Country] IS NULL THEN 'N/A' ELSE [Country] END,
	CASE WHEN [PostalCode] IS NULL THEN 'N/A' ELSE [PostalCode] END,
	CASE WHEN [Phone] IS NULL THEN 'N/A' ELSE [Phone] END,
	CASE WHEN [Fax] IS NULL THEN 'N/A' ELSE [Fax] END,
	CASE WHEN [Email] IS NULL THEN 'N/A' ELSE [Email] END,
	[BirthDate],
	[HireDate]
FROM [ChinookStaging].[dbo].[Employee];


-- Load values to Dim_Customer
INSERT INTO Dim_Customer(
	[Customer_Id],
	[Customer_First_Name],
	[Customer_Last_Name],
	[Customer_Company],
	[Customer_Address],
	[Customer_City],
	[Customer_State],
	[Customer_Country], 
	[Customer_Postal_Code],
	[Customer_Phone],
	[Customer_Fax],
	[Customer_Email],
	[Customer_Support_Rep_Id])
SELECT 
	[CustomerId],
	[FirstName],
	[LastName],
	CASE WHEN [Company] IS NULL THEN 'N/A' ELSE [Company] END,
	CASE WHEN [Address] IS NULL THEN 'N/A' ELSE [Address] END,
	CASE WHEN [City] IS NULL THEN 'N/A' ELSE [City] END,
	CASE WHEN [State] IS NULL THEN 'N/A' ELSE [State] END, 
    CASE WHEN [Country] IS NULL THEN 'N/A' ELSE [Country] END,
	CASE WHEN [PostalCode] IS NULL THEN 'N/A' ELSE [PostalCode] END,
	CASE WHEN [Phone] IS NULL THEN 'N/A' ELSE [Phone] END,
	CASE WHEN [Fax] IS NULL THEN 'N/A' ELSE [Fax] END,
	CASE WHEN [Email] IS NULL THEN 'N/A' ELSE [Email] END,
	[SupportRepId]
FROM [ChinookStaging].[dbo].[Customer];


-- Load values to Dim_Product_Music (different insert into due to lack of connecting joins
INSERT INTO Dim_Product_Music(
	[Track_Id],
	[Track_Name],
	[Track_Composer],
	[Track_Miliseconds],
	[Track_Bytes],
	[Track_Unit_Price],
	[Album_Id],
	[Album_Title],
	[Artist_Id],
	[Artist_Name],
	[Media_Type_Id],
	[Media_Type_Name],
	[Genre_Id],
	[Genre_Name])
SELECT
	a.[TrackId], 
	a.[Name], 
	CASE WHEN a.[Composer] IS NULL THEN 'N/A' ELSE a.[Composer] END,
	a.[Milliseconds],
	a.[Bytes],
	a.[UnitPrice],
	b.[AlbumId],
	b.[Title],
	c.[ArtistId],
	c.[Name],
	f.[MediaTypeId],
	f.[Name],
	g.[GenreId],
	g.[Name]
FROM [ChinookStaging].[dbo].[Track] a
	INNER JOIN [ChinookStaging].[dbo].[Album] b ON a.[AlbumId] = b.[AlbumId]
	INNER JOIN [ChinookStaging].[dbo].[Artist] c ON b.[ArtistId] = c.[ArtistId]
	INNER JOIN [ChinookStaging].[dbo].[Media_Type] f ON a.[MediaTypeId] = f.[MediaTypeId]
	INNER JOIN [ChinookStaging].[dbo].[Genre] g ON a.[GenreId] = g.[GenreId];




-- Load values to Fact_Sales
INSERT INTO Fact_Sales(
	[Invoice_Line_Key],
	[Invoice_Id],
	[Track_Key],
	[Employee_Key],
	[Customer_Key],
	[Date_Key],
	[Invoice_Date],
	[Quantity],
	[Price],
	[Total],
	[Extended_Price_Amount])
SELECT
	f.[Invoice_Line_Key],
	b.[InvoiceId],
	e.[Track_Key],
	g.[Employee_Key],
	d.[Customer_Key],
	c.[Date_Key],
	b.[InvoiceDate],
	a.[Quantity],
	a.[UnitPrice],
	b.[Total],
	a.[Quantity] * a.[UnitPrice] AS [Extended_Price_Amount]
FROM [ChinookStaging].[dbo].[Invoice_Line] a
	INNER JOIN [ChinookStaging].[dbo].[Invoice] b ON a.[InvoiceId] = b.[InvoiceId]
	INNER JOIN [ChinookDW].[dbo].[Dim_Date] c ON b.[InvoiceDate] = c.[Full_Date]
	INNER JOIN [ChinookDW].[dbo].[Dim_Customer] d ON b.[CustomerId] = d.[Customer_Id]
	INNER JOIN [ChinookDW].[dbo].[Dim_Product_Music] e ON a.[TrackId] = e.[Track_Id]
	INNER JOIN [ChinookDW].[dbo].[Dim_Sales_Info] f ON a.[InvoiceLineId] = f.[Invoice_Line_Id]
	INNER JOIN [ChinookDW].[dbo].[Dim_Employee] g ON d.[Customer_Support_Rep_Id] = g.[Employee_Id];


--recreate the constraints Foreign Keys
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



SELECT * FROM [dbo].[Fact_Sales]
