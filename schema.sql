CREATE TABLE SORTIES(
  "GLPI" TEXT,
  "Priorite" TEXT,
  "Provenance" TEXT,
  "DateCreation" TEXT,
  "CentreCout" TEXT,
  "Reference" TEXT,
  "Description" TEXT,
  "Date BL" TEXT,
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
  "Tagis" TEXT,
  "Societe" TEXT,
  "NumeroOfl" TEXT,
  " Pays" TEXT
);
CREATE UNIQUE INDEX Stag on SORTIES(tagis);
CREATE TABLE SORTIES_Sidetable(
        "TagIS" TEXT,
        "DateCreation" TEXT,
        "DateBL" TEXT
);
CREATE UNIQUE INDEX SStag on SORTIES_Sidetable(tagis);
CREATE TABLE SORTIES_Type(
    "TagIS" TEXT,
    "TypeSortie" TEXT
);
CREATE UNIQUE INDEX STtag on SORTIES_Type(tagis);
CREATE TABLE Stock_Sidetable(
  "NbSem" TEXT,
  "CoutHebdo" TEXT,
  "InDate" TEXT,
  "InAnnee" TEXT,
  "InMois" TEXT,
  "InJour" TEXT,
  "BU" TEXT,
  "SurFamille" TEXT,
  "Sousfamille" TEXT,
  "Famille" TEXT,
  "Etat" TEXT,
  "Stock" TEXT,
  "Produit" TEXT,
  "TagIs" TEXT
);
CREATE TABLE ENTREES_Type(
TagIS TEXT,
TypeEntree TEXT,
DateEntree TEXT
);
CREATE UNIQUE INDEX ETtag on ENTREES_Type(TagIS,DateEntree,TypeEntree);
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
/* v_STOCK(NbSem,InDate,InAnnee,InMois,InJour,BU,SurFamille,Sousfamille,Famille,Etat,Stock,Produit,TagIs) */;
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
/* v_typesorties(tagis,Typesorties) */;
CREATE UNIQUE INDEX k_SoTag ON SORTIES(tagis);
CREATE VIEW v_statsortie as
  SELECT tagis, "PCA" as Usage FROM sorties
  WHERE GLPI IN (2003200324,2003200325,2003200326,2003200327,2003200328,2003200347,2003200389,2003200459)
UNION
  SELECT tagis,"MAGNETIK" AS Usage   FROM sorties 
  WHERE ADR1 LIKE "%3 BOULEVARD ROMAIN ROLLAND%"
  AND GLPI NOT IN (2003200324,2003200325,2003200326,2003200327,2003200328,2003200347,2003200389,2003200459)
UNION
  SELECT tagis,"CHRONOSHIP" AS Usage   FROM sorties 
  WHERE sdepot="CHRONOPOST SHIPPING" 
  AND ADR1 NOT LIKE "%3 BOULEVARD ROMAIN ROLLAND%"
UNION
  SELECT tagis,"EXPEDITOR" AS Usage FROM sorties 
  WHERE sdepot="COLIPOSTE SHIPPING" 
  AND ADR1 NOT LIKE "%3 BOULEVARD ROMAIN ROLLAND%"
UNION
  SELECT tagis,"COLISSIMO" AS Usage FROM sorties 
  WHERE sdepot LIKE "COLIPOSTE%" 
  AND sdepot <> "COLIPOSTE SHIPPING" 
  AND ADR1 NOT LIKE "%3 BOULEVARD ROMAIN ROLLAND%"
UNION
  SELECT tagis,"ALTURING" AS Usage FROM sorties 
  WHERE sdepot="TELINTRANS" 
  AND ADR1 NOT LIKE "%3 BOULEVARD ROMAIN ROLLAND%"
UNION
  SELECT tagis,"CHR METIER" AS Usage FROM sorties 
  WHERE sdepot LIKE "CHRONOPOST%" 
  AND sdepot <> "CHRONOPOST SHIPPING" 
  AND ADR1 NOT LIKE "%3 BOULEVARD ROMAIN ROLLAND%"
/* v_statsortie(Tagis,Usage) */;
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
/* v_adresses(DernierDossier,DernierBL,Dpt,NomSite,NomClient,Adr1,Adr2,Adr3,CodePostal,Ville,Pays) */;
CREATE VIEW LastLivMagnetik AS
with storage as (
    select max(datebl) as datemax 
    from v_sorties,sorties 
    where adr1 like "%3 BOULEVARD ROMAIN ROLLAND%" 
        and v_sorties.tagis=sorties.tagis
) 
select glpi,
    count(sorties.tagis) as nb,
    datebl,
    nomclient, 
    reference,
    description
    from sorties,storage,v_sorties 
where  sorties.tagis=v_sorties.tagis 
    and datebl > date(datemax,"-3 days")
    and adr1 like "%3 BOULEVARD ROMAIN ROLLAND%" 
group by reference,glpi
order by datebl desc,glpi,reference
/* LastLivMagnetik(GLPI,nb,DateBL,NomClient,Reference,Description) */;
CREATE VIEW LastLivMagnetikLink AS
with storage as (
    select max(datebl) as datemax 
    from v_sorties,sorties 
    where adr1 like "%3 BOULEVARD ROMAIN ROLLAND%" 
        and v_sorties.tagis=sorties.tagis
) 
select 
    "https://glpi.alturing.eu/front/ticket.form.php?id=" || glpi as "Lien GLPI"
from sorties,storage,v_sorties 
where  sorties.tagis=v_sorties.tagis 
    and datebl > date(datemax,"-3 days")
    and adr1 like "%3 BOULEVARD ROMAIN ROLLAND%" 
group by glpi
order by datebl desc,glpi
/* LastLivMagnetikLink("Lien GLPI") */;
CREATE TABLE suivi_attente(
  "TagIs" TEXT,
  "Motif" TEXT,
  "Suivi" TEXT,
  "date_vu" TEXT
);
CREATE TABLE catalogue(
  "Ref" TEXT,
  " Reference Gen" TEXT,
  " Reference Alt" TEXT,
  " Magasin Dest" TEXT,
  " Famille" TEXT,
  "Designation" TEXT,
  " Cat�gorie" TEXT,
  "Poids (Kg)" TEXT,
  " Partenaire" TEXT,
  " Projet" TEXT,
  "Active" TEXT,
  "" TEXT
);
CREATE VIEW v_dernieredate as select substr(dernieredate.nomfich,10,4) || "-" || substr(dernieredate.nomfich,14,2) || "-" || substr(dernieredate.nomfich,16,2) as dernierimport from dernieredate order by nomfich desc limit 1;
CREATE TABLE histostock(
Projet TEXT,
Reference TEXT,
Designation TEXT,
OkDispo INT,
OkReserve INT,
SAV INT,
Maintenance INT,
Destruction INT,
Alivrer INT
, dateimport text
CHECK (OkDispo=OkDispo+1-1)
);
CREATE UNIQUE INDEX k_histostock on histostock(dateimport,reference,projet);
CREATE VIEW v_lastliv as
with storage as (select max(datebl) as datemax from v_sorties) select glpi,count(sorties.tagis) as Nb,"date bl",societe,nomclient,cp,ville,reference,description from sorties,v_sorties,storage where sorties.tagis=v_sorties.tagis and datebl = datemax group by glpi,reference
/* v_lastliv(GLPI,Nb,"Date BL",Societe,NomClient,CP,Ville,Reference,Description) */;
CREATE VIEW v_temp_typesortie as select glpi, priorite, provenance, reference, cp, tagis,glpi || provenance as glpiprov,cp || reference as cpref from sorties
/* v_temp_typesortie(GLPI,Priorite,Provenance,Reference,CP,Tagis,glpiprov,cpref) */;
CREATE VIEW v_test_typesortie as
select distinct  GLPI,Priorite,Provenance,Reference,CP,Tagis,glpiprov,cpref,"RMA" as typesortie from  v_temp_typesortie 
where glpiprov like "%NAV%" or glpiprov like "%RMA%" or glpiprov like "%RETOUR%" or glpiprov like "%REPAR%"
-- group by tagis
UNION
select distinct  GLPI,Priorite,Provenance,Reference,CP,Tagis,glpiprov,cpref,"RMA" as typesortie from  v_temp_typesortie 
where cpref like "94043C__34%" or cpref like "91019CLP34%" or cpref like "94360CHR63%" or cpref like "69750%DIV%"
-- group by tagis
UNION
select distinct  GLPI,Priorite,Provenance,Reference,CP,Tagis,glpiprov,cpref,"DEM" as typesortie from  v_temp_typesortie 
where glpiprov like "PR%" or glpiprov like "%dem%" or glpiprov like "%dep%" or glpiprov like "%rec%"
-- group by tagis
UNION
select distinct  GLPI,Priorite,Provenance,Reference,CP,Tagis,glpiprov,cpref,"DEL" as typesortie from  v_temp_typesortie 
where glpiprov like "%PAL%" or glpiprov like "%deS%"
-- group by tagis
UNION
select distinct  GLPI,Priorite,Provenance,Reference,CP,Tagis,glpiprov,cpref,"INC" as typesortie from  v_temp_typesortie 
where glpiprov like "%SW%P%" OR glpiprov like "%SWA%" OR glpiprov like "%INC%" OR (priorite="P2" and glpi like "__________" and provenance not like "_E%")
-- group by tagis
/* v_test_typesortie(GLPI,Priorite,Provenance,Reference,CP,Tagis,glpiprov,cpref,typesortie) */;
CREATE VIEW v_OFLX AS
WITH Storage AS (
    SELECT NoOFL,Date_Creation,Date_Expedition,Date_souhaitee,Date_Notification,  Heure_Notification
    FROM OFLX
    WHERE Date_Creation <> ""
UNION ALL
    SELECT NoOFL,DateCreation,Date_Expedition,Date_souhaitee,Date_Notification,Heure_Notification
    FROM OFLX,Sorties
    WHERE Date_Creation = ""
    AND OFLX.NOOFL=Sorties.NumeroOfl
)

SELECT NoOFL,
    substr(Date_Creation,7,4) || "-" || substr(Date_Creation,4,2)  || "-" || substr(Date_Creation,1,2) AS Date_Creation, 
    substr(Date_Expedition,7,4) || "-" || substr(Date_Expedition,4,2)  || "-" || substr(Date_Expedition,1,2) AS Date_Expedition, 
    substr(Date_souhaitee,7,4) || "-" || substr(Date_souhaitee,4,2)  || "-" || substr(Date_souhaitee,1,2) AS Date_souhaitee, 
    substr(Date_Creation,7,4) || "-" || substr(Date_Creation,4,2)  || "-" || substr(Date_Creation,1,2)  AS DateHeure_Notification
    -- substr(Date_Notification,7,4) || "-" || substr(Date_Notification,4,2)  || "-" || substr(Date_Notification,1,2) || " " || Heure_Notification AS DateHeure_Notification
    FROM Storage
    -- where DateHeure_Notification = "-- "
    where Date_Notification = ""
UNION ALL
SELECT NoOFL,
    substr(Date_Creation,7,4) || "-" || substr(Date_Creation,4,2)  || "-" || substr(Date_Creation,1,2) AS Date_Creation, 
    substr(Date_Expedition,7,4) || "-" || substr(Date_Expedition,4,2)  || "-" || substr(Date_Expedition,1,2) AS Date_Expedition, 
    substr(Date_souhaitee,7,4) || "-" || substr(Date_souhaitee,4,2)  || "-" || substr(Date_souhaitee,1,2) AS Date_souhaitee, 
    -- substr(Date_Creation,7,4) || "-" || substr(Date_Creation,4,2)  || "-" || substr(Date_Creation,1,2)  AS DateHeure_Notification
    substr(Date_Notification,7,4) || "-" || substr(Date_Notification,4,2)  || "-" || substr(Date_Notification,1,2) || " " || Heure_Notification AS DateHeure_Notification
    FROM Storage
    where DateHeure_Notification <> "-- "
    
ORDER BY  NoOfl ASC
/* v_OFLX(NoOFL,Date_Creation,Date_Expedition,Date_souhaitee,DateHeure_Notification) */;
CREATE TABLE Stock(
  "Qte" INT,
  "Nom_projet" TEXT,
  "Ref" TEXT,
  "Lib" TEXT,
  "Designation" TEXT,
  "Etat" TEXT,
  "Statut" TEXT,
  "Numero_de_serie" TEXT,
  "TagIs" TEXT,
  "DateEntree" TEXT,
  "vide" TEXT
  CHECK(
        Qte=1
    AND
        Lib="Lib"
    AND
        Vide=""
    AND
        length(TagIs)=12
    AND
        substr(tagis,1,2)="TE"
    )
);
CREATE TABLE ENTREES(
  "Projet" TEXT,
  "Reference" TEXT,
  "Numero_Serie" TEXT,
  "DateEntree" TEXT,
  "APT" TEXT,
  "RefAppro" TEXT,
  "BonTransport" TEXT,
  "Libelle" TEXT,
  "TagIS" TEXT,
  "NumTag" TEXT
  CHECK(
        length(TagIs)=12
    AND
        substr(tagis,1,2)="TE"
    )
);
CREATE UNIQUE INDEX k_entrees on entrees(tagis,dateentree,reference);
CREATE VIEW v_v_typesortie as select distinct * from v_test_typesortie group by tagis
/* v_v_typesortie(GLPI,Priorite,Provenance,Reference,CP,Tagis,glpiprov,cpref,typesortie) */;
CREATE VIEW v_ref_sortie as select
substr(reference,1,3) as BU,
substr(reference,4,1) as SurFamille,
substr(reference,5,1) as SousFamille,
substr(reference,6,1) as Etat,
substr(reference,7,1) as Stock,
substr(reference,8)   as produit
,
substr(reference,4,2) as Famille,
tagis
from sorties
/* v_ref_sortie(BU,SurFamille,SousFamille,Etat,Stock,produit,Famille,Tagis) */;
CREATE VIEW v_ref_stock as select
substr(ref,1,3) as BU,
substr(ref,4,1) as SurFamille,
substr(ref,5,1) as SousFamille,
substr(ref,6,1) as Etat,
substr(ref,7,1) as Stock,
substr(ref,8)   as Produit,
substr(ref,4,2) as Famille,
Tagis
from stock
/* v_ref_stock(BU,SurFamille,SousFamille,Etat,Stock,Produit,Famille,TagIs) */;
CREATE VIEW v_LastLivMagnetik AS
with storage                as
     (
            select
                   max(datebl) as datemax
            from
                   v_sorties
                 , sorties
            where
                   adr1            like "%3 BOULEVARD ROMAIN ROLLAND%"
                   and v_sorties.tagis=sorties.tagis
     )
select
         glpi
       , count(sorties.tagis) as nb
       , datebl
       , nomclient
       , reference
       , description
       , Numeros_de_colis
       , "https://glpi.alturing.eu/front/ticket.form.php?id="
                  || glpi as "Lien"
from
         sorties
       , storage
       , v_sorties
       , OFLX
where
         sorties.tagis=v_sorties.tagis
         and datebl   > date(datemax,"-3 days")
         and adr1  like "%3 BOULEVARD ROMAIN ROLLAND%"
         and sorties.NumeroOFL = OFLX.NoOFL
group by
         reference
       , glpi
order by
         datebl desc
       , glpi
       , reference
         /* LastLivMagnetik(GLPI,nb,DateBL,NomClient,Reference,Description) */
/* v_LastLivMagnetik(GLPI,nb,DateBL,NomClient,Reference,Description,Lien) */
/* v_LastLivMagnetik(GLPI,nb,DateBL,NomClient,Reference,Description,Numeros_de_colis,Lien) */;
CREATE TABLE OFLX(
      "RefClient" TEXT,
      "Projet" TEXT,
      "Type" TEXT,
      "NoOFL" TEXT NOT NULL,
      "Priorite" TEXT,
      "Date_Creation" TEXT,
      "Date_Expedition" TEXT,
      "Societe" TEXT,
      "Nom_Client" TEXT,
      "Adresse" TEXT,
      "Code_Postal" TEXT,
      "Destination" TEXT,
      "Date_souhaitee" TEXT,
      "Date_Notification" TEXT,
      "Heure_Notification" TEXT,
      "Numeros_de_colis" TEXT,
      "vide" TEXT
      check (
            instr(Date_Expedition,"/")=3
        AND instr(Date_souhaitee,"/")=3
        AND vide=""
      )
);
CREATE UNIQUE INDEX k_ofl on oflx(noofl);
CREATE VIEW v_sn_entrees as
select tagis,numero_serie as SN from entrees where numero_serie not like "S________" OR (numero_serie like "S________" AND libelle not like "%lenovo%" and libelle not like "%generique%")
union
select tagis,substr(numero_serie,2,8) as SN from entrees where numero_serie like "S________" AND (libelle like "%lenovo%" or libelle like "%generique%")
/* v_sn_entrees(TagIS,SN) */;
CREATE VIEW v_sn_stock as
select tagis,numero_de_serie as SN from stock where numero_de_serie not like "S________" OR (numero_de_serie like "S________" AND Designation not like "%lenovo%" and Designation not like "%generique%")
union
select tagis,substr(numero_de_serie,2,8) as SN from stock where numero_de_serie like "S________" AND (Designation like "%lenovo%" or Designation like "%generique%")
/* v_sn_stock(TagIs,SN) */;
CREATE VIEW v_1moisLivMagnetik AS
with storage                as
     (
            select
                   max(datebl) as datemax
            from
                   v_sorties
                 , sorties
            where
                   adr1            like "%3 BOULEVARD ROMAIN ROLLAND%"
                   and v_sorties.tagis=sorties.tagis
     )
select
         glpi as GLPI
       , datebl as env
       , oflx.societe as proj
       , Numeros_de_colis as lieu
       , count(sorties.tagis) as qte
       , reference as ref
       , description as lib
       , nom_client as dem

from
         sorties
       , storage
       , v_sorties
       , OFLX
where
         sorties.tagis=v_sorties.tagis
         and datebl   > date(datemax,"-1 month")
         and adr1  like "%3 BOULEVARD ROMAIN ROLLAND%"
         and sorties.NumeroOFL = OFLX.NoOFL
group by
         reference
       , glpi
order by
         datebl desc
       , glpi
       , reference
/* v_1moisLivMagnetik(GLPI,env,proj,lieu,qte,ref,lib,dem) */;
CREATE VIEW v_SORTIES AS 
    SELECT
        "TagIS"
,       date(substr(DateCreation,7,4) || "-" || substr(DateCreation,4,2) || "-" ||  substr(DateCreation,1,2))  AS DateCreation
,       date(substr("Date BL",7,4) || "-" || substr("Date BL",4,2) || "-" ||  substr("Date BL",1,2))  AS DateBL
,       substr(reference,1,3) AS BU
,       substr(reference,4,1) AS "SurFamille"
,       substr(reference,5,1) AS "Sousfamille"
,       substr(reference,4,1) AS "Famille"
,       substr(reference,6,1) AS "Etat"
,       substr(reference,7,1) AS "Stock"
,       substr(reference,8,3) AS "Produit"
    FROM SORTIES
    WHERE "Date BL" LIKE "__/__/____"
UNION ALL
    SELECT
        "TagIS"
,       date(substr(DateCreation,7,4) || "-" || substr(DateCreation,4,2) || "-" ||  substr(DateCreation,1,2))  AS DateCreation
,       date(substr(DateCreation,7,4) || "-" || substr(DateCreation,4,2) || "-" ||  substr(DateCreation,1,2),"+1 day")  AS DateBL
,       substr(reference,1,3) AS BU
,       substr(reference,4,1) AS "SurFamille"
,       substr(reference,5,1) AS "Sousfamille"
,       substr(reference,4,1) AS "Famille"
,       substr(reference,6,1) AS "Etat"
,       substr(reference,7,1) AS "Stock"
,       substr(reference,8,3) AS "Produit"
    FROM SORTIES
    WHERE "Date BL" =""
/* v_SORTIES(Tagis,DateCreation,DateBL,BU,SurFamille,Sousfamille,Famille,Etat,Stock,Produit) */;
CREATE VIEW v_PM_sorties as select count(sorties.tagis) as NB,strftime("%Y-%m",datebl) as mois,produit,description from sorties,v_sorties where sorties.tagis=v_sorties.tagis group by mois,produit order by mois,produit
/* v_PM_sorties(NB,mois,Produit,Description) */;
CREATE UNIQUE INDEX k_Stock ON STOCK(TagIs);
CREATE UNIQUE INDEX k_Stock_CI ON STOCK(TagIs COLLATE NOCASE);
CREATE INDEX k_SN_Stock_CI ON Stock(Numero_de_serie COLLATE NOCASE);
CREATE INDEX k_datebl_sorties on sorties("Date BL");
CREATE INDEX k_RG_Sorties ON SORTIES(Reference, GLPI);
CREATE INDEX k_SN_Entrees_CI ON ENTREES(Numero_Serie COLLATE NOCASE);
CREATE VIEW v_entrees as
    select tagis
,    reference
,   substr(dateentree,7,4) || "-" || substr(dateentree,4,2) || "-" || substr(dateentree,1,2) || substr(dateentree,11) as DateEntree,       substr(reference,1,3) AS BU
,   substr(reference,4,1) AS "SurFamille"
,   substr(reference,5,1) AS "Sousfamille"
,   substr(reference,4,1) AS "Famille"
,   substr(reference,6,1) AS "Etat"
,   substr(reference,7,1) AS "Stock"
,   substr(reference,8,3) AS "Produit"
from entrees
/* v_entrees(TagIS,Reference,DateEntree,BU,SurFamille,Sousfamille,Famille,Etat,Stock,Produit) */;
CREATE VIEW v_Retour_UC_Windows2mois AS
SELECT
         sn
       , entrees.tagis
       , entrees.reference
       , libelle
       , v_entrees.dateentree
FROM
         entrees
       , v_entrees
       , v_sn_entrees
WHERE
         entrees.tagis=v_sn_entrees.tagis
     AND entrees.tagis=v_entrees.tagis
     AND entrees.tagis IN
         (
                SELECT DISTINCT
                       entrees.tagis
                FROM
                       entrees
                WHERE
                       entrees.tagis > "TE"
                                     || substr(strftime("%Y%m%d",date("now", "-2 month")),3)
                   AND numero_serie > " "
         )
         AND
         (
                  entrees.reference IN ("UC","PORTABLE")
               or entrees.reference like "___10R%"
               or entrees.reference like "___11R%"
         )
GROUP BY
         entrees.tagis
HAVING
         entrees.libelle   NOT LIKE "%FREEDOS%"
     AND entrees.reference NOT LIKE "%STT"
ORDER BY
         entrees.tagis
/* v_Retour_UC_Windows2mois(SN,TagIS,Reference,Libelle,DateEntree) */;
CREATE VIEW v_1er_sn_entree as
with storage as (
  select distinct v_entrees.dateentree,sn
    from entrees,v_sn_entrees,v_entrees
    where entrees.tagis=v_entrees.tagis
    and entrees.tagis=v_sn_entrees.tagis
    and v_sn_entrees.sn in (
      select sn  from stock,v_stock,v_sn_stock
        where stock.tagis=v_stock.tagis 
        and surfamille in ("1","3","4","6") and sousfamille <> "9"
        and length(stock.numero_de_serie)>3
        and stock.tagis=v_sn_stock.tagis
    )
)
-- select dateentree,sn
select min(dateentree) as Date1eEntree,sn
  from storage
 group by sn
  order by sn 
-- limit 10
/* v_1er_sn_entree(Date1eEntree,sn) */;
CREATE VIEW v_1ere_entree AS
SELECT
       refappro
     , v_entrees.dateentree
     , v_sn_entrees.sn
     , entrees.tagis
     , entrees.reference
     , libelle
     , apt
     , projet
FROM
         entrees
     , v_entrees
     , v_1er_sn_entree
     , v_sn_entrees
WHERE
       entrees.tagis=v_entrees.tagis
   AND surfamille in ("1","3","4","6")
   AND sousfamille         <> "9"
   AND entrees.tagis        =v_sn_entrees.tagis
   AND v_sn_entrees.sn      = v_1er_sn_entree.sn
   AND v_entrees.dateentree = v_1er_sn_entree.Date1eEntree
/* v_1ere_entree(RefAppro,DateEntree,SN,TagIS,Reference,Libelle,APT,Projet) */;
