REM @echo off
goto :debut
StockCLP34.cmd
CREATION    18:26 24/11/2020 d'après EtatStock.cmd 10:07 24/11/2020 meilleure gestion de la date des données


:debut
pushd ..\data
sqlite3 sandbox.db ".separator ;" ".header on" "select REPLACE(projet,'COLIPOSTE ','') as Stock,reference,designation,okdispo as Dispo,alivrer as A_livrer from v_teexport where reference like 'CLP34%%' and okdispo+alivrer >0;" > ..\StatsIS\quipo\%~n0\%~n0.csv
rem on procède en deux fois car le CSV doit être hébergé en plus du xml
gawk -f ..\bin\csv2xml.awk ..\StatsIS\quipo\%~n0\%~n0.csv > ..\StatsIS\quipo\%~n0\fichier.xml

if not exist dernier_export.txt echo %date% >dernier_export.txt
sed "s/\([0-9][0-9][0-9][0-9]\)\([0-9][0-9]\)\([0-9][0-9]\)/\3\/\2\/\1/" dernier_export.txt >..\StatsIS\quipo\%~n0\date.txt
:: dernier_export.txt a été créé par la dernière exécution de exportis.cmd
popd
