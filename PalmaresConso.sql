-- 01/07/2020  12:01 création de 1976 PalmaresConso.sql
-- Sort la liste des 10 produits les plus déstockés par I&S sur la semaine, le mois et l'année écoulés

.mode list
.output PalmaresConso.txt
SELECT "Produits les plus consommés sur la semaine du " || strftime("%d/%m/%Y",date("now","-19 hours","start of day","-7 days")) || " au " || strftime("%d/%m/%Y",date("now","-9 hours","start of day"));

.mode column
.width -5,3,3,50

SELECT
         count(sorties.tagis) as NB
       , v_sorties.bu
       , v_sorties.produit
       , sorties.description
FROM
         sorties
       , v_sorties
WHERE
         sorties.tagis  =v_sorties.tagis
         and surfamille >"0"
         and surfamille <"A"
         and datebl    >= date("now","-19 hours","start of day","-7 days")
GROUP BY
         v_sorties.bu
       , produit
ORDER BY
         NB DESC LIMIT 10
;

.mode list

SELECT CHAR(13) || CHAR(10) || "Produits les plus consommés sur le mois du " || strftime("%d/%m/%Y",date("now","-19 hours","start of day","-1 month")) || " au " || strftime("%d/%m/%Y",date("now","-19 hours","start of day"));

.mode column
.width -5,3,3,50

SELECT
         count(sorties.tagis) as NB
       , v_sorties.bu
       , v_sorties.produit
       , sorties.description
FROM
         sorties
       , v_sorties
WHERE
         sorties.tagis  =v_sorties.tagis
         and surfamille >"0"
         and surfamille <"A"
         and datebl    >= date("now","-19 hours","start of day","-1 month")
GROUP BY
         v_sorties.bu
       , produit
ORDER BY
         NB DESC LIMIT 10
;

.mode list

SELECT CHAR(13) || CHAR(10) || "Produits les plus consommés sur l'année écoulée entre le " || strftime("%d/%m/%Y",date("now","-19 hours","start of day","-1 year")) || " et le " || strftime("%d/%m/%Y",date("now","-19 hours","start of day"));

.mode column
.width -5,3,3,50

SELECT
         count(sorties.tagis) as NB
       , v_sorties.bu
       , v_sorties.produit
       , sorties.description
FROM
         sorties
       , v_sorties
WHERE
         sorties.tagis  =v_sorties.tagis
         and surfamille >"0"
         and surfamille <"A"
         and datebl    >= date("now","-19 hours","start of day","-1 year")
GROUP BY
         v_sorties.bu
       , produit
ORDER BY
         NB DESC LIMIT 10
;
.output
