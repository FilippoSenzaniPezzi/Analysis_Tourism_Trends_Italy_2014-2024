-- BRAND MARKET SHARE EVOLUTION

-- Tourism Category
WITH Tourism_Category_Totals AS (
    SELECT 
        Year,
        Main_Tourism_Category,
        SUM(Total_Arrivals) AS Tourism_Category_Total_Arrivals
    FROM "Analysis_Tourism_Trends_Italy_2014-2024"
    WHERE Main_Tourism_Category IS NOT NULL
    GROUP BY Year, Main_Tourism_Category
),
Yearly_Totals AS (
    SELECT 
        Year,
        SUM(Total_Arrivals) AS Total_National_Arrivals
    FROM "Analysis_Tourism_Trends_Italy_2014-2024"
    GROUP BY Year
)
SELECT 
    B.Year,
    B.Main_Tourism_Category,
    B.Tourism_Category_Total_Arrivals,
    ROUND((B.Tourism_Category_Total_Arrivals * 100.0 / Y.Total_National_Arrivals), 2) AS Market_Share_Perc
FROM Tourism_Category_Totals B
JOIN Yearly_Totals Y ON B.Year = Y.Year
WHERE B.Year IN (2014, 2019, 2024)
ORDER BY B.Main_Tourism_Category, B.Year;

-- Tourism Brand
WITH Brand_Totals AS (
    SELECT 
        Year,
        Tourism_Brand,
        SUM(Total_Arrivals) AS Brand_Total_Arrivals
    FROM "Analysis_Tourism_Trends_Italy_2014-2024"
    WHERE Tourism_Brand IS NOT NULL
    GROUP BY Year, Tourism_Brand
),
Yearly_Totals AS (
    SELECT 
        Year,
        SUM(Total_Arrivals) AS Total_National_Arrivals
    FROM "Analysis_Tourism_Trends_Italy_2014-2024"
    GROUP BY Year
)
SELECT 
    B.Year,
    B.Tourism_Brand,
    B.Brand_Total_Arrivals,
    ROUND((B.Brand_Total_Arrivals * 100.0 / Y.Total_National_Arrivals), 2) AS Market_Share_Perc
FROM Brand_Totals B
JOIN Yearly_Totals Y ON B.Year = Y.Year
WHERE B.Year IN (2014, 2019, 2024)
ORDER BY B.Tourism_Brand, B.Year;