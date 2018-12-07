@echo off
goto :debut
IncProdIS.cmd
CREE    30/11/2018 - 15:06:45 produit la stat des incidents de production I&S

:debut
@echo on
pushd ..\work

gawk -f ..\bin\outsql.awk GLPIincProdIS.txt >GLPIincProdIS.csv

sqlite3 <SQLITEIncProdIS.sql

REM @echo GLPI;CodeErreur>DossiersErrProd.csv
del DossiersErrProd.csv 2>nul
for /F %%I in (dossiers.txt) do sqlite3 IncProdIS.db "select content from incProdIS where tickets_id=%%I;" |gawk '/ISI/ {print "%%I;" gensub(/.*(ISI-[A-z]+).*/,toupper("\\\1"),1)}' >>DossiersErrProd.csv

sqlite3 <SQLITEstatIncProdIS.sql

popd
goto :eof

détermination de la période d'extraction des stats
1°) vérifier quel le dernier mois de stats mémorisé
2°) si on est dans le même mois, prendre la même période
3°) sinon prendre le mois suivant
