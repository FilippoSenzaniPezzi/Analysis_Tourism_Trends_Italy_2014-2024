CREATE VIEW Hospitality_Performance AS
SELECT 
    Year,
   	Region,
   	Province,
   	Municipality,
    Main_Tourism_Category,
    Tourism_Brand,
    Total_Arrivals,
    Total_Nights,
    Hotel_Arrivals,
    Hotel_Nights,
    (Total_Arrivals - Hotel_Arrivals) AS Extra_Hotel_Arrivals,
    (Total_Nights - Hotel_Nights) AS Extra_Hotel_Nights
FROM "Analysis_Tourism_Trends_Italy_2014-2024"
WHERE Year IN (2014, 2019, 2024);

/* Leaving the data of single municipalities, rather then grouping them for categories, allows Tableau
to perform the aggregation. In this way, I'll be able to calculate for example the average length of
stay not only by category, but also by single municipality.
*/