-- ARRIVALS AND LENGTH OF STAY: YEARLY TREND AND COVID-19 IMPACT

-- Thanks to the window function LAG, I can perform a year-over-year analysis of national tourism flows.

SELECT 
    Year,
    SUM(Total_Arrivals) AS National_Arrivals,
    SUM(Total_Nights) AS National_Nights_Spent,
    -- Calculate YoY percentage change for arrivals
    ROUND(
        ((SUM(Total_Arrivals) - LAG(SUM(Total_Arrivals)) OVER (ORDER BY Year)) * 100.0 / 
        LAG(SUM(Total_Arrivals)) OVER (ORDER BY Year)), 2) AS Arrivals_YoY_Perc,
    -- Calculate the average length of stay
    ROUND(CAST(SUM(Total_Nights) AS FLOAT) / SUM(Total_Arrivals), 2) AS Avg_Length_of_Stay
FROM "Analysis_Tourism_Trends_Italy_2014-2024"
GROUP BY Year
ORDER BY Year;


