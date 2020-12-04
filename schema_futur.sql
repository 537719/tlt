-- schema de la bdd I&S au 15:33 23/09/2020
CREATE TABLE SORTIES(
  "GLPI"            TEXT NOT NULL,
  "Priorite"        TEXT NOT NULL,
  "Provenance"      TEXT NOT NULL,
  "DateCreation"    TEXT NOT NULL,
  "CentreCout"      TEXT NOT NULL,
  "Reference"       TEXT NOT NULL,
  "Description"     TEXT NOT NULL,
  "DateBL"          TEXT NOT NULL,
  "BU"              TEXT NOT NULL,
  "sDepot"          TEXT NOT NULL,
  "NumSerie"        TEXT NOT NULL,
  "NomClient"       TEXT NOT NULL,
  "Adr1"            TEXT NOT NULL,
  "Adr2"            TEXT NOT NULL,
  "Adr3"            TEXT NOT NULL,
  "CP"              TEXT NOT NULL,
  "Dep"             TEXT NOT NULL,
  "Ville"           TEXT NOT NULL,
  "Tagis"           TEXT NOT NULL PRIMARY KEY,
  "Societe"         TEXT NOT NULL,
  "NumeroOfl"       TEXT NOT NULL,
  "Pays"            TEXT NOT NULL
  
  CHECK(
    TagIS LIKE "TE__________"
  OR
    TagIS LIKE "SN____________"
  )
);
CREATE UNIQUE INDEX Stag on SORTIES(tagis);


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
    Alivrer INT,
    dateimport text
    CHECK (
        OkDispo=OkDispo+1-1
    AND
        DateImport LIKE "____-__-__"
    )
);
CREATE UNIQUE INDEX k_histostock on histostock(dateimport,reference,projet);

CREATE VIEW v_lastliv as
with storage as (select max(datebl) as datemax from v_sorties) 
select glpi,count(sorties.tagis) as Nb,DateBL,societe,nomclient,cp,ville,reference,description 
from sorties,v_sorties,storage 
where sorties.tagis=v_sorties.tagis and datebl = datemax 
group by glpi,reference
/* v_lastliv(GLPI,Nb,DateBL,Societe,NomClient,CP,Ville,Reference,Description) */;

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
        (
        TagIS LIKE "TE__________"
      OR
        TagIS LIKE "SN____________"

        )
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
    TagIS LIKE "TE__________"
  OR
    TagIS LIKE "SN____________"
  )
);
CREATE UNIQUE INDEX k_entrees on entrees(tagis,dateentree,reference);


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
CREATE VIEW v_PM_sorties as 
select count(sorties.tagis) as NB,strftime("%Y-%m",datebl) as mois,produit,description 
from sorties,v_sorties 
where sorties.tagis=v_sorties.tagis 
group by mois,produit 
order by mois,produit
/* v_PM_sorties(NB,mois,Produit,Description) */;
CREATE UNIQUE INDEX k_Stock ON STOCK(TagIs);
CREATE UNIQUE INDEX k_Stock_CI ON STOCK(TagIs COLLATE NOCASE);
CREATE INDEX k_SN_Stock_CI ON Stock(Numero_de_serie COLLATE NOCASE);
CREATE INDEX k_datebl_sorties on sorties(DateBL);
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
,       date(substr(DateBL,7,4) || "-" || substr(DateBL,4,2) || "-" ||  substr(DateBL,1,2))  AS DateBL
,       substr(reference,1,3) AS BU
,       substr(reference,4,1) AS "SurFamille"
,       substr(reference,5,1) AS "Sousfamille"
,       substr(reference,4,2) AS "Famille"
,       substr(reference,6,1) AS "Etat"
,       substr(reference,7,1) AS "Stock"
,       substr(reference,8,3) AS "Produit"
    FROM Sorties
    WHERE DateBL LIKE "__/__/____"
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
    WHERE DateBL =""
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


CREATE VIEW V_DossierValide AS
SELECT
    CASE
        WHEN glpi LIKE "IM_______" THEN substr(glpi,3,7) -- Ancien incident SM7
        WHEN glpi LIKE "RM______-___" THEN substr(glpi,3,6) || substr(glpi,10,3) -- Ancienne demande SM7
        WHEN glpi LIKE "RM_____-___" THEN substr(glpi,3,6) || substr(glpi,10,3) -- Ancienne demande SM7 avec oubli du zéro initial
        -- WHEN length(glpi)<9 THEN 0  -- Référence numérique qui ne peut pas être un numéro de dossier -- activer cette clause invalide les dossiers mal saisis
        ELSE CAST(substr(glpi,1,10) as integer) 
    END Dossier
    -- permet de considérer comme valide les cas où le numéro de dossier est complété par une mention textuelle
    
,   glpi,priorite,provenance,reference,societe,cp,ville,tagis
,   CASE
        WHEN DateBL="" THEN date(substr(datecreation,7,4) || "-" || substr(datecreation,4,2) || "-" || substr(datecreation,1,2))
        ELSE date(substr(DateBL,7,4) || "-" || substr(DateBL,4,2) || "-" || substr(DateBL,1,2))
        -- Si la date d'expéditon est omise, on remplace par celle de création
    END DateBL
from sorties
/* V_DossierValide(Dossier,GLPI,Priorite,Provenance,Reference,Societe,CP,Ville,Tagis,DateBL) */;
CREATE VIEW V_Sorties AS
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
/* V_debug_typesortie(Dossier,GLPI,Priorite,Provenance,Reference,Societe,CP,Ville,Tagis,DateBL,TypeSortie) */;

CREATE VIEW v_dernierimport AS
-- rappel de la dernière date d'import des données
select max(dateimport) as maxdate from histostock;
