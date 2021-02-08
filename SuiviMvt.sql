-- SuiviMvt.sql
-- CREATION 11:34 28/09/2020 Marque comme étant vus les mouvements I&S à suivre qui viennent d'être détectés.
-- MODIF    22:32 07/10/2020 Produit un fichier texte des mouvements du dernier jour ouvrable
-- MODIF    12:14 11/12/2020 ramène la création des index en tête de requête et active le timer pour l'exécution des requêtes

-- Prérequis :
-- -- Existence de la base TABLE SuiviMvt consignant la liste des mouvements suivis

-- Mise à jour de la table des mouvements suivis
-- Opère sur la surveillance des APT, Dossiers ou colis reçus et sur les dossiers expédiés

CREATE INDEX IF NOT EXISTS k_SuiviMVT_date ON SuiviMVT(DateVu DESC);
CREATE INDEX IF NOT EXISTS k_OFLX_RefClient ON OFLX(RefClient);
CREATE INDEX IF NOT EXISTS k_SORTIES_glpi ON SORTIES(GLPI);
CREATE INDEX IF NOT EXISTS k_SuiviMVT_Donnee_Datevu ON SuiviMVT(Donnee, DateVu);

-- -- surveille entrées :
-- Marque comme étant vu les dossiers/APT/colis surveillés qui apparaissent dans le matériel reçu
.changes on
.print Mise à jour
-- -- -- dossiers
WITH storage AS -- -- -- Vérification si un numéro de dossier surveillé apparait dans la liste des réceptions
     (
              SELECT
                       DATE("now") AS DateVu
                     ,"Dossier"    AS Donnee
                     , Valeur
                     , DateSurv
                     , Motif
              FROM
                       SuiviMvt
                     , Entrees
                     , v_Entrees
              WHERE
                       DateVu                    =""
                       AND Donnee                ="Dossier"
                       AND v_Entrees.DateEntree >= DateSurv
                       AND Entrees.TagIS         =v_Entrees.TagIS
                       AND RefAppro           LIKE "%"
                                || Valeur
                                || "%"
              GROUP BY
                       Valeur
     )
     REPLACE
INTO
     SuiviMvt
     (
          DateVu
        , Donnee
        , Valeur
        , DateSurv
        , Motif
     )
SELECT *
FROM
       storage
;

-- -- -- APT
WITH storage AS -- -- -- Vérification si un numéro d'APT surveillé apparait dans la liste des réceptions
     (
              SELECT
                       DATE("now") AS DateVu
                     ,"Livraison"  AS Donnee
                     , Valeur
                     , DateSurv
                     , Motif
             FROM
                       SuiviMvt
                     , Entrees
                     , v_Entrees
              WHERE
                       DateVu                    =""
                       AND Donnee                ="Livraison"
                       AND v_Entrees.DateEntree >= DateSurv
                       AND Entrees.TagIS         =v_Entrees.TagIS
                       AND APT                LIKE "%"
                                || Valeur
                                || "%"
              GROUP BY
                       Valeur
     )
     REPLACE
INTO
     SuiviMvt
     (
          DateVu
        , Donnee
        , Valeur
        , DateSurv
        , Motif
     )
SELECT *
FROM
       storage
;

-- -- -- Colis
WITH storage AS -- -- -- Vérification si un numéro de colis surveillé apparait dans la liste des réceptions
     (
              SELECT
                       DATE("now") AS DateVu
                     ,"Colis"      AS Donnee
                     , Valeur
                     , DateSurv
                     , Motif
              FROM
                       SuiviMvt
                     , Entrees
                     , v_Entrees
              WHERE
                       DateVu                    =""
                       AND Donnee                ="Colis"
                       AND v_Entrees.DateEntree >= DateSurv
                       AND Entrees.TagIS         =v_Entrees.TagIS
                       AND BonTransport       LIKE "%"
                                || Valeur
                                || "%"
              GROUP BY
                       Valeur
     )
     REPLACE
INTO
     SuiviMvt
     (
          DateVu
        , Donnee
        , Valeur
        , DateSurv
        , Motif
     )
SELECT *
FROM
       storage
;

-- -- surveille sortie
-- Marque comme étant vu les dossiers surveillés qui apparaissent dans le matériel expédiés

UPDATE
       SuiviMvt
SET    DateVu = DATE("now")
WHERE
       DateVu    =""
       AND Donnee="Dossier"
       AND Valeur in
       (
              SELECT
                     GLPI
              FROM
                     vv_sorties
                   , SuiviMvt
              WHERE
                     glpi        =Valeur
                     AND datebl >= DateSurv
       )
;
.changes off
.print Restitution des données


CREATE VIEW IF NOT EXISTS v_SuiviMvt AS
-- 11:26 28/09/2020 Listage des mouvements I&S à suivre qui viennent d'être détectés comme étant effectués.
-- Doit être exécuté aussitôt après l'exécution du script SuiviMvt.sql
-- 15:36 29/09/2020 MODIF : Supprime les crochets et virgules dans les numéros des colis expédiés (pas besoin de le faire dans les colis reçus)
-- 14:06 01/10/2020 Rajoute la date de début de surveillance, affiche les mouvements surveillés mais pas encore vus et les mouvements vus depuis moins d'un mois (au lieu de juste la journée précédemment)
-- 09:40 02/10/2020 suppression de la clause "group by" dans le suivi des sorties car elle faussait les quantités affichées
WITH storage AS
     (
               SELECT -- sorties
                         Donnee
                       , Valeur
                       , DateBL AS DateMvt
                       , DateSurv
                       , Reference
                       , Description AS Designation
                       , NumSerie
                       , sDepot AS Stock
                       -- , NumeroOFL aucune utilité
                       , REPLACE(REPLACE(REPLACE(numeros_de_colis,"[",""),"]",""),","," ") AS Transport
                       , sorties.Societe  AS Societe
                       , SORTIES.TagIS
                       , Motif
               FROM
                         SORTIES
                       , SuiviMvt
                       , v_SORTIES
                         LEFT JOIN
                                   OFLX
                                   ON
                                             OFLX.refclient = Valeur
               WHERE
                             DateVu    >=DATE("now","-1 month")
                         AND Donnee="Dossier"
                         AND Valeur=glpi
                         AND SORTIES.TagIS=v_SORTIES.TagIS
               -- GROUP BY -- la présence de cette clause perturbe l'affichage des quantités en sortie
                         -- Valeur
                       -- , Reference
               -- ORDER BY Valeur
               -- ;
               UNION
               SELECT -- -- -- dossiers (reste quelques cas de doublons)
                      -- count(Entrees.TagIS) AS Nb,
                       Donnee
                    , Valeur
                    , DATE(v_Entrees.DateEntree) AS DateVu
                    , DateSurv
                    , Entrees.Reference
                    , Libelle
                    , Numero_Serie
                    , Projet
                    -- , APT doublon avec la colonne "valeur" si on cherche sur APT, inutile sinon
                    , BonTransport
                    , RefAppro
                    , Entrees.TagIS AS TagIS
                    , Motif
               FROM
                      SuiviMvt
                    , Entrees
                    , v_Entrees
               WHERE
                         
                          DateVu    >=DATE("now","-1 month")
                      AND Donnee                ="Dossier"
                      AND v_Entrees.DateEntree >= datesurv
                      AND Entrees.TagIS         =v_Entrees.TagIS
                      AND RefAppro           like "%"
                             || Valeur
                             || "%"
               -- GROUP BY Valeur,Numero_Serie
               -- ;
               UNION
               SELECT -- -- -- APT
                      -- count(Entrees.TagIS) AS Nb,
                      Donnee
                    , Valeur
                    , date(v_Entrees.DateEntree) AS DateVu
                    , DateSurv
                    , Entrees.Reference
                    , Libelle
                    , Numero_Serie
                    , Projet
                    -- , APT doublon avec la colonne "valeur" si on cherche sur APT, inutile sinon
                    , BonTransport
                    , RefAppro
                    , Entrees.TagIS AS TagIS
                    , Motif
               FROM
                      SuiviMvt
                    , Entrees
                    , v_Entrees
               WHERE
                          DateVu    >=DATE("now","-1 month")
                      AND Donnee                ="Livraison"
                      AND v_Entrees.DateEntree >= datesurv
                      AND Entrees.TagIS         =v_Entrees.TagIS
                      AND APT                like "%"
                             || Valeur
                             || "%"
               -- GROUP BY Valeur
               -- ;
               UNION
               SELECT -- -- Colis
                        -- count(v_Entrees.TagIS) AS Nb,
                        Donnee
                      , Valeur
                      , date(v_Entrees.DateEntree) AS DateVu
                      , DateSurv
                      , Entrees.Reference
                      , Libelle
                      , Numero_Serie
                      , Projet
                      -- , APT doublon avec la colonne "valeur" si on cherche sur APT, inutile sinon
                      , BonTransport
                      , RefAppro
                      , Entrees.TagIS AS TagIS
                      , Motif
               FROM
                        SuiviMvt
                      , Entrees
                      , v_Entrees
               WHERE
                            DateVu    >=DATE("now","-1 month")
                        AND Donnee                ="Colis"
                        AND v_Entrees.DateEntree >= datesurv
                        AND Entrees.TagIS         =v_Entrees.TagIS
                        AND BonTransport       like "%"
                                 || Valeur
                                 || "%"
               GROUP BY
                        Entrees.TagIS
                        -- GROUP BY Valeur
                        -- ;
               UNION
               SELECT
                         Donnee
                       , Valeur
                       , "N/A"  AS DateVu
                       , DateSurv
                       , ""     AS Reference
                       , ""     AS Designation
                       , ""     AS NumSerie
                       , ""     AS Stock
                       , ""     AS Transport
                       , ""     AS Societe
                       , ""     AS TagIS
                       , Motif 
               FROM SuiviMvt
               WHERE DateVu=""
     )
SELECT DISTINCT
         (COUNT(TagIS) * (DateMvt >"")) AS Qte -- nombre de lignes concernées par le mouvement
       , *
FROM
         storage
         -- WHERE Donnee="Dossier"
GROUP BY
         Valeur
       , Reference  -- une ligne par dossier/colis/apt et référence d'article différente
;

.print configure
.read ../bin/sqliteshowsauve.sql

.separator ;
.header on
.print Sortie CSV

CREATE VIEW IF NOT EXISTS vv_SuiviMvt_1mois AS
    SELECT  * 
    FROM    v_SuiviMvt
    WHERE   DateMvt >= DATE("now","-1 month") 
    OR      DateMvt="N/A"
    ORDER BY DateMvt DESC,DateSurv DESC
;
.once ../work/suivimvt.csv
SELECT * FROM vv_SuiviMvt_1mois;

.print Sortie TXT
.mode box

CREATE VIEW IF NOT EXISTS vv_SuiviMvt_1jour AS
    WITH STORAGE AS ( -- Détermination de la date à partir de laquelle on recherche les mouvements
        -- Le SELECT CASE en commentaire produit les données du dernier jour ouvrable écoulé compte tenu du fait que les données sont disponibles à 19h
        -- SELECT CASE
            -- WHEN (strftime("%w",date("now")) >="1" and strftime("%w",date("now")) <"6" and strftime("%H",datetime("now","localtime") >= "19")) THEN date("now")           -- lundi à vendredi après 19h => jour même
            -- WHEN (strftime("%w",date("now")) >="2" and strftime("%w",date("now")) <"6" and strftime("%H",datetime("now","localtime") <  "19")) THEN date("now","-1 day")  -- mardi à vendredi avant 19h => la veille
            -- WHEN (strftime("%w",date("now")) = "1" and strftime("%H",datetime("now","localtime") <  "19")) THEN date("now","-3 days")      -- lundi avant 19h => 3 jours avant
            -- ELSE date("now","-" || (strftime("%w",date("now"))/6)-2 || "days")      --  samedi ou dimanche quelle que soit l'heure => vendredi précédent
        -- END querydate
        
        -- Le SELECT ci-dessous produit les donnés les plus récentes que l'on a
        SELECT max(datevu) AS querydate from suivimvt
        -- La préférence entre les deux, outre la simplicité, tient au fait que le cas le plus compliqué ne donne rien s'il n'y a rien ce jour précis alors que le plus simple donne toujiurs quelque chose*
    )
    SELECT  Valeur,printf("%3d",Qte) AS Qté,Substr(Reference,1,10) AS Référence,substr(Designation,1,40) AS Désignation,substr(Stock,instr(stock," ")+1) AS Stock,
        CASE
            WHEN Donnee="Dossier" THEN Transport
            ELSE Societe
        END
    ,
    Motif
    FROM    v_SuiviMvt,storage
    WHERE   DateMvt >= QueryDate AND DateMvt like "____-__-__"
    ORDER BY DateMvt DESC,DateSurv DESC
;
.timer on
.once ../work/lastmvt.txt
SELECT * FROM vv_SuiviMvt_1jour;

.print restaure config
.read ../bin/buildsqliteshowrestore.sql
.read ../bin/sqliteshowrestore.sql

