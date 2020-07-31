-- IncProdIS.sql
-- CREATION     15:48 mardi 4 février 2020 pour usage dans SQLite
-- FONCTION     Ventilation des erreurs de production I&SAMPLE
-- ENTREE         fichier glpi.csv obtenu d'après la requête suivante :
--                          "Tâches - Date" après "01-01-2020 00:00"
--                    ET  "Tâches - Date" avant "01-02-2020 00:00"
--                    ET  "Tâches - Description" contient "isi-"
-- ATTENTION : ne pas prendre de période à cheval sur plusieurs mois
-- "isi-" est le préfixe des codes indiqués par I&S en cas d'erreur de production
--
-- SORTIE        fichier "resultat.csv" comportant une ligne par code erreur, avec indication du mois et du nombre d'occurences
-- PREREQUIS fichier codeserreur.csv listant les codes d'erreur valides
-- DIFFICULTÉ produire un résultat (0) pour les codes d'erreur n'apparaissant pas sur la période donnée.

.separator ;
drop table if exists IncProdIS;
.import glpi.csv IncProdIS

drop table if exists codeserreur;
CREATE TABLE codeserreur(
    code text,
    sujet text,
    description text,
    abrege text
);

.import codeserreur.csv CodesErreur

-- alter table codeserreur add column(abrege text);
update codeserreur set abrege=substr(code,1,5);

.header on
.output resultats.csv
with storage as (
    select code,abrege from codeserreur
)
select 
    strftime(
        "%Y-%m-%d",
        date( -- date des tâches reportées au dernier jour du mois
            substr(max("Tâches - Date"),7,4) || "-" || substr(max("Tâches - Date"),4,2) || "-" || substr(max("Tâches - Date"),1,2)
        )
    ) as Jour
    ,code
    ,max(0,count("ID")) as Nombre 
from incprodis,storage 
where "Tâches - Description" LIKE ("%" || storage.abrege || "%") 
group by code 
order by code
; -- attention, on peut avoir des codes avec des dates différentes

.output
drop table if exists resultats;
.import resultats.csv resultats

.header off
.output resultats.csv
with storage as (
    select Jour from resultats group by Jour -- attention, produit un résultat par jour pour lequel on a une stat
)
SELECT 
         storage.Jour,c.code,0
FROM codeserreur c, storage
LEFT JOIN resultats r USING(code)
WHERE r.code IS NULL
group by code -- on n'a plus qu'une seule date maintenant
;
.output
.import resultats.csv resultats

.header off
.output resultats.csv
select Jour, replace(code,"-",";;") as Erreur, Nombre from resultats;
-- on remplace le "-" par deux ";;" dans les codes en sortie afin d'avoir un format compatible avec le script "transpose .awk" lancé à la suite pour mettre les lignes en colonnes.

.output nomresultat.txt
select 
    strftime(
        "%Y-%m-%d",
        date( -- date des tâches reportées au dernier jour du mois
            substr(max("Tâches - Date"),7,4) || "-" || substr(max("Tâches - Date"),4,2) || "-" || substr(max("Tâches - Date"),1,2)
        )
    ) as Jour
from incprodis;
