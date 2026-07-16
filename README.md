<h1>AdventureWorks SQL Analysis</h1>

**Which sales territories generated more than $1 million in revenue in a given year, and how do they rank against each other?**

What the query does:
- Groups by territory and year
- Converts revenue to USD
- Filters out cancelled and rejected orders
- Filters to only show values of total revenue exceeding $1M
- Sorts by revenue descending

Skills:
- Joins (LEFT JOIN, INNER JOIN)
- GROUP BY and Aggregations (SUM)
- Filtering (WHERE, HAVING)
- Null Handling (COALESCE)

**Query**

```sql
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
```

**Result**

| Territory      | Year | Total Revenue in USD (Millions) |
|----------------|------|---------------------------------|
| Southwest      | 2024 | 10.25                           |
| Southwest      | 2023 | 8.76                            |
| Northwest      | 2024 | 6.76                            |
| United Kingdom | 2024 | 5.88                            |
| Northwest      | 2023 | 4.78                            |
| Canada         | 2024 | 4.47                            |
| Southwest      | 2025 | 4.43                            |
| France         | 2024 | 4.25                            |
| Canada         | 2023 | 4.19                            |
| Southwest      | 2022 | 3.71                            |
| United Kingdom | 2025 | 3.61                            |
| Central        | 2024 | 3.37                            |
| Northwest      | 2025 | 3.35                            |
| Northwest      | 2022 | 3.16                            |
| Northeast      | 2023 | 3.13                            |
| Central        | 2023 | 3.11                            |
| Southeast      | 2023 | 2.99                            |
| Northeast      | 2024 | 2.97                            |
| Germany        | 2024 | 2.71                            |
| Southeast      | 2024 | 2.71                            |
| United Kingdom | 2023 | 2.56                            |
| Australia      | 2024 | 2.48                            |
| Southeast      | 2022 | 2.20                            |
| France         | 2025 | 1.86                            |
| France         | 2023 | 1.73                            |
| Canada         | 2025 | 1.71                            |
| Germany        | 2025 | 1.71                            |
| Australia      | 2025 | 1.69                            |
| Canada         | 2022 | 1.65                            |
| Central        | 2022 | 1.35                            |
| Australia      | 2023 | 1.27                            |
| Central        | 2025 | 1.08                            |
| Australia      | 2022 | 1.05                            |

**Which territories outperform the yearly average total revenue for all territories**

Skills:
- Subqueries
- Joins
- Conditions (CASE)

**Query**

```sql
SELECT
	c.[Name] AS Territory,
	YEAR(a.OrderDate) AS [Year],
	ROUND(SUM(a.TotalDue / COALESCE(b.EndOfDayRate, 1)) / 1000000, 2) AS [Total Revenue in USD (Millions)],
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
ORDER BY [Year], [Total Revenue in USD (Millions)] DESC
```
**Result**

| Territory      | Year | Total Revenue in USD (Millions) | Performance   |
|----------------|------|---------------------------------|---------------|
| Southwest      | 2022 | 3.71                            | Above Average |
| Northwest      | 2022 | 3.16                            | Above Average |
| Southeast      | 2022 | 2.20                            | Above Average |
| Canada         | 2022 | 1.65                            | Above Average |
| Central        | 2022 | 1.35                            | Below Average |
| Australia      | 2022 | 1.05                            | Below Average |
| Northeast      | 2022 | 0.85                            | Below Average |
| United Kingdom | 2022 | 0.64                            | Below Average |
| Germany        | 2022 | 0.14                            | Below Average |
| France         | 2022 | 0.07                            | Below Average |
| Southwest      | 2023 | 8.76                            | Above Average |
| Northwest      | 2023 | 4.78                            | Above Average |
| Canada         | 2023 | 4.19                            | Above Average |
| Northeast      | 2023 | 3.13                            | Below Average |
| Central        | 2023 | 3.11                            | Below Average |
| Southeast      | 2023 | 2.99                            | Below Average |
| United Kingdom | 2023 | 2.56                            | Below Average |
| France         | 2023 | 1.73                            | Below Average |
| Australia      | 2023 | 1.27                            | Below Average |
| Germany        | 2023 | 0.61                            | Below Average |
| Southwest      | 2024 | 10.25                           | Above Average |
| Northwest      | 2024 | 6.76                            | Above Average |
| United Kingdom | 2024 | 5.88                            | Above Average |
| Canada         | 2024 | 4.47                            | Below Average |
| France         | 2024 | 4.25                            | Below Average |
| Central        | 2024 | 3.37                            | Below Average |
| Northeast      | 2024 | 2.97                            | Below Average |
| Germany        | 2024 | 2.71                            | Below Average |
| Southeast      | 2024 | 2.71                            | Below Average |
| Australia      | 2024 | 2.48                            | Below Average |
| Southwest      | 2025 | 4.43                            | Above Average |
| United Kingdom | 2025 | 3.61                            | Above Average |
| Northwest      | 2025 | 3.35                            | Above Average |
| France         | 2025 | 1.86                            | Below Average |
| Canada         | 2025 | 1.71                            | Below Average |
| Germany        | 2025 | 1.71                            | Below Average |
| Australia      | 2025 | 1.69                            | Below Average |
| Central        | 2025 | 1.08                            | Below Average |
| Southeast      | 2025 | 0.99                            | Below Average |
| Northeast      | 2025 | 0.88                            | Below Average |
