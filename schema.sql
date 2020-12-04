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
CREATE VIEW v_PM_sorties as select count(sorties.tagis) as NB,strftime("%Y-%m",datebl) as mois,produit,description from sorties,v_sorties where sorties.tagis=v_sorties.tagis group by mois,produit order by mois,produit
/* v_PM_sorties(NB,mois,Produit,Description) */;
CREATE UNIQUE INDEX k_Stock ON STOCK(TagIs);
CREATE UNIQUE INDEX k_Stock_CI ON STOCK(TagIs COLLATE NOCASE);
CREATE INDEX k_SN_Stock_CI ON Stock(Numero_de_serie COLLATE NOCASE);
CREATE INDEX k_datebl_sorties on sorties("Date BL");
CREATE INDEX k_RG_Sorties ON SORTIES(Reference, GLPI);
CREATE INDEX k_SN_Entrees_CI ON ENTREES(Numero_Serie COLLATE NOCASE);
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
         substr(Nom_projet,1,3) as BU, -- préférer nom_projet plutôt que le début de la référence afin de ne pas être perturbé par les articles génériques n'ayant pas une référence normalisée tels que les baies ou switches
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
CREATE VIEW V_TARIF AS
SELECT Cat, REPLACE(ReceptionUnitaire,",",".") as ReceptionUnitaire, REPLACE(Swap,",",".") AS Swap, REPLACE(StockageUnitaireParSemaine,",",".") AS StockageUnitaireParSemaine, REPLACE(Expedition,",",".") AS Expedition, REPLACE(Transfert,",",".") AS Transfert, REPLACE(SortieManuelle,",",".") AS SortieManuelle FROM TARIF
/* V_TARIF(Cat,ReceptionUnitaire,Swap,StockageUnitaireParSemaine,Expedition,Transfert,SortieManuelle) */;
CREATE TABLE Catalogue(
    Ref TEXT ,
    ReferenceGen TEXT ,
    ReferenceAlt TEXT ,
    MagasinDest TEXT ,
    Famille TEXT ,
    Designation TEXT ,
    Categorie TEXT ,
    Kg NUM ,
    Partenaire TEXT ,
    Projet TEXT ,
    Active TEXT ,
    Vide TEXT NOT NULL
        CHECK(
                Active IN ("Oui","Non")
        )
);
CREATE TRIGGER T_kg_catalogue
    AFTER INSERT ON catalogue
WHEN new.kg like "%,%"
BEGIN
   UPDATE catalogue
   SET kg=REPLACE(NEW.Kg,",",".")
   WHERE kg like "_,_"
   ;
END;
CREATE TABLE Tarif(
    Cat                         TEXT NOT NULL,
    Libelle                     TEXT NOT NULL,
    Designation                 TEXT NOT NULL,
    Commentaire                 TEXT NOT NULL,
    ReceptionUnitaire           NUM  NOT NULL,
    Swap                        NUM  NOT NULL,
    StockageUnitaireParSemaine  NUM  NOT NULL,
    Expedition                  NUM  NOT NULL,
    Transfert                   NUM  NOT NULL,
    SortieManuelle              NUM  NOT NULL
        CHECK(ReceptionUnitaire LIKE "%,%")
);
CREATE UNIQUE INDEX K_Tarif on tarif(cat);
CREATE VIEW v_Entrees as
    select tagis
,    reference
,   substr(dateentree,7,4) || "-" || substr(dateentree,4,2) || "-" || substr(dateentree,1,2) || substr(dateentree,11) as DateEntree
,   substr(reference,1,3) AS BU
,   substr(reference,4,1) AS "SurFamille"
,   substr(reference,5,1) AS "Sousfamille"
,   substr(reference,4,2) AS "Famille"
,   substr(reference,6,1) AS "Etat"
,   substr(reference,7,1) AS "Stock"
,   substr(reference,8,3) AS "Produit"
FROM Entrees
/* v_Entrees(TagIS,Reference,DateEntree,BU,SurFamille,Sousfamille,Famille,Etat,Stock,Produit) */;
CREATE VIEW v_Sorties AS
    SELECT
        "TagIS"
,       date(substr(DateCreation,7,4) || "-" || substr(DateCreation,4,2) || "-" ||  substr(DateCreation,1,2))  AS DateCreation
,       date(substr("Date BL",7,4) || "-" || substr("Date BL",4,2) || "-" ||  substr("Date BL",1,2))  AS DateBL
,       substr(reference,1,3) AS BU
,       substr(reference,4,1) AS "SurFamille"
,       substr(reference,5,1) AS "Sousfamille"
,       substr(reference,4,2) AS "Famille"
,       substr(reference,6,1) AS "Etat"
,       substr(reference,7,1) AS "Stock"
,       substr(reference,8,3) AS "Produit"
    FROM Sorties
    WHERE "Date BL" LIKE "__/__/____"
UNION ALL
    SELECT
        "TagIS"
,       date(substr(DateCreation,7,4) || "-" || substr(DateCreation,4,2) || "-" ||  substr(DateCreation,1,2))  AS DateCreation
,       date(substr(DateCreation,7,4) || "-" || substr(DateCreation,4,2) || "-" ||  substr(DateCreation,1,2),"+1 day")  AS DateBL
,       substr(reference,1,3) AS BU
,       substr(reference,4,1) AS "SurFamille"
,       substr(reference,5,1) AS "Sousfamille"
,       substr(reference,4,2) AS "Famille"
,       substr(reference,6,1) AS "Etat"
,       substr(reference,7,1) AS "Stock"
,       substr(reference,8,3) AS "Produit"
    FROM Sorties
    WHERE "Date BL" =""
/* v_Sorties(Tagis,DateCreation,DateBL,BU,SurFamille,Sousfamille,Famille,Etat,Stock,Produit) */;
CREATE TABLE familles(
CodeFamille int not null,
CodeType text not null,
LibFamille text not null,
LibType text not null,
Proposition text
check(codefamille>0
AND codefamille<=9
AND length(codetype)=1
)
);
CREATE UNIQUE INDEX k_famille on familles(codefamille,codetype);
CREATE VIEW v_familles as select codefamille || codetype as famille,codefamille as surfamille,codetype as sousfamille,libfamille as nom,
case
when proposition > "" then proposition 
else libtype 
end prenom
from familles
order by surfamille,sousfamille
/* v_familles(famille,surfamille,sousfamille,nom,prenom) */;
CREATE VIEW v_sorties_portables_CHR as
with storage as (
select strftime("%Y-%m",datebl) as mois,count(v_sorties.tagis) as Neufs,0 as Recond 
from v_sorties,v_v_typesortie
where v_sorties.famille="11" and v_sorties.etat="N" and v_sorties.BU="CHR" and v_sorties.tagis=v_v_typesortie.tagis and v_v_typesortie.typesortie in ("DEM","INC") 
group by mois,etat

UNION
select strftime("%Y-%m",datebl) as mois,0 as Neufs,count(v_sorties.tagis) as Recond 
from v_sorties,v_v_typesortie
where v_sorties.famille="11" and v_sorties.etat="R" and v_sorties.BU="CHR" and v_sorties.tagis=v_v_typesortie.tagis and v_v_typesortie.typesortie in ("DEM","INC") 
group by mois,etat
)
select date(Mois || "-28","+1 month","start of month","-1 day") as Mois,sum(neufs) as Neufs,sum(recond) as Recond from storage group by mois order by mois
/* v_sorties_portables_CHR(Mois,Neufs,Recond) */;
CREATE VIEW v_sorties_portables_CHR_13mois AS
with storage as (
select date(strftime("%Y-%m-28",datebl),"+1 month","start of month","-1 day") as MoisRef from v_sorties where datebl > date("now","start of month","-13 months") group by moisref 
)
select max(mois) as Mois,sum(neufs) as Neufs,sum(recond) as Recond from v_sorties_portables_chr,storage where mois between date(moisref,"-1 year") and moisref group by moisref
/* v_sorties_portables_CHR_13mois(Mois,Neufs,Recond) */;
CREATE VIEW v_TEexport as
-- re-création de l'export quotidien envoyé par l'automate
with storage as (select max(dateimport) as maxdate from histostock) select Projet, Reference, Designation, OkDispo, OkReserve, SAV, Maintenance, Destruction, Alivrer, dateimport from histostock,storage where dateimport=maxdate
/* v_TEexport(Projet,Reference,Designation,OkDispo,OkReserve,SAV,Maintenance,Destruction,Alivrer,dateimport) */;
CREATE TABLE AuditADB(
    NUMERO_ADB TEXT NOT NULL,
    DATE_AUDIT TEXT NOT NULL,
    TYPE_MATERIEL TEXT NOT NULL,
    SYSTEM_MANUFACTURER TEXT NOT NULL,
    SYSTEM_MODEL TEXT NOT NULL,
    SYSTEM_SERIAL TEXT NOT NULL,
    CPU_MODEL TEXT NOT NULL,
    DISK_CAPACITY TEXT NOT NULL,
    MEMORY_CAPACITY TEXT NOT NULL,
    OPTICAL_DRIVE_TYPE TEXT NOT NULL,
    OS TEXT NOT NULL,
    VALEUR_REPRISE INT NOT NULL,
    GRADE TEXT NOT NULL,
    COMMMENTAIRES TEXT NOT NULL,
    NUMERO_PALETTE TEXT NOT NULL,
    FA TEXT NOT NULL,
    CLIENT TEXT NOT NULL
    
    CHECK(
        DATE_AUDIT LIKE "__/__/____ __:__"
    AND GRADE BETWEEN "A" AND "Z"
    AND LENGTH(GRADE)=1
    )
);
CREATE INDEX K_SoPriPro on SORTIES(PRIORITE,PROVENANCE);
CREATE VIEW v_test_typesortie as
select distinct  GLPI,Priorite,Provenance,Reference,CP,Tagis,glpiprov,cpref,"RMA1" as typesortie from  v_temp_typesortie
where glpiprov like "%NAV%" or glpiprov like "%RMA%" or glpiprov like "%RETOUR%" or glpiprov like "%REPAR%"
-- NAVETTE, RMA, RETOUR, REPARATION => RMA
UNION
select distinct  GLPI,Priorite,Provenance,Reference,CP,Tagis,glpiprov,cpref,"RMA2" as typesortie from  v_temp_typesortie
where cpref like "94043C__34%" or cpref like "77600C__34%" or cpref like "91019CLP34%" or cpref like "94360CHR63%" or cpref like "69750%DIV%"
-- Ancienne et nouvelle adresse de LVI, SCC, Athesi,HubOne => RMA
UNION

select distinct  GLPI,Priorite,Provenance,Reference,CP,Tagis,glpiprov,cpref,"DEM" as typesortie from  v_temp_typesortie
where glpiprov like "%PR%" or glpiprov like "%dem%" or glpiprov like "%dep%" or glpiprov like "%re%conf%"
-- production ou préparation ou projet, demande, deploiement, reconfiguration => DEMande
UNION
select distinct  GLPI,Priorite,Provenance,Reference,CP,Tagis,glpiprov,cpref,"DEL" as typesortie from  v_temp_typesortie
where glpiprov like "%PAL%" or glpiprov like "%deS%"
-- PALette ou DEStruction => DEL
UNION
select distinct  GLPI,Priorite,Provenance,Reference,CP,Tagis,glpiprov,cpref,"INC" as typesortie from  v_temp_typesortie
where glpiprov like "%SW%P%" OR glpiprov like "%SWA%" OR glpiprov like "%INC%" OR (priorite="P2" and glpi like "__________" and provenance not like "_E%")
/* v_test_typesortie(GLPI,Priorite,Provenance,Reference,CP,Tagis,glpiprov,cpref,typesortie) */;
CREATE VIEW V_debug_typesortie AS
SELECT *,
    CASE
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

FROM V_DossierValide
/* V_debug_typesortie(Dossier,GLPI,Priorite,Provenance,Reference,Societe,CP,Ville,Tagis,NumeroOfl,NumSerie,DateBL,BU,SurFamille,Sousfamille,Famille,Etat,Stock,Produit,TypeSortie) */;
CREATE TABLE SFPliste(
    CodeStat    TEXT NOT NULL PRIMARY KEY,
    LibStat     TEXT NOT NULL,
    Seuil       INTEGER NOT NULL
);
CREATE TABLE SFPproduits(
    CodeStat    TEXT NOT NULL,
    Reference   TEXT NOT NULL
);
CREATE UNIQUE INDEX K_SFPP on sfpproduits(reference);
CREATE VIEW v_dernierimport AS
-- rappel de la dernière date d'import des données
select max(dateimport) as maxdate from histostock
/* v_dernierimport(maxdate) */;
CREATE TABLE IF NOT EXISTS "sfpSorties"(
    CodeStat    TEXT NOT NULL,
    DateStat    TEXT NOT NULL,
    INC         INTEGER NOT NULL DEFAULT 0,
    DEM         INTEGER NOT NULL DEFAULT 0,
    RMA         INTEGER NOT NULL DEFAULT 0,
    DEL         INTEGER NOT NULL DEFAULT 0,
    DIV         INTEGER NOT NULL DEFAULT 0
);
CREATE TABLE ISIResultats(
    Jour TEXT NOT NULL,
    Code TEXT NOT NULL,
    Nombre INTEGER NOT NULL DEFAULT 0
    CHECK( Code like "ISI-%")
);
CREATE TABLE IncProdIS(
  "ID" TEXT,
  "Titre" TEXT,
  "Entité" TEXT,
  "Statut" TEXT,
  "Contact / Bénéficiaire - Contact / Bénéficiaire" TEXT,
  "Catégorie" TEXT,
  "Priorité" TEXT,
  "Dernière modification" TEXT,
  "Appelant / Demandeur - Appelant / Demandeur" TEXT,
  "Contact / Bénéficiaire - Emplacement" TEXT,
  "Plugins - Contrat" TEXT,
  "Description" TEXT,
  "Tâches - Description" TEXT,
  "Type" TEXT,
  "Tâches - Date" TEXT,
  "" TEXT
);
CREATE TABLE codeserreur(
    code text,
    sujet text,
    description text
    CHECK(substr(code,1,4)="ISI-")
    -- le check est là pour éviter d'insérer la ligne de titre comme faisant partie des données
, abrege text);
CREATE TABLE Resultats(
    Jour TEXT NOT NULL,
    Code TEXT NOT NULL,
    Nombre INTEGER NOT NULL DEFAULT 0
    CHECK( Code like "ISI-%")
);
CREATE UNIQUE INDEX k_ISIr on Resultats(Jour,Code);
CREATE TABLE matosreseau(
  "dossier" TEXT,
  "tagis" TEXT,
  "sn" TEXT,
  "modèle" TEXT,
  "Projet" TEXT,
  "CdP" TEXT
);
CREATE TABLE SuiviMVT(
    DateVu tTEXT NOT NULL DEFAULT "",
    Donnee TEXT NOT NULL DEFAULT "Dossier",
    Valeur TEXT NOT NULL DEFAULT "",
    DateSurv TEXT NOT NULL DEFAULT "",
    Motif   TEXT NOT NULL DEFAULT ""
    CHECK (
        (datevu LIKE "____-__-__" or datevu="")
    AND
            (datesurv LIKE "____-__-__")
    AND
        (date(datevu) >= date(datesurv) OR datevu="")
    AND (Donnee IN ("Dossier","Livraison","Colis")        )
    AND (length(valeur) between 10 and 13)
    )
);
CREATE UNIQUE INDEX k_SurvS ON SuiviMVT(Donnee,Valeur);
CREATE TABLE sqliteshow(
Donnee text not null primary key,
valeur text
);
CREATE VIEW v_sqliteshow as select donnee,valeur from sqliteshow
/* v_sqliteshow(Donnee,valeur) */;
CREATE TRIGGER T_show
   INSTEAD OF INSERT ON v_sqliteshow
-- WHEN new.donnee = old.donnee 
BEGIN
   -- set 
   REPLACE into sqliteshow(valeur,donnee) values(new.valeur,new.donnee)
   -- WHERE donnee=new.donnee
   ;
END;
CREATE VIEW v_SuiviMvt AS
-- 11:26 28/09/2020 Listage des mouvements I&S à suivre qui viennent d'être détectés comme étant effectués.
-- Doit être exécuté aussitôt après l'exécution du script SuiviMvt.sql
-- 15:36 29/09/2020 MODIF : Supprime les crochets et virgules dans les numéros des colis expédiés (pas besoin de le faire dans les colis reçus)
-- 14:06 01/10/2020 Rajoute la date de début de surveillance, affiche les mouvements surveillés mais pas encore vus et les mouvements vus depuis moins d'un mois (au lieu de juste la journée précédemment)
WITH storage AS
     (
               SELECT -- sorties
                         Donnee
                       , Valeur
                       , DateBL AS DateMvt
                       , DateSurv
                       , Reference
                       , Description AS Designation
                       , NumSerie
                       , sDepot AS Stock
                       -- , NumeroOFL aucune utilité
                       , REPLACE(REPLACE(REPLACE(numeros_de_colis,"[",""),"]",""),","," ") AS Transport
                       , sorties.Societe  AS Societe
                       , SORTIES.TagIS
                       , Motif
               FROM
                         SORTIES
                       , SuiviMvt
                       , v_SORTIES
                         LEFT JOIN
                                   OFLX
                                   ON
                                             OFLX.refclient = Valeur
               WHERE
                             DateVu    >=DATE("now","-1 month")
                         AND Donnee="Dossier"
                         AND Valeur=glpi
                         AND SORTIES.TagIS=v_SORTIES.TagIS
               -- GROUP BY -- la présence de cette clause perturbe l'affichage des quantités en sortie
                         -- Valeur
                       -- , Reference
               -- ORDER BY Valeur
               -- ;
               UNION
               SELECT -- -- -- dossiers (reste quelques cas de doublons)
                      -- count(Entrees.TagIS) AS Nb,
                       Donnee
                    , Valeur
                    , DATE(v_Entrees.DateEntree) AS DateVu
                    , DateSurv
                    , Entrees.Reference
                    , Libelle
                    , Numero_Serie
                    , Projet
                    -- , APT doublon avec la colonne "valeur" si on cherche sur APT, inutile sinon
                    , BonTransport
                    , RefAppro
                    , Entrees.TagIS AS TagIS
                    , Motif
               FROM
                      SuiviMvt
                    , Entrees
                    , v_Entrees
               WHERE
                         
                          DateVu    >=DATE("now","-1 month")
                      AND Donnee                ="Dossier"
                      AND v_Entrees.DateEntree >= datesurv
                      AND Entrees.TagIS         =v_Entrees.TagIS
                      AND RefAppro           like "%"
                             || Valeur
                             || "%"
               -- GROUP BY Valeur,Numero_Serie
               -- ;
               UNION
               SELECT -- -- -- APT
                      -- count(Entrees.TagIS) AS Nb,
                      Donnee
                    , Valeur
                    , date(v_Entrees.DateEntree) AS DateVu
                    , DateSurv
                    , Entrees.Reference
                    , Libelle
                    , Numero_Serie
                    , Projet
                    -- , APT doublon avec la colonne "valeur" si on cherche sur APT, inutile sinon
                    , BonTransport
                    , RefAppro
                    , Entrees.TagIS AS TagIS
                    , Motif
               FROM
                      SuiviMvt
                    , Entrees
                    , v_Entrees
               WHERE
                          DateVu    >=DATE("now","-1 month")
                      AND Donnee                ="Livraison"
                      AND v_Entrees.DateEntree >= datesurv
                      AND Entrees.TagIS         =v_Entrees.TagIS
                      AND APT                like "%"
                             || Valeur
                             || "%"
               -- GROUP BY Valeur
               -- ;
               UNION
               SELECT -- -- Colis
                        -- count(v_Entrees.TagIS) AS Nb,
                        Donnee
                      , Valeur
                      , date(v_Entrees.DateEntree) AS DateVu
                      , DateSurv
                      , Entrees.Reference
                      , Libelle
                      , Numero_Serie
                      , Projet
                      -- , APT doublon avec la colonne "valeur" si on cherche sur APT, inutile sinon
                      , BonTransport
                      , RefAppro
                      , Entrees.TagIS AS TagIS
                      , Motif
               FROM
                        SuiviMvt
                      , Entrees
                      , v_Entrees
               WHERE
                            DateVu    >=DATE("now","-1 month")
                        AND Donnee                ="Colis"
                        AND v_Entrees.DateEntree >= datesurv
                        AND Entrees.TagIS         =v_Entrees.TagIS
                        AND BonTransport       like "%"
                                 || Valeur
                                 || "%"
               GROUP BY
                        Entrees.TagIS
                        -- GROUP BY Valeur
                        -- ;
               UNION
               SELECT
                         Donnee
                       , Valeur
                       , "N/A"  AS DateVu
                       , DateSurv
                       , ""     AS Reference
                       , ""     AS Designation
                       , ""     AS NumSerie
                       , ""     AS Stock
                       , ""     AS Transport
                       , ""     AS Societe
                       , ""     AS TagIS
                       , Motif 
               FROM SuiviMvt
               WHERE DateVu=""
     )
SELECT DISTINCT
         (COUNT(TagIS) * (DateMvt >"")) AS Qte -- nombre de lignes concernées par le mouvement
       , *
FROM
         storage
         -- WHERE Donnee="Dossier"
GROUP BY
         Valeur
       , Reference  -- une ligne par dossier/colis/apt et référence d'article différente
/* v_SuiviMvt(Qte,Donnee,Valeur,DateMvt,DateSurv,Reference,Designation,NumSerie,Stock,Transport,Societe,TagIS,Motif) */;
CREATE VIEW v_TransposeStatsSorties AS
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
/* v_TransposeStatsSorties(CodeStat,INC,DEM,RMA,DEL,ATL,IND,DateStat) */;
CREATE TABLE ProjetsDeploiements (
    CodeProjet  TEXT NOT NULL PRIMARY KEY,
    NomProjet   TEXT NOT NULL DEFAULT ""
);
CREATE VIEW v_SuiviDeploiements as 
-- Nécessité d'un trigger avec clause instead pour inserrer, donc on le fera sur cette vue
select CodeSite,CodeProjet,Dossier from SuiviDeploiements
/* v_SuiviDeploiements(CodeSite,CodeProjet,Dossier) */;
CREATE TRIGGER Ti_SuiviDeploiements
-- sans ça, l'INSERT échoue et arrête le script
-- résultat de ce trigger, on ajoute uniquement les lignes qui n'existent pas encore sans toucher aux autres
INSTEAD OF INSERT ON v_SuiviDeploiements
WHEN NOT EXISTS (select * from suivideploiements where suivideploiements.codesite=new.codesite and suivideploiements.codeprojet=new.codeprojet)
BEGIN
    INSERT into suivideploiements(codesite,CodeProjet) select CodeColissimo,"PMCOLLX" from deplpmlxcol where CodeColissimo=new.codesite 
    ;
END;
CREATE VIEW v_ProchaineDate AS
select min(date(migration,"-7 days")) AS ProchaineDate,CodeColissimo,site from deplpmlxcol,suivideploiements
where codesite=CodeColissimo and CodeProjet="PMCOLLX" and dossier=0
/* v_ProchaineDate(ProchaineDate,CodeColissimo,SITE) */;
CREATE TABLE DEPLPMLXCOL (
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
CREATE TRIGGER Tu_SuiviDeploiements
-- sans ça, l'INSERT échoue et arrête le script
-- résultat de ce trigger, on ajoute uniquement les lignes qui n'existent pas encore sans toucher aux autres
INSTEAD OF INSERT ON v_SuiviDeploiements
WHEN EXISTS (select * from suivideploiements where suivideploiements.codesite=new.codesite and suivideploiements.codeprojet=new.codeprojet)
BEGIN
    UPDATE suivideploiements set dossier=new.dossier WHERE codesite=new.codesite  AND CodeProjet="PMCOLLX"
    ;
END;
CREATE TABLE SuiviDeploiements (
-- indispensable pour pouvoir ne pas sélectionner les déploiements auxquel un dossier est déjà affecté
-- /!\ Attention, nécessité d'un trigger donc on inserre sur la vue et non sur la table
    CodeSite    TEXT  NOT NULL,
    CodeProjet  TEXT NOT NULL,
    Dossier     INTEGER NOT NULL DEFAULT 0
);
CREATE UNIQUE INDEX K_SD on SuiviDeploiements(CodeSite,CodeProjet);
CREATE VIEW v_CreationDossierAbregee AS
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
/* v_CreationDossierAbregee(Creation,SITE,CodeColissimo,Envoi,"SITE:1",NOM,ADR1,ADR2,CPV) */;
CREATE TABLE sfpStats(
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
CREATE UNIQUE INDEX k_sfpStats ON sfpStats(DateStat,CodeStat);
CREATE VIEW V_StatIS AS
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
/* V_StatIS(DateStat,Incident,Demande,RMA,Destruction,undef,CodeStat,OkDispo,OkReserve,SAV,Maintenance,"Destruction:1",Alivrer,"CodeStat:1",Seuil,LibStat) */;
CREATE VIEW V_ValCatalogue AS

-- CREATE VIEW V_Catalogue AS
SELECT
    Ref AS Reference,

    -- SUBSTR(Ref,1,3) AS BU,
    -- SUBSTR(Ref,4,1) AS SurFamille,
    -- SUBSTR(Ref,5,1) AS SousFamille,
    -- SUBSTR(Ref,6,1) AS Etat,
    -- SUBSTR(Ref,7,1) AS Stock,
    -- SUBSTR(Ref,8)   AS Produit,
    SUBSTR(Ref,4,2) AS Famille,

    Categorie,
    CAST(REPLACE(Kg,",",".")          AS NUMERIC) AS Kg,
    -- Active,
    -- Projet
    -- ,
    CAST(REPLACE(ReceptionUnitaire,",",".")          AS NUMERIC) AS Cout_Reception,
    CAST(REPLACE(Swap,",",".")                       AS NUMERIC) AS Cout_Swap,
    CAST(REPLACE(StockageUnitaireParSemaine,",",".") AS NUMERIC) AS Cout_StockHebdo,
    CAST(REPLACE(Expedition,",",".")                 AS NUMERIC) AS Cout_Expedition,
    CAST(REPLACE(Transfert,",",".")                  AS NUMERIC) AS Cout_Transfert,
    CAST(REPLACE(SortieManuelle,",",".")             AS NUMERIC) AS Cout_SortieManuelle
    
FROM    Catalogue
    ,
        Tarif
WHERE   Catalogue.Categorie=Tarif.Cat

-- ORDER BY
    -- Projet,Ref
/* V_ValCatalogue(Reference,Famille,Categorie,Kg,Cout_Reception,Cout_Swap,Cout_StockHebdo,Cout_Expedition,Cout_Transfert,Cout_SortieManuelle) */;
CREATE VIEW V_Catalogue AS
SELECT
    Ref AS Reference,

    SUBSTR(Ref,1,3) AS BU,
    SUBSTR(Ref,4,1) AS SurFamille,
    SUBSTR(Ref,5,1) AS SousFamille,
    SUBSTR(Ref,6,1) AS Etat,
    SUBSTR(Ref,7,1) AS Stock,
    SUBSTR(Ref,8)   AS Produit,
    SUBSTR(Ref,4,2) AS Famille,

    Categorie,
    Active,
    CAST(REPLACE(Kg,",",".")          AS NUMERIC) AS Kg,
    Projet,
    Designation
    -- ,
    -- CAST(REPLACE(ReceptionUnitaire,",",".")          AS NUMERIC) AS Cout_Reception,
    -- CAST(REPLACE(Swap,",",".")                       AS NUMERIC) AS Cout_Swap,
    -- CAST(REPLACE(StockageUnitaireParSemaine,",",".") AS NUMERIC) AS Cout_StockHebdo,
    -- CAST(REPLACE(Expedition,",",".")                 AS NUMERIC) AS Cout_Expedition,
    -- CAST(REPLACE(Transfert,",",".")                  AS NUMERIC) AS Cout_Transfert,
    -- CAST(REPLACE(SortieManuelle,",",".")             AS NUMERIC) AS Cout_SortieManuelle
    
FROM    Catalogue
    -- ,
        -- Tarif
-- WHERE   Catalogue.Categorie=Tarif.Cat

ORDER BY
    Projet,Ref
/* V_Catalogue(Reference,BU,SurFamille,SousFamille,Etat,Stock,Produit,Famille,Categorie,Active,Kg,Projet,Designation) */;
CREATE TABLE cataloguesrefchrsansmmvt(
    fichier text,
    Ref text,
    refgen text,
    refalt text,
    magdest text,
    famille test,
    designation text,
    cat text,
    kg text,
    partenaire text,
    projet text,
    active text
    check(active in ("Oui","Non"))
);
CREATE VIEW v_cataloguesrefchrsansmmvt as
select
    substr(fichier,14,4) || "-" || substr(fichier,18,2) || "-" || substr(fichier,20,2) as apparition,
    ref,
    projet
    from cataloguesrefchrsansmmvt
    group by apparition,ref,projet
/* v_cataloguesrefchrsansmmvt(apparition,Ref,projet) */;
CREATE VIEW vv_SuiviMvt_1mois AS
    SELECT  * 
    FROM    v_SuiviMvt
    WHERE   DateMvt >= DATE("now","-1 month") 
    OR      DateMvt="N/A"
    ORDER BY DateMvt DESC,DateSurv DESC
/* vv_SuiviMvt_1mois(Qte,Donnee,Valeur,DateMvt,DateSurv,Reference,Designation,NumSerie,Stock,Transport,Societe,TagIS,Motif) */;
CREATE VIEW vv_SuiviMvt_1jour AS
    WITH STORAGE AS ( -- Détermination de la date à partir de laquelle on recherche les mouvements
        -- Le SELECT CASE en commentaire produit les données du dernier jour ouvrable écoulé compte tenu du fait que les données sont disponibles à 19h
        -- SELECT CASE
            -- WHEN (strftime("%w",date("now")) >="1" and strftime("%w",date("now")) <"6" and strftime("%H",datetime("now","localtime") >= "19")) THEN date("now")           -- lundi à vendredi après 19h => jour même
            -- WHEN (strftime("%w",date("now")) >="2" and strftime("%w",date("now")) <"6" and strftime("%H",datetime("now","localtime") <  "19")) THEN date("now","-1 day")  -- mardi à vendredi avant 19h => la veille
            -- WHEN (strftime("%w",date("now")) = "1" and strftime("%H",datetime("now","localtime") <  "19")) THEN date("now","-3 days")      -- lundi avant 19h => 3 jours avant
            -- ELSE date("now","-" || (strftime("%w",date("now"))/6)-2 || "days")      --  samedi ou dimanche quelle que soit l'heure => vendredi précédent
        -- END querydate
        
        -- Le SELECT ci-dessous produit les donnés les plus récentes que l'on a
        SELECT max(datevu) AS querydate from suivimvt
        -- La préférence entre les deux, outre la simplicité, tient au fait que le cas le plus compliqué ne donne rien s'il n'y a rien ce jour précis alors que le plus simple donne toujiurs quelque chose*
    )
    SELECT  Valeur,printf("%3d",Qte) AS Qté,Substr(Reference,1,10) AS Référence,substr(Designation,1,40) AS Désignation,substr(Stock,instr(stock," ")+1) AS Stock,
        CASE
            WHEN Donnee="Dossier" THEN Transport
            ELSE Societe
        END Information
    ,
    Motif
    FROM    v_SuiviMvt,storage
    WHERE   DateMvt >= QueryDate AND DateMvt like "____-__-__"
    ORDER BY DateMvt DESC,DateSurv DESC
/* vv_SuiviMvt_1jour(Valeur,"Qté","Référence","Désignation",Stock,Information,Motif) */;
CREATE INDEX k_SuiviMVT_date ON SuiviMVT(DateVu DESC);
CREATE INDEX k_OFLX_RefClient ON OFLX(RefClient);
CREATE INDEX k_SORTIES_glpi ON SORTIES(GLPI);
CREATE INDEX k_SuiviMVT_Donnee_Datevu ON SuiviMVT(Donnee, DateVu);
CREATE VIEW v_sfpStats AS
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
/* v_sfpStats(DateStat,Incident,Demande,RMA,DEL,undef,CodeStat,OkDispo,OkReserve,SAV,Maintenance,Destruction,Alivrer,CodeStatBis,Seuil,LibStat) */;
CREATE INDEX k_SFPproduits_CodeStat ON SFPproduits(CodeStat);
CREATE TABLE p_Sorties(
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
CREATE UNIQUE INDEX k_Psorties ON p_Sorties(CodeStat,DateStat,ItemStat);
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
/* V_DossierValide(Dossier,GLPI,Priorite,Provenance,Reference,Societe,CP,Ville,Tagis,NumeroOfl,NumSerie,DateBL,BU,SurFamille,Sousfamille,Famille,Etat,Stock,Produit) */;
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
/* vv_Sorties(GLPI,DateBL,TypeSortie,Famille,Reference,BU,SurFamille,Sousfamille,Etat,Stock,Produit,Tagis,NumeroOfl,NumSerie,CP,Ville,Societe) */;
CREATE TABLE v_gsorties(
  "GLPI" TEXT,
  "Priorit�" TEXT,
  "Provenance" TEXT,
  "DateCr�ation" TEXT,
  "CentreCout" TEXT,
  "Reference" TEXT,
  "Description" TEXT,
  "Date BL" TEXT,
  "D�pot" TEXT,
  "sDepot" TEXT,
  "Num Serie" TEXT,
  "Nom Client L" TEXT,
  "Adr1 L" TEXT,
  "Adr2 L" TEXT,
  "Adr3 L" TEXT,
  "CP L" TEXT,
  "Dep" TEXT,
  "Ville L" TEXT,
  "Tagis" TEXT,
  "Societe L" TEXT,
  "NumeroOfl" TEXT,
  " Pays de destination" TEXT
);
CREATE TABLE g_SORTIES(
-- 12:57 20/10/2020 utilisation de la feature "generated columns"
-- /!\ L'import .csv ne marche pas en direct sur la table parce que :
--     le csv comporte moins de champs que la table ET on ne peut pas écrire sur les champs générés
-- sqlite> .import is_out_dernier.csv g_sorties
-- Error: table g_sorties has 23 columns but 25 values were supplied
-- Une généralisation de l'usage des champs calculés pourrait permettre de se passer de la vue v_sorties par exemple
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
  "Pays" TEXT,
  "Vide" TEXT default "", -- # bug de sqlite, colonne morte obligatoire entre les champs importés via csv et les champs calculés
  DateBL GENERATED ALWAYS     AS (        substr("Date BL",7,4) || "-" || substr("Date BL",4,2) || "-" || substr("Date BL",1,2))     STORED,
  DateEntree GENERATED ALWAYS AS ("20" || substr(tagis,3,2)     || "-" || substr(tagis,5,2)     || "-" || substr(tagis,7,2))     STORED
);
CREATE UNIQUE INDEX kg_sorties on g_sorties(tagis);
CREATE VIEW vg_sorties as select * from g_sorties
-- Contournement du problème d'import via un trigger instead of insert sur une table homologue à la vue
/* vg_sorties(GLPI,Priorite,Provenance,DateCreation,CentreCout,Reference,Description,"Date BL",BU,sDepot,NumSerie,NomClient,Adr1,Adr2,Adr3,CP,Dep,Ville,Tagis,Societe,NumeroOfl,Pays,Vide,DateBL,DateEntree) */
/* vg_sorties(GLPI,Priorite,Provenance,DateCreation,CentreCout,Reference,Description,"Date BL",BU,sDepot,NumSerie,NomClient,Adr1,Adr2,Adr3,CP,Dep,Ville,Tagis,Societe,NumeroOfl,Pays,Vide,DateBL,DateEntree) */;
CREATE TRIGGER tg_sorties
INSTEAD OF INSERT ON vg_sorties
-- l'utilisation de ce trigger procure toujours l'affichage d'erreurs parce qu'on importe moins de champs que ce qu'il y a dans la vue mais c'est justement corrigé par le trigger
-- is_out_dernier.csv:1362: expected 25 columns but found 22 - filling the rest with NULL
-- le champ "vide" est affecté de sa valeur par défaut (ici : "") et les champs générés sont affectés de leur valeur calculée
BEGIN
    INSERT OR REPLACE INTO g_sorties(
  "GLPI",
  "Priorite",
  "Provenance",
  "DateCreation",
  "CentreCout",
  "Reference",
  "Description",
  "Date BL",
  "BU",
  "sDepot",
  "NumSerie",
  "NomClient",
  "Adr1",
  "Adr2",
  "Adr3",
  "CP",
  "Dep",
  "Ville",
  "Tagis",
  "Societe",
  "NumeroOfl",
  "Pays"
)
values (
  new."GLPI",
  new."Priorite",
  new."Provenance",
  new."DateCreation",
  new."CentreCout",
  new."Reference",
  new."Description",
  new."Date BL",
  new."BU",
  new."sDepot",
  new."NumSerie",
  new."NomClient",
  new."Adr1",
  new."Adr2",
  new."Adr3",
  new."CP",
  new."Dep",
  new."Ville",
  new."Tagis",
  new."Societe",
  new."NumeroOfl",
  new."Pays"
);
END;
CREATE VIRTUAL TABLE posts 
USING FTS5(title, body)
/* posts(title,body) */;
CREATE TABLE IF NOT EXISTS 'posts_data'(id INTEGER PRIMARY KEY, block BLOB);
CREATE TABLE IF NOT EXISTS 'posts_idx'(segid, term, pgno, PRIMARY KEY(segid, term)) WITHOUT ROWID;
CREATE TABLE IF NOT EXISTS 'posts_content'(id INTEGER PRIMARY KEY, c0, c1);
CREATE TABLE IF NOT EXISTS 'posts_docsize'(id INTEGER PRIMARY KEY, sz BLOB);
CREATE TABLE IF NOT EXISTS 'posts_config'(k PRIMARY KEY, v) WITHOUT ROWID;
CREATE TABLE SuiviChgt(
  "Titre" TEXT,
  "Entite" TEXT,
  "ID" INTEGER,
  "Statut" TEXT,
  "Urgence" TEXT,
  "Contact" TEXT,
  "Responsable" TEXT,
  "NbDocuments" TEXT,
  "Description" TEXT,
  "Ouverture" TEXT,
  "Cloture" TEXT,
  "Attribution" TEXT,
  "Modification" TEXT
  CHECK(
    id +1 -1 = id -- vérifie que l'id est de type numérique afin d'exclure la ligne d'en-tête
  )
);
CREATE VIEW v_CreationDossier AS
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
/* v_CreationDossier(Creation,"""Client                : ACP > "" || SITE","""Catégorie             : Demande de matériel > Matériel réseau et serveur > Demande d'installation serveur agence""","""Attribué à            : I&S_DEPART""","""Appelant / Demandeur  : COUGOULAT PATRICE""","""Contact               : "" || NOM","""Titre                 : DEPLOIEMENT Postes Maîtres Colissimo Linux de "" || SITE","""Description           :""","""Depuis le stock COLIPOSTE FIL DE L'EAU préparer""","""2 CLPMETL POSTE MAITRE COLISSIMO LINUX""","""selon la nouvelle procédure [SOP_PRC_COL Production de poste maitre.docx] disponible sur le serveur I&S (WIGNV1) dans Coliposte\Poste Maitre Linux\ ""","""CODE Colissimo : "" || CodeColissimo","""Nom des postes : PM-"" || CodeColissimo || ""-1 et PM-"" || CodeColissimo || ""-2""","""En cas de problème avec les fichiers de configuration notifier le dossier à N2_SYSTEME""","""""",Envoi,"""Coordonnées d'expédition :""",site,"""attn : "" || trim(NOM)",ADR1,ADR2,CPV,""""":1",""""":2") */;
CREATE TABLE cablesprojets(
    Annee   integer,
    QtIn    integer,
    E_In    NUMBER,
    QStock INTEGER,
    E_Stockage NUMERIC,
    QtOut   integer,
    E_Out   NUMBER,
    Q10Out INTEGER
    check(annee between 2016 and 2020)
);
CREATE UNIQUE INDEX k_cpa on cablesprojets(annee);
CREATE VIEW V_audit AS
SELECT 
Tagis,Reference,
SUBSTR(Reference,1,3) AS BU
,
SUBSTR(Reference,4,2) AS Famille,
SUBSTR(Reference,6,1) AS Etat,
SUBSTR(Reference,7,1) AS Stock,
SUBSTR(Reference,8,3) AS Produit
,
SUBSTR(Dateentree,7,4) || "-" || SUBSTR(Dateentree,4,2) || "-" || SUBSTR(Dateentree,1,2) || SUBSTR(Dateentree,11,9) AS DateTimeEntree
FROM Entrees
/* V_audit(TagIS,Reference,BU,Famille,Etat,Stock,Produit,DateTimeEntree) */;
CREATE VIEW vv_Entrees AS
SELECT
TagIS,Reference,DateEntree,
CASE
WHEN BU IN ("CHR","CLP","ALT") THEN ""
ELSE Reference
END RefProvisoire,
CASE
WHEN BU IN ("CHR","CLP","ALT") THEN Reference
ELSE ""
END RefDefinitive,
CASE
WHEN BU IN ("CHR","CLP","ALT") THEN ""
ELSE DateEntree
END DateReception,
CASE
WHEN BU IN ("CHR","CLP","ALT") THEN DateEntree
ELSE ""
END DateAudit
FROM v_entrees
/* vv_Entrees(TagIS,Reference,DateEntree,RefProvisoire,RefDefinitive,DateReception,DateAudit) */;
CREATE VIEW vvv_Entrees AS
SELECT
TagIS,Reference,DateEntree,
MAX(Refprovisoire) AS Refprovisoire,
MAX(RefDefinitive) AS RefDefinitive,
MAX(DateReception) AS DateReception,
MAX(DateAudit)   AS DateAudit
FROM vv_Entrees
GROUP BY TagIS
/* vvv_Entrees(TagIS,Reference,DateEntree,Refprovisoire,RefDefinitive,DateReception,DateAudit) */;
CREATE VIEW v_Suivi_Sorties AS
-- d'après v_SuiviMvt du 09:40 02/10/2020
-- Liste des déstockages I&S des 30 derniers jours effectués sur dossier GLPI, avec affichage des numéros de colis
WITH storage AS
     (
               SELECT -- sorties
                         GLPI
                       , DateBL 
                       , Reference
                       , Description AS Designation
                       , NumSerie
                       , sDepot AS Stock
                       , NumeroOFL 
                       , REPLACE(REPLACE(REPLACE(numeros_de_colis,"[",""),"]",""),","," ") AS Transport
                       , sorties.Societe  AS Societe
                       , SORTIES.TagIS
               FROM
                         SORTIES
                       , v_SORTIES
                         LEFT JOIN
                                   OFLX
                                   ON
                                             OFLX.refclient = GLPI
               WHERE
                             length(CAST(GLPI AS INTEGER))=10
                         AND SORTIES.TagIS=v_SORTIES.TagIS
                         -- and datebl > date("now","-2 day") -- uniquement pour debug
     )
SELECT DISTINCT
         COUNT(TagIS)  AS Qte -- nombre de lignes concernées par le mouvement
       , *
FROM
         storage
GROUP BY
         GLPI
       , Reference  -- une ligne par dossier et référence d'article différente
/* v_Suivi_Sorties(Qte,GLPI,DateBL,Reference,Designation,NumSerie,Stock,NumeroOFL,Transport,Societe,TagIS) */;
CREATE VIEW vv_SuiviSorties_1mois AS
    SELECT               GLPI
                       , DateBL 
                       , Societe
                       , Qte
                       , Reference
                       , Designation
                       , NumSerie
                       , Transport
                       , TagIS
                       , NumeroOFL 

    FROM     v_SuiviSorties_1mois
    WHERE    Datebl >= DATE("now","-1 month") 
    ORDER BY Datebl DESC,GLPI DESC;
CREATE VIEW vv_Suivi_Sorties_1mois AS
    SELECT               GLPI
                       , DateBL 
                       , Societe
                       , Qte
                       , Reference
                       , Designation
                       , NumSerie
                       , Transport
                       , TagIS
                       , NumeroOFL 

    FROM     v_Suivi_Sorties
    WHERE    Datebl >= DATE("now","-1 month") 
    ORDER BY Datebl DESC,GLPI DESC
/* vv_Suivi_Sorties_1mois(GLPI,DateBL,Societe,Qte,Reference,Designation,NumSerie,Transport,TagIS,NumeroOFL) */;
