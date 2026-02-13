-- NATIONAL RANKING EVOLUTION: TOP & FLOP PERFORMERS BETWEEN 2014 AND 2024

WITH Yearly_Rankings AS (
    SELECT 
        Year,
        Municipality,
        Province,
        Region,
        Main_Tourism_Category,
        Total_Arrivals,
        RANK() OVER (PARTITION BY Year ORDER BY Total_Arrivals DESC) AS National_Rank
    FROM "Analysis_Tourism_Trends_Italy_2014-2024"
    WHERE Year IN (2014, 2024)
)
SELECT 
	R14.Municipality,
	R14.Province,
	R14.Region,
	/* By subdividing the regions location along the peninsula, we can have a deeper comprehension 
	of how northern, central and southern Italy have performed
	 */
	CASE
	    WHEN R14.Region IN ("Valle D'Aosta", 'Piemonte', 'Lombardia', 'Trento', 'Bolzano-Bozen', 'Veneto', 'Friuli-Venezia Giulia', 'Liguria', 'Emilia-Romagna') THEN 'North'
	    WHEN R14.Region IN ('Toscana', 'Marche', 'Umbria', 'Lazio', 'Abruzzo') THEN 'Center'
	    ELSE 'South & Islands'
	END AS Geographic_Area,
	R14.Main_Tourism_Category,
	R14.National_Rank AS Rank_2014,
	R24.National_Rank AS Rank_2024,
	(R14.National_Rank - R24.National_Rank) AS Positions_Gained
	FROM Yearly_Rankings R14
/* The next part of the query will consider only municipalities existing both in 2014 and 2024, showing their 
ranking in these 2 years side by side. A self join will be used rather than an inner join because the table is 
joined with itself. Since I cannot compare the rank between two different rows of the same table, thanks to 
the self join I'm "cloning" the table, allowing to display the 2014 "clone" and the 2024 "clone" side by side 
and compare them.
 */
	JOIN Yearly_Rankings R24 ON R14.Municipality = R24.Municipality 
	    AND R14.Province = R24.Province
	WHERE R14.Year = 2014 AND R24.Year = 2024
	  AND R14.Total_Arrivals > 5000
	ORDER BY Positions_Gained DESC -- Conversely, ASC allows to display "flop" performers
	--LIMIT 10
	;

-- How many top municipalities per geographical area?
WITH Yearly_Rankings AS (
    SELECT 
        Year,
        Municipality,
        Province,
        Region,
        Main_Tourism_Category,
        Total_Arrivals,
        RANK() OVER (PARTITION BY Year ORDER BY Total_Arrivals DESC) AS National_Rank
    FROM "Analysis_Tourism_Trends_Italy_2014-2024"
    WHERE Year IN (2014, 2024)
),
Rank_Evolution AS (
	SELECT 
	    R14.Municipality,
	    R14.Province,
	    R14.Region,
	    CASE
	        WHEN R14.Region IN ("Valle D'Aosta", 'Piemonte', 'Lombardia', 'Trento', 'Bolzano-Bozen', 'Veneto', 'Friuli-Venezia Giulia', 'Liguria', 'Emilia-Romagna') THEN 'North'
	        WHEN R14.Region IN ('Toscana', 'Marche', 'Umbria', 'Lazio', 'Abruzzo') THEN 'Center'
	        ELSE 'South & Islands'
	    END AS Geographic_Area,
	    R14.Main_Tourism_Category,
	    R14.National_Rank AS Rank_2014,
	    R24.National_Rank AS Rank_2024,
	    (R14.National_Rank - R24.National_Rank) AS Positions_Gained,
	    ROUND(((R24.Total_Arrivals - R14.Total_Arrivals) * 100.0 / R14.Total_Arrivals), 2) AS Growth_Rate_Perc
	FROM Yearly_Rankings R14
	JOIN Yearly_Rankings R24 ON R14.Municipality = R24.Municipality 
	    AND R14.Province = R24.Province
	WHERE R14.Year = 2014 AND R24.Year = 2024
	  AND R14.Total_Arrivals > 5000 
	ORDER BY Positions_Gained DESC -- Conversely, ASC allows to display "flop" performers
	LIMIT 100
)
SELECT 
    Geographic_Area,
    COUNT(*) AS Number_of_Municipalities
FROM Rank_Evolution
GROUP BY Geographic_Area
ORDER BY Number_of_Municipalities DESC;

-- The last rows can be modified as follows to find out municipalities subdivision among northern regions
SELECT 
    Region,
    COUNT(*) AS Number_of_Top_Municipalities
FROM Rank_Evolution
WHERE Geographic_Area = "North"
GROUP BY Region
ORDER BY Number_of_Top_Municipalities DESC;

-- Or to inspect their tourism category
SELECT 
    Main_Tourism_Category,
    COUNT(*) AS Number_of_Municipalities
FROM Rank_Evolution
GROUP BY Main_Tourism_Category
ORDER BY Number_of_Municipalities DESC;