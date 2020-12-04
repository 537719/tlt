CREATE VIEW V_DossierValide AS
-- Vérifie si la valeur du champ GLPI dans un enregistrement de déstockage correspond à un numéro de dossier valide ou pas
-- -- C'est une information essentielle pour déterminer le type de sortie, utilisée en aval par la vue vv_Sorties
-- En profite pour produire également les informations utiles à vv_Sorties sans avoir à réinterroger la base SORTIES soit :
-- -- Informations sur le destinataires (servent à trancher pour déterminer certains types de sortie)
-- -- Eclatement de la référence en chacun de ses composants et Conversion de la date de sortie au format standard
-- -- Informations de suivi et croisement tels que tagis et numero d'ofl
-- S'appuie sur la table SORTIES uniquement
-- Historique
-- -- 10:46 24/09/2020 Ecriture dans la forme actuelle
-- -- 11:11 24/09/2020 privilégie l'information d'appartenance plutôt que la référence pour déterminer la BU afin de l'afficher correctement dans le cas des références génériques
-- -- -- sans cela IMPRIMANTE donnait IMP au lieu de la bonne BU
-- -- 19:25 15/10/2020 rajout du numéro de série

SELECT
    CASE
        WHEN glpi LIKE "IM_______" THEN substr(glpi,3,7) -- Ancien incident SM7
        WHEN glpi LIKE "RM______-___" THEN substr(glpi,3,6) || substr(glpi,10,3) -- Ancienne demande SM7
        WHEN glpi LIKE "RM_____-___" THEN substr(glpi,3,6) || substr(glpi,10,3) -- Ancienne demande SM7 avec oubli du zéro initial
        -- WHEN length(glpi)<9 THEN 0  -- Référence numérique qui ne peut pas être un numéro de dossier -- activer cette clause invalide les dossiers mal saisis
        ELSE CAST(substr(glpi,1,10) as integer)
    END Dossier
    -- permet de considérer comme valides les cas où le numéro de dossier est complété par une mention textuelle

,   glpi,priorite,provenance,reference,societe,cp,ville,tagis,numeroofl,numserie

,   CASE
        WHEN "Date BL"="" THEN date(substr(datecreation,7,4) || "-" || substr(datecreation,4,2) || "-" || substr(datecreation,1,2))
        ELSE date(substr("Date BL",7,4) || "-" || substr("Date BL",4,2) || "-" || substr("Date BL",1,2))
        -- Si la date d'expéditon est absente, on remplace par celle de création (cas rare mais présent dans des enregistrements anciens
    END DateBL
    -- Eclatement de la référence en chacun de ses composants
,   CASE -- Détermination de la BU
        WHEN BU LIKE "CHR%" THEN "CHR"
        WHEN BU LIKE "COL%" THEN "CLP"
        WHEN BU LIKE "TEL%" THEN "ALT"
        ELSE substr(reference,1,3)
    END BU
-- ,       substr(reference,1,3) AS BU
,       substr(reference,4,1) AS "SurFamille"
,       substr(reference,5,1) AS "Sousfamille"
,       substr(reference,4,2) AS "Famille"
,       substr(reference,6,1) AS "Etat"
,       substr(reference,7,1) AS "Stock"
,       substr(reference,8,3) AS "Produit"
from sorties
;

CREATE VIEW vv_Sorties AS
-- Synthèse des informations significatives sur les infos de stock :
-- -- Eclatement de la référence en chacun de ses composants
-- -- Conversion de la date de sortie au format standard
-- -- Calcul du type de sortie parmi les possibilités suivantes :
-- -- -- INC Incident
-- -- -- DEM Demande
-- -- -- RMA Envoi en maintenance
-- -- -- DEL Mise en destruction
-- -- -- ATL Traitement atelier
-- -- -- IND Cause indéterminée (ne devrait jamais se produire)
-- S'appuie sur :
-- -- Table SORTIES
-- -- Vue   V_DossierValide
-- Historique
-- -- 10:46 24/09/2020 Ecriture dans la forme actuelle
-- -- 19:28 15/10/2020 Rajout du numéro de série

SELECT glpi, datebl
,   CASE -- Détermination du type de sortie
        -- cas indépendants de la manière dont est formé le numéro de dossier
        WHEN Provenance NOT LIKE "%DE%TR%" AND Provenance LIKE "_E%"   THEN "DEM" -- Demande à faible priorite
        WHEN Provenance     LIKE "%DE%TR%" OR  Provenance LIKE "%P_L%" THEN "DEL" -- Mise en destruction, matche aussi bien "DEsTRuction" que "DETRuire"
        WHEN glpi       NOT LIKE "%DE%TR%" AND glpi       LIKE "_E%"   THEN "DEM" -- Demande à faible priorite
        WHEN glpi           LIKE "%DE%TR%" OR  glpi       LIKE "%P_L%" THEN "DEL" -- Mise en destruction

        -- cas historique des anciens dossiers SM7
        WHEN glpi like "IM_______"    THEN "INC"
        WHEN glpi like "RM%-___" THEN "DEM"

        -- cas où l'on a un dossier valide
        WHEN Dossier > 0 AND Priorite="P2" AND (Provenance     IN ("SWAP","") OR  Provenance =  Dossier) THEN "INC" -- swap normal
        WHEN Dossier > 0 AND Priorite="P2" AND (Provenance NOT IN ("SWAP","") AND Provenance <> Dossier) THEN "DEM" -- demande à haute priorite

        WHEN Dossier > 0 AND Provenance="" AND CP     IN ("94043","77600","91019","94360","69750") THEN "RMA" -- Envoi vers un des mainteneurs habituels
        WHEN Dossier > 0 AND Priorite="P5" AND CP     IN ("94043","77600","91019","94360","69750") THEN "RMA" -- Envoi vers un des mainteneurs habituels
        WHEN Dossier > 0 AND Provenance LIKE "%NAV%"  THEN "RMA" -- Envoi vers un des mainteneurs habituels

        WHEN Dossier > 0 AND Priorite IN ("P3","P4") AND Provenance =  "SWAP" THEN "INC" -- Incident mal référencé
        WHEN Dossier > 0 AND Priorite IN ("P3","P4") AND Provenance <> "SWAP" THEN "DEM" -- Demande normale

        WHEN Dossier > 0 AND Priorite="" AND Provenance LIKE "%S%W%P" THEN "INC" -- Incident mal référencé
        WHEN Dossier > 0 AND Priorite="" AND CP="92390" THEN "ATL" -- Reste chez I&S pour un traitement en atelier

        WHEN Dossier > 0 AND Priorite="" AND Provenance="" THEN "DEM"

        WHEN Dossier = 0 AND CP="92390" THEN "ATL" -- Reste chez I&S pour un traitement en atelier
        WHEN Dossier = 0 AND Provenance LIKE "MMO %" AND glpi = Provenance THEN "ATL" -- Transfert à l'ancien atelier Telintrans de Tours
        WHEN Dossier = 0 AND Provenance LIKE "%DISPO%" THEN "ATL" -- Reste chez I&S pour un traitement en atelier
        WHEN Dossier = 0 AND Societe LIKE "%INTEG%" THEN "ATL" -- Reste chez I&S pour un traitement en atelier
        WHEN Dossier = 0 AND Provenance LIKE "%PROJ%" THEN "DEM" -- Traîtement particulier pour un projet
        WHEN Dossier = 0 AND CP="79140" AND Priorite NOT IN ("P2","P3","P4") THEN "DEL" -- Envoi en destruction
        WHEN Dossier = 0 AND CP     IN ("94043","77600","91019","94360","69750") THEN "RMA" -- Envoi vers un des mainteneurs habituels
        WHEN Dossier = 0 AND CP NOT IN ("94043","77600","91019","94360","69750") AND Provenance LIKE "%RMA%" THEN "RMA" -- Envoi vers un autre mainteneur
        WHEN Dossier = 0 AND Provenance LIKE "%DEM%" THEN "DEM"   -- Demande zarbi
        WHEN Dossier = 0 AND Reference LIKE "%DIVERS%" THEN "DEM"   -- Demande zarbi
        WHEN Dossier = 0 AND (glpi LIKE "Dossier%" OR GLPI LIKE "%MAIL%") THEN "DEM"   -- Demande zarbi
        WHEN Provenance LIKE "Dossier%" OR Provenance LIKE "%MA%" THEN "DEM"   -- Demande zarbi


        ELSE "IND"  -- Pour INDéterminé
    END TypeSortie
,   famille,reference,bu,surfamille,sousfamille,etat,stock,produit
,   tagis,numeroofl,numserie
,   cp,ville,societe
FROM V_DossierValide
/* vv_Sorties(GLPI,DateBL,TypeSortie,Famille,Reference,BU,SurFamille,Sousfamille,Etat,Stock,Produit,Tagis,NumeroOfl,CP,Ville,Societe) */;