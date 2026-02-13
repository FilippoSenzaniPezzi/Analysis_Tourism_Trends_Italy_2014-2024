-- HOTEL VS EXTRA-HOTEL ACCOMMODATION CHOICE OVER TIME

-- Arrivals
SELECT 
    Year,
    SUM(Hotel_Arrivals) AS Total_Hotel_Arrivals,
    -- Calculating extra-hotel arrivals by subtraction from the total arrivals
    SUM(Total_Arrivals - Hotel_Arrivals) AS Total_Extra_Hotel_Arrivals,
    -- Calculate the percentage share of each sector
    ROUND(SUM(Hotel_Arrivals) * 100.0 / SUM(Total_Arrivals), 2) AS Hotel_Market_Share_Perc,
    ROUND(SUM(Total_Arrivals - Hotel_Arrivals) * 100.0 / SUM(Total_Arrivals), 2) AS Extra_Hotel_Market_Share_Perc
FROM "Analysis_Tourism_Trends_Italy_2014-2024"
GROUP BY Year
ORDER BY Year;

-- Nights spent
SELECT 
    Year,
    SUM(Hotel_Nights) AS Total_Hotel_Nights,
    -- Calculating extra-hotel nights by subtraction from the total nights
    SUM(Total_Nights - Hotel_Nights) AS Total_Extra_Hotel_Nights,
    -- Calculate the percentage share of each sector
    ROUND(SUM(Hotel_Nights) * 100.0 / SUM(Total_Nights), 2) AS Hotel_Nights_Share_Perc,
    ROUND(SUM(Total_Nights - Hotel_Nights) * 100.0 / SUM(Total_Nights), 2) AS Extra_Hotel_Nights_Share_Perc
FROM "Analysis_Tourism_Trends_Italy_2014-2024"
GROUP BY Year
ORDER BY Year;