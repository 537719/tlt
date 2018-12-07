@echo off
goto :debut
SNxCC.cmd
anciennement  26/02/2018  12:17               385 maryemme.cmd
:: traite un fichier d'export des produits expédiés par I&S pour en extraire  la liste des codes imputations, s/n, nom client et localisation pour tous les PC chronopost produits (hors shipping)

PREREQUIS :
    possibilité d'interroger la base GLPI en SQL (par exemple via HeidiSQL)
    AWK (ici dans sa version GNU incluse dans GIT : gawk)
    SQLITE (ici dans sa version sqlite3.exe)
    echo.exe (ici renommé én uecho.exe afin d'éviter la confusion - inclus dans git)


MODIF 02/07/2018 - 14:32:30 ne prend pas en compte le matériel entré en stock avant 10/2016
REM gawk -F; "BEGIN {OFS=FS} NR==1 {print $5 OFS $8 OFS $11 OFS $12 OFS $20 OFS $16 OFS $18 OFS $19};$6 ~ /^CHR10N[F|P]...$/ {tagis=gensub(/TE/,vide,1,$19);if (tagis > "1610000000") {print $5 OFS $8 OFS $11 OFS $12 OFS $20 OFS $16 OFS $18 OFS $19}}" %1
MODIF 02/07/2018 - 16:38:30 ne produit que les informations nécessaires : rajout du numéro GLPI, conservation de la date et du numéro de série et c'est tout
MODIF 02/07/2018 - 17:28:03 force la sortie vers un nom de fichier immuable
AJOUT 02/07/2018 - 17:28:03 enchaîne avec le croisement GLPI puis le croisement des résultats
MODIF 17/07/2018 - 10:57:37 maryemme.cmd,devient SNxCC.cmd
MODIF 20/07/2018 - 15:04:39 externalisation dans le script genCSVsnGLPI.awk de l'extraction des numéros de série concernés afin d'utiliser exactement les même critères que pour l'interrogationGLPI
BUG   08/08/2018 - 15:02:04 s'assure que les scripts awk exécutés proviennent bien du dossier des scripts
MODIF 06/12/2018 - 16:11:21 convertit le csv de résultat en un fichier xml

:debut
@echo on
if @%1@==@@ goto err0
if not exist %1 goto :err1

md ..\work 2>nul

@echo "%~d0%~p0" |sed -e "s/\\\/\//g" -e "s/\d34//g" -e "s/bin.*$/work/" >%temp%\workdirlx.tmp
set /p workdirlx=<%temp%\workdirlx.tmp
:: ^^ chemin d'accès "unix style" 
@echo "%~d0%~p0" |sed -e                 "s/\d34//g" -e "s/bin.*$/work/" >%temp%\workdir.tmp
set /p workdir=<%temp%\workdir.tmp
:: chemin d'accès au dossier de travail


pushd "%workdir%"
if exist ??base.* del ??base.* 
if exist ??base.* goto :errdel
:: si la destruction n'a pas pu être effectuée c'est qu'un fichier est certainemen verrouillé

REM @echo off
REM pause
REM gawk -F; "BEGIN {OFS=FS} NR==1 {print $1 OFS $8 OFS $11};$6 ~ /^CHR1[0-1].[^S][^0|^Z]..$/ {tagis=gensub(/TE/,vide,1,$19);if (tagis > "1610000000") {print $1 OFS $8 OFS $11}}" %1 >SNbase.csv
REM les données produites doivent ensuite être croisées avec celles issues de la requête SQL issue de l'invocation de genSQLccbGLPI.awk sur le même jeu de données
gawk -f ..\bin\genCSVsnGLPI.awk %1 >SNbase.csv

:loop1
:: vérification de la sortie
if not exist SNbase.csv goto :errSN
for %%I in (SNbase.csv) do if %%~zI EQU 0 goto errSNsize
set heure=%time:~0,5%
set timecheck=%date% %heure%
REM set h
REM pause
for %%I in (SNbase.csv) do if NOT "%%~tI" EQU "%timecheck%" goto errSNtime


REM pause

REM Production des données issues de GLPI
gawk -v outputfile="%workdirlx%/CCbase.txt" -f ..\bin\genSQLccbGLPI.awk %1 >glpi_centrecout_beneficiaire.sql
REM pause
REM @echo exécuter la requête "source %workdirlx%/glpi_centrecout_beneficiaire.sql" et en sauvegarder le résultat en tant que CCbase.csv
@Echo copier la ligne suivante dans la ligne de commande mysql (sans les doubles quotes)
REM @echo tee "%workdirlx%/CCbase.txt"
@echo "source %workdirlx%/glpi_centrecout_beneficiaire.sql"
REM @echo notee


REM dir *.csv /od
REM pause

:loopdot
@echo off
uecho -n .
:: uecho = echo.exe renommé, option -n pour ne pas avoir de saut de ligne
if not exist CCbase.txt goto :loopdot

:loopstar
uecho -n *
:: uecho = echo.exe renommé, option -n pour ne pas avoir de saut de ligne
REM for %%I in (CCbase.csv) do if %%~zI EQU 0 goto :loopstar
grep -e "^[0-9]* rows in set" CCbase.txt 2>nul
REM grep -e "notee" CCbase.txt 2>nul
if errorlevel 1 goto :loopstar

:reprise
gawk -f ..\bin\outsql.awk CCbase.txt >CCbase.csv
:: ^^ convertit le query MySql en CSV

sqlite3 <SNxCC.SQL
uecho Ok
gawk -f csv2xml SNxCC.csv >SNxCC.xml

uecho -n Le résultat est dans : 
dir /-c SNxCC.* |grep -i SNxCC

popd

goto :eof
:errSNsize
@echo le fichier des SNbase.csv a une taille nulle
goto :eof
:errSNtime
@echo le fichier des SNbase.csv a une mauvaise date
goto :eof
:errSN
@echo le fichier SNbase.csv est manquant
goto :eof
:err1
@echo le fichier %1 n'existe pas
goto :eof
:err0
@echo donner le fichier sur lequel travailler
goto :eof

:errdel
@echo erreur de suppression de fichier
del %temp%\errdel.txt
goto :eof
