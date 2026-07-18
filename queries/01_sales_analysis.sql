WITH revenue_over_mil AS (
	SELECT
		c.[Name] AS Territory,
		YEAR(a.OrderDate) AS [Year],
		ROUND(SUM(a.TotalDue / COALESCE(b.EndOfDayRate, 1)) / 1000000, 2) AS [Revenue (USD)]
	FROM Sales.SalesOrderHeader a
		LEFT JOIN Sales.CurrencyRate b ON a.CurrencyRateID = b.CurrencyRateID
		JOIN Sales.SalesTerritory c ON a.TerritoryID = c.TerritoryID
	WHERE a.[Status] NOT IN (4, 6)
	GROUP BY c.[Name], YEAR(a.OrderDate)
	HAVING SUM(a.TotalDue / COALESCE(b.EndOfDayRate, 1)) > 1000000
)
SELECT Territory, COUNT(*) AS [Count]
FROM (
	SELECT DISTINCT [Name] from Sales.SalesTerritory
) t LEFT JOIN revenue_over_mil ON t.Name = revenue_over_mil.Territory
GROUP BY Territory
ORDER BY [Count] DESC, Territory