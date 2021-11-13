@echo off
goto :debut
SuiviMvt.cmd
CREATION    16:03 30/09/2020    Détecte les mouvements attendus dans le suivi et les publie sur le quipo
MODIF       15:15 01/10/2020    rajoute un décompte du nombre de lignes concernées
MODIF       16:13 01/10/2020    remplace la commande interne echo par son équivalent externe gnu renommé ici en uecho afin de bénéficier de l'option de suppression du caractère de fin de ligne
BUG         15:53 18/03/2021    Convertit (enfin) la sortie du codepage UTF-8 vers le 8859-1 requis pour le xml
MODIF       16:48 05/04/2021    met de côté le csv afin de l'exploiter ultérieurement
BUG         20:10 14/04/2021    le script était gelé lors de l'invocation du fichier texte de résultat, résolu en l'invoquant via un start
BUG         10:12 23/04/2021    remplace les & par des &amp dans le xml de résultat sinon ça bloque l'affichage ajax
MODIF       18:33 11/05/2021    n'affiche pas le fichier des mouvements suivis s'il n'y en a pas, mais un message d'avertissement à la place
BUG         18:36 11/05/2021    /!\ Attention, la datemvt peut être antérieure à la datevu, ce n'est pas un bug
MODIF       09:06 02/09/2021    Affiche en popup la liste des mouvements entrant en surveillance
:debut
@Echo Actualisation du suivi des mouvements logistiques sous surveillance

@echo vérification du blocage de la base
set codeerreur=0
sqlite3 sandbox.db "create table if not exists bidon(iteration integer,horodatage text default current_timestamp)";
REM if errorlevel 1 set codeerreur=%errorlevel%
if errorlevel 1 goto errsql


sqlite3 ../data/sandbox.db ".read ../bin/SuiviMvt.sql"

wc -l ..\work\suivimvt.csv |gawk '{print $1,"mouvements suivis"}'
xcopy /y ..\work\suivimvt.csv ..\StatsIS\quipo\SQLite

gawk -f ..\bin\csv2xml.awk ..\work\suivimvt.csv  |sed "s/\&/\&amp;/g"| iconv -f UTF-8 -t L1 > ..\work\fichier.xml
xcopy /y ..\work\fichier.xml ..\statsis\quipo\SuiviMvt >nul
uecho -n %date% > ..\statsis\quipo\SuiviMvt\date.txt

::MODIF       09:06 02/09/2021    Affiche en popup la liste des mouvements entrant en surveillance
sqlite3 -noheader -column ..\Data\sandbox.db ".print nouveaux mouvements sous surveillance" "select * from suivimvt where datesurv=(select max(datesurv) from suivimvt);"|convertcp 65001 1251 |msg /w %username%

for %%I in (..\work\lastmvt.txt) do if %%~zI GTR 0 start ..\work\lastmvt.txt
for %%I in (..\work\lastmvt.txt) do if %%~zI == 0 msg %username% pas de mouvement suivi aujourd'hui

goto :fin
:errsql
msg /w %username% Erreur sql No %codeerreur%
goto :debut
:fin