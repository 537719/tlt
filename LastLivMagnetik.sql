-- lastlivmagnetik.sql
-- CREATION 11:11 27/05/2020 exporte le détail des derniers envois d'I&S vers le siège
-- MODIF    12:28 24/06/2020 rajoute les numéros de colis
-- MODIF    16:10 26/06/2020 rajoute une sortie sur 1 mois au format CSV pour alimentation du quipo

.mode column
.width 10,2,10,20,10,50
.header on
.output lastlivmagnetik.txt
select  glpi
       , nb
       , datebl
       , nomclient
       , reference
       , description
       , numeros_de_colis
from v_LastLivMagnetik;
.mode list
.header off
select lien from v_LastLivMagnetik group by glpi;
.output
.mode list
.separator ;
.header on
.output livmgk.csv
select * from v_1moisLivMagnetik;
.output
