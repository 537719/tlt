-- StatsColi.SQL
-- Élaboration des statistiques d'activité mensuelle pour Colissimo
-- destinées à alimenter les tableaux de reporting "DP_TBD_CLP-aaaa-mm-Sss-Indicateurs SOP-AAAA-MM-JJ.xlsx"
--
-- Usage : Invocation via SQLite3.exe avec un fichier GLPI.CSV accessible :
-- sqlite3 < ../statscoli.sql
-- CREATION 03/05/2018 - 16:00:38 première version opérationnelle, remplace la conjonction de scripts StatsColi.cmd et StatsColi.awk

-- DEBUT
--  vide les anciennes données (inutile puisqu'on travaille sur une base temporaire
-- DROP TABLE STATSCOLI;
-- peuple la base avec les nouvelles données

-- BUG 03/09/2018 - 10:15:41 non encore corrigé : le fait que certaines entités n'aient aucune activité fait qu'elles ne sortent pas au lieu de sortir à zéro
--                          solution envisagée : créer une table intermédiaire initialisant à zéro toutes les entités dont on attend un résulat,
--                                                l'alimenter avec le résultat du query actuel puis faire le query définitif dessus
--     02/10/2018 - 11:42:28 implémentation de la correction en question

.separator ;
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

-- UPDATE STATSCOLI SET Activite = CHAR(183) || "Autres" -- 183 = caractère trié en dernier et dont l'affichage est acceptable
UPDATE STATSCOLI SET Activite = "Autres" -- 183 = caractère trié en dernier et dont l'affichage est acceptable
-- MODIF 01/10/2018 - 16:24:54 suppression du caractères 183 pour cause de modification dans la présentation des résultats
WHERE   `Type`="Incident"
AND     Activite = "Autres"
;


-- Production des stats
.output StatsColi.csv
-- section totalement refondue suite au BUG 03/09/2018 - 10:15:41
-- -- Repartition des dossiers :"
-- SELECT "Repartition des dossiers :", COUNT(`Type`)
-- FROM STATSCOLI
-- WHERE   Entité LIKE "%COLI%"
-- AND     (
        -- `Historique des attributions` LIKE "%CIL%"
-- OR      `Historique des attributions` LIKE "%PLANIF%"
-- OR      `Historique des attributions` LIKE "%SOLUTIONS30%"
-- OR      `Historique des attributions` LIKE "%DEPART%"
-- OR      `Historique des attributions` LIKE "%ECONOCOM%"
-- OR      `Historique des attributions` LIKE "%CRII%"
-- OR      `Historique des attributions` LIKE "%OPS%"
-- OR      `Historique des attributions` LIKE "%I\&amp;S%" ESCAPE "\"
-- "
        -- )
-- ;
-- SELECT `Type`, COUNT(`Type`)
-- FROM STATSCOLI
-- WHERE   Entité LIKE "%COLI%"
-- AND     (
        -- `Historique des attributions` LIKE "%CIL%"
-- OR      `Historique des attributions` LIKE "%PLANIF%"
-- OR      `Historique des attributions` LIKE "%SOLUTIONS30%"
-- OR      `Historique des attributions` LIKE "%DEPART%"
-- OR      `Historique des attributions` LIKE "%ECONOCOM%"
-- OR      `Historique des attributions` LIKE "%CRII%"
-- OR      `Historique des attributions` LIKE "%OPS%"
-- OR      `Historique des attributions` LIKE "%I\&amp;S%" ESCAPE "\"
-- "
--         -- )
-- GROUP BY `Type`
-- ORDER BY `Type` DESC
-- ;
-- SELECT CHAR(13);
-- -- Stat des Incidents par type de site
-- SELECT "Incidents par type de site", COUNT(`Type`)
-- FROM STATSCOLI
-- WHERE   Entité LIKE "%COLI%"
-- AND `Type` = "Incident"
-- AND     (
        -- `Historique des attributions` LIKE "%CIL%"
-- OR      `Historique des attributions` LIKE "%PLANIF%"
-- OR      `Historique des attributions` LIKE "%SOLUTIONS30%"
-- OR      `Historique des attributions` LIKE "%DEPART%"
-- OR      `Historique des attributions` LIKE "%ECONOCOM%"
-- OR      `Historique des attributions` LIKE "%CRII%"
-- OR      `Historique des attributions` LIKE "%OPS%"
-- OR      `Historique des attributions` LIKE "%I\&amp;S%" ESCAPE "\"
-- "
--        -- )
-- ;
-- SELECT "TypeSite", COUNT(`Type`)
-- FROM STATSCOLI
-- WHERE   Entité LIKE "%COLI%"
-- AND `Type` = "Incident"
-- AND     (
        -- `Historique des attributions` LIKE "%CIL%"
-- OR      `Historique des attributions` LIKE "%PLANIF%"
-- OR      `Historique des attributions` LIKE "%SOLUTIONS30%"
-- OR      `Historique des attributions` LIKE "%DEPART%"
-- OR      `Historique des attributions` LIKE "%ECONOCOM%"
-- OR      `Historique des attributions` LIKE "%CRII%"
-- OR      `Historique des attributions` LIKE "%OPS%"
-- OR      `Historique des attributions` LIKE "%I\&amp;S%" ESCAPE "\"
-- "
--        -- )
-- GROUP BY TypeSite
-- ORDER BY TypeSite
-- ;
-- SELECT CHAR(13);
--
-- -- Stat des Incidents par type d'activité
-- SELECT "Incidents par type d'activité", COUNT(`Type`)
-- FROM STATSCOLI
-- WHERE   Entité LIKE "%COLI%"
-- AND `Type` = "Incident"
-- AND     (
        -- `Historique des attributions` LIKE "%PLANIF%"
-- OR      `Historique des attributions` LIKE "%CIL%"
-- OR      `Historique des attributions` LIKE "%SOLUTIONS30%"
-- OR      `Historique des attributions` LIKE "%DEPART%"
-- OR      `Historique des attributions` LIKE "%ECONOCOM%"
-- OR      `Historique des attributions` LIKE "%CRII%"
-- OR      `Historique des attributions` LIKE "%OPS%"
-- OR      `Historique des attributions` LIKE "%I\&amp;S%" ESCAPE "\"
-- "
--        -- )
-- -- ;
--
-- SELECT "Activite", COUNT(`Type`)
-- FROM STATSCOLI
-- WHERE   Entité LIKE "%COLI%"
-- AND `Type` = "Incident"
-- AND     (
        -- `Historique des attributions` LIKE "%PLANIF%"
-- OR      `Historique des attributions` LIKE "%CIL%"
-- OR      `Historique des attributions` LIKE "%SOLUTIONS30%"
-- OR      `Historique des attributions` LIKE "%DEPART%"
-- OR      `Historique des attributions` LIKE "%ECONOCOM%"
-- OR      `Historique des attributions` LIKE "%CRII%"
-- OR      `Historique des attributions` LIKE "%OPS%"
-- OR      `Historique des attributions` LIKE "%I\&amp;S%" ESCAPE "\"
-- "
--        -- )
-- GROUP BY Activite
-- ORDER BY Activite
-- ;
-- SELECT CHAR(13);
--
-- -- Stat du Fil de l'eau PC par type de site
-- SELECT "Fil de l'eau PC par type de site", COUNT(`Type`)
-- FROM STATSCOLI
-- WHERE   Entité LIKE "%COLI%"
-- AND `Type` = "Demande"
-- AND     (
        -- `Historique des attributions` LIKE "%CIL%"
-- OR      `Historique des attributions` LIKE "%PLANIF%"
-- OR      `Historique des attributions` LIKE "%SOLUTIONS30%"
-- OR      `Historique des attributions` LIKE "%DEPART%"
-- OR      `Historique des attributions` LIKE "%ECONOCOM%"
-- OR      `Historique des attributions` LIKE "%CRII%"
-- OR      `Historique des attributions` LIKE "%OPS%"
-- OR      `Historique des attributions` LIKE "%I\&amp;S%" ESCAPE "\"
-- "
--        -- )
-- AND Catégorie LIKE "%Demande de ma%ouveau poste de travail%PC%"
-- ;
-- SELECT "TypeSite", COUNT(`Type`)
-- FROM STATSCOLI
-- WHERE   Entité LIKE "%COLI%"
-- AND `Type` = "Demande"
-- AND     (
        -- `Historique des attributions` LIKE "%CIL%"
-- OR      `Historique des attributions` LIKE "%PLANIF%"
-- OR      `Historique des attributions` LIKE "%SOLUTIONS30%"
-- OR      `Historique des attributions` LIKE "%DEPART%"
-- OR      `Historique des attributions` LIKE "%ECONOCOM%"
-- OR      `Historique des attributions` LIKE "%CRII%"
-- OR      `Historique des attributions` LIKE "%OPS%"
-- OR      `Historique des attributions` LIKE "%I\&amp;S%" ESCAPE "\"
-- "
--        -- )
-- AND Catégorie LIKE "%Demande de ma%ouveau poste de travail%PC%"
-- GROUP BY TypeSite
-- ORDER BY TypeSite
-- ;
-- SELECT CHAR(13);

-- nouvelle section de production des résultats suite au BUG 03/09/2018 - 10:15:41
-- création de la table des résultats
DROP TABLE IF EXISTS resultats ;
CREATE TABLE resultats(
    "stat" TEXT,
    "rang" INTEGER,
    "item" TEXT,
    "nombre" INTEGER
)
;

-- initialisation à zéro de tous les résultats de la table
INSERT INTO resultats VALUES(
    "site",1,"ACP",0
),(
    "site",2,"CLIENT",0
),(
    "site",3,"DOT",0
),(
    "site",4,"PFC",0
),(
    "site",5,"SIEGE/SAV",0
),(
    "site",6,"SOUS-TRAITANT",0
),(
    "site",7,"SPECIFIQUE",0
),(
    "type",1,"Incident",0
),(
    "type",2,"Demande",0
),(
    "FDE",1,"ACP",0
),(
    "FDE",2,"PFC",0
),(
    "FDE",3,"ADM",0
),(
    "activite",1,"Expeditor",0
),(
    "activite",2,"Imprimante",0
),(
    "activite",3,"UC Fixe",0
),(
    "activite",4,"UC Portable",0
),(
    "activite",5,"Autres",0
)
;

-- SELECT * FROM resultats
-- ORDER BY stat
-- -- GROUP BY stat
-- ;

-- actualisation des résultats pour la répartition des dossiers :"
WITH storage AS (
    SELECT
        Type AS TypeDossier ,COUNT(Type) AS NbType
    FROM STATSCOLI
    WHERE Entité LIKE "%COLI%"
    -- AND Type = "Incident"
    AND     (
            `Historique des attributions` LIKE "%CIL%"
        OR  `Historique des attributions` LIKE "%PLANIF%"
        OR  `Historique des attributions` LIKE "%SOLUTIONS30%"
        OR  `Historique des attributions` LIKE "%DEPART%"
        OR  `Historique des attributions` LIKE "%ECONOCOM%"
        OR  `Historique des attributions` LIKE "%CRII%"
        OR  `Historique des attributions` LIKE "%OPS%"
        OR  `Historique des attributions` LIKE "%I\&amp;S%" ESCAPE "\"
    -- " double quote en commentaire afin que la coloration syntaxique retombe sur ses pieds après le ESCAPE
        )
    GROUP BY TypeDossier
)

UPDATE resultats
SET
    nombre=(
        SELECT NbType FROM storage WHERE
        storage.TypeDossier=resultats.item -- AND resultats.stat="type"
)
WHERE resultats.stat="type"
;

-- actualisation des résultats pour les incidents par type de site
WITH storage AS (
    SELECT
        TypeSite,COUNT(Type) AS NbSite
    FROM STATSCOLI
    WHERE Entité LIKE "%COLI%"
    AND Type = "Incident"
    AND     (
            `Historique des attributions` LIKE "%CIL%"
        OR  `Historique des attributions` LIKE "%PLANIF%"
        OR  `Historique des attributions` LIKE "%SOLUTIONS30%"
        OR  `Historique des attributions` LIKE "%DEPART%"
        OR  `Historique des attributions` LIKE "%ECONOCOM%"
        OR  `Historique des attributions` LIKE "%CRII%"
        OR  `Historique des attributions` LIKE "%OPS%"
        OR  `Historique des attributions` LIKE "%I\&amp;S%" ESCAPE "\"
    -- " double quote en commentaire afin que la coloration syntaxique retombe sur ses pieds après le ESCAPE
        )
    GROUP BY TypeSite
)

UPDATE resultats
SET
    nombre=(
        SELECT NbSite FROM storage WHERE
        storage.TypeSite=resultats.item -- AND resultats.stat="site"
)
WHERE resultats.stat="site"
;

-- actualisation des résultats pour les incidents par type d'activité
WITH storage AS (
    SELECT
        Activite,COUNT(Type) AS NbActi
    FROM STATSCOLI
    WHERE Entité LIKE "%COLI%"
    AND Type = "Incident"
    AND     (
            `Historique des attributions` LIKE "%CIL%"
        OR  `Historique des attributions` LIKE "%PLANIF%"
        OR  `Historique des attributions` LIKE "%SOLUTIONS30%"
        OR  `Historique des attributions` LIKE "%DEPART%"
        OR  `Historique des attributions` LIKE "%ECONOCOM%"
        OR  `Historique des attributions` LIKE "%CRII%"
        OR  `Historique des attributions` LIKE "%OPS%"
        OR  `Historique des attributions` LIKE "%I\&amp;S%" ESCAPE "\"
    -- " double quote en commentaire afin que la coloration syntaxique retombe sur ses pieds après le ESCAPE
        )
    GROUP BY Activite
)

UPDATE resultats
SET
    nombre=(
        SELECT NbActi FROM storage WHERE
        storage.Activite=resultats.item -- AND resultats.stat="activite"
)
WHERE resultats.stat="activite"
;

-- actualisation des résultats pour le Fil de l'eau PC par type de site
 WITH storage AS (
   SELECT
        TypeSite,COUNT(Type) AS NbSite
    FROM STATSCOLI
    WHERE Entité LIKE "%COLI%"
    AND Type = "Demande"
    AND     (
            `Historique des attributions` LIKE "%CIL%"
        OR  `Historique des attributions` LIKE "%PLANIF%"
        OR  `Historique des attributions` LIKE "%SOLUTIONS30%"
        OR  `Historique des attributions` LIKE "%DEPART%"
        OR  `Historique des attributions` LIKE "%ECONOCOM%"
        OR  `Historique des attributions` LIKE "%CRII%"
        OR  `Historique des attributions` LIKE "%OPS%"
        OR  `Historique des attributions` LIKE "%I\&amp;S%" ESCAPE "\"
    -- " double quote en commentaire afin que la coloration syntaxique retombe sur ses pieds après le ESCAPE
        )
    AND Catégorie LIKE "%Demande de ma%ouveau poste de travail%PC%"
    GROUP BY TypeSite
)

UPDATE resultats
SET
    nombre=(
        SELECT NbSite FROM storage WHERE
        storage.TypeSite=resultats.item
)
WHERE resultats.stat="FDE"
;


-- correction à zéro des résultats nuls
UPDATE resultats SET nombre=0 WHERE nombre IS NULL ;


-- affichage des résultats
-- select stat,item,nombre from resultats  order by stat,rang;
SELECT "Repartition des dossiers :", SUM(`nombre`) FROM resultats WHERE stat="type";
SELECT item, nombre FROM resultats WHERE stat="type" ORDER BY rang;

SELECT "Incidents par type de site :", SUM(`nombre`) FROM resultats WHERE stat="site";
SELECT item, nombre FROM resultats WHERE stat="site" ORDER BY rang;

SELECT "Incidents par type d'activité :", SUM(`nombre`) FROM resultats WHERE stat="activite";
SELECT item, nombre FROM resultats WHERE stat="activite" ORDER BY rang;

SELECT "Fil de l'eau PC par type de site :", SUM(`nombre`) FROM resultats WHERE stat="FDE";
SELECT item, nombre FROM resultats WHERE stat="FDE" ORDER BY rang;


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
-- .exit
