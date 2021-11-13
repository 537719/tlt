@echo off
goto :debut
EnAttente.cmd
CREATION    15:25 09/02/2021 d'aprŠs StatStock.cmd du 18:41 08/02/2021
FONCTION    produit le graphique combinant l'historique 3 mois de la ventilation du mat‚riel g‚n‚rique par type
MODIF       10:41 26/03/2021 n‚cessite que gnuplot soit pr‚sent dans le path (donc install‚ "normalement" plut“t que juste copi‚) au lieu d'en d‚finir le chemin dans une variable d'environnement
MODIF       15:26 12/04/2021 archive l'image dans la table de graphiques de la bdd de stats
MODIF       11:40 16/04/2021 s'assure de ne pas copier des graphiques vides (on garde alors l'ancienne version)
MODIF       21:01 26/04/2021 supprime l'écriture de la désignation dans le graphique puisqu'elle est toujours la même et que ça pose des problèmes de gestion des accents

:debut
@echo Graphique des articles … auditer 
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
@echo Extraction des donn‚es sur l'‚tat du mat‚riel en attente d'audit
sqlite3 -header -separator ; sandbox.db "select * from v4_%~n0_3mois;" > %~n0.csv
@echo G‚n‚ration des graphiques
gawk -f genmulticourbes.awk %~n0.csv > %~n0.plt
gnuplot -c %~n0.plt

:: s'assure de ne pas copier des graphiques vides (on garde alors l'ancienne version)
for %%I in (%~n0.png) do if %%~zI GTR 0 (
copy /y %~n0.png ..\StatsIS\quipo\%~n0\graphique.png
sqlite3 ..\StatsIS\quipo\SQLite\quipo.db "insert or replace into graphiques(code,Image,Sujet) values('graphique',readfile('%~n0.png'),'%~n0') ;"
)

popd
REM pause