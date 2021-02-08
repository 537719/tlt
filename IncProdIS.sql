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

-- BUG      14:55 28/02/2020 corrige la définition de champ de la base des codes erreur afin d'éviter un message d'erreur inutile à l'exécution
-- BUG      09:10 27/03/2020 erreur dans la contrainte check sur la table des codes erreur
-- MODIF    09:10 27/03/2020 adaptation au nouveau format de date utilisé par glpi
-- BUG      21:10 25/09/2020 suppression de l'export/import temporaire des résultats intermédiaires et correction d'erreurs de sortie
-- MODIF    11:36 13/01/2021 remplace la vérification de présence de "ISI-" par "ISI" car il arrive que le signe "-" ne soit pas saisi

--inchangé 21:10 25/09/2020
.separator ;
drop table if exists IncProdIS;
.import glpi.csv IncProdIS

-- rectification des dates du format aaaa-mm-jj  hh:mm au format aaaa-mm-jj hh:mm
update IncProdIS set "Tâches - Date" = substr("Tâches - Date",7,4) || "-" || substr("Tâches - Date",4,2)  || "-" || substr("Tâches - Date",1,2) || substr("Tâches - Date",11,6) where "Tâches - Date" like "__-__-____ __:__" ;


drop table if exists codeserreur;
CREATE TABLE codeserreur(
    code text,
    sujet text,
    description text
    CHECK(substr(code,1,4)="ISI")
    -- le check est là pour éviter d'insérer la ligne de titre comme faisant partie des données
);

.import codeserreur.csv CodesErreur

alter table codeserreur add column abrege text;
update codeserreur set abrege=substr(code,1,5);


-- nouveau 21:10 25/09/2020
drop table if exists Resultats;
CREATE TABLE Resultats(
    Jour TEXT NOT NULL,
    Code TEXT NOT NULL,
    Nombre INTEGER NOT NULL DEFAULT 0
    CHECK( Code like "ISI%")
);
CREATE UNIQUE INDEX k_ISIr on Resultats(Jour,Code);

with storage as (
    select date(max("Tâches - Date")) as maxdate 
    from incprodis
) 
replace into Resultats(Jour,Code) 
select maxdate,code
from storage,codeserreur
;


with storage as (
    select codeserreur.code,abrege,jour 
    from codeserreur,Resultats 
    where Resultats.code=codeserreur.code
) 
replace into Resultats(Jour,Code,Nombre) 
select Jour,storage.code,count(id) 
from storage,incprodis 
where "Tâches - Description" LIKE ("%" || storage.abrege || "%") 
group by storage.abrege
;

--inchangé 21:10 25/09/2020
.output resultats.csv
select Jour, replace(code,"-",";;") as Erreur, Nombre from resultats;
-- on remplace le "-" par deux ";;" dans les codes en sortie afin d'avoir un format compatible avec le script "transpose .awk" lancé à la suite pour mettre les lignes en colonnes.

-- simplifié 21:10 25/09/2020
.header off
.output nomresultat.txt
select jour from resultats group by jour ;
.output

