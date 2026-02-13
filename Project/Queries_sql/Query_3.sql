-- ANALYSIS OF EFFICIENCY (LENGTH OF STAY PER ARRIVAL & HOTEL SECTOR PERFORMANCE)

SELECT 
    Main_Tourism_Category,
    SUM(Total_Arrivals) AS Total_Arrivals,
    SUM(Total_Nights) AS Total_Nights,
    ROUND(CAST(SUM(Total_Nights) AS FLOAT) / SUM(Total_Arrivals), 2) AS Avg_Length_of_Stay,
    ROUND(SUM(Hotel_Nights) * 100.0 / SUM(Total_Nights), 2) AS Hotel_Nights_Share_Perc
FROM "Analysis_Tourism_Trends_Italy_2014-2024"
WHERE Year = 2024
GROUP BY Main_Tourism_Category
ORDER BY Avg_Length_of_Stay DESC;
