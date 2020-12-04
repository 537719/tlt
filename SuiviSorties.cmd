@echo off
goto :debut
SuiviSorties.cmd
d'après SuiviMvt.cmd du 16:13 01/10/2020
CREATION    16:43 18/11/2020    Sélectionne les expéditions effectuées par I&S sur dossier GLPI et les publie sur le quipo
fin de ligne
:debut
@Echo Actualisation du suivi des mouvements logistiques sous surveillance

sqlite3 ../data/sandbox.db ".read ../bin/SuiviSorties.sql"

wc -l ..\work\SuiviSorties.csv |gawk '{print $1,"envois suivis"}'

gawk -f ..\bin\csv2xml.awk ..\work\SuiviSorties.csv |sed  "s/\&/\&amp;/" > ..\work\fichier.xml
xcopy /y ..\work\fichier.xml ..\statsis\quipo\SuiviSorties >nul
uecho -n %date% > ..\statsis\quipo\SuiviSorties\date.txt

REM ..\work\lastmvt.txt
