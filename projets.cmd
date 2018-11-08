@echo off
goto :debut
projets.cmd
d'après projexped.cmd 23/10/2018 - 17:23:07
CREE    24/10/2018 - 10:37:27 suivi du matériel attendu ou expédié dans le cadre des projets
MODIF   29/10/2018 - 13:11:58 convertit le résultat de CP850 en iso8859-1 afin d'afficher correctement les caractères accentués
MODIF   31/10/2018 - 11:34:30 la concaténation des fichiers de donnée a désormais ses en-têtes de champs en occurence unique et en tête de fichier, au prix d'un tri par numéro de TAG IS décroissant
MODIF   02/11/2018 - 11:26:50 inverse la présentation de la date de jj/mm/aaaa en aaaa/mm/jj afin de permettre des opérations de tri ultérieures par l'affichage xslt qui ne connait pas le type "date"
MODIF   02/11/2018 - 16:14:07 écriture des en-têtes désactivée et remplacée par une définition des champs dans le script sql d'import des données
MODIF   02/11/2018 - 16:14:07 rajoute l'expression du tagis de manière à pouvoir y appliquer un filtre d'unicité dans le traitement sqlite
MODIF   02/11/2018 - 16:14:07 expurge les éventuels espaces parasites en tête de la désignation des articles expédiés
BUG     08/11/2018 - 11:04:06 affiche un message si une anomalie est détectée lors de la conversion des accents



PREREQUIS :
    Ligne de commande MySQL ayant un accès en lecture à la base GLPI
    utilitaires Unix inclus dans la distrib de git, dont :
        date (ici renommé en udate)
        grep
        awk
        SQLITE (ici dans sa version sqlite3)
        iconv (conversion de charset)
    scripts :
        GLPIliveprojects.sql        (lextrait depuis la base GLPI toutes les informations requises pour le suivi des projets en cours)
        projets.sql                 (liste du matériel attendu et du matériel expédié sur les dits dossiers)
    Dossiers
        ..\data\ en lecture
        ..\work\ en lecture/écriture
    Données
        export des produits expédiés, dans le dossier ..\data\

:debut
@echo off

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
copy GLPIliveprojects.sql "%workdir%"
REM mise à disposition du script d'interrogation de SQLite
copy projets.sql "%workdir%"

cd ..\data
REM cat is_out_2???0?.csv is_out_2???1?.csv >"%workdir%\is_out_all.csv"
usort -t; -k19 -r -u -o "%workdir%\is_out_all.csv" is_out_2???0?.csv is_out_2???1?.csv
cd /d "%workdir%"

del GLPIliveprojects*.txt 2>nul
del testfin.txt 2>nul

:loop1
:: vérification de la sortie

REM Production des données issues de GLPI
@Echo copier la ligne suivante dans la ligne de commande mysql (sans les doubles quotes)
@echo "source %workdirlx%/GLPIliveprojects.sql"


:loopdot
@echo off
uecho -n .
:: uecho = echo.exe renommé, option -n pour ne pas avoir de saut de ligne
if not exist GLPIliveprojects*.txt goto :loopdot

:loopstar
uecho -n *
:: uecho = echo.exe renommé, option -n pour ne pas avoir de saut de ligne
dir -c GLPIliveproject*.txt   | sed   -n -e "/^ *4 /p" >testfin.txt
:: vérifie si on a 4 fichiers
if not exist testfin.txt goto :loopstar
for %%I in (testfin.txt) do if %%~zI==0 goto :loopstar

:reprise
@echo OK
for %%I in (GLPIliveprojects*.txt) do gawk -f ..\bin\outsql.awk %%I > %%~nI.csv
:: ^^ convertit les querys MySql en CSV
sed -i "s/\d34//g" GLPIliveprojectsNumbers.csv
:: supprime les double quotes de ce fichier

:: utilise le résultat précédent comme filtre de recherche dans les expéditions d'I&S afin de générer la liste du matériel expédié sur les projets
REM @echo GLPI;Date BL;Ville L;Reference;Description>projexped.csv
rem écriture des en-têtes désactivée et remplacée par une définition des champs dans le script sql d'import des données
:: Attention, pas d'espace avant la redirection sinon il est rajouté au texte redirigé et perturbe le nommage des champs dans la base sqlite générée à partir du fichier csv

grep -f GLPIliveprojectsNumbers.csv "%workdir%\is_out_all.csv" |usort  -n -t; -k18 -k1 -k6|gawk -F; '$1~ /^[0-9]{10}$/ {split($8,exped,"/");print $1 FS exped[3] "/" exped[2] "/" exped[1] FS $18 FS $6 FS gensub(/^ */,"",1,$7) FS $19}' >projexped.csv
:: interroge la base SQLITE initialisée de manière à générer la liste des produits demandés

@echo Initialisation du détail des dossiers projets
sqlite3 projets.db ".separator ;" "DROP TABLE IF EXISTS Dossiers;" ".import GLPIliveprojectsDetails.csv Dossiers"

@echo Extraction des informations projets
call ..\bin\ArticlesDemandesProjets.cmd
call ..\bin\VillesDemandesProjets.cmd

@echo Croisement des données
sqlite3 projets.db <projets.sql

:: conversion des accents
REM Les données étant ce qu'elles sont, on arrive ici avec des données en codepage 850 alors qu'il nous faut de l'iso8859-1
iconv -f 850 -t ISO-8859-1 fichier.csv >fichier_ISO-8859-1.csv
if not exist fichier_ISO-8859-1.csv msg /w %username% "Le fichier fichier_ISO-8859-1.csv n'a pas pu être créé"
move /y fichier_ISO-8859-1.csv fichier.csv
if exist fichier_ISO-8859-1.csv msg /w %username% "Le fichier fichier_ISO-8859-1.csv n'a pas pu être déplacé"

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
