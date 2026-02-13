CREATE VIEW RFD_Model AS
WITH RFD_Base AS ( 
    SELECT 
        Region,
        Province,
        Municipality,
        Main_Tourism_Category,
        Tourism_Brand,
        CASE
            WHEN Region IN ("Valle D'Aosta", 'Piemonte', 'Lombardia', 'Trento', 'Bolzano-Bozen', 'Veneto', 'Friuli-Venezia Giulia', 'Liguria', 'Emilia-Romagna') THEN 'North'
	 		WHEN Region IN ('Toscana', 'Marche', 'Umbria', 'Lazio', 'Abruzzo') THEN 'Center'
	   		ELSE 'South & Islands'
        END AS Geographic_Area,
        MAX(CASE WHEN Year = 2024 THEN Total_Arrivals ELSE 0 END) AS Recency_Value,
        ROUND(MAX(CASE WHEN Year = 2024 THEN Total_Arrivals ELSE 0 END) * 1.0 / 
              NULLIF(MAX(CASE WHEN Year = 2014 THEN Total_Arrivals ELSE 0 END), 0), 2) AS Frequency_Index,
        ROUND(MAX(CASE WHEN Year = 2024 THEN Total_Nights ELSE 0 END) * 1.0 / 
              NULLIF(MAX(CASE WHEN Year = 2024 THEN Total_Arrivals ELSE 0 END), 0), 2) AS Duration_Value
    FROM "Analysis_Tourism_Trends_Italy_2014-2024"
    GROUP BY Region, Province, Municipality, Main_Tourism_Category, Tourism_Brand
),
Scoring AS ( 
    SELECT *,
        NTILE(5) OVER(ORDER BY Recency_Value) AS R_Score,
        NTILE(5) OVER(ORDER BY Frequency_Index) AS F_Score,
        NTILE(5) OVER(ORDER BY Duration_Value) AS D_Score
    FROM RFD_Base
    WHERE Recency_Value > 5000 
),
Segmentation AS (
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
    Geographic_Area, Region, Province, Municipality, 
    Main_Tourism_Category, Tourism_Brand,
    Recency_Value, Frequency_Index, Duration_Value, 
    R_Score, F_Score, D_Score,
    Total_RFD_Score, Segment
FROM Segmentation;