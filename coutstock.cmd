@echo off
goto :debut
coutstock.cmd
CREATION    22:43 02/02/2021 Extraction, par mois, par famille de produit et pour chaque BU, des co–ts de stockage hebdomadaires 
PREREQUIS   bdd sandbox.sql … jour + requetes ad hoc
MODIF       18:05 03/02/2021 remplace la requete v4_Stat_CoutStock_13mois par v4_Stat_CoutStock_57semaines afin d'avoir un meilleur lissage des donn‚es
:debut
pushd ..\data
REM goto :boucle
@echo Extraction des co–ts de stockage par famille de produit
sqlite3 -header -separator ; sandbox.db "select * from v4_Stat_CoutStock_57semaines ;" > ..\work\CoutStock13mois.csv
:: Requˆte trŠs longue … ex‚cuter donc on sort pour toutes les BU en une seule fois et on filtre ensuite

:boucle
@echo boucle de g‚n‚ration graphique
cd ..\work

for %%I in (CHR CLP TLT) do (
sed -n -e 1p -e "s/;%%I//p" CoutStock13mois.csv > %%I13mois.csv
:: ^^ ‚vite de faire autant d'appels … la requˆte SQLite qu'il y a de BU car elle est d'ex‚cution longue
gawk -f genempilaire.awk %%I13mois.csv > %%I13mois.plt
%gnuplot% -c %%I13mois.plt
move /y %%I13mois.png ..\StatsIS\quipo\CoutStock
REM dir %%I13mois.*
)
:fin
popd

