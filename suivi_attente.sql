-- suivi_attente.sql
-- suivi résolution des articles en attente de décision
-- prérequis :  BDD SQLite de suivi I&S : IetS.db
--                  dernière liste des articles en attente de décision, exportée depuis le google sheet : ../work/Attente_aaaammjj.tsv renommé en Attente_maj.tsv
-- CREATION 11:32 12/02/2020

-- exporte la dernière version de la table de suivi
.separator \t
.output suivi_attente.tsv
.header on
select * from suivi_attente where date_vu  group by tagis order by tagis asc, date_vu desc;
.output

-- purge la table  existante de suivi de ses entrées inutiles
drop table if exists suivi_attente;
.separator \t
.import suivi_attente.tsv suivi_attente

-- rajoute les dernières modifs (modifier le nom de fichier en conséquence)
.import ../work/Attente_maj.tsv  suivi_attente

-- liste la date la plus récente à laquelle chaque tag a été vue
-- select tagis,date_vu from suivi_attente where date_vu  group by tagis order by tagis asc, date_vu desc;

with storage as (
    select
        tagis,
        -- strftime(
            -- "%Y-%m-%d",
            -- date( 
                -- substr(date_vu,7,4) || "-" || substr(date_vu,4,2) || "-" || substr(date_vu,1,2)
            -- )
        -- ) as Jour
        date_vu as jour
,        strftime("%Y-%m-%d",date("now")) as Aujourdhui
,       max(date_vu) as datemax
    from suivi_attente 
    where date_vu  
    group by tagis 
    order by tagis asc, jour desc
)
select
    count(storage.tagis) as "Tags clos le :"
   ,jour
   ,max(datemax) as datemaxmax
from storage, suivi_attente
where storage.tagis=suivi_attente.tagis
and jour <> Aujourdhui
-- and date_vu < datemaxmax
-- and date_vu <> datemax
group by storage.jour
;
