-- SuiviSorties.sql
CREATE VIEW IF NOT EXISTS v_Suivi_Sorties AS
-- d'après v_SuiviMvt du 09:40 02/10/2020
-- Liste des déstockages I&S des 30 derniers jours effectués sur dossier GLPI, avec affichage des numéros de colis
WITH storage AS
     (
               SELECT -- sorties
                         GLPI
                       , DateBL 
                       , Reference
                       , Description AS Designation
                       , NumSerie
                       , sDepot AS Stock
                       , NumeroOFL 
                       , REPLACE(REPLACE(REPLACE(numeros_de_colis,"[",""),"]",""),","," ") AS Transport
                       , sorties.Societe  AS Societe
                       , SORTIES.TagIS
               FROM
                         SORTIES
                       , v_SORTIES
                         LEFT JOIN
                                   OFLX
                                   ON
                                             OFLX.refclient = GLPI
               WHERE
                             length(CAST(GLPI AS INTEGER))=10
                         AND SORTIES.TagIS=v_SORTIES.TagIS
                         -- and datebl > date("now","-2 day") -- uniquement pour debug
     )
SELECT DISTINCT
         COUNT(TagIS)  AS Qte -- nombre de lignes concernées par le mouvement
       , *
FROM
         storage
GROUP BY
         GLPI
       , Reference  -- une ligne par dossier et référence d'article différente
;

.print configure
.read ../bin/sqliteshowsauve.sql

.separator ;
.header on
.print Sortie CSV

CREATE VIEW IF NOT EXISTS vv_Suivi_Sorties_1mois AS
    SELECT               GLPI
                       , DateBL 
                       , Societe
                       , Qte
                       , Reference
                       , Designation
                       , NumSerie
                       , Transport
                       , TagIS
                       , NumeroOFL 

    FROM     v_Suivi_Sorties
    WHERE    Datebl >= DATE("now","-1 month") 
    ORDER BY Datebl DESC,GLPI DESC
;
.once ../work/SuiviSorties.csv
SELECT * FROM vv_Suivi_Sorties_1mois;

.print restaure config
.read ../bin/buildsqliteshowrestore.sql
.read ../bin/sqliteshowrestore.sql
