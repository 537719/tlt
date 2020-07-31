-- etatstock.sql
-- Importe le dernier export récapitulatif des stocks
-- Prérequis :
-- dossier ./stock contenant le dernier fichier TEexport_AAAAMMJJ.csv
-- présence d'un fichier texte nommé dernier_export.txt produit par dernieresynthesestock.cmd
-- Table SQLite Histostock structurée tel que le fichier TEexport_AAAAMMJJ avec en plus une colonne de date
-- CREATION 13:32 18/05/2020

DELETE FROM Histostock WHERE dateimport IS NULL;
DELETE FROM dernieredate;
-- dernieredate = table contenant le nom de la dernière synthèse de stock trouvée
.import dernier_export.txt Histostock
