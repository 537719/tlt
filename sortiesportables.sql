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
;

CREATE VIEW v_sorties_portables_CHR_13mois AS
with storage as (
select date(strftime("%Y-%m-28",datebl),"+1 month","start of month","-1 day") as MoisRef from v_sorties where datebl > date("now","start of month","-13 months") group by moisref 
)
select max(mois) as Mois,sum(neufs) as Neufs,sum(recond) as Recond from v_sorties_portables_chr,storage where mois between date(moisref,"-1 year") and moisref group by moisref
;

