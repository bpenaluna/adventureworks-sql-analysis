<h1>AdventureWorks SQL Analysis</h1>

**Which sales territories generated more than $1 million in revenue in a given year, and how do they rank against each other?**

What the query does:
- Groups by territory and year
- Converts revenue to USD
- Filters out cancelled and rejected orders
- Filters to only show values of total revenue exceeding $1M
- Sorts by revenue descending

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
