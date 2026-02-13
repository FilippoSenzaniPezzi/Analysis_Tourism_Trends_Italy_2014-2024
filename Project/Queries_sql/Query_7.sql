-- RFD MODEL TO IDENTIFY HIDDEN JEMS

WITH RFD_Base AS ( -- This CTE extracts R, F and D for each municipality
    SELECT 
        Region,
        Province,
        Municipality,
        Main_Tourism_Category,
        /* Recency: arrivals in 2024. The use of MAX at the beginning of the following rows is due to the
        fact that, later in the code, I will group by municipality. At that time, SQL will have to choose 
        only one of the two values returned by CASE WHEN. Since one of the two values will always be 0, 
        I'm telling SQL to consider the MAX.
        */
        MAX(CASE WHEN Year = 2024 THEN Total_Arrivals ELSE 0 END) AS Recency_Value,
        /* Frequency: growth index over the decade. Looking at the fraction, multiplying the numerator by 1.0 
        forces SQL to convert that number into a float before executing the division. It's an implicit type casting, 
        faster to read and write rather than CAST(Total_Nights AS FLOAT). In this way, the output will have decimal
        numbers. As far as the denominator is concerned, the use of NULLIF prevents the query to return a 
        "Division by zero" error if a municipality had 0 tourists in 2014.
         */
        ROUND(MAX(CASE WHEN Year = 2024 THEN Total_Arrivals ELSE 0 END) * 1.0 / 
              NULLIF(MAX(CASE WHEN Year = 2014 THEN Total_Arrivals ELSE 0 END), 0), 2) AS Frequency_Index,
        -- Duration: average length of stay in 2024
        ROUND(MAX(CASE WHEN Year = 2024 THEN Total_Nights ELSE 0 END) * 1.0 / 
              NULLIF(MAX(CASE WHEN Year = 2024 THEN Total_Arrivals ELSE 0 END), 0), 2) AS Duration_Value
    FROM "Analysis_Tourism_Trends_Italy_2014-2024"
    GROUP BY Region, Province, Municipality, Main_Tourism_Category
),
Scoring AS ( -- This CTE assigns them scores from 1 to 5 using quintiles
    SELECT *,
        NTILE(5) OVER(ORDER BY Recency_Value) AS R_Score,
        NTILE(5) OVER(ORDER BY Frequency_Index) AS F_Score,
        NTILE(5) OVER(ORDER BY Duration_Value) AS D_Score
    FROM RFD_Base
    WHERE Recency_Value > 5000 -- Filter to avoid statistical noise caused by small municipalities
),
Segmentation AS (/* This CTE calculates the total score for each municipality and subdivides them
into categories based on score intervals. 
*/
	SELECT *,
	(R_Score + F_Score + D_Score) AS Total_RFD_Score,
	CASE 
        WHEN (R_Score + F_Score + D_Score) >= 13 THEN 'Top Destination'
        WHEN (R_Score + F_Score + D_Score) BETWEEN 9 AND 12 THEN 'High Potential'
        WHEN D_Score = 5 THEN 'Long-Stay Niche'
        ELSE 'Standard Market'
    END AS Segment
	FROM Scoring
)
SELECT
    Region, Province, Municipality, Main_Tourism_Category,
    Recency_Value, Frequency_Index, Duration_Value, Total_RFD_Score, Segment
FROM Segmentation
ORDER BY Total_RFD_Score DESC, Duration_Value DESC;

-- What's the top destinations tourism categories? Change the last rows as follows:
SELECT 
    Main_Tourism_Category,
    COUNT(*) AS Number_of_Top_Destinations
FROM Segmentation
WHERE Segment = "Top Destination"
GROUP BY Main_Tourism_Category
ORDER BY Number_of_Top_Destinations DESC;

-- In which regions are located the 167 top destinations?
SELECT 
    Region,
    COUNT(*) AS Number_of_Top_Destinations
FROM Segmentation
WHERE Segment = "Top Destination"
GROUP BY Region
ORDER BY Number_of_Top_Destinations DESC;

-- In which regions are located the 63 municipalities able to score 14?
SELECT 
    Region,
    COUNT(*) AS Number_of_Top_Destinations
FROM Segmentation
WHERE (R_Score + F_Score + D_Score) = 14
GROUP BY Region
ORDER BY Number_of_Top_Destinations DESC;


-- Querying municipalities with a stagnating market:
SELECT
    Region, Province, Municipality, Main_Tourism_Category,
    Frequency_Index, Segment
FROM Segmentation
WHERE R_Score = 5 AND D_Score = 5 AND F_Score <= 2
ORDER BY Frequency_Index DESC;
