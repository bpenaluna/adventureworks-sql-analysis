SELECT
	c.[Name] AS Territory,
	YEAR(a.OrderDate) AS [Year],
	ROUND(SUM(a.TotalDue / COALESCE(b.EndOfDayRate, 1)) / 1000000, 2) AS [Total Revenue in USD (Millions)]
FROM Sales.SalesOrderHeader a
	LEFT JOIN Sales.CurrencyRate b ON a.CurrencyRateID = b.CurrencyRateID
	JOIN Sales.SalesTerritory c ON a.TerritoryID = c.TerritoryID
WHERE a.[Status] NOT IN (4, 6)
GROUP BY c.[Name], YEAR(a.OrderDate)
HAVING SUM(a.TotalDue / COALESCE(b.EndOfDayRate, 1)) > 1000000
ORDER BY [Total Revenue in USD (Millions)] DESC