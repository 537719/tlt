-- SFPencours.sql
-- CREATION 06/10/2020  03:49   Statistiques I&S par famille de produit : Remplace l'ancien système basé sur un "join" de fichiers textes
-- MODIF    17:06 01/12/2020    le cumul des produits expédiés est désormais calculé sur le mois écoulé et non depuis le début du mois
-- --                           -- parce que c'est désormais possible
-- --                           -- parce que ça donne à tout moment une vision plus lisse et plus parlante de la situation

CREATE TABLE IF NOT EXISTS sfpListe(
    CodeStat    TEXT NOT NULL PRIMARY KEY,
    LibStat     TEXT NOT NULL,
    Seuil       INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS sfpProduits(
    CodeStat    TEXT NOT NULL,
    Reference   TEXT NOT NULL PRIMARY KEY
);
CREATE INDEX IF NOT EXISTS k_SFPproduits_CodeStat ON SFPproduits(CodeStat);

CREATE TABLE IF NOT EXISTS sfpSorties(
    CodeStat    TEXT NOT NULL,
    DateStat    TEXT NOT NULL,
    INC         INTEGER NOT NULL DEFAULT 0,
    DEM         INTEGER NOT NULL DEFAULT 0,
    RMA         INTEGER NOT NULL DEFAULT 0,
    DEL         INTEGER NOT NULL DEFAULT 0,
    DIV         INTEGER NOT NULL DEFAULT 0
    CHECK(      DateStat LIKE "____-__-__")
);
CREATE UNIQUE INDEX IF NOT EXISTS k_sfpSorties ON sfpSorties(DateStat,CodeStat);

CREATE TABLE IF NOT EXISTS sfpStats(
-- archivage des stats
    DateStat    TEXT NOT NULL,
    Incident    INTEGER NOT NULL DEFAULT 0,
    Demande     INTEGER NOT NULL DEFAULT 0,
    RMA         INTEGER NOT NULL DEFAULT 0,
    DEL         INTEGER NOT NULL DEFAULT 0,
    undef       INTEGER NOT NULL DEFAULT 0,
    CodeStat    TEXT NOT NULL,
    OkDispo     INTEGER NOT NULL DEFAULT 0,
    OkReserve   INTEGER NOT NULL DEFAULT 0,
    SAV         INTEGER NOT NULL DEFAULT 0,
    Maintenance INTEGER NOT NULL DEFAULT 0,
    Destruction INTEGER NOT NULL DEFAULT 0,
    Alivrer     INTEGER NOT NULL DEFAULT 0,
    CodeStatBis TEXT NOT NULL,              -- Ce champ fait doublon car l'ancien système de stat était construit ainsi
    Seuil       INTEGER NOT NULL DEFAULT 0, -- bien qu'il soit déjà dans sfpListe le seuil est archivé ici car il peut changer au cours de la vie du produit
    LibStat     TEXT NOT NULL   -- Pareil pour le libellé du produit
    CHECK(      DateStat LIKE "____-__-__"
          AND   CodeStat=CodeStatBis -- Autant utiliser le doublon pour vérification de la cohérence des données
        )
);

CREATE UNIQUE INDEX IF NOT EXISTS k_sfpStats ON sfpStats(DateStat,CodeStat);

-- CREATE TRIGGER T_StatsUpdate 
--    INSTEAD OF INSERT ON v_sfpSorties
-- -- WHEN new.donnee = old.donnee 
-- BEGIN
--    -- set 
--    REPLACE into sqliteshow(valeur,donnee) values(new.valeur,new.donnee)
--    -- WHERE donnee=new.donnee
--   ;
-- END;


-- utiliser le trigger pour mettre à jour les stats sans écraser à zéro les valeurs déjà établies

-- 1°) Compilation des données de déstockage
-- -- 1a) créer dans la table des stats hebdo un enregistrement par famille de produit pour la date de stat considérée
WITH STORAGE AS (
    select codestat,max(dateimport) as maxdate from sfpproduits,histostock group by codestat
)
REPLACE INTO sfpSorties(CodeStat,DateStat) select codestat,maxdate from storage
-- ceci réinitialise dans la table de destination les champs autres que ceux explicitement indiqués à leur valeur par défaut
;

-- -- 1b) pour chaque champ de stat, indiquer pour chaque produit les valeurs relevées à la date de la stat
-- -- Création de la table pivor des résultats qui sera transposée ensuite
CREATE TABLE IF NOT EXISTS p_Sorties(
-- table pivot des sorties : le contenu de cette table sera ensuite transposé dans une autre
    CodeStat    TEXT NOT NULL,
    DateStat    TEXT NOT NULL,
    ItemStat    TEXT NOT NULL DEFAULT "IND",
    Valeur      INTEGER NOT NULL DEFAULT 0
    CHECK       (
            ItemStat    IN  ("INC","DEM","RMA","DEL","ATL","IND","DIV")
        AND DateStat    LIKE "____-__-__"
    )
);
CREATE UNIQUE INDEX IF NOT EXISTS k_Psorties ON p_Sorties(CodeStat,DateStat,ItemStat);

-- -- Peuplement de la table pivot des résultats
-- -- -- initialise les items
delete from p_sorties;
with storage as (
    select typesortie from vv_sorties group by typesortie
)
INSERT OR REPLACE INTO p_Sorties(CodeStat,DateStat,ItemStat)  select codestat,maxdate,typesortie from sfpproduits,v_dernierimport,storage group by codestat,typesortie
;

-- -- -- renseigne les valeurs non nulles
with storage as (
    select codestat,reference from sfpproduits
)
REPLACE INTO p_Sorties(CodeStat,DateStat,ItemStat,Valeur)  
select codestat,maxdate,typesortie
,count(tagis)
from v_dernierimport,vv_sorties,storage 
-- where vv_sorties.reference LIKE  storage.reference and datebl between date(maxdate,"start of month") and maxdate 
where vv_sorties.reference LIKE  storage.reference and datebl between date(maxdate,"-1 month") and maxdate 
     -- and typesortie="DIV"
group by storage.codestat,vv_sorties.typesortie
;


-- -- 1c) Restitution des résultats transposés
CREATE VIEW IF NOT EXISTS v_TransposeStatsSorties AS
-- Transposition de la table pivot
-- trouvé sur https://stackoverflow.com/questions/3611542/sql-columns-for-different-categories
select     CodeStat,
    max(case when     ItemStat="INC" then     Valeur END) as INC,
    max(case when     ItemStat="DEM" then     Valeur END) as DEM,
    max(case when     ItemStat="RMA" then     Valeur END) as RMA,
    max(case when     ItemStat="DEL" then     Valeur END) as DEL,
    max(case when     ItemStat="ATL" then     Valeur END) as ATL,
    max(case when     ItemStat="IND" then     Valeur END) as IND,
    DateStat
from p_Sorties
group by CodeStat
;

-- 4°) Production d'une sortie similaire à l'ancienne stat
CREATE VIEW IF NOT EXISTS V_StatIS AS
SELECT
    Datestat,INC AS Incident,DEM AS Demande,RMA,DEL as Destruction,ATL + IND AS undef,sfpProduits.CodeStat,
    sum(OkDispo) AS OkDispo,sum(OkReserve) AS OkReserve,sum(SAV) AS SAV,sum(Maintenance) AS Maintenance,sum(Destruction) AS Destruction,sum(Alivrer) AS Alivrer,
    SFPliste.CodeStat,Seuil,LibStat
FROM v_TransposeStatsSorties,v_TEexport,SFPliste,sfpProduits
WHERE
        DateStat=DateImport
        AND SFPliste.CodeStat=sfpProduits.CodeStat
    AND v_TransposeStatsSorties.CodeStat=SFPliste.CodeStat
    AND v_TEexport.Reference like sfpproduits.reference
group by sfpproduits.codestat
;    

REPLACE INTO sfpStats(DateStat,Incident,Demande,RMA,DEL,undef,CodeStat,OkDispo,OkReserve,SAV,Maintenance,Destruction,Alivrer,CodeStatBis,Seuil,LibStat)
SELECT
    Datestat,INC AS Incident,DEM AS Demande,RMA,DEL ,ATL + IND AS undef,sfpProduits.CodeStat,
    sum(OkDispo) AS OkDispo,sum(OkReserve) AS OkReserve,sum(SAV) AS SAV,sum(Maintenance) AS Maintenance,sum(Destruction) AS Destruction,sum(Alivrer) AS Alivrer,
    SFPliste.CodeStat,Seuil,LibStat
FROM v_TransposeStatsSorties,v_TEexport,SFPliste,sfpProduits
WHERE
        DateStat=DateImport
        AND SFPliste.CodeStat=sfpProduits.CodeStat
    AND v_TransposeStatsSorties.CodeStat=SFPliste.CodeStat
    AND v_TEexport.Reference like sfpproduits.reference
group by sfpproduits.codestat
;

CREATE VIEW IF NOT EXISTS v_sfpStats AS
WITH storage AS (
    SELECT date(max(dateimport),"start of month","-1 year","-1 month") AS mindate,date(max(dateimport),"start of month","-1 day") AS maxdate,max(dateimport) AS lastdate FROM histostock
)
SELECT  DateStat,Incident,Demande,RMA,DEL,undef,CodeStat,OkDispo,OkReserve,SAV,Maintenance,Destruction,Alivrer,CodeStatBis,Seuil,LibStat 
FROM    sfpstats,storage 
WHERE   codestat IN (select codestat from sfpstats group by codestat)
    AND (
        datestat=lastdate 
    OR  datestat BETWEEN storage.mindate AND storage.maxdate
        )
ORDER BY codestat ASC, datestat ASC
;

.separator ;
.headers on
-- .once ../StatsIS/sfpStats.csv
select * from v_sfpStats;

