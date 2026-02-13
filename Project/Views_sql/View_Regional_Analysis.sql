CREATE VIEW Regional_Analysis AS
SELECT 
    Year,
    Region,
    Province,
    Municipality,
    Main_Tourism_Category,
    Total_Arrivals,
    CASE 
	    WHEN Municipality IN ("Aosta", "Torino", "Milano", "Genova", "Trento", "Bolzano/Bozen", "Venezia", "Trieste", 
	    					"Bologna", "Firenze", "Perugia", "Ancona", "Roma", "L'Aquila", "Campobasso", "Napoli", "Bari",
	    					"Catanzaro", "Potenza", "Cagliari", "Palermo")
         THEN 1 
         ELSE 0 
    END AS Capital_City,
    CASE
        WHEN Region IN ("Valle D'Aosta", 'Piemonte', 'Lombardia', 'Trento', 'Bolzano-Bozen', 'Veneto', 'Friuli-Venezia Giulia', 'Liguria', 'Emilia-Romagna') THEN 'North'
	 	WHEN Region IN ('Toscana', 'Marche', 'Umbria', 'Lazio', 'Abruzzo') THEN 'Center'
	   	ELSE 'South & Islands'
    END AS Geographic_Area
FROM "Analysis_Tourism_Trends_Italy_2014-2024"
WHERE Year IN (2014, 2024);

/* RANK function will be performed by Tableau. It will be also capable of showing the municipalities needed to reach
50% of regional tourism volume.
*/