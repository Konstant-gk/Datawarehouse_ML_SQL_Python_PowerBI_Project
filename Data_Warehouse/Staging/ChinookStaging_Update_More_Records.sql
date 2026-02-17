USE ChinookStaging
GO
UPDATE i
SET i.Total = subquery.Total
FROM Invoice i
INNER JOIN (
    SELECT il.InvoiceId, SUM(il.UnitPrice * il.Quantity) AS Total
    FROM Invoice_Line il
    GROUP BY il.InvoiceId
) subquery
ON i.InvoiceId = subquery.InvoiceId;
SELECT *
  FROM [ChinookStaging].[dbo].[Invoice]
USE master
GO