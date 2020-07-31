@echo off
goto :debut
IncProdIS.cmd
CREE    30/11/2018 - 15:06:45 produit la stat des incidents de production I&S
MODIF   14:58 30/01/2019    tronque les code erreurs afin de minimiser les risques d'erreurs de saisie
MODIF   16:18 30/01/2019    rajoute le nom de la bdd sqlite sur laquelle travailler lors de la phase d'extraction des stats
MODIF   10:55 05/02/2019    retraite la liste des codes erreurs en fonction des recodifications à apporter (suite à détection manuelle)
MODIF   17:05 04/02/2020    script renommé en IncProdIS2019.cmd et désormais obsolète suite à la suppression de l'accès MySql via ODBC. Remplacé par un nouveau IncProdIS.cmd qui fonctionne sur une export réalisé depuis le frontal web glpi

A FAIRE 11:59 05/02/2019 rajouter la purge du fichier texte exporté de glpi et l'invocation du script mysql sur glpi

:debut
@echo on
md ..\work 2>nul

@echo "%~d0%~p0" |sed -e "s/\\\/\//g" -e "s/\d34//g" -e "s/bin.*$/work/" >%temp%\workdirlx.tmp
set /p workdirlx=<%temp%\workdirlx.tmp
:: ^^ chemin d'accès "unix style" 
@echo "%~d0%~p0" |sed -e                 "s/\d34//g" -e "s/bin.*$/work/" >%temp%\workdir.tmp
set /p workdir=<%temp%\workdir.tmp
:: chemin d'accès au dossier de travail
pushd "%workdir%"

REM pushd ..\work
copy ..\bin\GLPIincProdIS.sql .
del GLPIincProdIS.txt 2>nul
@Echo Editer %workdir:&=^&%\GLPIincProdIS.sql de manière à ajuster les dates puis
@Echo copier la ligne suivante dans la ligne de commande mysql (sans les doubles quotes)
@echo "source %workdirlx%/GLPIincProdIS.sql"

:loopdot
@echo off
uecho -n .
:: uecho = echo.exe renommé, option -n pour ne pas avoir de saut de ligne
if not exist GLPIincProdIS.txt goto :loopdot

:loopstar
uecho -n *
:: uecho = echo.exe renommé, option -n pour ne pas avoir de saut de ligne
grep -e "^[0-9]* rows in set" GLPIincProdIS.txt 2>nul
if errorlevel 1 goto :loopstar

:reprise
gawk -f ..\bin\outsql.awk GLPIincProdIS.txt >GLPIincProdIS.csv

sqlite3 IncProdIS.db <SQLITEIncProdIS.sql

@echo off
REM @echo GLPI;CodeErreur>DossiersErrProd.csv
del DossiersErrProd.csv 2>nul
@echo Constitue la liste des dossiers ayant eu une erreur de production
REM Constitue la liste des dossiers ayant eu une erreur de production
for /F %%I in (dossiers.txt) do sqlite3 IncProdIS.db "select content from incProdIS where tickets_id=%%I;" |gawk '/ISI/ {print "%%I;" toupper(substr(gensub(/.*(ISI-[A-z]+).*/,toupper("\\\1"),1),1,6))}' >>DossiersErrProd.csv
usort -u -o DossiersErrProd.csv DossiersErrProd.csv

REM Corrige la liste en fonction des recodifications à apporter après analyse manuelle
IF NOT EXIST Recodification.csv  goto :resultatsqlite
REM vérifie auparavant qu'il y a bien des recodifications à apporter
gawk -F; "{print $1 FS substr($2,1,6)}" Recodification.csv >2recod.csv
REM ^^ extrait du fichier des recodifications la partie qui concerne les codes erronés à corriger
grep -v -f 2recod.csv DossiersErrProd.csv |usort -u -o DossiersErrProd.tmp
REM ^^ crée une liste temporaire des dossiers dont les erreurs ne sont pas à corriger
join -t ; -1 1 -2 1 -o 2.1,2.3 DossiersErrProd.csv Recodification.csv >> DossiersErrProd.tmp
REM ^^ Rajoute en bout de liste les erreurs requalifiées
usort -u -o DossiersErrProd.csv DossiersErrProd.tmp
REM ^^ et dédoublonne
Uecho -n Nombre de dossiers en erreur : 
wc -l DossiersErrProd.csv 

del 2recod.csv
del DossiersErrProd.tmp

:resultatsqlite
sqlite3 IncProdIS.db <SQLITEstatIncProdIS.sql

popd
goto :eof

détermination de la période d'extraction des stats
1°) vérifier quel le dernier mois de stats mémorisé
2°) si on est dans le même mois, prendre la même période
3°) sinon prendre le mois suivant
