WITH performance AS (
	SELECT
		c.[Name] AS Territory,
		YEAR(a.OrderDate) AS [Year],
		ROUND(SUM(a.TotalDue / COALESCE(b.EndOfDayRate, 1)), 2) AS [Revenue (USD)],
		LAG(ROUND(SUM(a.TotalDue / COALESCE(b.EndOfDayRate, 1)), 2), 1, 0)
			OVER(PARTITION BY c.[Name] ORDER BY YEAR(a.OrderDate)) AS [Last Year Revenue],
		CASE
			WHEN SUM(a.TotalDue / COALESCE(b.EndOfDayRate, 1)) > (
				SELECT AVG(YearlyTotal)
				FROM (
					SELECT SUM(a1.TotalDue) AS YearlyTotal
					FROM Sales.SalesOrderHeader a1
						JOIN Sales.SalesTerritory c1 ON a1.TerritoryID = c1.TerritoryID
					WHERE YEAR(a1.OrderDate) = YEAR(a.OrderDate)
					GROUP BY c1.[Name]
				) AS TerritoryTotals
			) THEN 'Above Average'
			ELSE 'Below Average'
		END AS Performance
	FROM Sales.SalesOrderHeader a
		LEFT JOIN Sales.CurrencyRate b ON a.CurrencyRateID = b.CurrencyRateID
		JOIN Sales.SalesTerritory c ON a.TerritoryID = c.TerritoryID
	WHERE a.[Status] NOT IN (4, 6)
	GROUP BY c.[Name], YEAR(a.OrderDate)
)
SELECT Territory, [Year], [Revenue (USD)],
	CASE
		WHEN [Last Year Revenue] = 0 THEN 0 ELSE ROUND(100 * [Revenue (USD)] / [Last Year Revenue], 2)
	END AS [Percentage Change],
	Performance
FROM performance
ORDER BY Territory DESC, [Year]