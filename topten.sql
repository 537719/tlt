-- sandbox.db
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

CREATE TABLE SORTIES_Type(
    "TagIS" TEXT,
    "TypeSortie" TEXT
);
CREATE UNIQUE INDEX STtag on SORTIES_Type(tagis);

CREATE TABLE SORTIES_Sidetable(
        "TagIS" TEXT,
        "DateCreation" TEXT,
        "DateBL" TEXT
);
CREATE UNIQUE INDEX SStag on SORTIES_Sidetable(tagis);

.separator ;

with storage as (
    select
            tagis,
            strftime(
                "%Y-%m-%d",
                date( 
                    substr(DateCreation,7,4) || "-" || substr(DateCreation,4,2) || "-" || substr(DateCreation,1,2)
                )
            ) as DateCreation
           ,
            strftime(
                "%Y-%m-%d",
                date( 
                    substr("date bl",7,4) || "-" || substr("date bl",4,2) || "-" || substr("date bl",1,2)
                )
            ) as DateBL
    from SORTIES
)
INSERT OR REPLACE INTO  SORTIES_Sidetable(tagis,datecreation,datebl)
select tagis,datecreation,datebl from storage
;
update sorties_sidetable set datebl=date(datecreation,"+1 day") where datebl is null;

select printf("%8d",sum(nbsem * couthebdo)) as cumulcout,ref,"nom projet" from stock,stock_sidetable where stock.tagis=stock_sidetable.tagis group by "nom projet",ref order by cumulcout desc limit 10;

select count(sorties.tagis) from sorties,sorties_sidetable where reference="CHR73NP0H5" and sdepot="CHRONOPOST PROJETS INFRASTRUCTURE" and sorties.tagis=sorties_sidetable.tagis and sorties_sidetable.datebl>date("now","-1 year");

.mode column
.width 25 10 50 12 7 6

.header on
.output palmares.csv
-- durée de vie en année de chaque article présent en stock et déstocké durant l'année passée
with storage as (
    select count(stock.tagis) as QStock,
        -- printf("%8d E",sum(nbsem * couthebdo)) as cumulcout,
        printf("%8d",sum(couthebdo)) as CoutHebdo,
        ref,"nom projet" as projet
        -- ,stock.tagis
    from stock,stock_sidetable 
    where stock.tagis=stock_sidetable.tagis 
    -- and ref like "CHR32%"
    group by projet,ref 
    -- order by cumulcout desc 
    -- limit 10
)
select 
    projet as Stock,
    storage.ref as Reference,
    Description as Designation,
    -- printf("%.0f",Qstock) as "Qte en stock",
    printf("%.0f",Qstock) as Qstock,
    -- printf("%d",count(sorties.tagis)) as "Sorties sur 1 an", 
    printf("%d",count(sorties.tagis)) as Sorties, 
    -- printf("%5.1f",(Qstock+0.0)/count(sorties.tagis)) as "Annees avant epuisement du stock"
    printf("%5.1f",(Qstock+0.0)/count(sorties.tagis)) as Annees
   -- , printf("%8.2f",(CoutHebdo*Qstock)) as "Cout de stockage hebdomadaire"
    -- ,printf("%d",(Qstock+0.0)/count(sorties.tagis)*365.25*24*3600) as "secondes avant epuisement du stock"
    -- , cumulcout as "Cumul du cout de stockage"
    from sorties,sorties_sidetable ,storage
    where 
        reference=storage.ref
    and 
        sdepot=storage.projet
    and 
        sorties.tagis=sorties_sidetable.tagis 
        and sorties_sidetable.datebl >= date("now","-1 year")
    GROUP BY REFERENCE
    ORDER BY projet asc, "secondes avant epuisement du stock" desc
    -- limit 20
;
.header off
-- Articles présents en stock n'étant pas sortis depuis 1 an
with storage as (
    select 
        "nom projet" as Stock,
        ref as Reference
        from stock 
    -- where ref like "CHR%" 
    except 
        select sdepot, reference 
        from sorties, sorties_sidetable 
        where sorties.tagis=sorties_sidetable.tagis 
        and sorties_sidetable.datebl > date("now","-1 year")
)
select 
        "nom projet" as Stock,
        ref as Reference,
        Designation,
        count(stock.tagis) as Qstock,
        0 as "Sorties sur 1 an"
        -- ,(substr(date(printf("%d",(strftime("%s",date("now"))-avg(strftime("%s",indate)))),"unixepoch"),1,4)-1970) || " an(s) " || (substr(date(printf("%d",(strftime("%s",date("now"))-avg(strftime("%s",indate)))),"unixepoch"),6,2)) || " mois"
       , printf("%5.1f",(strftime("%s",date("now"))-avg(strftime("%s",indate)))/3600/24/365.25)
        -- ,printf("%d",(strftime("%s",date("now"))-avg(strftime("%s",indate)))),indate
        -- ,(strftime("%s",date("now"))-avg(strftime("%s",indate)))/(3600*24*365)
        -- ,printf("%d",avg(strftime("%s",indate)))
        -- ,indate
        from stock,storage
        , stock_sidetable
        where 
            stock."nom projet"=storage.stock
        AND
            stock.ref=storage.reference
        AND
            stock.tagis=stock_sidetable.tagis
        GROUP BY storage.stock,reference
;
.output

select  (substr(date(printf("%d",(strftime("%s",date("now"))-avg(strftime("%s","2018-05-31")))),"unixepoch"),1,4)-1970) || " an(s) " || (substr(date(printf("%d",(strftime("%s",date("now"))-avg(strftime("%s","2018-05-31")))),"unixepoch"),6,2)) || " mois";

-- durée de vie en année de chaque article présent en stock et déstocké durant l'année passée
with storage as (
    select count(stock.tagis) as QStock,
        -- printf("%8d E",sum(nbsem * couthebdo)) as cumulcout,
        ref,"nom projet" as projet
        -- ,stock.tagis
    from stock,stock_sidetable 
    where stock.tagis=stock_sidetable.tagis 
    -- and ref like "CHR32%"
    group by projet,ref 
    -- order by cumulcout desc 
    -- limit 10
)
select 
    projet as Stock,
    storage.ref as Reference,
    Description as Designation,
    printf("%.0f",Qstock) as "Qte en stock",
    printf("%d",count(sorties.tagis)) as "Sorties sur 1 an", 
    printf("%5.1f",(Qstock+0.0)/count(sorties.tagis)) as "Annees avant epuisement du stock"
        ,(substr(date(printf("%d",(strftime("%s",date("now"))-printf("%d",(Qstock+0.0)/count(sorties.tagis)*365.25*24*3600))),"unixepoch"),1,4)-1970) || " an(s) " || (substr(date(printf("%d",(strftime("%s",date("now"))-printf("%d",(Qstock+0.0)/count(sorties.tagis)*365.25*24*3600))),"unixepoch"),6,2)) || " mois"
    -- ,printf("%d",(Qstock+0.0)/count(sorties.tagis)*365.25*24*3600) as "secondes avant epuisement du stock"

    -- , cumulcout as "Cumul du cout de stockage"
    from sorties,sorties_sidetable ,storage
    where 
        reference=storage.ref
    and 
        sdepot=storage.projet
    and 
        sorties.tagis=sorties_sidetable.tagis 
        and sorties_sidetable.datebl >= date("now","-1 year")
    GROUP BY REFERENCE
    ORDER BY projet asc, "secondes avant epuisement du stock" desc
    -- limit 20
;


select  (
    -- substr(
        -- date(
            printf("%5.1f",(strftime("%s",date("now"))-avg(strftime("%s","2017-05-31")))/3600/24/365.25)
        -- ,"unixepoch")
        -- ,1,4)-1970
    ) 
;
