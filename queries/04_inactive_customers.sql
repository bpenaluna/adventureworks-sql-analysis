WITH DaysSinceOrdered AS (
	SELECT
		c.CustomerID,
		DATEDIFF(
			day,
			MAX(OrderDate),
			(SELECT MAX(OrderDate) FROM Sales.SalesOrderHeader)
		) AS DaysSince
	FROM Sales.Customer c
		LEFT JOIN Sales.SalesOrderHeader s ON (c.CustomerID = s.CustomerID)
	GROUP BY c.CustomerID
),
Grouped AS (
	SELECT
		CustomerID,
		CASE
		    WHEN DaysSince IS NULL THEN 'Never Ordered'
			WHEN DaysSince BETWEEN 0 AND 30 THEN '0 - 30 Days'
			WHEN DaysSince BETWEEN 31 AND 90 THEN '31 - 90 Days'
			WHEN DaysSince BETWEEN 91 AND 365 THEN '91 - 365 Days'
			ELSE '> 365 Days'
		END AS DaysSinceLastOrder
	FROM DaysSinceOrdered
)
SELECT
	DaysSinceLastOrder,
	COUNT(CustomerID) AS NumberOfCustomers,
	100.0 * COUNT(CustomerID) / (SELECT COUNT(DISTINCT CustomerID) FROM Sales.Customer) AS 'Percentage (%)'
FROM Grouped
GROUP BY DaysSinceLastOrder
ORDER BY NumberOfCustomers DESC