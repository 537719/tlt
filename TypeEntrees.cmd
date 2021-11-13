@echo off
goto :debut
TypeEntrees.cmd
CREATION    17:51 10/02/2021 d'aprŠs EnAttente.cmd du 15:25 09/02/2021
FONCTION    produit le graphique combinant l'historique 3 mois des entr‚es de mat‚riel g‚n‚rique par type de motif d'entr‚e
  
:debut
REM @echo on
if "%isdir%"=="" goto :eof
:: si la variable n'est pas d‚finie on ne fait rien
:: quillemets importants sinon plantage … cause du & d'I&StatStock

pushd "%isdir%\Data"
@echo Extraction des donn‚es sur les motifs d'entr‚e en stock
sqlite3 -header -separator ; sandbox.db "select * from v4_%~n0_3mois;" > %~n0.csv
@echo G‚n‚ration des graphiques
gawk -f genmulticourbes.awk %~n0.csv > %~n0.plt
%gnuplot% -c %~n0.plt
move /y %~n0.png ..\StatsIS\quipo\VolumIS\entrees.png
popd
