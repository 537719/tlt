@echo off
goto debut
Suivre.CMD
CREATION    11:29 30/09/2020 Alimentation de la base des mouvements I&S à suivre
FONCTIONNEMENT : Suivre  [Valeur] [Motif] => Rajoute dans la base de suivi le dossier/colis/appro dont la valeur et le motif sont fournis.
PREREQUIS   : suivrefiltre.awk script awk
            : sandbox.db bdd de suivi de l'activité I&S
            : aSuivre.sql intégration des données à suivre dans la bdd
Exploitation : Après usage de ce script puis importation des nouvelles données d'activité dans la base, exécuter le script SuiviMvt.cmd

:debut
REM @echo on
@echo %1 |gawk -f SuivreFiltre.awk > ..\work\SuivreFiltre.txt
if errorlevel 1 goto erreur

set /p filtre=< ..\work\SuivreFiltre.txt
shift
shift
set filtre=;%filtre%;%date:~6,10%-%date:~3,2%-%date:~0,2%;%0 %1 %2 %3 %4 %5 %6 %7 %8 %9
@echo %filtre% > ..\work\SuivreFiltre.txt
rem Le texte saisi à la console est en codepage 850 mais dois être importé dans sqlite qui travaille en UTF
convertcp 850 65001 /i ..\work\SuivreFiltre.txt /o ..\work\aSuivre.csv
rem 65001 = code de l'utf-8 pour convertcp
sqlite3 ../data/sandbox.db < ../bin/aSuivre.sql

goto :eof



:erreur
type ..\work\SuivreFiltre.txt