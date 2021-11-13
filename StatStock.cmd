@echo off
goto :debut
StatStock.cmd
CREATION    17:07 01/02/2021 par externalisation depuis creestat.cmd
UTILITE     produit le graphique combinant l'historique 13 mois des ‚tats monitor‚s du mat‚riel en stock   
MODIF       18:41 08/02/2021 rajoute un indicateur de progression sur la requête SQLite    
BUG         18:17 09/02/2021 supprime la modif pr‚c‚dente car l'indication de progression allait dans les donn‚es g‚n‚r‚es et non … l'‚cran
MODIF       13:28 23/03/2021 rajout de la v‚rification du isdir afin d'ˆtre autonome
MODIF       10:41 26/03/2021 n‚cessite que gnuplot soit pr‚sent dans le path (donc install‚ "normalement" plut“t que juste copi‚) au lieu d'en d‚finir le chemin dans une variable 
MODIF       15:26 12/04/2021 archive l'image dans la table de graphiques de la bdd de stats
MODIF       11:40 16/04/2021 s'assure de ne pas copier des graphiques vides (on garde alors l'ancienne version)
MODIF       21:01 26/04/2021 supprime l'écriture de la désignation dans le graphique puisqu'elle est toujours la même et que ça pose des problèmes de gestion des accents
BUG         20:47 28/04/2021 correction d'une inversion entre sujet et commentaire

:debut
REM @echo on
@Echo Graphiques sur l'‚tat du mat‚riel en stock

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
pushd "%isdir%\Data"
@echo Extraction des donn‚es sur l'‚tat du mat‚riel en stock
sqlite3 -header -separator ; sandbox.db "select * from v3_%~n0;" > %~n0.csv

@echo G‚n‚ration des graphiques
gawk -f genmulticourbes.awk %~n0.csv > %~n0.plt
gnuplot -c %~n0.plt

:: s'assure de ne pas copier des graphiques vides (on garde alors l'ancienne version)
for %%I in (%~n0.png) do if %%~zI GTR 0 (
copy /y %~n0.png ..\StatsIS\quipo\%~n0\graphique.png
sqlite3 ..\StatsIS\quipo\SQLite\quipo.db "insert or replace into graphiques(code,Image,Commentaire,Sujet) values('graphique',readfile('%~n0.png'),readfile('..\StatsIS\quipo\%~n0\Commentaire.txt'),'%~n0') ;"
)

popd
