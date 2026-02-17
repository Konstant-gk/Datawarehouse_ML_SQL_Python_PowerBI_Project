CREATE DATABASE ChinookStaging
GO

USE ChinookStaging
GO

DROP TABLE IF EXISTS ChinookStaging.dbo.Employee;
DROP TABLE IF EXISTS ChinookStaging.dbo.Customer;
DROP TABLE IF EXISTS ChinookStaging.dbo.Genre;
DROP TABLE IF EXISTS ChinookStaging.dbo.Album;
DROP TABLE IF EXISTS ChinookStaging.dbo.Artist;
DROP TABLE IF EXISTS ChinookStaging.dbo.Invoice;
DROP TABLE IF EXISTS ChinookStaging.dbo.Invoice_Line;
DROP TABLE IF EXISTS ChinookStaging.dbo.Media_Type;
DROP TABLE IF EXISTS ChinookStaging.dbo.Playilst;
DROP TABLE IF EXISTS ChinookStaging.dbo.Playilst_Track;
DROP TABLE IF EXISTS ChinookStaging.dbo.Track;



--1. get data FROM Employee



SELECT EmployeeID, FirstName, LastName, Title, ReportsTo, BirthDate, HireDate, Address, City, State, Country, PostalCode, Phone, Fax, Email
INTO ChinookStaging.dbo.Employee
FROM Chinook.dbo.Employee


--2 get FROM Customer


SELECT  CustomerId, FirstName, LastName, Company, Address, City, State, Country, PostalCode, Phone, Fax, Email, SupportRepId
INTO ChinookStaging.dbo.Customer
FROM Chinook.dbo.Customer

--3  get FROM Album

SELECT  AlbumId, Title, ArtistId
INTO ChinookStaging.dbo.Album
FROM Chinook.dbo.Album

--4  get FROM Artist

SELECT  ArtistId, Name
INTO ChinookStaging.dbo.Artist
FROM Chinook.dbo.Artist

--5  get FROM Genre

SELECT  GenreId, Name
INTO ChinookStaging.dbo.Genre
FROM Chinook.dbo.Genre

--6  get FROM Invoice

SELECT  InvoiceId, CustomerId, InvoiceDate, BillingAddress, BillingCity, BillingState, BillingCountry, BillingPostalCode, Total
INTO ChinookStaging.dbo.Invoice
FROM Chinook.dbo.Invoice

--7  get FROM InvoiceLine

SELECT InvoiceLineId, InvoiceId, TrackId, UnitPrice, Quantity
INTO ChinookStaging.dbo.Invoice_Line
FROM Chinook.dbo.InvoiceLine

--8  get FROM Media_Type

SELECT  MediaTypeId, Name
INTO ChinookStaging.dbo.Media_Type
FROM Chinook.dbo.MediaType

--9  get FROM Playlist

SELECT  PlaylistId, Name
INTO ChinookStaging.dbo.Playlist
FROM Chinook.dbo.Playlist

--10  get FROM Playlist_Track

SELECT  PlaylistId, TrackId
INTO ChinookStaging.dbo.Playlist_Track
FROM Chinook.dbo.PlaylistTrack

--11  get FROM Track

SELECT  TrackId, Name, AlbumId, MediaTypeId, GenreId, Composer, Milliseconds, Bytes,UnitPrice
INTO ChinookStaging.dbo.Track
FROM Chinook.dbo.Track







