-- majdbIS.sql
-- CREATION 10:41 27/05/2020 actualise la BDD SQLite des données I&S d'après les derniers exports réalisés
-- BUG      14:30 29/05/2020 rajoute la purge des tables de stock et de catalogue avant import
-- MODIF    16:34 10/06/2020 active l'import des OFLX et des réceptions de matériel

.separator ;
delete from catalogue;
.import is_catalogue_dernier.csv catalogue
.import is_in_dernier.csv Entrees
.import is_OFLX_dernier.csv OFLX
.import is_out_dernier.csv Sorties
delete from stock;
.import is_stock_dernier.csv Stock
.import TEexport_dernier.csv histostock

