-- Rename columns necessary for the analysis and drop the others

ALTER TABLE "2023_raw" RENAME COLUMN Column10 TO Total_Arrivals;
ALTER TABLE "2023_raw" RENAME COLUMN Column13 TO Hotel_Arrivals;
ALTER TABLE "2023_raw" RENAME COLUMN Column20 TO Total_Nights;
ALTER TABLE "2023_raw" RENAME COLUMN Column23 TO Hotel_Nights;
ALTER TABLE "2023_raw" RENAME COLUMN "Regione / Region" TO Region;
ALTER TABLE "2023_raw" RENAME COLUMN "Provincia / Province" TO Province;
ALTER TABLE "2023_raw" RENAME COLUMN "Comune / Municipality" TO Municipality;
ALTER TABLE "2023_raw" RENAME COLUMN "Cod. Istat" TO ISTAT_code;

ALTER TABLE "2023_raw" DROP COLUMN "Cod. Reg";
ALTER TABLE "2023_raw" DROP COLUMN "Cod. Prov.";
ALTER TABLE "2023_raw" DROP COLUMN "flag";
ALTER TABLE "2023_raw" DROP COLUMN "Arrivi / Arrivals";
ALTER TABLE "2023_raw" DROP COLUMN Column9;
ALTER TABLE "2023_raw" DROP COLUMN Column11;
ALTER TABLE "2023_raw" DROP COLUMN Column12;
ALTER TABLE "2023_raw" DROP COLUMN Column14;
ALTER TABLE "2023_raw" DROP COLUMN Column15;
ALTER TABLE "2023_raw" DROP COLUMN Column16;
ALTER TABLE "2023_raw" DROP COLUMN Column17;
ALTER TABLE "2023_raw" DROP COLUMN "Presenze / Nights spent";
ALTER TABLE "2023_raw" DROP COLUMN Column19;
ALTER TABLE "2023_raw" DROP COLUMN Column21;
ALTER TABLE "2023_raw" DROP COLUMN Column22;
ALTER TABLE "2023_raw" DROP COLUMN Column24;
ALTER TABLE "2023_raw" DROP COLUMN Column25;
ALTER TABLE "2023_raw" DROP COLUMN Column26;

-- Remove unnecessary rows

DELETE FROM "2023_raw" WHERE "ISTAT_code" = '';
DELETE FROM "2023_raw" WHERE "Municipality" LIKE "Altri comuni%";

-- Focusing on columns content, regions need to be written in lower case

UPDATE "2023_raw"
SET "Region" = UPPER(SUBSTR("Region", 1, 1)) || LOWER(SUBSTR("Region", 2))
WHERE "Region" != '';
UPDATE "2023_raw"
SET "Region" = "Valle D'Aosta"
WHERE "Region" = "Valle d'aosta";
UPDATE "2023"
SET "Region" = "Bolzano-Bozen"
WHERE "Region" = "Bolzano - Bozen";
UPDATE "2023_raw"
SET "Region" = "Friuli-Venezia Giulia"
WHERE "Region" = "Friuli-venezia giulia";
UPDATE "2023_raw"
SET "Region" = "Emilia-Romagna"
WHERE "Region" = "Emilia-romagna";

-- Same for provinces

UPDATE "2023_raw"
SET "Province" = UPPER(SUBSTR("Province", 1, 1)) || LOWER(SUBSTR("Province", 2))
WHERE "Province" != '';
UPDATE "2023_raw"
SET "Province" = "Verbano-Cusio-Ossola"
WHERE "Province" = "Verbano-cusio-ossola";
UPDATE "2023_raw"
SET "Province" = "Valle D'Aosta/Vallée D'Aoste"
WHERE "Province" = "Valle d'aosta/vallÉe d'aoste";
UPDATE "2023_raw"
SET "Province" = "Monza e Brianza"
WHERE "Province" = "Monza e brianza";
UPDATE "2023"
SET "Province" = "Bolzano-Bozen"
WHERE "Province" = "Bolzano-bozen";
UPDATE "2023_raw"
SET "Province" = "La Spezia"
WHERE "Province" = "La spezia";
UPDATE "2023_raw"
SET "Province" = "Reggio Nell'Emilia"
WHERE "Province" = "Reggio nell'emilia";
UPDATE "2023_raw"
SET "Province" = "Forli'-Cesena"
WHERE "Province" = "Forli'-cesena";
UPDATE "2023_raw"
SET "Province" = "Massa-Carrara"
WHERE "Province" = "Massa-carrara";
UPDATE "2023"
SET "Province" = "Pesaro e Urbino"
WHERE "Province" = "Pesaro e urbino";
UPDATE "2023_raw"
SET "Province" = "Ascoli Piceno"
WHERE "Province" = "Ascoli piceno";
UPDATE "2023_raw"
SET "Province" = "L'Aquila"
WHERE "Province" = "L'aquila";
UPDATE "2023_raw"
SET "Province" = "Barletta-Andria-Trani"
WHERE "Province" = "Barletta-andria-trani";
UPDATE "2023_raw"
SET "Province" = "Reggio Di Calabria"
WHERE "Province" = "Reggio di calabria";
UPDATE "2023_raw"
SET "Province" = "Vibo Valentia"
WHERE "Province" = "Vibo valentia";
UPDATE "2023_raw"
SET "Province" = "Sud Sardegna"
WHERE "Province" = "Sud sardegna";

/* As far as columns containing numbers are concerned: 
- replace '-' and '(*)' with '0';
- trim the values to avoid spaces at the beginning of the cell;
- remove the dot as a delimiter between thousands and hundreds
*/

UPDATE "2023_raw" 
SET 
    "Hotel_Arrivals" = '0',
    "Hotel_Nights" = '0'
WHERE "Hotel_Arrivals" LIKE '%-%' 
   OR "Hotel_Arrivals" LIKE '%(*)%'
   OR "Hotel_Nights" LIKE '%-%' 
   OR "Hotel_Nights" LIKE '%(*)%';

UPDATE "2023_raw"
SET 
	"Total_Arrivals" = REPLACE(TRIM("Total_Arrivals"), '.', ''),
    "Hotel_Arrivals" = REPLACE(TRIM("Hotel_Arrivals"), '.', ''),
    "Total_Nights" = REPLACE(TRIM("Total_Nights"), '.', ''),
    "Hotel_Nights" = REPLACE(TRIM("Hotel_Nights"), '.', '')
WHERE "Region" IS NOT NULL;

/* Changing the last 5 columns data types:
- ISTAT_code needs to be a text, so that we don't loose '00' at the beginning of the 6-digit code;
- Total_Arrivals, Hotel_Arrivals, Total_Nights, Hotel_Nights need to be numbers;
- inside SQLite, ALTER COLUMN is not available. I need to create new columns with clean data
- and drop the old columns
*/

ALTER TABLE "2023_raw" ADD COLUMN ISTAT_code_clean TEXT;
ALTER TABLE "2023_raw" ADD COLUMN Hotel_Arrivals_clean INTEGER;
ALTER TABLE "2023_raw" ADD COLUMN Hotel_Nights_clean INTEGER;
ALTER TABLE "2023_raw" ADD COLUMN Total_Arrivals_clean INTEGER;
ALTER TABLE "2023_raw" ADD COLUMN Total_Nights_clean INTEGER;

UPDATE "2023_raw"
SET 
	ISTAT_code_clean = SUBSTR('000000' || REPLACE(CAST("ISTAT_code" AS TEXT), '.0', ''), -6),
	Total_Arrivals_clean = CAST("Total_Arrivals" AS INTEGER),
    Hotel_Arrivals_clean = CAST("Hotel_Arrivals" AS INTEGER),
	Total_Nights_clean = CAST("Total_Nights" AS INTEGER),
    Hotel_Nights_clean = CAST("Hotel_Nights" AS INTEGER)
WHERE Region IS NOT NULL;

ALTER TABLE "2023_raw" DROP COLUMN Hotel_Arrivals;
ALTER TABLE "2023_raw" DROP COLUMN Hotel_Nights;
ALTER TABLE "2023_raw" DROP COLUMN Total_Nights;
ALTER TABLE "2023_raw" DROP COLUMN Total_Arrivals;
ALTER TABLE "2023_raw" DROP COLUMN ISTAT_code;

/* I want the columns to be ordered in the same way I have on Excel. The command MOVE doesn't
exist in SQLite, so I need to create a new table, where I will also rename the columns
*/

CREATE TABLE "2023" AS
SELECT 
	Region,
	Province,
	Municipality,
	ISTAT_code_clean AS ISTAT_code,
	Total_Arrivals_clean AS Total_Arrivals,
	Hotel_Arrivals_clean AS Hotel_Arrivals,
	Total_Nights_clean AS Total_Nights,
	Hotel_Nights_clean AS Hotel_Nights
FROM "2023_raw";

-- Eventually, after adding a "Year" column to this final clean table, I can drop the old 2023_raw

ALTER TABLE "2023" ADD COLUMN Year INTEGER;

UPDATE "2023"
SET Year = 2023
WHERE Region IS NOT NULL;

DROP TABLE "2023_raw";

VACUUM;

