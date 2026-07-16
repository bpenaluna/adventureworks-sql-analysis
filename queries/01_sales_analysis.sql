/*
SELECT 
	YEAR(OrderDate) AS [Year],
	COUNT(DISTINCT CustomerID) AS "Number of Unique Customers",
	AVG(SubTotal + TaxAmt),
	SUM(SubTotal + TaxAmt),
	SUM(TotalDue),
	AVG(TaxAmt / SubTotal)
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate)
ORDER BY "Number of Unique Customers" DESC
*/

SELECT DISTINCT a.CurrencyRateID, c.[Name] AS "From Currency", d.[Name] AS "To Currency"
FROM Sales.SalesOrderHeader a
	JOIN Sales.CurrencyRate b ON a.CurrencyRateID = b.CurrencyRateID
	JOIN Sales.Currency c ON b.FromCurrencyCode = c.CurrencyCode
	JOIN Sales.Currency d ON b.ToCurrencyCode = d.CurrencyCode