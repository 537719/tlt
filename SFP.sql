-- Statistiques I&S par famille de produit 
CREATE TABLE SFPliste(
    CodeStat    TEXT NOT NULL PRIMARY KEY,
    LibStat     TEXT NOT NULL,
    Seuil       INTEGER NOT NULL
)
;

CREATE TABLE SFPproduits(
    CodeStat    TEXT NOT NULL,
    Reference   TEXT NOT NULL PRIMARY KEY
)
;

CREATE TABLE SFPstats(
    CodeStat    TEXT NOT NULL,
    DateStat    TEXT NOT NULL,
    INC         INTEGER NOT NULL DEFAULT 0,
    DEM         INTEGER NOT NULL DEFAULT 0,
    RMA         INTEGER NOT NULL DEFAULT 0,
    DEL         INTEGER NOT NULL DEFAULT 0,
    DIV         INTEGER NOT NULL DEFAULT 0
)
;
CREATE UNIQUE INDEX k_SFPstats ON SFPstats(DateStat,CodeStat);

with storage as (
    select codestat,reference from sfpproduits
) 
select codestat,maxdate
,count(tagis) as nbDEM
from v_dernierimport,vv_sorties,storage 
where vv_sorties.reference = storage.reference and datebl between date(maxdate,"start of month") and maxdate 
     and typesortie="DEM"
group by storage.codestat
;

-- peuplement de la table des stats
with storage as (
    select codestat,reference from sfpproduits
)
REPLACE INTO SFPstats(CodeStat,DateStat,INC)  
select codestat,maxdate
,count(tagis) as nbINC
from v_dernierimport,vv_sorties,storage 
where vv_sorties.reference = storage.reference and datebl between date(maxdate,"start of month") and maxdate 
     and typesortie="INC"
group by storage.codestat
;
with storage as (
    select codestat,reference from sfpproduits
)
REPLACE INTO SFPstats(CodeStat,DateStat,DEM)  
select codestat,maxdate
,count(tagis) as nbDEM
from v_dernierimport,vv_sorties,storage 
where vv_sorties.reference = storage.reference and datebl between date(maxdate,"start of month") and maxdate 
     and typesortie="DEM"
group by storage.codestat
;
with storage as (
    select codestat,reference from sfpproduits
)
REPLACE INTO SFPstats(CodeStat,DateStat,RMA)  
select codestat,maxdate
,count(tagis) as nbDEM
from v_dernierimport,vv_sorties,storage 
where vv_sorties.reference = storage.reference and datebl between date(maxdate,"start of month") and maxdate 
     and typesortie="RMA"
group by storage.codestat
;
with storage as (
    select codestat,reference from sfpproduits
)
REPLACE INTO SFPstats(CodeStat,DateStat,DEL)  
select codestat,maxdate
,count(tagis) as nbDEM
from v_dernierimport,vv_sorties,storage 
where vv_sorties.reference = storage.reference and datebl between date(maxdate,"start of month") and maxdate 
     and typesortie="DEL"
group by storage.codestat
;
with storage as (
    select codestat,reference from sfpproduits
)
REPLACE INTO SFPstats(CodeStat,DateStat,DIV)  
select codestat,maxdate
,count(tagis) as nbDEM
from v_dernierimport,vv_sorties,storage 
where vv_sorties.reference = storage.reference and datebl between date(maxdate,"start of month") and maxdate 
     and typesortie NOT IN ("INC","DEM","RMA","DEL")
group by storage.codestat
;
