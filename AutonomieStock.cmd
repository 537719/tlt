:: AutonomieStock.cmd
:: encodag OEM 863:French
goto :debut
D'aprŠs 11:35 28/02/2020 IncProdIS.cmd
Positionne les donn‚es et r‚pertoires pour le calcul d'autonomie des stocks I&S

script de pilotage de la requˆte AutonomieStock.sql visant … calculer, pour chaque article en stock combien d'ann‚es il faudrait pour l'‚puiser s'il continuait … ˆtre d‚stock‚ au mˆme rythme que durant l'ann‚e ‚coul‚e
CREATION    19:14 28/02/2020
PREREQUIS  requˆte AutonomieStock.sql en ..\bin
                   Pr‚sence en ..\Data des extractions au format CSV des exports de l'extranet I&S
                        Produits exp‚di‚s (s‚rie de fichiers is_out_aaaammjj.csv)
                        Stock (s‚rie de fichiers is_stock*.csv)
                    accŠs … SQLite
                    accŠs aux utilitaires GNU

:debut
REM @echo off
:: d‚termination du dossier de travail
if "@%isdir%@" NEQ "@@" goto isdirok
if exist ..\bin\getisdir.cmd (
call ..\bin\getisdir.cmd
goto isdirok
) else if exist .\bin\getisdir.cmd (
call ..\bin\getisdir.cmd
goto isdirok
)

msg /w %username% Impossible de trouver le dossier I^&S
goto :fin
:isdirok


REM positionnement dans le dossier de donn‚es
pushd ..\Data

REM v‚rification de l'existence des donn‚es
:: existence du stock
if not exist is_stock.csv goto :errstock
:: date du stockj
udate -r is_stock.csv "+%s" >stream.dat:time
set /p datestock=<stream.dat:time
udate "+%s" >stream.dat:time
set /p datenow=<stream.dat:time
set /a delta=%datenow%-%datestock%
set /a delta=24*3600-%delta%
if %delta% LSS 0 goto :tropvieux

:: concat‚nation des sorties de stock
del is_out_current.csv 2>nul
for /f %%I in ('dir /b /aa is_out_??????.csv') do cat %%I >> is_out_current.csv
attrib -a is_out_??????.csv

if not exist is_out_current.csv goto :errsorties
 
 :: lance la requˆte SQLite en s'attendant … ce qu'elle porte le mˆme nom que le pr‚sent script mais avec une extension diff‚rente
 
for %%I in (%0) do sqlite3 sandbox.db <..\bin\%%~nI.sql
 
 :: finalisation des donn‚es
for %%I in (%0) do gawk -f ..\bin\csv2xml.awk palmares.csv |sed "s/&/\&amp;/pg" > ..\StatsIS\quipo\%%~nI\fichier.xml
dir /-c is_stock.csv |gawk "$1 ~ /[0-9]{2}\/[0-9]{2}\/[0-9]{4}/ {print $1}"  > ..\StatsIS\quipo\%%~nI\date.txt
:: date d'actualisation des donn‚es, afin de l'afficher dans la page web ^^

 goto :fin
 :: traitement des erreurs
 :errsorties
 msg /w %username% Le fichier d'extraction des sorties est absent
@echo le fichier d'extraction des sorties est absent
 goto :fin
 :errstock
 msg /w %username% Le fichier d'extraction des stocks est absent
@echo le fichier d'extraction des stocks est absent
 goto :fin
 :tropvieux
 msg /w %username% Le fichier d'extraction des stocks est trop ancien
@echo Le fichier d'extraction des stocks est trop ancien
 goto :fin
 :errsize
 msg /w %username% Un des fichiers de donn‚es a une taille nulle
@echo Un des fichiers de donn‚es a une taille nulle
  goto :fin
 
 :fin
 popd
 