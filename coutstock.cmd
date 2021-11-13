@echo off
goto :debut
coutstock.cmd
CREATION    22:43 02/02/2021 Extraction, par mois, par famille de produit et pour chaque BU, des coûts de stockage hebdomadaires 
PREREQUIS   bdd sandbox.sql à jour + requetes ad hoc
MODIF       18:05 03/02/2021 remplace la requete v4_Stat_CoutStock_13mois par v4_Stat_CoutStock_57semaines afin d'avoir un meilleur lissage des données
MODIF       18:41 08/02/2021 rajoute un indicateur de progression sur la requête SQLite    
MODIF       13:28 23/03/2021 rajout de la vérification du isdir afin d'être autonome
MODIF       10:41 26/03/2021 nécessite que gnuplot soit présent dans le path (donc installé "normalement" plutôt que juste copié) au lieu d'en définir le chemin dans une variable 
BUG         18:28 26/03/2021 Suppression du "progress" dans l'extraction sqlite car il s'affichait dans le csv sorti et non sur la console
MODIF       15:26 12/04/2021 archive des graphiques dans la table de graphiques de la bdd de stats
MODIF       12:06 16/04/2021 s'assure de ne pas copier des graphiques vides (on garde alors l'ancienne version)
MODIF       10:56 22/04/2021 archive également le commentaire du graphique dans la bdd de stats

:debut
REM @echo on
@echo Extraction, par mois, par famille de produit et pour chaque BU, des coûts de stockage hebdomadaires 
if "@%isdir%@" NEQ "@@" goto isdirok
if exist ..\bin\getisdir.cmd (
call ..\bin\getisdir.cmd
goto isdirok
) else if exist .\bin\getisdir.cmd (
call ..\bin\getisdir.cmd
goto isdirok
)

msg /w %username% Impossible de trouver le dossier I^&S
goto :eof
:isdirok
REM @echo on
pushd ..\data
REM goto :boucle
@echo Extraction des coûts de stockage par famille de produit
sqlite3 -header -separator ; sandbox.db "select * from v4_Stat_CoutStock_57semaines ORDER BY DateStock ASC ;" > ..\work\CoutStock13mois.csv
:: Requête très longue à exécuter donc on sort pour toutes les BU en une seule fois et on filtre ensuite

:boucle
@echo boucle de génération graphique
cd ..\work

for %%I in (CHR CLP TLT) do (
sed -n -e 1p -e "s/;%%I//p" CoutStock13mois.csv > %%I13mois.csv
:: ^^ évite de faire autant d'appels à la requête SQLite qu'il y a de BU car elle est d'exécution longue
gawk -f genempilaire.awk %%I13mois.csv > %%I13mois.plt
gnuplot -c %%I13mois.plt

:: s'assure de ne pas copier des graphiques vides (on garde alors l'ancienne version)
for %%J in (%%I13mois.png) do if %%~zJ GTR 0 (

copy /y %%I13mois.png ..\StatsIS\quipo\CoutStock
sqlite3 ..\StatsIS\quipo\SQLite\quipo.db "insert or replace into graphiques(code,Image,Sujet) values('%%I13mois',readfile('%%I13mois.png'),'%~n0') ;"
)

REM dir %%I13mois.*
)
:fin
popd

REM pause