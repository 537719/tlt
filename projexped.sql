-- projexped.sql
-- 20/09/2018 - 15:10:07

-- indique combien d'articles indiques ont étés envoyés sur un même site/dossier/jour donné
-- transforme un fichier ayant ia structure suivante
    -- GLPI;Date BL;Ville L;Reference;Description
    -- 1808200126;06/09/2018;NEUVILLE SUR SARTHE;CHR10NP1ER;UC HP PRODESK 600 G3 SMALL FORM FACTOR PC WIN 10
    -- 1808200126;06/09/2018;NEUVILLE SUR SARTHE;CHR10NP1ER;UC HP PRODESK 600 G3 SMALL FORM FACTOR PC WIN 10
    -- 1808200126;06/09/2018;NEUVILLE SUR SARTHE;CHR10NP1ER;UC HP PRODESK 600 G3 SMALL FORM FACTOR PC WIN 10
    -- 1808200126;06/09/2018;NEUVILLE SUR SARTHE;CHR25NP1FJ;ECRAN 22" HP E223
    -- 1808200126;06/09/2018;NEUVILLE SUR SARTHE;CHR25NP1FJ;ECRAN 22" HP E223
    -- 1808200126;06/09/2018;NEUVILLE SUR SARTHE;CHR25NP1FJ;ECRAN 22" HP E223
    -- 1808200126;06/09/2018;NEUVILLE SUR SARTHE;CHR25NP1FJ;ECRAN 22" HP E223
    -- 1808200126;06/09/2018;NEUVILLE SUR SARTHE;CHR47NP1F5;CARTE WIFI INTEL AVEC ANTENNE EXTERNE ref 7265802.11AC PCIe X1
    -- 1808200126;06/09/2018;NEUVILLE SUR SARTHE;CHR47NP1F5;CARTE WIFI INTEL AVEC ANTENNE EXTERNE ref 7265802.11AC PCIe X1
    -- 1808200126;06/09/2018;NEUVILLE SUR SARTHE;CHR47NP1F5;CARTE WIFI INTEL AVEC ANTENNE EXTERNE ref 7265802.11AC PCIe X1
-- en
    -- GLPI;Date BL;Ville L;Reference;Description
    -- 1808200126;06/09/2018;NEUVILLE SUR SARTHE;3;CHR10NP1ER;UC HP PRODESK 600 G3 SMALL FORM FACTOR PC WIN 10
    -- 1808200126;06/09/2018;NEUVILLE SUR SARTHE;4;CHR25NP1FJ;ECRAN 22" HP E223
    -- 1808200126;06/09/2018;NEUVILLE SUR SARTHE;3;CHR47NP1F5;CARTE WIFI INTEL AVEC ANTENNE EXTERNE ref 7265802.11AC PCIe X1

-- Destiné à être invoqué au travers de SQLITE en ligne de commande
-- sqlite3 <projexped.sql >projexped.html

-- modif 21/09/2018 - 13:38:31 produit une sortie sous forme de tableau HTML plutôt que du csv
-- bug   21/09/2018 - 15:00:08 ajout du champ GLPI dans la clause GROUP faute de quoi les sous-totaux étaient incorrects
-- modif 21/09/2018 - 15:00:08 modification cosmétique des noms de champs via l'utilisation d'alias
-- modif 11/10/2018 - 15:47:38 meilleure présentation du tableau html généré en sortie

.separator ;
.import projexped.csv database
.separator " "

SELECT '<table border="1px" cellspacing="1px" cellpadding="1px" > ';
SELECT '<caption><b>Produits sortis sur les projets en cours au ',strftime('%d/%m/%Y','now'),'<hr></caption>';

.headers on
.mode html
SELECT GLPI, "Date BL" AS Date, "Ville L" AS Ville ,count(Reference) AS Qte,Reference,Description FROM DATABASE GROUP BY Reference,GLPI ORDER BY Ville,GLPI;
.headers off
.mode csv
SELECT '</table>';
