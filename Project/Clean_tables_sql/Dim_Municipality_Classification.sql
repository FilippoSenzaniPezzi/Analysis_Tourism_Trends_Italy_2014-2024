/* Once the Master_Tourism_Data table has been created, I can now proceed in the
same way I've done before on Power Query. In order to handle administrative
adjustments over the decade, the table "Comuni Classificazione Brand", renamed
as "Dim_Municipality_Classification", will be used as dimension table. Connecting the ISTAT_code
column in Master_Tourism_Data to the same column in Dim_Municipality_Classification
with a Left Join, allows to preserve the most recent administrative subdivision.

Import Dim_Municipality_Classification_raw to clean it, starting by renaming the columns
and dropping the unused ones.
*/
ALTER TABLE Dim_Municipality_Classification_raw RENAME COLUMN REGIONE TO Region;
ALTER TABLE Dim_Municipality_Classification_raw DROP COLUMN "COD REG";
ALTER TABLE Dim_Municipality_Classification_raw RENAME COLUMN PROVINCIA TO Province;
ALTER TABLE Dim_Municipality_Classification_raw DROP COLUMN "COD PRO";
ALTER TABLE Dim_Municipality_Classification_raw RENAME COLUMN COMUNE TO Municipality;
ALTER TABLE Dim_Municipality_Classification_raw DROP COLUMN "COD COM";
ALTER TABLE Dim_Municipality_Classification_raw RENAME COLUMN PROCOM TO ISTAT_code;
ALTER TABLE Dim_Municipality_Classification_raw RENAME COLUMN "CATEGORIA TURISTICA PREVALENTE" TO Main_Tourism_Category;
ALTER TABLE Dim_Municipality_Classification_raw RENAME COLUMN "BRAND TURISTICO" TO Tourism_Brand;

/* The ISTAT_code column data type needs to be changed to text in order to preserve
the 6-digit code. I create a new ISTAT_code_clean column and I drop the old one
*/
ALTER TABLE Dim_Municipality_Classification_raw ADD COLUMN ISTAT_code_clean TEXT;

UPDATE Dim_Municipality_Classification_raw
SET 
	ISTAT_code_clean = SUBSTR('000000' || REPLACE(CAST("ISTAT_code" AS TEXT), '.0', ''), -6)
WHERE Region IS NOT NULL;

ALTER TABLE Dim_Municipality_Classification_raw DROP COLUMN ISTAT_code;

-- Display regions and provinces in lower case

UPDATE Dim_Municipality_Classification_raw
SET "Region" = UPPER(SUBSTR("Region", 1, 1)) || LOWER(SUBSTR("Region", 2))
WHERE "Region" != '';
UPDATE Dim_Municipality_Classification_raw
SET "Region" = "Valle D'Aosta"
WHERE "Region" = "Valle d'aosta";
UPDATE Dim_Municipality_Classification_raw
SET "Region" = "Bolzano-Bozen"
WHERE "Region" = "Bolzano - bozen";
UPDATE Dim_Municipality_Classification_raw
SET "Region" = "Friuli-Venezia Giulia"
WHERE "Region" = "Friuli-venezia giulia";
UPDATE Dim_Municipality_Classification_raw
SET "Region" = "Emilia-Romagna"
WHERE "Region" = "Emilia-romagna";

UPDATE Dim_Municipality_Classification_raw
SET "Province" = UPPER(SUBSTR("Province", 1, 1)) || LOWER(SUBSTR("Province", 2))
WHERE "Province" != '';
UPDATE Dim_Municipality_Classification_raw
SET "Province" = "Valle D'Aosta/Vallée D'Aoste"
WHERE "Province" = "Valle d'aosta/vallÉe d'aoste";
UPDATE Dim_Municipality_Classification_raw
SET "Province" = "Bolzano-Bozen"
WHERE "Province" = "Bolzano-bozen";
UPDATE Dim_Municipality_Classification_raw
SET "Province" = "La Spezia"
WHERE "Province" = "La spezia";
UPDATE Dim_Municipality_Classification_raw
SET "Province" = "Reggio Nell'Emilia"
WHERE "Province" = "Reggio nell'emilia";
UPDATE Dim_Municipality_Classification_raw
SET "Province" = "Forli'-Cesena"
WHERE "Province" = "Forli'-cesena";
UPDATE Dim_Municipality_Classification_raw
SET "Province" = "Massa-Carrara"
WHERE "Province" = "Massa-carrara";
UPDATE Dim_Municipality_Classification_raw
SET "Province" = "Pesaro e Urbino"
WHERE "Province" = "Pesaro e urbino";
UPDATE Dim_Municipality_Classification_raw
SET "Province" = "Ascoli Piceno"
WHERE "Province" = "Ascoli piceno";
UPDATE Dim_Municipality_Classification_raw
SET "Province" = "L'Aquila"
WHERE "Province" = "L'aquila";
UPDATE Dim_Municipality_Classification_raw
SET "Province" = "Barletta-Andria-Trani"
WHERE "Province" = "Barletta-andria-trani";
UPDATE Dim_Municipality_Classification_raw
SET "Province" = "Reggio Di Calabria"
WHERE "Province" = "Reggio di calabria";
UPDATE Dim_Municipality_Classification_raw
SET "Province" = "Vibo Valentia"
WHERE "Province" = "Vibo valentia";
UPDATE Dim_Municipality_Classification_raw
SET "Province" = "Sud Sardegna"
WHERE "Province" = "Sud sardegna";
UPDATE Dim_Municipality_Classification_raw
SET "Province" = "Verbano-Cusio-Ossola"
WHERE "Province" = "Verbano-cusio-ossola";
UPDATE Dim_Municipality_Classification_raw
SET "Province" = "Monza e Brianza"
WHERE "Province" = "Monza e brianza";

-- Translate the content of Main_Tourism_Category in English

UPDATE Dim_Municipality_Classification_raw
SET Main_Tourism_Category = "Big cities (with multidimensional tourism)"
WHERE Main_Tourism_Category = "Grandi città (con turismo multidimensionale)";
UPDATE Dim_Municipality_Classification_raw
SET Main_Tourism_Category = "Municipalities with a maritime vocation"
WHERE Main_Tourism_Category = "Comuni con vocazione marittima";
UPDATE Dim_Municipality_Classification_raw
SET Main_Tourism_Category = "Municipalities with a mountain vocation"
WHERE Main_Tourism_Category = "Comuni con vocazione montana";
UPDATE Dim_Municipality_Classification_raw
SET Main_Tourism_Category = "Municipalities with a cultural, historical, artistic and landscape vocation"
WHERE Main_Tourism_Category = "Comuni a vocazione culturale, storica, artistica e paesaggistica";
UPDATE Dim_Municipality_Classification_raw
SET Main_Tourism_Category = "Municipalities with a maritime vocation + a cultural, historical, artistic and landscape vocation"
WHERE Main_Tourism_Category = "Comuni a vocazione marittima e con vocazione culturale, storica, artistica e paesaggistica";
UPDATE Dim_Municipality_Classification_raw
SET Main_Tourism_Category = "Municipalities with a mountain vocation + a cultural, historical, artistic and landscape vocation"
WHERE Main_Tourism_Category = "Comuni a vocazione montana e con vocazione culturale, storica, artistica e paesaggistica";
UPDATE Dim_Municipality_Classification_raw
SET Main_Tourism_Category = "Municipalities with a cultural, historical, artistic and landscape vocation + other vocations"
WHERE Main_Tourism_Category = "Comuni a vocazione culturale, storica, artistica e paesaggistica e altre vocazioni";
UPDATE Dim_Municipality_Classification_raw
SET Main_Tourism_Category = "Municipalities with lake tourism "
WHERE Main_Tourism_Category = "Comuni del turismo lacuale";
UPDATE Dim_Municipality_Classification_raw
SET Main_Tourism_Category = "Municipalities with thermal tourism"
WHERE Main_Tourism_Category = "Comuni del turismo termale";
UPDATE Dim_Municipality_Classification_raw
SET Main_Tourism_Category = "Other tourist municipalities with two vocations"
WHERE Main_Tourism_Category = "Altri comuni turistici con due vocazioni";
UPDATE Dim_Municipality_Classification_raw
SET Main_Tourism_Category = "Tourist municipalities without a specific category"
WHERE Main_Tourism_Category = "Comuni turistici non appartenenti ad una categoria specifica";
UPDATE Dim_Municipality_Classification_raw
SET Main_Tourism_Category = "Non-touristic municipalities"
WHERE Main_Tourism_Category = "Comuni non turistici";


/* As far as the column Tourism_Brand is concerned, rather than having empty
cells, I'll be writing "Not branded".
*/
UPDATE Dim_Municipality_Classification_raw
SET Tourism_Brand = "Not branded"
WHERE Tourism_Brand = '';

/* I want the columns to be ordered in the same way I have on Excel. The command MOVE doesn't
exist in SQLite, so I need to create a new table, where I will also rename the ISTAT_code_clean
column to just ISTAT_code. Finally, I can drop the old table Dim_Municipality_Classification_raw
*/

CREATE TABLE Dim_Municipality_Classification AS
SELECT 
	Region,
	Province,
	Municipality,
	ISTAT_code_clean AS ISTAT_code,
	Main_Tourism_Category,
	Tourism_Brand
FROM Dim_Municipality_Classification_raw;

DROP TABLE Dim_Municipality_Classification_raw;

VACUUM;
