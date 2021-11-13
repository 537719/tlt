-- SuiviMvt.sql
-- CREATION 11:34 28/09/2020 Marque comme étant vus les mouvements I&S à suivre qui viennent d'être détectés.
-- MODIF    22:32 07/10/2020 Produit un fichier texte des mouvements du dernier jour ouvrable
-- MODIF    12:14 11/12/2020 ramène la création des index en tête de requête et active le timer pour l'exécution des requêtes
-- MODIF	18:41 08/02/2021 rajoute puis supprime un indicateur de progression sur la requête SQLite
-- MODIF    14:13 12/03/2021 Inversion de l'ordre de sortie entre CSV et TXT afin de permettre de pouvoir lire le TXT pendant que le CSV travaille
-- MODIF    14:15 12/03/2021 active la trace afin de permettre de voir qu'il se passe qqch pendant l'exécution des requêtes longues
-- BUG      15:53 17/03/2021 la modif précédente oubliait de quitter le mode box
-- MODIF    15:23 28/04/2021 considère comme étant à suivre les dossiers projets ou spx présents dans la backlog I&S
-- MODIF    15:29 27/05/2021 rajout du rattrapage des dossiers créés puis clos avant que leur passage dans la backlog I&S ne soit détecté
-- MODIF    14:12 18/06/2021 détecte aussi les dossiers de production de serveur, déloc ou PMCTRIG même si pas demandés par un chef de projet
-- MODIF    14:26 01/09/2021 détection des PC Linux 

-- Prérequis :
-- -- Existence de la base TABLE SuiviMvt consignant la liste des mouvements suivis

-- Mise à jour de la table des mouvements suivis
-- Opère sur la surveillance des APT, Dossiers ou colis reçus et sur les dossiers expédiés

CREATE INDEX IF NOT EXISTS k_SuiviMVT_date ON SuiviMVT(DateVu DESC);
CREATE INDEX IF NOT EXISTS k_OFLX_RefClient ON OFLX(RefClient);
CREATE INDEX IF NOT EXISTS k_SORTIES_glpi ON SORTIES(GLPI);
CREATE INDEX IF NOT EXISTS k_SuiviMVT_Donnee_Datevu ON SuiviMVT(Donnee, DateVu);

.changes on

-- 5:23 28/04/2021 Actualisation de la backlog I&S
-- suppose qu'un export de la vue glpi des dossiers affectés à I&S_DEPART soit présent
.print Backlog I&S
DELETE FROM Backlog;
.separator ;
.print .import --skip 1 ../data/glpi.csv Backlog
.import --skip 1 ../data/glpi.csv Backlog
.print backlog to suivimvt
WITH storage AS (
-- dossiers projets et SPX
-- La liste des personnes dont la création de dossier est à surveiler se tient dans la table trigrammes
    SELECT ID,Titre,TRG,
    trim(substr(Emplacement,1,instr(Emplacement,">")-1)) as TypeSite,
    CASE
        WHEN instr(substr(Emplacement,instr(Emplacement,">")+1)," - ") = 0 THEN trim( substr(Emplacement,instr(Emplacement,">")+1))
        ELSE trim(substr(Emplacement,instr(Emplacement,">")+1,instr(substr(Emplacement,instr(Emplacement,">")+1)," - ")-1))
    END Lieu
    from Backlog,Trigrammes WHERE type="Demande" and Demandeur = Nom
)
INSERT INTO SuiviMvt(Donnee,Valeur,DateSurv,Motif) 
    SELECT "Dossier",id,CURRENT_DATE,
    CASE
        WHEN Titre LIKE "%" || Lieu || "%" THEN TRG || " " || Titre
        ELSE TRG || " " || Lieu || " " || Titre
    END Motif
    FROM storage
    WHERE ((select count(*) FROM SuiviMvt WHERE Valeur=storage.ID )=0)
ORDER BY Id
;
WITH storage AS (
-- serveurs, delocs, PMCTRIG hors scanners
-- 14:26 01/09/2021 détection des PC Linux
    SELECT ID,Titre,
    trim(substr(Emplacement,1,instr(Emplacement,">")-1)) as TypeSite,
    CASE
        WHEN instr(substr(Emplacement,instr(Emplacement,">")+1)," - ") = 0 THEN trim( substr(Emplacement,instr(Emplacement,">")+1))
        ELSE trim(substr(Emplacement,instr(Emplacement,">")+1,instr(substr(Emplacement,instr(Emplacement,">")+1)," - ")-1))
    END Lieu
    FROM Backlog WHERE description like "%DELOC%" or description like "%SERVEUR%" or description like "%TRIG%" OR description like "%CHRMETL%" or description like "%LINUX%"
      OR Titre LIKE "%LINUX%"
     AND titre not like "%scanner%" -- sans quoi on a aussi les demandes de scanners
)
INSERT INTO SuiviMvt(Donnee,Valeur,DateSurv,Motif) 
    SELECT "Dossier",id,CURRENT_DATE,
    CASE
        WHEN Titre LIKE "%" || Lieu || "%" THEN  Titre
        ELSE  Lieu || " " || Titre
    END Motif
    FROM storage
    WHERE ((select count(*) FROM SuiviMvt WHERE Valeur=storage.ID )=0)
ORDER BY Id
;

.changes off
.print .read ../bin/backlogsuivi.sql
.read ../bin/backlogsuivi.sql
.changes on

.print surveille entrées :
-- -- surveille entrées :
-- Marque comme étant vu les dossiers/APT/colis surveillés qui apparaissent dans le matériel reçu
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

.print -- -- -- APT
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

.print -- -- -- Colis
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

.print -- -- surveille sortie
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
.print  .read ../bin/sqliteshowsauve.sql
.read ../bin/sqliteshowsauve.sql

.print Sortie TXT
.mode box
-- .trace stderr
-- .progress 6000000 --reset
-- .progress désactivé car dirigé vers le fichier de sortie et non vers la console
-- le .progress 6000000 est calibré pour avoir une dizaines d'étapes de l'indicateur de progression à la date de sa mise en place

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

.mode list
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
.trace off

.print restaure config
.read ../bin/buildsqliteshowrestore.sql
.read ../bin/sqliteshowrestore.sql

