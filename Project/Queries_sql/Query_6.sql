-- CONCENTRATION ANALYSIS

/* What's the capital city "weight" on the region's performance?
Since there's no "capital city" column in the database, I need to manually filter for these municipalities:
*/
WITH Regional_Totals AS (
    SELECT 
        Region, 
        SUM(Total_Arrivals) AS Regional_Arrivals
    FROM "Analysis_Tourism_Trends_Italy_2014-2024"
    WHERE Year = 2024
    GROUP BY Region
),
Capital_City_Data AS (
    SELECT 
        Region, 
        Municipality AS Capital_City, 
        Total_Arrivals AS Capital_City_Arrivals
    FROM "Analysis_Tourism_Trends_Italy_2014-2024"
    WHERE Year = 2024 AND Municipality IN ("Aosta", "Torino", "Milano", "Genova", "Trento", "Bolzano/Bozen",
    "Venezia", "Trieste", "Bologna", "Firenze", "Perugia", "Ancona", "Roma", "L'Aquila", "Campobasso", "Napoli",
    "Bari", "Catanzaro", "Potenza", "Cagliari", "Palermo")
)
SELECT 
    C.Region,
    C.Capital_City,
    C.Capital_City_Arrivals,
    R.Regional_Arrivals,
    ROUND((C.Capital_City_Arrivals * 100.0 / R.Regional_Arrivals), 2) AS Capital_Weight_Perc
FROM Capital_City_Data C
/* The self join merges the "clone" Regional_Totals table with the "clone" Capital_City_Data table,
using the Region column as bridge
*/
JOIN Regional_Totals R ON C.Region = R.Region
ORDER BY Capital_Weight_Perc DESC;

-- Where does the 50% of regional tourism flow and which category does it belong to?
WITH Regional_Ranking AS (
    SELECT 
        Region,
        Municipality,        
        Main_Tourism_Category,
        Total_Arrivals,
        SUM(Total_Arrivals) OVER(PARTITION BY Region ORDER BY Total_Arrivals DESC) AS Cumulative_Arrivals,
        SUM(Total_Arrivals) OVER(PARTITION BY Region) AS Total_Region_Arrivals
    FROM "Analysis_Tourism_Trends_Italy_2014-2024"
    WHERE Year = 2024
),
Concentration_Logic AS (
    SELECT 
        Region,
        Municipality,
        Main_Tourism_Category,
        Total_Arrivals,
        ROUND((Cumulative_Arrivals * 100.0 / Total_Region_Arrivals), 2) AS Cumulative_Perc
    FROM Regional_Ranking
)
SELECT * FROM Concentration_Logic
WHERE Cumulative_Perc <=50
ORDER BY Region, Total_Arrivals DESC;

/* The query returns the list of all Italian regions in alphabetical order, displaying for each of them
the list of municipalities which, combined, represent half of the regional arrivals. Pay attention
at values in Cumulative_Perc column. They don't indicate the weight of the corresponding
municipality, they rather represent the weight sum of the current municipality plus the previous ones.
The aim is to stop the query once the sum reaches 50, in order to display the list of municipalities which
account for half of the regional tourism flow. For example, look at the first 2 rows of the output table: 
Montesilvano -> 8.48%, Pescara -> 15.95%. This doesn't mean that Pescara hosts 15.95% of the tourists
coming in Abruzzo: its weight is 15.95% - 8.48% = 7.47%. This has been reached in the CTE
Regional_Ranking; note that the first SUM OVER() contains an ORDER BY, so the sum will start from the
municipality with the highest volume of arrivals, while the second SUM OVER() doesn't contain the ORDER BY
because all of the region's municipalities need to be taken in considerations. As expected from how
the query has been coded, Lazio will be the only region not present in the output, since Roma alone attracts 
almost 80% of tourists visiting the region.
*/

/* Modifying the last rows allows to display regions from the one in which tourism is spreaded the most among its 
territory to the one where a single hub attracts the majority of arrivals.
*/
SELECT 
	Region, 
	COUNT(*) AS "Number_of_Municipalities_50%" 
FROM Concentration_Logic
WHERE Cumulative_Perc <=50
GROUP BY Region
ORDER BY "Number_of_Municipalities_50%" DESC;

-- Which tourism category do municipalities which count for 50% of regional tourism belong to?
SELECT 
    Region, 
    Main_Tourism_Category,
    COUNT(Municipality) AS Number_of_Municipalities
FROM Concentration_Logic
WHERE Cumulative_Perc <=50
GROUP BY Region, Main_Tourism_Category
ORDER BY
	SUM(COUNT(Municipality)) OVER(PARTITION BY Region) DESC;