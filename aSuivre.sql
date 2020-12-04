--- aSuivre.sql
-- CREATION 13:19 30/09/2020 Importe les nouveaux mouvements à surveiller
-- PREREQUIS    sandbox.db : bdd de suivi de l'activité I&S
--              aSuivre.csv : donnée de suvi générée par le script Suivre.cmd

-- .show
-- sauvegarde du statut des paramètres
.once ../work/sqliteshow.txt
.show

-- application des paramètres nécessaires à ce script
.separator ;
.headers on
.mode column

-- début du travail proprement dit
.import ../work/aSuivre.csv SuiviMvt

.echo off
SELECT "Nouveaux mouvements à suivre";
SELECT * FROM SuiviMVT WHERE DateSurv = DATE("now");

-- restauration des paramètres précédemment sauvegardés
.separator :
.import ../work/sqliteshow.txt v_sqliteshow
.headers off
.once ../bin/sqliteshowrestore.sql
select "." || ltrim(replace(donnee,"col","")),valeur from sqliteshow where substr(donnee,9) in ("mode","ator","idth","ders","echo") and donnee not like "%row%";
.read ../bin/sqliteshowrestore.sql
-- .show