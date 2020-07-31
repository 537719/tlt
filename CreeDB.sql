-- CreeDB.sql
-- Crée la BDD de traitement des données I&S avec les index et contraintes appropriés et des noms de champs sans accents ni espaces
-- CREATION 16:24 27/02/2020

-- sorties et annexes
CREATE TABLE SORTIES(
  "GLPI" TEXT,
  "Priorite" TEXT,
  "Provenance" TEXT,
  "DateCreation" TEXT,
  "CentreCout" TEXT,
  "Reference" TEXT,
  "Description" TEXT,
  "DateBL" TEXT,
  "BU" TEXT,
  "sDepot" TEXT,
  "NumSerie" TEXT,
  "NomClient" TEXT,
  "Adr1" TEXT,
  "Adr2" TEXT,
  "Adr3" TEXT,
  "CP" TEXT,
  "Dep" TEXT,
  "Ville" TEXT,
  "Tagis" TEXT  PRIMARY KEY NOT NULL,
  "Societe" TEXT,
  "NumeroOfl" TEXT,
  "Pays" TEXT
  CHECK(substr(Tagis,1,2)="TE"
  AND     length(TagIS)=12)
);
CREATE UNIQUE INDEX k_SoTag ON SORTIES(tagis);

CREATE VIEW v_SORTIES AS 
    SELECT
        "TagIS"
,       date(substr(DateCreation,7,4) || "-" || substr(DateCreation,4,2) || "-" ||  substr(DateCreation,1,2))  AS DateCreation
,       date(substr("Date BL",7,4) || "-" || substr("Date BL",4,2) || "-" ||  substr("Date BL",1,2))  AS DateBL
    FROM SORTIES
    WHERE "Date BL" LIKE "__/__/____"
UNION ALL
    SELECT
        "TagIS"
,       date(substr(DateCreation,7,4) || "-" || substr(DateCreation,4,2) || "-" ||  substr(DateCreation,1,2))  AS DateCreation
,       date(substr(DateCreation,7,4) || "-" || substr(DateCreation,4,2) || "-" ||  substr(DateCreation,1,2),"+1 day")  AS DateBL
    FROM SORTIES
    WHERE "Date BL" =""
;


-- del :
-- 2019    2097 =
-- 2018    3198 = 
-- 2017    5184 5220
-- 2016    2130=
-- 2015    423 838
-- 2014    1419 = 

drop view v_typesorties;

CREATE VIEW v_typesorties AS
with storage as (
    select tagis
    ,glpi || provenance as glpiprov
    ,priorite || cp || reference as pricpref from sorties
    -- where glpi<= "1000000000" or glpi >= "1400000000";
)
    select 
        tagis
    ,   "DEL" as Typesorties from storage 
    where glpiprov like "%pal%" or glpiprov like "%destr%" 
UNION
    select 
        tagis
    ,   "DEM" as Typesorties from storage 
    where glpiprov like "PR%" 
UNION
    select 
        storage.tagis
    ,   "DEM" as Typesorties from storage ,sorties
    where storage.tagis=sorties.tagis and Provenance like "_E%" and Provenance not like "DEST%" 
UNION
    select 
        tagis
    ,   "INC" as Typesorties from storage 
    where 
        -- substr(glpiprov,1,10) > "1000000000" 
    -- and 
    -- substr(glpiprov,1,10) < "2900000000"
    -- AND
         glpiprov not like "%NAV%"  
    and glpiprov not like "%RMA%"  
    and glpiprov not like "%RETOUR%"  
    and glpiprov not like "%REPAR%"
    and (
        pricpref like "P2_____C__10%"
    or pricpref like "P2_____C__47%"
    or pricpref like "P2_____C__32%"
    or pricpref like "P2_____C__34%"
    or pricpref like "P2_____CHR41N_0BQ"
    or pricpref like "P2_____CHR6___1A_"
    or pricpref like "P2_____CHR54__1E7"
    )

UNION

-- with storage as (
    -- select tagis,priorite || cp || reference as pricpref from sorties
    -- where glpi > "1000000000" and glpi < "1400000000"
-- )
    select 
        tagis
    ,   "RMA" as Typesorties from storage 
    where pricpref like "__94043C__34%" or pricpref like "__91019CLP34r%"  or pricpref like "__94360CHR63%" 
UNION
    SELECT
    tagis,"INC" as TypeSorties
    FROM storage
    WHERE
        glpiprov LIKE "%S%W%P"
    AND
        pricpref NOT LIKE "P2%"
UNION
    select 
        tagis
    ,   "RMA" as Typesorties from storage 
    where glpiprov like "%NAV%"  or glpiprov like "%RMA%"  or glpiprov like "%RETOUR%"  or glpiprov like "%REPAR%" 
ORDER BY tagis
;

select sorties_type.TagIS,sorties_type.TypeSortie,v_typesorties.typesorties,glpi,priorite,provenance,reference,cp,substr(glpi,1,10) from sorties_type,v_typesorties,sorties where sorties_type.TypeSortie != "DEM" and sorties_type.TagIS=v_typesorties.tagis and sorties_type.TagIS=sorties.TagIS and TypeSortie != Typesorties limit 10;



CREATE TABLE SORTIES_Type(
  "Tagis" TEXT  PRIMARY KEY NOT NULL,
    "TypeSortie" TEXT
);
CREATE UNIQUE INDEX k_SoTTag ON SORTIES_Type(Tagis);

-- stock et annexes
CREATE TABLE STOCK(
  "Qte" INTEGER,
  "NomProjet" TEXT,
  "Ref" TEXT,
  "Lib" TEXT,
  "Designation" TEXT,
  "Etat" TEXT,
  "Statut" TEXT,
  "NumSerie" TEXT,
  "Tagis" TEXT  PRIMARY KEY NOT NULL,
  "DateEntree" TEXT,
  "vide" TEXT
  CHECK(Qte=1
      AND vide=""
      AND (substr(Tagis,1,2)="TE" OR (substr(Tagis,1,2)="SN"
      AND   length(Tagis)=12)
  )
);
CREATE UNIQUE INDEX k_SkTag ON STOCK(Tagis);

CREATE VIEW v_STOCK AS
    WITH storage as (
            --  détermine la plus récente des dates d'entrée en stock afin de calculer le nombre de semaines depuis lequel chaque produit est en stock
            select  "20" || 
            substr(max(TagIs),3,2) 
            -- tagis est un meilleur indicateur de date que DateEntree car basé sur le premier mouvement de l'article concerné alors que DateEntree est basé sur le dernier
                || "-" || 
            substr(max(TagIs),5,2) 
                || "-" || 
            substr(max(TagIs),7,2) 
            as DATEMAX 
            from stock 
            where dateentree -- sous entendu "existe" : afin d'exclure la dernière ligne du fichier, qui ne comporte que le nombre total d'articles
    ) 
    select 
        (strftime("%s",datetime(datemax)) - strftime("%s",date("20" || substr(TagIs,3,2) || "-" || substr(TagIs,5,2) || "-" || substr(TagIs,7,2))))/604800+1 AS NbSem, -- nombre de secondes unix divisé par le nombre de secondes par semaine
        -- StockageUnitaireParSemaine as CoutHebdo,
        
        date("20" || substr(TagIs,3,2) || "-" || substr(TagIs,5,2) || "-" || substr(TagIs,7,2)) as InDate,
        "20" || substr(TagIs,3,2) as InAnnee,
         substr(TagIs,5,2) as InMois,
         substr(TagIs,7,2) as InJour,
         substr("Nom projet",1,3) as BU, -- préférer nom_projet plutôt que le début de la référence afin de ne pas être perturbé par les articles génériques n'ayant pas une référence normalisée tels que les baies ou switches
         substr(stock.ref,4,1) as SurFamille, substr(stock.ref,5,1) as Sousfamille, substr(stock.ref,4,2) as Famille, 
         substr(stock.ref,6,1) as Etat, substr(stock.ref,7,1) as Stock, 
         substr(stock.ref,8,3) as Produit,

        tagis
        
        from 
             storage
            ,stock 
        where 
            tagis like "TE__________"
        OR
            tagis like "SN__________"
        group 
            by tagis -- une même référence pouvant apparaître plusieurs fois dans le catalogue, on s'assure ainsi de ne la voir ressortir qu'une seule fois
;
















-- entrees
CREATE TABLE ENTREES(
  "Projet" TEXT,
  "Reference" TEXT,
  "Numero Serie" TEXT,
  "DateEntree" TEXT,
  "APT" TEXT,
  "RefAppro" TEXT,
  "BonTransport" TEXT,
  "Libellé" TEXT,
  "TagIS" TEXT,
  "NumTag" TEXT
);
CREATE TABLE ENTREES_Type(
TagIS TEXT,
TypeEntree TEXT,
DateEntree TEXT
);
CREATE UNIQUE INDEX ETtag on ENTREES_Type(TagIS,DateEntree,TypeEntree);
CREATE TABLE suivi_attente(
  "TagIs" TEXT,
  "Motif" TEXT,
  "Suivi" TEXT,
  "date_vu" TEXT
);



CREATE VIEW v_adresses as
SELECT
        glpi               AS DernierDossier ,
        datebl             AS DernierBL      ,
        printf("%02d",dep) AS Dpt            ,
        trim(societe)      AS NomSite        ,
        nomclient                            ,
        adr1                                 ,
        adr2                                 ,
        adr3                                 ,
        CP AS CodePostal                     ,
        ville                                ,
        " pays" AS Pays
FROM
        sorties,
        v_sorties
WHERE
        sorties.tagis =v_sorties.tagis
AND     societe       > "!"
AND     nomclient     > "!"
AND     sdepot NOT LIKE "%ship%"
AND     pays   NOT LIKE "FR%"
GROUP BY
        nomsite,
        cp

UNION

SELECT
        glpi               AS DernierDossier ,
        datebl             AS DernierBL      ,
        printf("%02d",dep) AS Dpt            ,
        trim(societe)      AS NomSite        ,
        nomclient                            ,
        adr1                                 ,
        adr2                                 ,
        adr3                                 ,
        printf("%05d",CP) AS CodePostal      ,
        ville                                ,
        " pays" AS Pays
FROM
        sorties,
        v_sorties
WHERE
        sorties.tagis =v_sorties.tagis
AND     societe       > "!"
AND     nomclient     > "!"
AND     sdepot NOT LIKE "%ship%"
AND     pays       LIKE "FR%"
GROUP BY
        nomsite,
        cp
ORDER BY
        cp ASC,
        datebl DESC 
;

 
