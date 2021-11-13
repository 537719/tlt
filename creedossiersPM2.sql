-- creedossiersPM2.sql
-- CREATION 14:11 02/03/2021 création dossiers seconde vague des postes maîtres coli
-- invocation par
-- .read ../bin/creedossiersPM2.sql
delete from DEPLPMLXCOL2;
.mode list
.separator \t
.import "../CLP/_Planning_ACP_LOT2-1-1.xlsx - Sheet1.tsv" DEPLPMLXCOL2
insert or replace into suivideploiements select printf("%06d",codecolissimo),"PMCOLLX",GLPI from DEPLPMLXCOL2 where cast(glpi as integer) >0;
select * from suivideploiements order by dossier asc;
INSERT OR REPLACE INTO DEPLPMLXCOL(
    CodeColissimo,
    SITE,
    ADR1,
    ADR2,
    ADR3,
    CPV,
    NOM,
    Migration,
    NoChange
)
SELECT
    printf("%06d",CodeColissimo) AS CodeColissimo,
    SITE,
    ADResse AS ADR1,
    -- REPLACE(ADResse, CPV,"") AS ADR1,
    "",
    "",
    CPV,
    Responsable,
    date(substr(Migration,7,4) || "-" || substr(Migration,4,2) || "-" || substr(Migration,1,2))  AS dMigration,
    Changement
FROM DEPLPMLXCOL2
WHERE
    -- dMigration > date("now")
     julianday(dmigration) > 0   
AND Cast(Changement AS Integer) = 0
AND cast(substr(CPV,1,5) AS INTEGER) >0
-- AND Cast(Changement AS Integer) > 0
-- limit 4
;

.mode list
.separator \n
select 
    -- "Dossier à créer le " || date(DEPLPMLXCOL.migration,"-7 days") as Creation
    "CODE Regate    : " || CodeRegate
    -- ,"Entité                : Entité racine > LA POSTE > BSCC Colissimo"
    ,"Client                : ACP > " || DEPLPMLXCOL.SITE
    ,"Catégorie             : Demande de matériel > Matériel réseau et serveur > Demande d'installation serveur agence"
    ,"Attribué à            : I&S_DEPART"
    ,"Appelant / Demandeur  : COUGOULAT PATRICE"
    ,"Contact               : " || NOM
    -- ,"Regate                : " || CodeRegate
    ,"Titre                 : DEPLOIEMENT Postes Maîtres Colissimo Linux de " || DEPLPMLXCOL.SITE
    ,"Description           :"
    ,"Depuis le stock COLIPOSTE FIL DE L'EAU préparer"
    ,"2 CLPMETL POSTE MAITRE COLISSIMO LINUX"
    -- ,"selon la nouvelle procédure [SOP_PRC_COL Production de poste maitre.docx] disponible sur le serveur I&S (WIGNV1) dans Coliposte\Poste Maitre Linux\ "
    ,"CODE Colissimo : " || DEPLPMLXCOL.CodeColissimo
    ,"Nom des postes : PM-" || DEPLPMLXCOL.CodeColissimo || "-1 et PM-" || DEPLPMLXCOL.CodeColissimo || "-2"
    ,"En cas de problème avec les fichiers de configuration notifier le dossier à N2_SYSTEMES"
    , CASE
        WHEN cast(NoChange AS INTEGER) > 0 THEN "Dossier lié au changement n° " || NoChange
        ELSE "Dossier lié au changement n° [inconnu]" 
      END
    -- ,""
    ,"Affecter à I&S_DEPART une fois que les KS seront OK"
    -- ,"/!\ Attention le poste doit être sur site au plus tard en début de matinée du " || CASE 
        -- WHEN strftime("%w",migration) <= "2" THEN strftime("%d/%m/%Y",date("migration","-4 days"))
        -- ELSE strftime("%d/%m/%Y",date("migration","-1 day"))
    -- END Envoi
    ,"Coordonnées d'expédition :"
    ,"COLISSIMO " || DEPLPMLXCOL.SITE as site
    -- ,"attn : " || trim(NOM)
    ,ADR1
    -- ,ADR2
    -- ,ADR3
    ,DEPLPMLXCOL.CPV
    ,"",""

from DEPLPMLXCOL,DEPLPMLXCOL2 where 
    DEPLPMLXCOL.CodeColissimo = DEPLPMLXCOL2.CodeColissimo
-- migration like "2021-03-11" 
and 
DEPLPMLXCOL.CodeColissimo not in (select codesite from suivideploiements where CodeProjet="PMCOLLX")
order by DEPLPMLXCOL.migration asc
LIMIT 1
;

