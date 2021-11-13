-- cataltstock.sql
-- CREATION 09/11/2018 - 13:03:37 traite dans sqlite le résultat produit par cataltstock.cmd de manière à avoir les quantités de tous les articles alturing du catalogue
-- MODIF    22:01 28/04/2021 fait la jointure avec un like plutôt qu'un égale afin de pouvoir agréger tous les écrans en une seule catégorie

-- quantités par produit, sans distinction de stock d'appartenance ni de qualité de neuf ou reconditionné
.separator ;
.import stockalt.csv Stock
.header on
.output cataltstock.csv
SELECT Reference,er AS Famille,ce AS Produit, SUM(OkDispo) AS Dispo, SUM(`A Livrer`) AS Attendu,Designation
FROM Stock
GROUP BY ce
ORDER BY Reference ASC
;

-- quantités par familles de produits
.import famillesproduits.csv Familles
.output stockALTparfamilles.csv
SELECT SUM(OkDispo) AS Dispo, SUM(`A Livrer`) AS Attendu
, er  as Code,
familles.famille as Famille
FROM Stock
,Familles
WHERE stock.er LIKE Familles.Code

Group by famille
Order by er
;
.output