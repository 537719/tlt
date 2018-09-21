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
.separator ;

.import projexped.csv database

.headers on

SELECT GLPI, "Date BL", "Ville L",count(Reference),Reference,description FROM DATABASE GROUP BY Reference ORDER BY "Ville L",GLPI;