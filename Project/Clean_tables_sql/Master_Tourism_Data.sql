CREATE TABLE "Master_Tourism_Data" AS
SELECT * FROM "2014"
UNION ALL
SELECT * FROM "2015"
UNION ALL
SELECT * FROM "2016"
UNION ALL
SELECT * FROM "2017"
UNION ALL
SELECT * FROM "2018"
UNION ALL
SELECT * FROM "2019"
UNION ALL
SELECT * FROM "2020"
UNION ALL
SELECT * FROM "2021"
UNION ALL
SELECT * FROM "2022"
UNION ALL
SELECT * FROM "2023"
UNION ALL
SELECT * FROM "2024";

-- Check if the number of rows in Master_Tourism_Data is equal to the sum of the single tables

SELECT 
    (SELECT COUNT(*) FROM "2014") +
    (SELECT COUNT(*) FROM "2015") +
    (SELECT COUNT(*) FROM "2016") +
    (SELECT COUNT(*) FROM "2017") +
    (SELECT COUNT(*) FROM "2018") +
    (SELECT COUNT(*) FROM "2019") +
    (SELECT COUNT(*) FROM "2020") +
    (SELECT COUNT(*) FROM "2021") +
    (SELECT COUNT(*) FROM "2022") +
    (SELECT COUNT(*) FROM "2023") +
    (SELECT COUNT(*) FROM "2024") AS Sum_of_tables,
    
    (SELECT COUNT(*) FROM "Master_Tourism_Data") AS Total_rows;

/*The result is 39441 for both the operations, which means that UNION ALL has been correctly executed. 
On the other side, I noticed a discrepancy of 30 records with respect to the Power Query output on Excel:
the worksheet Master_Tourism_Data has 39411 rows. 
Let's then try to look for duplicate rows with the following query:
*/

SELECT Municipality, Province, Year, COUNT(*)
FROM "Master_Tourism_Data"
GROUP BY Municipality, Province, Year
HAVING COUNT(*) > 1;

/* When I launch the query, I get no outputs. As a consequence, I can deduct that SQL’s granular processing 
preserved records that were implicitly filtered or deduplicated by Power Query's automated cleaning steps. 
By maintaining these records on SQL, I can ensure total fidelity to the ISTAT source, allowing for a more transparent dataset.
*/
