/*
===========================
Slice : Ventes du produit “New York”
===========================
*/

-- Supprimer la table si elle existe déjà pour éviter les erreurs
DROP TABLE Transactions_NewYork;

-- Créer une nouvelle table avec toutes les transactions à New York
SELECT 
    F.Transaction_ID,       -- Identifiant de la transaction
    D.FullDate,             -- Date complète de la transaction
    C.Customer_Name,        -- Nom du client
    P.Product_Name,         -- Nom du produit
    F.Total_Items,          -- Quantité totale vendue
    F.Total_Cost            -- Coût total de la transaction
INTO Transactions_NewYork  -- Création de la table Transactions_NewYork
FROM Fact_Transaction F
JOIN Dim_Location L ON F.Location_ID = L.Location_ID  -- Jointure sur la localisation
JOIN Dim_Date D ON F.Date_ID = D.Date_ID             -- Jointure sur la date
JOIN Dim_Customer C ON F.Customer_ID = C.Customer_ID -- Jointure sur le client
JOIN Dim_Product P ON F.Product_ID = P.Product_ID    -- Jointure sur le produit
WHERE L.City = 'New York';                           -- Filtrer uniquement la ville "New York"


/*
===========================
Dice : Ventes à New York pour "Student" en hiver
===========================
*/

-- Supprimer la table si elle existe
DROP TABLE Sales_NewYork_Student_Winter;

-- Créer une table avec les ventes filtrées par ville, catégorie de client et saison
SELECT 
    P.Product_Name,               -- Nom du produit
    SUM(F.Total_Cost) AS TotalSales -- Somme des ventes pour chaque produit
INTO Sales_NewYork_Student_Winter  -- Création de la table Sales_NewYork_Student_Winter
FROM Fact_Transaction F
JOIN Dim_Location L ON F.Location_ID = L.Location_ID
JOIN Dim_Customer C ON F.Customer_ID = C.Customer_ID
JOIN Dim_Date D ON F.Date_ID = D.Date_ID
JOIN Dim_Product P ON F.Product_ID = P.Product_ID
WHERE L.City = 'New York'          -- Ville = New York
  AND C.Customer_Category = 'Student' -- Catégorie = Student
  AND D.Season = 'Winter'          -- Saison = Winter
GROUP BY P.Product_Name             -- Grouper par produit
ORDER BY TotalSales DESC;           -- Trier par ventes décroissantes


/*
===========================
Roll-up : Agrégation par année, produit et ville
===========================
*/

-- Supprimer la table si elle existe
DROP TABLE ROLLUP_YEAR_PRODUCT_CITY;

-- Calculer les ventes totales à différents niveaux de hiérarchie
SELECT 
    D.Year,              -- Année de la transaction
    P.Product_Name,      -- Nom du produit
    L.City,              -- Ville
    SUM(F.Total_Cost) AS TotalSales -- Somme des ventes
INTO ROLLUP_YEAR_PRODUCT_CITY       -- Création de la table ROLLUP_YEAR_PRODUCT_CITY
FROM Fact_Transaction F
JOIN Dim_Date D ON F.Date_ID = D.Date_ID
JOIN Dim_Product P ON F.Product_ID = P.Product_ID
JOIN Dim_Location L ON F.Location_ID = L.Location_ID
GROUP BY ROLLUP (D.Year, P.Product_Name, L.City) -- Agrégation progressive : année → produit → ville
ORDER BY 
    D.Year,
    P.Product_Name,
    L.City;


/*
===========================
Drill-down : Détail des ventes par mois pour 2022
===========================
*/

-- Supprimer la table si elle existe
DROP TABLE DRILLDOW_NMONTH_CITY_PRODUCT;

-- Obtenir les ventes détaillées par mois, ville et produit pour l'année 2022
SELECT 
    D.Month,             -- Mois
    L.City,              -- Ville
    P.Product_Name,      -- Produit
    SUM(F.Total_Cost) AS TotalSales -- Somme des ventes
INTO DRILLDOW_NMONTH_CITY_PRODUCT  -- Création de la table DRILLDOW_NMONTH_CITY_PRODUCT
FROM Fact_Transaction F
JOIN Dim_Date D ON F.Date_ID = D.Date_ID
JOIN Dim_Product P ON F.Product_ID = P.Product_ID
JOIN Dim_Location L ON F.Location_ID = L.Location_ID
WHERE D.Year = 2022       -- Filtrer uniquement l'année 2022
GROUP BY D.Month, L.City, P.Product_Name -- Grouper par mois, ville et produit
ORDER BY D.Month, L.City, TotalSales DESC; -- Trier par mois, ville et ventes décroissantes
