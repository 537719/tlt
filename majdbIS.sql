-- majdbIS.sql
-- CREATION 10:41 27/05/2020 actualise la BDD SQLite des données I&S d'après les derniers exports réalisés
-- BUG      14:30 29/05/2020 rajoute la purge des tables de stock et de catalogue avant import
-- MODIF    16:34 10/06/2020 active l'import des OFLX et des réceptions de matériel
-- MODIF    10:42 20/12/2020 rajoute l'import de l'archivage des stocks et du catalogue
-- MODIF    16:08 01/02/2021 gère un backup du stock via une nouvelle base stockbackup et deux triggers, voir plus tard si également nécessaire pour d'autres tables

.separator ;
delete from catalogue;
.import is_catalogue_dernier.csv catalogue
.import is_in_dernier.csv Entrees
.import is_OFLX_dernier.csv OFLX
.import is_out_dernier.csv Sorties
delete from stock; -- un trigger recopie dans stockbackup chaque enregistrepment supprimé de stock
.import is_stock_dernier.csv Stock
delete from stockbackup where lastupdate < (select max(lastupdate) from stockbackup); -- ne garde dns le backup que la dernière instance de chaque produit présent en stock
.import TEexport_dernier.csv histostock
.import catarchive.csv catarchive
.import stockarchive.csv stockarchive

