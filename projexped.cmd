@echo off
goto :debut
projexped.cmd
20/09/2018 - 15:33:38
suivi des envois effectués par I&S dans le cadre des projets

PREREQUIS :
    Ligne de commande MySQL ayant un accès en lecture à la base GLPI
    utilitaires Unix inclus dans la distrib de git, dont :
        date (ici renommé en udate)
        grep
        awk
    SQLITE (ici dans sa version sqlite3)
    scripts :
        liveGLPIprojects.sql
        projexped.sql
    Dossiers
        ..\data\ en lecture
        ..\work\ en lecture/écriture
    Données
        export des produits expédiés, dans le dossier ..\data\

:debut
if @%1@==@@ goto err0
if not exist %1 goto :err1

md ..\work 2>nul

@echo "%~d0%~p0" |sed -e "s/\\\/\//g" -e "s/\d34//g" -e "s/bin.*$/work/" >%temp%\workdirlx.tmp
set /p workdirlx=<%temp%\workdirlx.tmp
:: ^^ chemin d'accès "unix style" 
@echo "%~d0%~p0" |sed -e                 "s/\d34//g" -e "s/bin.*$/work/" >%temp%\workdir.tmp
set /p workdir=<%temp%\workdir.tmp
:: chemin d'accès au dossier de travail

REM mise à disposition du script d'interrogation de GLPI
copy liveGLPIprojects.sql "%workdir%"
REM mise à disposition du script d'interrogation de SQLite
copy projexped.sql "%workdir%"


pushd "%workdir%"
if exist projexped.csv del projexped.csv
if exist liveGLPIprojects.txt del liveGLPIprojects.txt 
if exist liveGLPIprojects.txt goto :errdel
:: si la destruction n'a pas pu être effectuée c'est qu'un fichier est certainemen verrouillé


:loop1
:: vérification de la sortie
REM if not exist SNbase.csv goto :errSN
REM for %%I in (SNbase.csv) do if %%~zI EQU 0 goto errSNsize
REM set heure=%time:~0,5%
REM set timecheck=%date% %heure%
REM for %%I in (SNbase.csv) do if NOT "%%~tI" EQU "%timecheck%" goto errSNtime



REM Production des données issues de GLPI
@Echo copier la ligne suivante dans la ligne de commande mysql (sans les doubles quotes)
@echo "source %workdirlx%/liveGLPIprojects.sql"


:loopdot
@echo off
uecho -n .
:: uecho = echo.exe renommé, option -n pour ne pas avoir de saut de ligne
if not exist liveGLPIprojects.txt goto :loopdot

:loopstar
uecho -n *
:: uecho = echo.exe renommé, option -n pour ne pas avoir de saut de ligne
grep -e "^[0-9]* rows in set" liveGLPIprojects.txt 2>nul
if errorlevel 1 goto :loopstar

:reprise
gawk -f ..\bin\outsql.awk liveGLPIprojects.txt >liveGLPIprojects.csv
:: ^^ convertit le query MySql en CSV

:: utilise le résultat précédent comme filtre de recherche dans les expéditions d'I&S
grep -f liveGLPIprojects.csv ..\data\is_out_201809.csv |usort  -n -t; -k18 -k1 -k6|gawk -F; "{print $1 FS $8 FS $18 FS $6 FS $7}"  >projexped.csv


sqlite3 <projexped.sql >projexped.html
uecho Ok
uecho -n Le résultat est dans : 
dir /-c projexped.html |grep -i html
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
