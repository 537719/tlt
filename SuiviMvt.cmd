@echo off
goto :debut
SuiviMvt.cmd
CREATION    16:03 30/09/2020    Détecte les mouvements attendus dans le suivi et les publie sur le quipo
MODIF       15:15 01/10/2020    rajoute un décompte du nombre de lignes concernées
MODIF       16:13 01/10/2020    remplace la commande interne echo par son équivalent externe gnu renommé ici en uecho afin de bénéficier de l'option de suppression du caractère de fin de ligne
:debut
@Echo Actualisation du suivi des mouvements logistiques sous surveillance

sqlite3 ../data/sandbox.db ".read ../bin/SuiviMvt.sql"

wc -l ..\work\suivimvt.csv |gawk '{print $1,"mouvements suivis"}'

gawk -f ..\bin\csv2xml.awk ..\work\suivimvt.csv > ..\work\fichier.xml
xcopy /y ..\work\fichier.xml ..\statsis\quipo\SuiviMvt >nul
uecho -n %date% > ..\statsis\quipo\SuiviMvt\date.txt

..\work\lastmvt.txt
