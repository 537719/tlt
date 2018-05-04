-- StatsColi.SQL
-- Élaboration des statistiques d'activité mensuelle pour Colissimo
-- destinées à alimenter les tableaux de reporting "DP_TBD_CLP-aaaa-mm-Sss-Indicateurs SOP-AAAA-MM-JJ.xlsx"
--
-- Usage : Invocation via SQLite3.exe avec un fichier GLPI.CSV accessible :
-- sqlite3 < ../statscoli.sql
-- CREATION 03/05/2018 - 16:00:38 première version opérationnelle, remplace la conjonction de scripts StatsColi.cmd et StatsColi.awk
-- MODIF 04/05/2018 - 10:50:43 rajout du commentaire relatif à la tenir à jour du chemin d'accès du fichier à importer

-- DEBUT
--  vide les anciennes données (inutile puisqu'on travaille sur une base temporaire
-- DROP TABLE STATSCOLI;
-- peuple la base avec les nouvelles données
.separator ;
-- la ligne suivante est réécrite par le script cmd appelant afin de tenir à jour le chemin d'accès au fichier
.import C:/Users/Utilisateur/Documents/TLT/Stats/EnCours/glpi.csv STATSCOLI

-- ajoute les champs nécessaires à la ventilation des stats à produire
ALTER TABLE STATSCOLI ADD COLUMN TypeSite TEXT ;
ALTER TABLE STATSCOLI ADD COLUMN Activite TEXT DEFAULT "Autres" ;

-- Peuplement des champs nouvellement créés
-- -- "Type de site"
UPDATE STATSCOLI SET TypeSite = trim(substr(Emplacement,1,instr(Emplacement," ")-1)," ")
WHERE   Entité LIKE "%COLI%"
-- AND `Type` = "Incident" -- Donnée à renseigner aussi bien pour les incidents que pour les demandes
AND     (
        `Historique des attributions` LIKE "%CIL%"
OR      `Historique des attributions` LIKE "%PLANIF%"
OR      `Historique des attributions` LIKE "%SOLUTIONS30%"
OR      `Historique des attributions` LIKE "%DEPART%"
OR      `Historique des attributions` LIKE "%ECONOCOM%"
OR      `Historique des attributions` LIKE "%CRII%"
OR      `Historique des attributions` LIKE "%OPS%"
OR      `Historique des attributions` LIKE "%I\&amp;S%" ESCAPE "\"
-- " double quote en commentaire afin que la coloration syntaxique retombe sur ses pieds après le ESCAPE
        )
;
UPDATE STATSCOLI SET Activite = "Expeditor"
WHERE   `Type`="Incident"
AND     Entité LIKE "%COLI%SHIP%"
AND     (
        `Historique des attributions` LIKE "%CIL%"
OR      `Historique des attributions` LIKE "%PLANIF%"
OR      `Historique des attributions` LIKE "%SOLUTIONS30%"
OR      `Historique des attributions` LIKE "%DEPART%"
OR      `Historique des attributions` LIKE "%ECONOCOM%"
OR      `Historique des attributions` LIKE "%CRII%"
OR      `Historique des attributions` LIKE "%OPS%"
OR      `Historique des attributions` LIKE "%I\&amp;S%" ESCAPE "\"
-- "
        )
;
UPDATE STATSCOLI SET Activite = "Imprimante"
WHERE   `Type`="Incident"
AND     Entité LIKE "%COLI%"
AND NOT Entité LIKE "%SHIP%"
AND     Catégorie LIKE "%IMPRIMANTE%"
AND     (
        `Historique des attributions` LIKE "%CIL%"
OR      `Historique des attributions` LIKE "%PLANIF%"
OR      `Historique des attributions` LIKE "%SOLUTIONS30%"
OR      `Historique des attributions` LIKE "%DEPART%"
OR      `Historique des attributions` LIKE "%ECONOCOM%"
OR      `Historique des attributions` LIKE "%CRII%"
OR      `Historique des attributions` LIKE "%OPS%"
OR      `Historique des attributions` LIKE "%I\&amp;S%" ESCAPE "\"
-- "
        )
;

UPDATE STATSCOLI SET Activite = "UC Fixe"
WHERE   `Type`="Incident"
AND     Entité LIKE "%COLI%"
AND NOT Entité LIKE "%SHIP%"
AND     Catégorie LIKE "%FIXE%"
AND     (
        `Historique des attributions` LIKE "%CIL%"
OR      `Historique des attributions` LIKE "%PLANIF%"
OR      `Historique des attributions` LIKE "%SOLUTIONS30%"
OR      `Historique des attributions` LIKE "%DEPART%"
OR      `Historique des attributions` LIKE "%ECONOCOM%"
OR      `Historique des attributions` LIKE "%CRII%"
OR      `Historique des attributions` LIKE "%OPS%"
OR      `Historique des attributions` LIKE "%I\&amp;S%" ESCAPE "\"
-- "
        )
;
UPDATE STATSCOLI SET Activite = "UC Portable"
WHERE   `Type`="Incident"
AND     Entité LIKE "%COLI%"
AND NOT Entité LIKE "%SHIP%"
AND     (
    Catégorie LIKE "%PORTABLE%"
OR  Catégorie LIKE "%TABLETTE%"
        )
AND     (
        `Historique des attributions` LIKE "%CIL%"
OR      `Historique des attributions` LIKE "%PLANIF%"
OR      `Historique des attributions` LIKE "%SOLUTIONS30%"
OR      `Historique des attributions` LIKE "%DEPART%"
OR      `Historique des attributions` LIKE "%ECONOCOM%"
OR      `Historique des attributions` LIKE "%CRII%"
OR      `Historique des attributions` LIKE "%OPS%"
OR      `Historique des attributions` LIKE "%I\&amp;S%" ESCAPE "\"
-- "
        )
;


-- Correction du peuplement par défaut des champs rajoutés
-- -- corrige les données de type de site erronnées  pour les incidents
UPDATE STATSCOLI SET TypeSite = "SIEGE/SAV"
WHERE   `Type` = "Incident" -- Modification différente pour les incidents et les demandes
AND (   TypeSite="SIEGE"
OR      TypeSite="SAV"
OR      TypeSite="DSCC"
)
;
UPDATE STATSCOLI SET TypeSite = "DOT"
WHERE   TypeSite="DRV"
;

-- corrige les données de type de site erronnées pour les demandes
UPDATE STATSCOLI SET TypeSite = "ADM"
WHERE   `Type` = "Demande" -- Modification différente pour les incidents et les demandes
AND (   TypeSite="SIEGE"
OR      TypeSite="SAV"
OR      TypeSite="DSCC"
OR      TypeSite="DOT"
OR      TypeSite="DRV"
)
;
UPDATE STATSCOLI SET TypeSite = "PFC"
WHERE   `Type` = "Demande" -- Modification différente pour les incidents et les demandes
AND (   TypeSite="SPECIFIQUE"
)
;

UPDATE STATSCOLI SET Activite = CHAR(183) || "Autres" -- 183 = caractère trié en dernier et dont l'affichage est acceptable
WHERE   `Type`="Incident"
AND     Activite = "Autres"
;


-- Production des stats
.output StatsColi.csv
-- Repartition des dossiers :"
SELECT "Repartition des dossiers :", COUNT(`Type`)
FROM STATSCOLI
WHERE   Entité LIKE "%COLI%"
AND     (
        `Historique des attributions` LIKE "%CIL%"
OR      `Historique des attributions` LIKE "%PLANIF%"
OR      `Historique des attributions` LIKE "%SOLUTIONS30%"
OR      `Historique des attributions` LIKE "%DEPART%"
OR      `Historique des attributions` LIKE "%ECONOCOM%"
OR      `Historique des attributions` LIKE "%CRII%"
OR      `Historique des attributions` LIKE "%OPS%"
OR      `Historique des attributions` LIKE "%I\&amp;S%" ESCAPE "\"
-- "
        )
;
SELECT `Type`, COUNT(`Type`)
FROM STATSCOLI
WHERE   Entité LIKE "%COLI%"
AND     (
        `Historique des attributions` LIKE "%CIL%"
OR      `Historique des attributions` LIKE "%PLANIF%"
OR      `Historique des attributions` LIKE "%SOLUTIONS30%"
OR      `Historique des attributions` LIKE "%DEPART%"
OR      `Historique des attributions` LIKE "%ECONOCOM%"
OR      `Historique des attributions` LIKE "%CRII%"
OR      `Historique des attributions` LIKE "%OPS%"
OR      `Historique des attributions` LIKE "%I\&amp;S%" ESCAPE "\"
-- "
        )
GROUP BY `Type`
ORDER BY `Type` DESC
;
SELECT CHAR(13);

-- Stat des Incidents par type de site
SELECT "Incidents par type de site", COUNT(`Type`)
FROM STATSCOLI
WHERE   Entité LIKE "%COLI%"
AND `Type` = "Incident"
AND     (
        `Historique des attributions` LIKE "%CIL%"
OR      `Historique des attributions` LIKE "%PLANIF%"
OR      `Historique des attributions` LIKE "%SOLUTIONS30%"
OR      `Historique des attributions` LIKE "%DEPART%"
OR      `Historique des attributions` LIKE "%ECONOCOM%"
OR      `Historique des attributions` LIKE "%CRII%"
OR      `Historique des attributions` LIKE "%OPS%"
OR      `Historique des attributions` LIKE "%I\&amp;S%" ESCAPE "\"
-- "
        )
;
SELECT "TypeSite", COUNT(`Type`)
FROM STATSCOLI
WHERE   Entité LIKE "%COLI%"
AND `Type` = "Incident"
AND     (
        `Historique des attributions` LIKE "%CIL%"
OR      `Historique des attributions` LIKE "%PLANIF%"
OR      `Historique des attributions` LIKE "%SOLUTIONS30%"
OR      `Historique des attributions` LIKE "%DEPART%"
OR      `Historique des attributions` LIKE "%ECONOCOM%"
OR      `Historique des attributions` LIKE "%CRII%"
OR      `Historique des attributions` LIKE "%OPS%"
OR      `Historique des attributions` LIKE "%I\&amp;S%" ESCAPE "\"
-- "
        )
GROUP BY TypeSite
ORDER BY TypeSite
;
SELECT CHAR(13);

--  Stat des Incidents par type d'activité
SELECT "Incidents par type d'activité", COUNT(`Type`)
FROM STATSCOLI
WHERE   Entité LIKE "%COLI%"
AND `Type` = "Incident"
AND     (
        `Historique des attributions` LIKE "%PLANIF%"
OR      `Historique des attributions` LIKE "%CIL%"
OR      `Historique des attributions` LIKE "%SOLUTIONS30%"
OR      `Historique des attributions` LIKE "%DEPART%"
OR      `Historique des attributions` LIKE "%ECONOCOM%"
OR      `Historique des attributions` LIKE "%CRII%"
OR      `Historique des attributions` LIKE "%OPS%"
OR      `Historique des attributions` LIKE "%I\&amp;S%" ESCAPE "\"
-- "
        )
;

SELECT "Activite", COUNT(`Type`)
FROM STATSCOLI
WHERE   Entité LIKE "%COLI%"
AND `Type` = "Incident"
AND     (
        `Historique des attributions` LIKE "%PLANIF%"
OR      `Historique des attributions` LIKE "%CIL%"
OR      `Historique des attributions` LIKE "%SOLUTIONS30%"
OR      `Historique des attributions` LIKE "%DEPART%"
OR      `Historique des attributions` LIKE "%ECONOCOM%"
OR      `Historique des attributions` LIKE "%CRII%"
OR      `Historique des attributions` LIKE "%OPS%"
OR      `Historique des attributions` LIKE "%I\&amp;S%" ESCAPE "\"
-- "
        )
GROUP BY Activite
ORDER BY Activite
;
SELECT CHAR(13);


-- Stat du Fil de l'eau PC par type de site
SELECT "Fil de l'eau PC par type de site", COUNT(`Type`)
FROM STATSCOLI
WHERE   Entité LIKE "%COLI%"
AND `Type` = "Demande"
AND     (
        `Historique des attributions` LIKE "%CIL%"
OR      `Historique des attributions` LIKE "%PLANIF%"
OR      `Historique des attributions` LIKE "%SOLUTIONS30%"
OR      `Historique des attributions` LIKE "%DEPART%"
OR      `Historique des attributions` LIKE "%ECONOCOM%"
OR      `Historique des attributions` LIKE "%CRII%"
OR      `Historique des attributions` LIKE "%OPS%"
OR      `Historique des attributions` LIKE "%I\&amp;S%" ESCAPE "\"
-- "
        )
AND Catégorie LIKE "%Demande de ma%ouveau poste de travail%PC%"
;
SELECT "TypeSite", COUNT(`Type`)
FROM STATSCOLI
WHERE   Entité LIKE "%COLI%"
AND `Type` = "Demande"
AND     (
        `Historique des attributions` LIKE "%CIL%"
OR      `Historique des attributions` LIKE "%PLANIF%"
OR      `Historique des attributions` LIKE "%SOLUTIONS30%"
OR      `Historique des attributions` LIKE "%DEPART%"
OR      `Historique des attributions` LIKE "%ECONOCOM%"
OR      `Historique des attributions` LIKE "%CRII%"
OR      `Historique des attributions` LIKE "%OPS%"
OR      `Historique des attributions` LIKE "%I\&amp;S%" ESCAPE "\"
-- "
        )
AND Catégorie LIKE "%Demande de ma%ouveau poste de travail%PC%"
GROUP BY TypeSite
ORDER BY TypeSite
;
SELECT CHAR(13);

-- Incidents par catégorie
SELECT "Incidents par catégorie", COUNT(`Type`)
FROM STATSCOLI
WHERE   Entité LIKE "%COLI%"
AND `Type` = "Incident"
AND     (
        `Historique des attributions` LIKE "%PLANIF%"
OR      `Historique des attributions` LIKE "%CIL%"
OR      `Historique des attributions` LIKE "%SOLUTIONS30%"
OR      `Historique des attributions` LIKE "%DEPART%"
OR      `Historique des attributions` LIKE "%ECONOCOM%"
OR      `Historique des attributions` LIKE "%CRII%"
OR      `Historique des attributions` LIKE "%OPS%"
OR      `Historique des attributions` LIKE "%I\&amp;S%" ESCAPE "\"
-- "
        )
;
SELECT "Catégorie", COUNT(`Type`)
FROM STATSCOLI
WHERE   Entité LIKE "%COLI%"
AND `Type` = "Incident"
AND     (
        `Historique des attributions` LIKE "%PLANIF%"
OR      `Historique des attributions` LIKE "%CIL%"
OR      `Historique des attributions` LIKE "%SOLUTIONS30%"
OR      `Historique des attributions` LIKE "%DEPART%"
OR      `Historique des attributions` LIKE "%ECONOCOM%"
OR      `Historique des attributions` LIKE "%CRII%"
OR      `Historique des attributions` LIKE "%OPS%"
OR      `Historique des attributions` LIKE "%I\&amp;S%" ESCAPE "\"
-- "
        )
GROUP BY Catégorie
ORDER BY Catégorie
;
SELECT CHAR(13);

-- fermeture du fichier de sortie
.output 

-- Et c'est fini
SELECT "Résultat dans le fichier StatsColi.csv" ;
.exit
