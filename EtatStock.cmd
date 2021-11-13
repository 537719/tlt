@echo off
goto :debut
EtatStock.cmd
CREATION    08:53 19/11/2020 Transforme l'état quotidien des stocks I&S en une forme affichable sur le quipo
MODIF1      10:07 24/11/2020 meilleure gestion de la date des données
MODIF       16:48 05/04/2021 met de côté le csv jusqu'alors consommé dans un pipe afin de l'exploiter ultérieurement
BUG         18:54 28/04/2021 ne cherchait pas au bon endroit le csv pour le transformer en xml

:debut
pushd ..\data
REM @echo sqlite3 sandbox.db ".separator ;" ".header on" "select Projet ,Reference,Replace(Designation,'&','&amp;') as Designation,OkDispo as 'Ok Dispo',Alivrer as 'A Livrer' from v_teexport where OkDispo+Alivrer > 0  order by stock,reference"
sqlite3 sandbox.db ".separator ;" ".header on" "select Projet as Stock,Reference,Replace(Designation,'&','&amp;') as Designation,OkDispo as 'Ok Dispo',Alivrer as 'A Livrer' from v_teexport where OkDispo+Alivrer > 0  order by stock,reference;" > "..\StatsIS\quipo\SQLite\%~n0.csv"
gawk -f ..\bin\csv2xml.awk "..\work\%~n0.csv" > ..\StatsIS\quipo\%~n0\fichier.xml

if not exist dernier_export.txt echo %date% >dernier_export.txt
sed "s/\([0-9][0-9][0-9][0-9]\)\([0-9][0-9]\)\([0-9][0-9]\)/\3\/\2\/\1/" dernier_export.txt >..\StatsIS\quipo\%~n0\date.txt
:: dernier_export.txt a été créé par la dernière exécution de exportis.cmd
popd
