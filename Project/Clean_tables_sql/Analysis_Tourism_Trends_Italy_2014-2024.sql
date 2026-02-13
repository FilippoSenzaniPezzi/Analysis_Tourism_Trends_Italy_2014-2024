/* After creating also the dimension table Dim_Municipality_Classification, it can
now be joined to Master_Tourism_Data with a LEFT JOIN on the ISTAT_code column. Beside
the columns Main_Tourism_Category and Tourist_Brand, I want also Province and
Municipality to be taken from Dim_Municipality_Classification rather than
Master_Tourism_Data, in order to use the most recent names for provinces and
municipalities. In this way, I'm going to obtain only one row per municipality
and per province, and not one for each time it changed name.
*/
CREATE TABLE "Analysis_Tourism_Trends_Italy_2014-2024" AS
SELECT 
    T.Region,
    D.Province,
    D.Municipality,
    T.ISTAT_code,
    T.Total_Arrivals,
    T.Hotel_Arrivals,
    T.Total_Nights,
    T.Hotel_Nights,
    T.Year,
    D.Main_Tourism_Category,
    D.Tourism_Brand
FROM Master_Tourism_Data T
LEFT JOIN Dim_Municipality_Classification D 
    ON T.ISTAT_code = D.ISTAT_code;

-- In order to double-check, the following query allows to see if the table starts with NULL values:

SELECT *
FROM "Analysis_Tourism_Trends_Italy_2014-2024" 
ORDER BY Municipality ASC;

/* This query returns the first 3947 rows with NULL values in the columns Province,
Municipality, Main_Tourism_Category and Tourism_Brand. This means that LEFT JOIN
didn't find a match between ISTAT_code columns for a lot of records. I then went
back to check the table Master_Tourism_Data, and I noticed a 5-digit ISTAT code for
all the records in 2017, instead of a 6-digit one as it should be. In order to be
more precise, I want to count the total number of 5-digit and 6-digit ISTAT codes
among these 3947. I'm expecting to get just a few 6-digit codes, which should be
those administrative entities which changed name during time, and a lot of 5-digit
codes, corresponding to the records in 2017, so I run the following query
 */
SELECT
  SUM(CASE WHEN LENGTH(ISTAT_code) = 5 THEN 1 ELSE 0 END) AS "5_digits",
  SUM(CASE WHEN LENGTH(ISTAT_code) = 6 THEN 1 ELSE 0 END) AS "6_digits"
FROM (
  SELECT DISTINCT ISTAT_code
  FROM Master_Tourism_Data
  WHERE ISTAT_code NOT IN (
    SELECT ISTAT_code
    FROM Dim_Municipality_Classification
  )
);

/* The result is something unexpected: the count of 5-digit codes is 0, against 3590
6-digit codes, even if I can clearly see 5-digit codes on the Master_Tourism_Data table.
This can lead to 2 options: option 1, the data types of ISTAT_code columns in Master_Tourism_Data
and Dim_Municipality_Classification are different. I discard this option, because I know both
of them are TEXT. So the only other possible explanation is the presence of a space after the
5-digit codes, which are then displayed as 6-digit ones. To verify it, I run the query
 */
SELECT 
    ISTAT_code, 
    LENGTH(ISTAT_code) as Length,
    '>' || ISTAT_code || '<' as view_spaces -- By displaying the code between > < I can easily spot spaces
FROM Master_Tourism_Data
WHERE ISTAT_code NOT IN (SELECT ISTAT_code FROM Dim_Municipality_Classification);

/*I can finally confirm that, beside the length being 6-digits for all the records, several
present a space as 6th-digit. A new table can be created:
 */
CREATE TABLE "Analysis_Tourism_Trends_Italy_2014-2024_clean" AS
SELECT 
	T.Region,
	COALESCE(D.Province, T.Province) AS Province,
    COALESCE(D.Municipality, T.Municipality) AS Municipality,
    T.ISTAT_code,
    T.Total_Arrivals,
    T.Hotel_Arrivals,
    T.Total_Nights,
    T.Hotel_Nights,
    T.Year,
    D.Main_Tourism_Category,
    D.Tourism_Brand
FROM Master_Tourism_Data T
LEFT JOIN Dim_Municipality_Classification D 
    ON printf('%06d', CAST(TRIM(T.ISTAT_code) AS INTEGER)) =
       printf('%06d', CAST(TRIM(D.ISTAT_code) AS INTEGER));

/* COALESCE takes the most recent names for provinces and municipalities when present, while providing
the original historical records in case of missing matches, rather than leaving an empty value.
TRIM removes spaces before and after ISTAT codes, then CAST() AS INTEGER transforms the string in a number, 
deliting wrong formattings if present. Finally, printf('%06d',...) rebuilds the 6-digit ISTAT code string.
To be sure that everything went as planned, I run again the same query
 */
SELECT 
    ISTAT_code, 
    LENGTH(ISTAT_code) as Length,
    '>' || ISTAT_code || '<' as view_spaces
FROM "Analysis_Tourism_Trends_Italy_2014-2024_clean"
WHERE ISTAT_code NOT IN (SELECT ISTAT_code FROM Dim_Municipality_Classification);

/* Unfortunately, I notice that the space is still present in several ISTAT codes, but now the columns
Province and Municipality don't have any NULL value, while the number of NULL values in Main_Tourism_Category
and Tourism_Brand dropped from 3947 to 545. Even though this situation is more promising than earlier, 
when I had 3947 NULL values in Province, Municipality, Main_Tourism_Category and Tourism_Brand, there's
still a problem. The attempt of removing spaces using TRIM is failing probably because those characters
are not spaces, but something more complex. Anyway, 98.6% of the records have been correctly merged; the
remaining 1.4% (545 records out of 39441) will be categorised as "Not classified", rather than
having NULL values in Main_Tourism_Category and Tourism_Brand columns, in order to preserve the overall
integrity of the database:
 */ 
UPDATE "Analysis_Tourism_Trends_Italy_2014-2024_clean" 
SET Tourism_Brand = "Not classified"
WHERE Tourism_Brand IS NULL;

UPDATE "Analysis_Tourism_Trends_Italy_2014-2024_clean" 
SET Main_Tourism_Category = "Not classified"
WHERE Main_Tourism_Category IS NULL;

/* Since I cannot solve the 5-digit ISTAT code problem, maybe these 545 missing records are due to the fact
that, as mentioned several times, the name of some administrative entity has changed over time. Let's
then check the number of not classified records per year:
*/
SELECT 
    Year, 
    COUNT(*) AS "Number of records without Tourism Category and Brand"
FROM "Analysis_Tourism_Trends_Italy_2014-2024_clean"
WHERE Main_Tourism_Category OR Tourism_Brand = "Not classified"
GROUP BY Year
ORDER BY Year ASC;

/* The result of this query is the answer I was looking for: 88.6% of the missing records are dating back
 between 2014 and 2017, when provinces and municipalities may have had different names. I can now drop
 the old Analysis_Tourism_Trends_Italy_2014-2024 table and use Analysis_Tourism_Trends_Italy_2014-2024_clean,
 which I will rename:
 */
DROP TABLE "Analysis_Tourism_Trends_Italy_2014-2024";

ALTER TABLE "Analysis_Tourism_Trends_Italy_2014-2024_clean"
RENAME TO "Analysis_Tourism_Trends_Italy_2014-2024";
