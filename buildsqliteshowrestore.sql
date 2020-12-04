-- buildsqliteshowrestore.sql
-- CREATION 19:54 02/10/2020 Construit le script de restauration de l'état du show de sqlite après qu'il ait été sauvegardé par sqliteshowsauve.sql
--                           Exécuter ensuite le script ./bin/sqliteshowrestore.sql
-- BUG      22:28 07/10/2020 virgule au lieu de concaténation entre le point et la valeur
.mode list
.separator \t
.headers off
.once ../bin/sqliteshowrestore.sql
select "." || replace (trim(donnee),"col","") || valeur from sqliteshow where substr(donnee,length(donnee)-3,4) in ("ders","idth","ator","mode") and donnee not like "row%"
;
.read ../bin/sqliteshowrestore.sql