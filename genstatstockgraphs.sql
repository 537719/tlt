-- genstatstockgraphs.sql
-- CREATION 18:07 21/12/2020 Produit les données de stat sur l'état des stocks et crée le batch de génération de graphique pour les exploiter
-- OBSOLETE 17:41 01/02/2021 remplacé par StatStock.cmd qui place toutes les données sur un seul graphique au lieu d'en faire un par série
.exit

.mode list
.headers on
.separator ;
.once ../work/ada.csv
select datestock,qada as "Attente Décision Alturing"
from vv_Stat_EtatStock
where datestock >= date("now","-1 year","start of month","-1 day","start of month")
;

.once ../work/audit.csv
select datestock,qAudit as "Matériel à auditer"
from vv_Stat_EtatStock
where datestock >= date("now","-1 year","start of month","-1 day","start of month")
;

.once ../work/hs.csv
select datestock,qHS as "Matériel à réparer"
from vv_Stat_EtatStock
where datestock >= date("now","-1 year","start of month","-1 day","start of month")
;

.once ../work/ratiook.csv
select datestock,RatioOK as "Taux de matériel OK"
from vv_Stat_EtatStock
where datestock >= date("now","-1 year","start of month","-1 day","start of month")
;

.headers off
.output genstatstockgraphs.cmd
select "pushd ..\work";
select "for %%I in (ada hs audit ratiook) do %gnuplot% -c ..\bin\monocourbe.plt %%I.csv " || date("now","-1 year","start of month","-1 day","start of month") || " " || max(dateexport) from stockarchive ;
select "for %%I in (ada hs audit ratiook) do move  %%I.png ..\StatsIS\quipo\StatStock";
select "popd";
.output
.shell "genstatstockgraphs.cmd"
