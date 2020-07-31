-- AutonomieStock.sql
-- Indique pour chaque article en stock combien d'années il faudrait pour l'épuiser s'il continuait à être déstocké au même rythme que durant l'année écoulée
-- Pour les articles qui ne sont pas sorties, indique à la place depuis combien de temps ils sont en stock
-- CREATION 18:52 28/02/2020

-- Prérequis :
--      BDD Sqlite "sandbox.db" (jusqu'à validation et utilisation d'une BDD définitive)
--          structure prédéfinie dans la base
--      is_out_current.csv extractions au format .csv des produits expédiés par I&S concaténés dans un seul fichier à importer
--      is_stock.csv version la plus récente de l'extraction au format CSV de l'export du stock I&S
--      Script .CMD appelant, s'assurant que les fichiers .csv requis ont été mis à jour et que l'on est dans le bon répertoire

-- Sortie :
-- Fichier palmares.csv dont le format est :
-- No    Type    long       Champ           Description
-- 1       text    33          Stock              Nom du stock de provenance
-- 2       text    10          Reference        Rérérence normalisée
-- 3       text    84          Designation      Désignagion du produit
-- 4       int       4          Qstock              Quantitée actuellement présente en stock
-- 5       int       3          Sorties             Quantité déstockée durant l'année écoulée
-- 6       float    5          Annees             Durée d'autonomie du stock en années décimales

-- debut
.separator ;
.import is_out_current.csv SORTIES
.import is_stock.csv STOCK

-- Met à jour la table des dates de sorties, au format date de SQLite
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
-- Pare au cas éventuel ou la date de livraison ne serait pas renseignée (rare mais ça arrive)
update sorties_sidetable set datebl=date(datecreation,"+1 day") where datebl is null;

-- Production du CSV de sortie
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
    -- les lignes en commentaires sont là pour donner des exemples d'autres formats pour l'affichage de l'autonomie
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
    -- les lignes en commentaires sont là pour donner des exemples d'autres formats pour l'affichage de l'autonomie
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


