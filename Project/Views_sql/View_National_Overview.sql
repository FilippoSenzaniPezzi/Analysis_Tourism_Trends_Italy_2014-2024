CREATE VIEW National_Overview AS
SELECT 
    Year,
    SUM(Total_Arrivals) AS National_Arrivals,
    SUM(Total_Nights) AS National_Nights_Spent,
    ROUND(CAST(SUM(Total_Nights) AS FLOAT) / SUM(Total_Arrivals), 2) AS Avg_Length_of_Stay
FROM "Analysis_Tourism_Trends_Italy_2014-2024"
GROUP BY Year;

/* Note that YoY using LAG function is not calculated, because Tableau performs it better.