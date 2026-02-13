CREATE VIEW Market_Segmentation AS

-- Main_Tourism_Category
SELECT 
    Year,
    'Category' AS Dimension_Type,
    Main_Tourism_Category AS Segment_Name,
    SUM(Total_Arrivals) AS Arrivals,
    SUM(Total_Nights) AS Nights
FROM "Analysis_Tourism_Trends_Italy_2014-2024"
WHERE Main_Tourism_Category IS NOT NULL 
  AND Year IN (2014, 2019, 2024)
GROUP BY Year, Main_Tourism_Category

UNION ALL

-- Tourism_Brand
SELECT 
    Year,
    'Brand' AS Dimension_Type,
    Tourism_Brand AS Segment_Name,
    SUM(Total_Arrivals) AS Arrivals,
    SUM(Total_Nights) AS Nights
FROM "Analysis_Tourism_Trends_Italy_2014-2024"
WHERE Tourism_Brand IS NOT NULL 
  AND Year IN (2014, 2019, 2024)
GROUP BY Year, Tourism_Brand;

/* Note that I didn't calculate Market_Share_Perc, in order to have it updated if I apply filters on the
 Tableau dashboard. UNION ALL allows to have categories and brands all displayed in the same column, 
 labeled as Dimension_Type.
*/