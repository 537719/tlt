@echo off
goto :debut
projets.cmd
d'après projexped.cmd 23/10/2018 - 17:23:07
CREE    24/10/2018 - 10:37:27 suivi du matériel attendu ou expédié dans le cadre des projets
MODIF   29/10/2018 - 13:11:58 convertit le résultat de CP850 en iso8859-1 afin d'afficher correctement les caractères accentués
MODIF   31/10/2018 - 11:34:30 la concaténation des fichiers de donnée a désormais ses en-têtes de champs en occurence unique et en tête de fichier, au prix d'un tri par numéro de TAG IS décroissant



PREREQUIS :
    Ligne de commande MySQL ayant un accès en lecture à la base GLPI
    utilitaires Unix inclus dans la distrib de git, dont :
        date (ici renommé en udate)
        grep
        awk
        SQLITE (ici dans sa version sqlite3)
        iconv (conversion de charset)
    scripts :
        liveGLPIprojects.sql        (liste des numéros de dossier GLPI des dossiers de projets en cours)
        liveGLPIprojectsdetails.sql (liste des en-têtes des dossier GLPI des dossiers de projets en cours)
        projets.sql                 (liste du matériel attendu et du matériel expédié sur les dits dossiers)
    Dossiers
        ..\data\ en lecture
        ..\work\ en lecture/écriture
    Données
        export des produits expédiés, dans le dossier ..\data\

:debut


md ..\work 2>nul

@echo "%~d0%~p0" |sed -e "s/\\\/\//g" -e "s/\d34//g" -e "s/bin.*$/work/" >%temp%\workdirlx.tmp
set /p workdirlx=<%temp%\workdirlx.tmp
:: ^^ chemin d'accès "unix style" 
@echo "%~d0%~p0" |sed -e                 "s/\d34//g" -e "s/bin.*$/work/" >%temp%\workdir.tmp
set /p workdir=<%temp%\workdir.tmp
:: chemin d'accès au dossier de travail
pushd "%workdir%"
cd ..\bin
REM mise à disposition du script d'interrogation de GLPI
copy liveGLPIprojectsdetails.sql "%workdir%"
REM mise à disposition du script d'interrogation de SQLite
copy projets.sql "%workdir%"

cd ..\data
REM cat is_out_2???0?.csv is_out_2???1?.csv >"%workdir%\is_out_all.csv"
usort -t; -k19 -r -u -o "%workdir%\is_out_all.csv" is_out_2???0?.csv is_out_2???1?.csv
cd /d "%workdir%"

if exist projexped.csv del projexped.csv
if exist projetsencoursdetails.txt del projetsencoursdetails.txt 
if exist projetsencoursdetails.txt goto :errdel
:: si la destruction n'a pas pu être effectuée c'est qu'un fichier est certainemen verrouillé


:loop1
:: vérification de la sortie

REM Production des données issues de GLPI
@Echo copier la ligne suivante dans la ligne de commande mysql (sans les doubles quotes)
@echo "source %workdirlx%/liveGLPIprojectsdetails.sql"


:loopdot
@echo off
uecho -n .
:: uecho = echo.exe renommé, option -n pour ne pas avoir de saut de ligne
if not exist projetsencoursdetails.txt goto :loopdot

:loopstar
uecho -n *
:: uecho = echo.exe renommé, option -n pour ne pas avoir de saut de ligne
grep -e "^[0-9]* rows in set" projetsencoursdetails.txt 2>nul
if errorlevel 1 goto :loopstar

:reprise
gawk -f ..\bin\outsql.awk projetsencoursdetails.txt >projetsencoursdetails.csv
:: ^^ convertit le query MySql en CSV

:: initialisation de la base SQLITE et génération de la liste des dossiers GLPI
del liveGLPIprojects.csv 2>nul
sqlite3 projets.db <projetsInit.sql
if not exist liveGLPIprojects.csv msg /w %username% fichier liveGLPIprojects.csv manquant


:: utilise le résultat précédent comme filtre de recherche dans les expéditions d'I&S afin de générer la liste du matériel expédié sur les projets
@echo GLPI;Date BL;Ville L;Reference;Description>projexped.csv
:: Attention, pas d'espace avant la redirection sinon il est rajouté au texte redirigé et perturbe le nommage des champs dans la base sqlite générée à partir du fichier csv

grep -f liveGLPIprojects.csv "%workdir%\is_out_all.csv" |usort  -n -t; -k18 -k1 -k6|gawk -F; "$1~ /^[0-9]{10}$/ {print $1 FS $8 FS $18 FS $6 FS $7}" >>projexped.csv
:: interroge la base SQLITE initialisée de manière à générer la liste des produits demandés

@echo Extraction des informations projets
call ..\bin\ArticlesDemandesProjets.cmd
call ..\bin\VillesDemandesProjets.cmd
sqlite3 projets.db <projets.sql

:: conversion des accents
REM Les données étant ce qu'elles sont, on arrive ici avec des données en codepage 850 alors qu'il nous faut de l'iso8859-1
iconv -f 850 -t ISO-8859-1 fichier.csv >fichier_ISO-8859-1.csv
move /y fichier_ISO-8859-1.csv fichier.csv

:: transforme en xml le fichier csv généré
gawk -f ..\bin\csvproj2xml.awk fichier.csv > projexped.xml


uecho Ok
uecho -n Le résultat est dans : 
dir /-c projexped.xml |grep -i xml
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
