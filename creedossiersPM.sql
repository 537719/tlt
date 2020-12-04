-- creedossiersPM.sql
-- CREATION     21:12 02/10/2020 Produit le texte de description des dossiers de demande pour le déploiement des Postes Mâîtres Linux pour Colissimo
-- PREREQUIS    Table deplpmlxcol alimentée le fichier csv produit par la conversion par creedossiersPM.awk
.print version du 11:37 05/10/2020
.print Init
CREATE TABLE IF NOT EXISTS DEPLPMLXCOL (
    CodeColissimo  TEXT NOT NULL PRIMARY KEY,
    SITE TEXT NOT NULL,
    ADR1 TEXT NOT NULL,
    ADR2 TEXT NOT NULL,
    ADR3 TEXT NOT NULL,
    CPV TEXT NOT NULL,
    NOM TEXT NOT NULL,
    migration TEXT NOT NULL
    CHECK(
        CAST(CodeColissimo AS INTEGER) BETWEEN 1 AND 999999
    AND
        CPV LIKE "_____ %"
    )
);

CREATE TABLE IF NOT EXISTS SuiviDeploiements (
-- indispensable pour pouvoir ne pas sélectionner les déploiements auxquel un dossier est déjà affecté
-- /!\ Attention, nécessité d'un trigger donc on inserre sur la vue et non sur la table
    CodeSite    TEXT  NOT NULL,
    CodeProjet  TEXT NOT NULL,
    Dossier     INTEGER NOT NULL DEFAULT 0
);
CREATE UNIQUE INDEX IF NOT EXISTS K_SD on SuiviDeploiements(CodeSite,CodeProjet);
CREATE VIEW IF NOT EXISTS v_SuiviDeploiements as 
-- Nécessité d'un trigger avec clause instead pour inserrer, donc on le fera sur cette vue
select CodeSite,CodeProjet,Dossier from SuiviDeploiements
;
CREATE TRIGGER IF NOT EXISTS Ti_SuiviDeploiements
-- sans ça, l'INSERT échoue et arrête le script
-- résultat de ce trigger, on ajoute uniquement les lignes qui n'existent pas encore sans toucher aux autres
INSTEAD OF INSERT ON v_SuiviDeploiements
WHEN NOT EXISTS (select * from suivideploiements where suivideploiements.codesite=new.codesite and suivideploiements.codeprojet=new.codeprojet)
BEGIN
    INSERT into suivideploiements(codesite,CodeProjet) select CodeColissimo,"PMCOLLX" from deplpmlxcol where CodeColissimo=new.codesite 
    ;
END
;

CREATE TRIGGER IF NOT EXISTS Tu_SuiviDeploiements
-- sans ça, l'import de csv échoue et arrête le script
-- résultat de ce trigger, on met à jour le numéro de dosser uniquement les lignes qui existent, par import de fichier csv
INSTEAD OF INSERT ON v_SuiviDeploiements
WHEN EXISTS (select * from suivideploiements where suivideploiements.codesite=new.codesite and suivideploiements.codeprojet=new.codeprojet)
BEGIN
    UPDATE suivideploiements set dossier=new.dossier WHERE codesite=new.codesite  AND CodeProjet="PMCOLLX"
    ;
END
;



CREATE TABLE IF NOT EXISTS ProjetsDeploiements (
    CodeProjet  TEXT NOT NULL PRIMARY KEY,
    NomProjet   TEXT NOT NULL DEFAULT ""
);


.print lecture data
.separator ;
.import ../CLP/Planning_PM-IDF.csv DEPLPMLXCOL
-- Planning_PM-IDF.csv est produit par application de TraduitDossiersPM.awk à l'export .tsv du planning fourni par colissimo

INSERT into v_suivideploiements(codesite,CodeProjet,dossier) select CodeColissimo,"PMCOLLX",0 from deplpmlxcol;
-- indispensable pour pouvoir ne pas sélectionner les déploiements auxquel un dossier est déjà affecté
-- /!\ Attention, nécessité d'un trigger donc on inserre sur la vue et non sur la table

.import ../CLP/SuiviDossiers.csv v_SuiviDeploiements
-- SuiviDossiers.csv est produit par application de SuivreDossiersPM.awk à l'export .tsv du planning fourni par colissimo
-- partie abandonnée et remplacée par l'invocation du script suivredepl [codesite] [codeprojet] [dossier] [texte descriptif]
-- pour le motif que c'est moins lourd que de refaire un export du fichier .tsv à chaque fois
-- et en plus ça rajoute le dossier dans la liste de ceux qui sont à suivre

.print vue
CREATE VIEW IF NOT EXISTS v_CreationDossierAbregee AS
select 
    strftime("%d/%m/%Y",date(migration,"-7 days")) as Creation
    ,SITE
    ,CodeColissimo
    ,CASE 
        WHEN strftime("%w",migration) <= "2" THEN strftime("%d/%m/%Y",date("migration","-4 days"))
        ELSE strftime("%d/%m/%Y",date("migration","-1 day"))
    END Envoi
, site
    , NOM
    ,ADR1
    ,ADR2
    -- ,ADR3
    ,CPV

from deplpmlxcol,suivideploiements 
where codesite=CodeColissimo and CodeProjet="PMCOLLX" and dossier=0

group by CodeColissimo
having creation <= "Dossier à créer le " || date("now")
order by migration asc
;

CREATE VIEW IF NOT EXISTS v_CreationDossier AS
-- CREATE VIEW v_CreationDossier AS
select 
    "Dossier à créer le " || date(migration,"-7 days") as Creation
    -- ,"Entité                : Entité racine > LA POSTE > BSCC Colissimo"
    ,"Client                : ACP > " || SITE
    ,"Catégorie             : Demande de matériel > Matériel réseau et serveur > Demande d'installation serveur agence"
    ,"Attribué à            : I&S_DEPART"
    ,"Appelant / Demandeur  : COUGOULAT PATRICE"
    ,"Contact               : " || NOM
    ,"Titre                 : DEPLOIEMENT Postes Maîtres Colissimo Linux de " || SITE
    ,"Description           :"
    ,"Depuis le stock COLIPOSTE FIL DE L'EAU préparer"
    ,"2 CLPMETL POSTE MAITRE COLISSIMO LINUX"
    ,"selon la nouvelle procédure [SOP_PRC_COL Production de poste maitre.docx] disponible sur le serveur I&S (WIGNV1) dans Coliposte\Poste Maitre Linux\ "
    ,"CODE Colissimo : " || CodeColissimo
    ,"Nom des postes : PM-" || CodeColissimo || "-1 et PM-" || CodeColissimo || "-2"
    ,"En cas de problème avec les fichiers de configuration notifier le dossier à N2_SYSTEME"
    ,""
    ,"/!\ Attention le poste doit être sur site au plus tard en début de matinée du " || CASE 
        WHEN strftime("%w",migration) <= "2" THEN strftime("%d/%m/%Y",date("migration","-4 days"))
        ELSE strftime("%d/%m/%Y",date("migration","-1 day"))
    END Envoi
    ,"Coordonnées d'expédition :"
    ,"COLISSIMO " || SITE as site
    ,"attn : " || trim(NOM)
    ,ADR1
    ,ADR2
    -- ,ADR3
    ,CPV
    ,"",""

from deplpmlxcol,suivideploiements 
where codesite=CodeColissimo and CodeProjet="PMCOLLX" and dossier=0

group by CodeColissimo
having creation <= "Dossier à créer le " || date("now")
order by migration asc
;

CREATE VIEW IF NOT EXISTS v_ProchaineDate AS
select min(date(migration,"-7 days")) AS ProchaineDate,CodeColissimo,site from deplpmlxcol,suivideploiements
where codesite=CodeColissimo and CodeProjet="PMCOLLX" and dossier=0
;

.print configure
.read ../bin/sqliteshowsauve.sql
.mode list
.headers off
.separator \n
.print execute
.output ../work/CreationDossier.txt
SELECT * FROM v_CreationDossier LIMIT 1;
WITH storage AS (
    SELECT COUNT(creation) AS nb FROM v_CreationDossier
)
-- SELECT "Pas de dossier à créer aujourd'hui "|| strftime("%d/%m/%Y",date("now")) FROM storage where nb=0;
SELECT "Prochain dossier à crééer le " || strftime("%d/%m/%Y",ProchaineDate) || " pour " || SITE || " " || CodeColissimo FROM v_ProchaineDate
;

.output
SELECT * FROM v_CreationDossier LIMIT 1;

.print restaure config
.read ../bin/buildsqliteshowrestore.sql
.read ../bin/sqliteshowrestore.sql

