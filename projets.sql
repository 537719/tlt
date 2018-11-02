-- projets.sql
-- 19/10/2018 - 11:55:14 produit la liste du matériel attendu ou déjà sorti sur les projets
-- 29/10/2018 - 16:17:23 restitue la ville pour le matériel non encore expédié, si la donnée est connue
-- 02/11/2018 - 16:14:07 définition explicite des champs du fichier des produits expédiés, avec création d'un filtre d'unicité sur le tagis


-- PREREQUIS : présence des fichiers :
--      ArticlesDemandesProjets.csv généré par ArticlesDemandesProjets.cmd
--      VillesDemandesProjets.csv généré par VillesDemandesProjets.cmd
--      projexped.csv géénré par projexped.cmd


.separator ;

DROP TABLE IF EXISTS Demandes;
DROP TABLE IF EXISTS Villes;
DROP TABLE IF EXISTS Demandeurs;
DROP TABLE IF EXISTS Expedies;

CREATE TABLE Expedies(
  "GLPI" INTEGER,
  "Date BL" TEXT,
  "Ville L" TEXT,
  "Reference" TEXT,
  "Description" TEXT,
  "TagIS" TEXT UNIQUE
);

.import ArticlesDemandesProjets.csv Demandes
.import VillesDemandesProjets.csv Villes
.import GLPIliveprojectsDemandeurs.csv Demandeurs
.import projexped.csv Expedies


.headers on
.output fichier.csv

-- sortie des produits déjà expédiés
SELECT  Expedies.GLPI
,       Expedies."Date BL"  AS Date
,       dossiers.name       AS Projet
,       Expedies."Ville L"  AS Ville 
,COUNT( Expedies.Reference) AS Qte
,       Expedies.reference
,       Expedies.Description
,       Demandeurs.Demandeur
FROM    Expedies,Dossiers,Demandeurs
WHERE   GLPI=id
AND     NoDossier=id
GROUP BY Expedies.Reference,Expedies.GLPI
ORDER BY Ville,Expedies.GLPI
;
.headers off

-- ancienne formulation, avec la ville en vide
-- SELECT demandes.GLPI,"__/__/__",dossiers.name AS Projet,"" AS VILLE,demandes.qte,demandes.reference,demandes.designation FROM demandes,dossiers WHERE demandes.glpi NOT IN (SELECT GLPI FROM expedies) AND demandes.glpi=dossiers.id;

-- nouvelle formulation, avec la ville des dossiers non expédiés qui apparait si elle est connue
SELECT  Dossiers.id AS GLPI
,       "__/__/__"
,       Dossiers.name AS Projet
,       Villes.ville AS Ville
,       Demandes.qte
,       Demandes.reference
,       demandes.designation
,       Demandeurs.Demandeur
FROM    Dossiers,Demandes,Demandeurs
LEFT JOIN Villes ON Villes.GLPI=Dossiers.id
WHERE   Demandes.GLPI=Dossiers.id
AND     Demandes.GLPI NOT IN (SELECT GLPI FROM Expedies)
AND     NoDossier=id
;


.output
.exit

-- select name,dossiers.id,villes.glpi,ville from dossiers left join villes on villes.glpi=dossiers.id
-- sort les villes assorties aux dossiers de demandes, lorsque la donnée existe

-- select Dossiers.id AS GLPI, Dossiers.name AS Projet,Villes.ville AS Ville,Demandes.qte,Demandes.reference FROM Dossiers,Demandes LEFT JOIN Villes ON Villes.GLPI=Dossiers.id WHERE Demandes.GLPI=Dossiers.id AND Demandes.GLPI NOT IN (SELECT GLPI FROM Expedies);
-- rajoute la qté et ref demandés, sur les dossiers pour lesquels aucune expédition n'a eu lieu

