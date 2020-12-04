-- sqliteshowsauve.sql
-- CREATION 19:53 02/10/2020 Sauvegarde le statut de "show" de la base sqlite en cours
--                           Exécuter buildsqliteshowrestore.sql pour construire le script de restauration puis exécuter sqliteshowrestore.sql pour restaurer l'état

.once ../work/sqliteshow.txt
.separator :

CREATE VIEW IF NOT EXISTS v_sqliteshow as 
select donnee,valeur from sqliteshow
/* v_sqliteshow(Donnee,valeur) */;
CREATE TRIGGER IF NOT EXISTS T_show
   INSTEAD OF INSERT ON v_sqliteshow
BEGIN
   REPLACE into sqliteshow(valeur,donnee) values(new.valeur,new.donnee)
   ;
END;
.import ../work/sqliteshow.txt v_sqliteshow
