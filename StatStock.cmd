@echo off
goto :debut
StatStock.cmd
CREATION    17:07 01/02/2021 par externalisation depuis creestat.cmd
UTILITE     produit le graphique combinant l'historique 13 mois des ‚tats monitor‚s du mat‚riel en stock       
:debut
REM @echo on
if "%isdir%"=="" goto :eof
:: si la variable n'est pas d‚finie on ne fait rien
:: quillemets importants sinon plantage … cause du & d'I&StatStock

pushd "%isdir%\Data"
@echo Extraction des donn‚es sur l'‚tat du mat‚riel en stock
sqlite3 -header -separator ; sandbox.db "select * from v3_%~n0;" > %~n0.csv
@echo G‚n‚ration des graphiques
gawk -f genmulticourbes.awk %~n0.csv > %~n0.plt
%gnuplot% -c %~n0.plt
move /y %~n0.png ..\StatsIS\quipo\%~n0\graphique.png
popd
