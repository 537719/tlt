-- coutsock.sql
-- requête à faire exécuter par SQLite depuis le dossier .\Data
-- exemple de lancement :
-- sqlite3 IetS.db <coutstock.sql

-- CREATION  27/01/2020  16:51 : calcule,par famille de produit et par BU, les coûts de stockage hebdomadaires et cumulés depuis l'entrée des produits en stock I&S d'après un fichier d'export de stock I&S
-- MODIF    15:59 mercredi 29 janvier 2020 Première version opérationnelle

-- initialisations
.separator ;
DROP TABLE IF EXISTS Stock;
DROP TABLE IF EXISTS Tarif;
DROP TABLE IF EXISTS Catalogue;

CREATE TABLE stock(
  Qte Integer,
  Nom_projet TEXT,
  Ref TEXT,
  Lib TEXT,
  Designation TEXT,
  Etat TEXT,
  Statut TEXT,
  Numéro_de_serie TEXT,
  TagIs TEXT,
  DateEntree TEXT,
  Rien TEXT
);
CREATE UNIQUE INDEX tagstock on Stock(tagis);
.import is_stock.csv stock
-- .import is_stock_20191031-20110319.csv stock
DELETE from Stock where tagis not like "TE%";
-- supprime la ligne d'ent-ete et la ligne de total, sachant que tout tagIS valide doit commencer par TE
-- ne pas le faire altère la détection de la date la plus récente

CREATE TABLE Tarif(
    Cat  TEXT,
    Libelle  TEXT,
    Designation  TEXT,
    Commentaire  TEXT,
    ReceptionUnitaire NUM,
    Swap NUM,
    StockageUnitaireParSemaine NUM,
    Expedition NUM,
    Transfert NUM,
    SortieManuelle NUM
);
.import tarif.csv Tarif
update tarif set StockageUnitaireParSemaine=replace(StockageUnitaireParSemaine,",",".");
-- au cas où le séparateur décimal serait erroné (ça doit être un point et pas une virgule)

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
    Vide TEXT 
);
.import is_catalogue.csv Catalogue

.output SideStock.csv
-- complément d'informations pour chaque article en stock :
-- nombre de semaines de présence en stock et coûts de stockage associés,
-- éclatement de la référence selon nomenclature
-- et tag pour la jointure
.header ON
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
    StockageUnitaireParSemaine as CoutHebdo,
    
    date("20" || substr(TagIs,3,2) || "-" || substr(TagIs,5,2) || "-" || substr(TagIs,7,2)) as InDate,
    "20" || substr(TagIs,3,2) as InAnnee,
     substr(TagIs,5,2) as InMois,
     substr(TagIs,7,2) as InJour,
     substr(stock.Nom_projet,1,3) as BU, -- préférer nom_projet plutôt que le début de la référence afin de ne pas être perturbé par les articles génériques n'ayant pas une référence normalisée tels que les baies ou switches
     substr(stock.ref,4,1) as SurFamille, substr(stock.ref,5,1) as Sousfamille, substr(stock.ref,4,2) as Famille, 
     substr(stock.ref,6,1) as Etat, substr(stock.ref,7,1) as Stock, 
     substr(stock.ref,8,3) as Produit,

    tagis
    
    from 
         storage
        ,stock 
        ,catalogue
        ,tarif
    where 
        stock.ref=catalogue.ref -- lien stock vers catalogue afin d'obtenir la catégorie de tarification
    AND 
        catalogue.categorie=tarif.cat -- lien catalogue vers tarif afin d'obtenir le coût de stockage hebdo pour la catégorie
    -- AND dateentree like "%2018%" 
    group 
        by tagis -- une même référence pouvant apparaître plusieurs fois dans le catalogue, on s'assure ainsi de ne la voir ressortir qu'une seule fois
        -- limit 10
;
.output

DROP TABLE IF EXISTS Stock_Sidetable;
.import SideStock.csv Stock_Sidetable
 -- complément d'informations pour chaque article en stock
CREATE UNIQUE INDEX TagSide on Stock_Sidetable(TagIs);
drop table IF EXISTS familles;
.import familles.csv familles
-- pour la ventilation par famille de produit

-- .header on
-- select count(stock.tagis)  as Qte ,nomfamille as Famille, sum(couthebdo) as CoutHebdo,sum(couthebdo*nbsem) as CoutCumul from stock,stock_sidetable,familles where stock.tagis=stock_sidetable.tagis AND stock_sidetable.famille=familles.codefamille group by nomfamille order by nomfamille;
-- .header off
-- select count(stock.tagis),"Total" as Famille, sum(couthebdo) as CoutHebdo,sum(couthebdo*nbsem) as CoutCumul from stock,stock_sidetable,familles where stock.tagis=stock_sidetable.tagis AND stock_sidetable.famille=familles.codefamille ;

.header off
.output nomresultat.txt
-- pour double usage :
--      renommer le fichier résultat selon la date la plus récente repérée dans le stock, après traitement de ce script
--      servir de filtre sur la date, donc besoin qu'elle soit écrite au même format que dans le fichier résultat
select "20" || 
        substr(max(tagis),3,2)
            || "-" || 
        substr(max(tagis),5,2) 
            || "-" || 
        substr(max(tagis),7,2) 
    as datemax 
    from stock
;

.output resultats.csv
-- nom temporaire du fichier résultat, à renommer en fonction de la date calculée juste avant, après traitement de ce script
-- contient la ventilation des coûts pour chaque BU et pour chaque famille de produit dans chaque BU
.header on
with storage as (
    select "20" || 
        substr(max(tagis),3,2)
            || "-" || 
        substr(max(tagis),5,2) 
            || "-" || 
        substr(max(tagis),7,2) 
    as datemax 
    from stock
)
    select 
        datemax as "Stockd du", BU
        , count(stock.tagis)  as Qte
        ,nomfamille as Famille
        , sum(couthebdo) as CoutHebdo
        ,sum(couthebdo*nbsem) as CoutCumul
    from storage,stock,stock_sidetable,familles
    where 
        stock.tagis=stock_sidetable.tagis 
    AND 
        stock_sidetable.famille=familles.codefamille 
    AND 
        stock_sidetable.stock != "S" 
        -- tout sauf le shipping, pour toutes les BU
    group by bu, nomfamille 
    order by bu, nomfamille
;
.header off
with storage as (
    select "20" || 
        substr(max(tagis),3,2)
            || "-" || 
        substr(max(tagis),5,2) 
            || "-" || 
        substr(max(tagis),7,2) 
    as datemax 
    from stock
)
    select 
        datemax, BU
        , count(stock.tagis)  as Qte
        ,"Shipping" as Famille
        , sum(couthebdo) as CoutHebdo
        ,sum(couthebdo*nbsem) as CoutCumul
    from storage,stock,stock_sidetable,familles
    where 
        stock.tagis=stock_sidetable.tagis 
    AND 
        stock_sidetable.famille=familles.codefamille 
    AND 
        stock_sidetable.stock = "S" 
        -- tout sauf le shipping, pour toutes les BU
    group by bu 
    order by bu
;


-- with storage as (
    -- select "20" || 
        -- substr(max(tagis),3,2) 
            -- || "-" || 
        -- substr(max(tagis),5,2) 
            -- || "-" || 
        -- substr(max(tagis),7,2) 
    -- as datemax 
    -- from stock
-- ) 
    -- select 
        -- datemax, BU
        -- , count(stock.tagis)  as Qte 
        -- ,"Shipping" as Famille
        -- , sum(couthebdo) as CoutHebdo
        -- ,sum(couthebdo*nbsem) as CoutCumul 
    -- from stock,stock_sidetable,familles 
    -- where 
        -- stock.tagis=stock_sidetable.tagis 
    -- AND 
        -- stock_sidetable.famille=familles.codefamille 
    -- AND 
        -- stock_sidetable.stock = "S" 
        -- Uniquement le shipping (tout type d'articles confondus), pour chaque BU
    -- group by bu 
    -- order by bu
-- ;
        
-- on ne calcule pas le total cumulé
-- select "Groupe" as BU,count(stock.tagis),"Total" as Famille, sum(couthebdo) as CoutHebdo,sum(couthebdo*nbsem) as CoutCumul from stock,stock_sidetable,familles where stock.tagis=stock_sidetable.tagis AND stock_sidetable.famille=familles.codefamille ;
.output
