-- =========================================
-- Création des tables de dimensions et de fait pour DW_Retail
-- =========================================

-- Utiliser la base de données DW_Retail
USE DW_Retail;
GO

-- Supprimer les tables existantes pour éviter les conflits
DROP TABLE Fact_Transaction;
DROP TABLE Dim_Date;
DROP TABLE Dim_Customer;
DROP TABLE Dim_Product;
DROP TABLE Dim_Location;
DROP TABLE Dim_PaymentMethod;
DROP TABLE Dim_Promotion;
DROP TABLE Stg_RetailTransactions;

-- =========================================
-- Table de dimension Dim_Date
-- =========================================
CREATE TABLE Dim_Date (
    Date_ID INT IDENTITY(1,1) PRIMARY KEY, -- Identifiant unique pour chaque date
    FullDate DATE,                         -- Date complète
    Year INT,                              -- Année
    Month INT,                             -- Mois
    Day INT,                               -- Jour
    Quarter INT,                            -- Trimestre
    Season VARCHAR(50)                      -- Saison (ex: Winter, Summer)
);

-- =========================================
-- Table de dimension Dim_Customer
-- =========================================
CREATE TABLE Dim_Customer (
    Customer_ID INT IDENTITY(1,1) PRIMARY KEY, -- Identifiant unique du client
    Customer_Name VARCHAR(50),                 -- Nom du client
    Customer_Category VARCHAR(50)              -- Catégorie du client (ex: Student, Regular)
);

-- =========================================
-- Table de dimension Dim_Product
-- =========================================
CREATE TABLE Dim_Product (
    Product_ID INT IDENTITY(1,1) PRIMARY KEY, -- Identifiant unique du produit
    Product_Name NVARCHAR(255)                -- Nom du produit (support des caractères Unicode)
);

-- =========================================
-- Table de dimension Dim_Location
-- =========================================
CREATE TABLE Dim_Location (
    Location_ID INT IDENTITY(1,1) PRIMARY KEY, -- Identifiant unique de la localisation
    City VARCHAR(50),                          -- Ville
    Store_Type VARCHAR(50)                     -- Type de magasin (ex: Boutique, Online)
);

-- =========================================
-- Table de dimension Dim_PaymentMethod
-- =========================================
CREATE TABLE Dim_PaymentMethod (
    PaymentMethod_ID INT IDENTITY(1,1) PRIMARY KEY, -- Identifiant unique de la méthode de paiement
    Payment_Method VARCHAR(50)                       -- Méthode de paiement (ex: Credit Card, Cash)
);

-- =========================================
-- Table de dimension Dim_Promotion
-- =========================================
CREATE TABLE Dim_Promotion (
    Promotion_ID INT IDENTITY(1,1) PRIMARY KEY, -- Identifiant unique de la promotion
    Promotion_Name VARCHAR(50),                 -- Nom de la promotion
    Discount_Applied BIT                         -- Indique si la promotion applique un rabais (0 = Non, 1 = Oui)
);

-- =========================================
-- Table de fait Fact_Transaction
-- =========================================
CREATE TABLE Fact_Transaction (
    Sales_ID INT IDENTITY(1,1) PRIMARY KEY,  -- Identifiant unique de la ligne de fait

    Transaction_ID BIGINT,                    -- Identifiant de transaction original
    Date_ID INT,                              -- Référence à Dim_Date
    Customer_ID INT,                          -- Référence à Dim_Customer
    Product_ID INT,                           -- Référence à Dim_Product
    Location_ID INT,                           -- Référence à Dim_Location
    PaymentMethod_ID INT,                      -- Référence à Dim_PaymentMethod
    Promotion_ID INT,                          -- Référence à Dim_Promotion

    Total_Items INT,                           -- Nombre total d’articles vendus
    Total_Cost DECIMAL(10,2),                 -- Coût total de la transaction

    -- Clés étrangères pour garantir l'intégrité référentielle
    FOREIGN KEY (Date_ID) REFERENCES Dim_Date(Date_ID),
    FOREIGN KEY (Customer_ID) REFERENCES Dim_Customer(Customer_ID),
    FOREIGN KEY (Product_ID) REFERENCES Dim_Product(Product_ID),
    FOREIGN KEY (Location_ID) REFERENCES Dim_Location(Location_ID),
    FOREIGN KEY (PaymentMethod_ID) REFERENCES Dim_PaymentMethod(PaymentMethod_ID),
    FOREIGN KEY (Promotion_ID) REFERENCES Dim_Promotion(Promotion_ID)
);

-- =========================================
-- Table de staging brute : Stg_RetailTransactions
-- =========================================
-- Sert à stocker les données importées avant transformation et chargement dans le modèle en étoile
CREATE TABLE Stg_RetailTransactions (
    Transaction_ID BIGINT,           -- Identifiant de transaction
    Transaction_Date DATE,           -- Date de la transaction
    Customer_Name VARCHAR(50),       -- Nom du client
    Customer_Category VARCHAR(50),   -- Catégorie du client
    Product NVARCHAR(255),           -- Nom du produit (à dénormaliser pour Dim_Product)
    City VARCHAR(50),                -- Ville
    Store_Type VARCHAR(50),          -- Type de magasin
    Payment_Method VARCHAR(50),      -- Méthode de paiement
    Promotion_Name VARCHAR(50),      -- Nom de la promotion
    Discount_Applied BIT,            -- Indicateur de rabais appliqué
    Season VARCHAR(50),              -- Saison de la transaction
    Total_Items INT,                 -- Nombre total d’articles vendus
    Total_Cost DECIMAL(10,2)        -- Coût total
);
