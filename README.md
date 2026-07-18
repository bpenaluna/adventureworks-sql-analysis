<h1>AdventureWorks SQL Analysis</h1>

**How many years did each territory generate more than $1 million in revenue?**

What the query does:
- Groups by territory and year
- Converts revenue to USD
- Filters out cancelled and rejected orders
- Filters to only show values of total revenue exceeding $1M
- Groups the resulting table (revenue_over_mil) by territory only, and counts the number of rows for each territory
- Joins on SalesTerritory table to include territories missing from the revenue_over_mil table (did not generate over $1 million in any given year) 
- Sorts by count descending and territory ascending

Skills:
- Joins (LEFT JOIN, INNER JOIN)
- GROUP BY and Aggregations (SUM)
- Filtering (WHERE, HAVING)
- Null Handling (COALESCE)

**Query**

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

**Result**

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

**Which territories outperform the yearly average total revenue for all territories?**

and

**What is the yearly percentage change in revenue for all territories?**

Skills:
- Subqueries
- CTEs
- Window functions (LAG, PARTION BY)
- Joins
- Conditions (CASE)

**Query**

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
		WHEN [Last Year Revenue] = 0 THEN 0 ELSE ROUND(100 * [Revenue (USD)] / [Last Year Revenue], 2)
	END AS [Percentage Change],
	Performance
FROM performance
ORDER BY Territory DESC, [Year]
```
**Result**

| Territory      | Year | Revenue (USD) | Percentage Change | Performance   |
|----------------|------|---------------|-------------------|---------------|
| United Kingdom | 2022 | 639968.15     | 0.00              | Below Average |
| United Kingdom | 2023 | 2560740.51    | 400.14            | Below Average |
| United Kingdom | 2024 | 5883489.99    | 229.76            | Above Average |
| United Kingdom | 2025 | 3610439.30    | 61.37             | Above Average |
| Southwest      | 2022 | 3710548.63    | 0.00              | Above Average |
| Southwest      | 2023 | 8763318.81    | 236.17            | Above Average |
| Southwest      | 2024 | 10245068.96   | 116.91            | Above Average |
| Southwest      | 2025 | 4431522.23    | 43.26             | Above Average |
| Southeast      | 2022 | 2198996.37    | 0.00              | Above Average |
| Southeast      | 2023 | 2993431.81    | 136.13            | Below Average |
| Southeast      | 2024 | 2705730.97    | 90.39             | Below Average |
| Southeast      | 2025 | 985940.21     | 36.44             | Below Average |
| Northwest      | 2022 | 3162034.70    | 0.00              | Above Average |
| Northwest      | 2023 | 4784722.19    | 151.32            | Above Average |
| Northwest      | 2024 | 6762984.40    | 141.35            | Above Average |
| Northwest      | 2025 | 3351713.47    | 49.56             | Above Average |
| Northeast      | 2022 | 851614.23     | 0.00              | Below Average |
| Northeast      | 2023 | 3126297.77    | 367.10            | Below Average |
| Northeast      | 2024 | 2965567.03    | 94.86             | Below Average |
| Northeast      | 2025 | 876730.61     | 29.56             | Below Average |
| Germany        | 2022 | 141161.15     | 0.00              | Below Average |
| Germany        | 2023 | 607828.18     | 430.59            | Below Average |
| Germany        | 2024 | 2710226.94    | 445.89            | Below Average |
| Germany        | 2025 | 1711010.37    | 63.13             | Below Average |
| France         | 2022 | 66477.29      | 0.00              | Below Average |
| France         | 2023 | 1730519.30    | 2603.17           | Below Average |
| France         | 2024 | 4247876.75    | 245.47            | Below Average |
| France         | 2025 | 1855576.42    | 43.68             | Below Average |
| Central        | 2022 | 1352234.52    | 0.00              | Below Average |
| Central        | 2023 | 3109279.21    | 229.94            | Below Average |
| Central        | 2024 | 3374336.30    | 108.52            | Below Average |
| Central        | 2025 | 1077449.22    | 31.93             | Below Average |
| Canada         | 2022 | 1650335.81    | 0.00              | Above Average |
| Canada         | 2023 | 4188808.66    | 253.82            | Above Average |
| Canada         | 2024 | 4465736.80    | 106.61            | Below Average |
| Canada         | 2025 | 1713762.11    | 38.38             | Below Average |
| Australia      | 2022 | 1049388.69    | 0.00              | Below Average |
| Australia      | 2023 | 1271243.37    | 121.14            | Below Average |
| Australia      | 2024 | 2481580.58    | 195.21            | Below Average |
| Australia      | 2025 | 1687808.77    | 68.01             | Below Average |
