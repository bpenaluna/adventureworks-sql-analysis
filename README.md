# AdventureWorks SQL Analysis

## Queries

### How many years did each territory generate more than $1 million in revenue?

**Skills:**
- Joins (LEFT JOIN, INNER JOIN)
- GROUP BY and Aggregations (SUM)
- Filtering (WHERE, HAVING)
- Null Handling (COALESCE)

**Query:**

```sql
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
```

**Result:**

| Territory      | Count |
|----------------|-------|
| Australia      | 4     |
| Canada         | 4     |
| Central        | 4     |
| Northwest      | 4     |
| Southwest      | 4     |
| France         | 3     |
| Southeast      | 3     |
| United Kingdom | 3     |
| Germany        | 2     |
| Northeast      | 2     |

**Key Takeaways:**
- All of the territories generated a total yearly income of at least $1 million at least twice
- Australia, Canada, Central, Northwest and Southwest achieved this the most (4 times)
- Germany and Northeast achieved it the least (2 times)

### Which territories outperform the yearly average total revenue for all territories? What is the yearly percentage change in revenue for all territories?

**Skills:**
- Subqueries
- CTEs
- Window functions (LAG, PARTION BY)
- Joins
- Conditions (CASE)

**Query:**

```sql
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
		WHEN [Last Year Revenue] = 0 THEN 0 ELSE ROUND(100 * ([Revenue (USD)] - [Last Year Revenue]) / [Last Year Revenue], 2)
	END AS [Percentage Change],
	Performance
FROM performance
ORDER BY Territory DESC, [Year]
```
**Result:**

| Territory      | Year | Revenue (USD) | Percentage Change | Performance   |
|----------------|------|---------------|-------------------|---------------|
| United Kingdom | 2022 | 639968.15     | 0.00              | Below Average |
| United Kingdom | 2023 | 2560740.51    | 300.14            | Below Average |
| United Kingdom | 2024 | 5883489.99    | 129.76            | Above Average |
| United Kingdom | 2025 | 3610439.30    | -38.63            | Above Average |
| Southwest      | 2022 | 3710548.63    | 0.00              | Above Average |
| Southwest      | 2023 | 8763318.81    | 136.17            | Above Average |
| Southwest      | 2024 | 10245068.96   | 16.91             | Above Average |
| Southwest      | 2025 | 4431522.23    | -56.74            | Above Average |
| Southeast      | 2022 | 2198996.37    | 0.00              | Above Average |
| Southeast      | 2023 | 2993431.81    | 36.13             | Below Average |
| Southeast      | 2024 | 2705730.97    | -9.61             | Below Average |
| Southeast      | 2025 | 985940.21     | -63.56            | Below Average |
| Northwest      | 2022 | 3162034.70    | 0.00              | Above Average |
| Northwest      | 2023 | 4784722.19    | 51.32             | Above Average |
| Northwest      | 2024 | 6762984.40    | 41.35             | Above Average |
| Northwest      | 2025 | 3351713.47    | -50.44            | Above Average |
| Northeast      | 2022 | 851614.23     | 0.00              | Below Average |
| Northeast      | 2023 | 3126297.77    | 267.10            | Below Average |
| Northeast      | 2024 | 2965567.03    | -5.14             | Below Average |
| Northeast      | 2025 | 876730.61     | -70.44            | Below Average |
| Germany        | 2022 | 141161.15     | 0.00              | Below Average |
| Germany        | 2023 | 607828.18     | 330.59            | Below Average |
| Germany        | 2024 | 2710226.94    | 345.89            | Below Average |
| Germany        | 2025 | 1711010.37    | -36.87            | Below Average |
| France         | 2022 | 66477.29      | 0.00              | Below Average |
| France         | 2023 | 1730519.30    | 2503.17           | Below Average |
| France         | 2024 | 4247876.75    | 145.47            | Below Average |
| France         | 2025 | 1855576.42    | -56.32            | Below Average |
| Central        | 2022 | 1352234.52    | 0.00              | Below Average |
| Central        | 2023 | 3109279.21    | 129.94            | Below Average |
| Central        | 2024 | 3374336.30    | 8.52              | Below Average |
| Central        | 2025 | 1077449.22    | -68.07            | Below Average |
| Canada         | 2022 | 1650335.81    | 0.00              | Above Average |
| Canada         | 2023 | 4188808.66    | 153.82            | Above Average |
| Canada         | 2024 | 4465736.80    | 6.61              | Below Average |
| Canada         | 2025 | 1713762.11    | -61.62            | Below Average |
| Australia      | 2022 | 1049388.69    | 0.00              | Below Average |
| Australia      | 2023 | 1271243.37    | 21.14             | Below Average |
| Australia      | 2024 | 2481580.58    | 95.21             | Below Average |
| Australia      | 2025 | 1687808.77    | -31.99            | Below Average |

**Key takeaways:**
- Canada has falled below the yearly average for the last two years despite being above average for the two years before with a big dropoff it yearly revenue from 2024-25 (-61.62%)
- All territories experienced a fall in revenue from 2024-25 with the biggest being Northeast (-70.44%) and the smallest being Australia (-31.99%)
- Northwest and Southwest were above average in terms of total yearly revenue for every year between 2022-25
- Northeast, Germany, France and Australia were below average in terms of total yearly revenue for every year between 2022-25
- The single biggest yearly percentage change in revenue was in France from 2022-23 (2503.17%)

### What is the distribution of the customers' last orders?

**Skills:**
- Multiple CTEs
- Joins
- Null handling
- Conditions (CASE)

**Query:**

```sql
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
```

**Result:**

| DaysSinceLastOrder | NumberOfCustomers | Percentage (%)  |
|--------------------|-------------------|-----------------|
| 91 - 365 Days      | 12992             | 65.549949545913 |
| 31 - 90 Days       | 4180              | 21.089808274470 |
| > 365 Days         | 1016              | 5.126135216952  |
| 0 - 30 Days        | 931               | 4.697275479313  |
| Never Ordered      | 701               | 3.536831483350  |

**Key Takeaways:**
- The majority of customers (65.5%) last ordered between 91 and 365 days.
- 3.54% of registered customers have never ordered.
