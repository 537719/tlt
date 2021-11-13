@echo off
goto :debut
plotloop.cmd
(anciennement plotloopnew.cmd)
CREATION    16:26 12/10/2020    Remplace plotloop.cmd du 16:44 mardi 22 janvier 2019 
            Adaptation à la nouvelle situation où les stats sont produites par sqlite et non plus par un mécanisme awk/batch
USAGE       Invocation par creestats.new.cmd
RELEASE     12:08 15/10/2020 première version opérationnelle

PREREQUIS   Ficher de stat sfpStats.csv qui contient un en-tête puis toutes les stats de tous les produits sur les 13 derniers mois dont le mois en cours et qui a la même structure que les fichiers [nomdestat].csv précédemment utilisés
DateStat;Incident;Demande;RMA;DEL;undef;CodeStat;OkDispo;OkReserve;SAV;Maintenance;Destruction;Alivrer;CodeStatBis;Seuil;LibStat
2019-10-31;8;38;0;0;0;C11;8;9;0;5;0;0;C11;15;Imprimantes C11 Chronopost
2019-11-30;6;47;0;0;0;C11;29;0;0;5;0;0;C11;15;Imprimantes C11 Chronopost
...
2020-03-31;35;66;26;0;0;COLPV;595;0;0;0;17;0;COLPV;200;Imprimantes Colissimo Expeditor PV
2020-04-30;44;54;9;0;0;COLPV;592;0;0;0;19;250;COLPV;200;Imprimantes Colissimo Expeditor PV
2020-05-31;47;101;15;0;0;COLPV;445;0;0;0;21;250;COLPV;200;Imprimantes Colissimo Expeditor PV
...
2020-08-31;24;75;31;0;0;ZPL;283;75;0;0;0;0;ZPL;100;Imprimantes ZPL pour Chronoship
2020-09-30;47;113;43;0;0;ZPL;237;8;0;0;0;14;ZPL;100;Imprimantes ZPL pour Chronoship
2020-10-05;5;27;0;0;0;ZPL;224;3;0;0;0;0;ZPL;100;Imprimantes ZPL pour Chronoship

BUG     10:15 04/12/2020 les pages web produites étaient concaténées dans un fichier au lieu d'être placées dans un répertoire
MODIF   14:18 06/01/2021 plotloopnew.cmd renommé en plotloop.cmd
BUG     11:14 17/06/2021 un \ en trop dans le chemin d'accès empêchait la màj de la bdd des graphiques
BUG     12:05 18/06/2021 Erreur de logique : les graphiques ne doivent être mis à jour dans la bdd qu'après avoir été vérifiés donc pas ici mais dans creestats.cmd

:debut
REM @echo on
pushd ..\Data
sqlite3 sandbox.db ".read ../bin/SFPencours.sql" 1>..\StatsIS\sfpStats.csv 2>%temp%\erreur.sql
Uecho -n Anomalies de traitement SQLite : 
grep -v  "UNIQUE" %temp%\erreur.sql |wc -l
CD ..\StatsIS

if not exist sfpStats.csv goto :errfich
REM for %%I in (sfpStats.csv) @echo %%I %%~zI
for %%I in (sfpStats.csv) do if @%%~zI@==@0@ goto :errsize

REM pause
if not exist %gnuplot% goto :gnuplot
REM pause


REM Extraction de la liste des stats à générer
gawk -F; "NR==1 {next} {print $7}" sfpStats.csv |usort -u -o sfpListe.txt
:: On évite la première ligne, qui est un en-tête et dont l'utilisation gérèrerait un fichier de taille nulle

REM fixation des bornes temporelles
:: le fichier csv est calibré sur le mois en cours plus les 12 précédents, donc il n'y a pas à transmettre les dates en paramètre
gawk -F; -v datemin="9999-99-99" -v datemax="" -v setdatemin="set datedeb=" -v setdatemax="set datefin=" "$1 ~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/ {if ($1 > datemax ) {datemax=$1};if ($1<datemin) {datemin=$1}} END {print setdatemin datemin;print setdatemax datemax}" sfpStats.csv > setbornesdates.cmd
call setbornesdates.cmd

REM Génération des fichiers de stat
REM rd /s /q quipo/%datefin% 2>nul
REM md quipo/%datefin%

if not exist quipo\%datefin%\nul md quipo\%datefin%
if not exist quipo\%datefin%\nul goto errdossier
:: 10:15 04/12/2020 sans cela les pages web produites sont concaténées dans un seul fichier au lieu d'être placées dans un répertoire

for /F %%I in (sfpliste.txt) do (
    @echo Graphique au %datefin% pour %%I
REM Construit pour chaque famille de produit les fichiers de données pour alimenter gnuplot
    head -1 sfpStats.csv |sed "s/;/\t/g" > %%I.tab
    grep %%I sfpStats.csv |sed "s/;/\t/g" >> %%I.tab
    
  REM Reconstitue un csv à jour
sed -n -e "1p" -e "/%%I/p" sfpStats.csv > %%I.tmp
  move /y %%I.csv %%I.bak.csv >nul
  move /y %%I.tmp %%I.csv >nul


    REM Crée le graphique
    "%gnuplot%"  -c ..\bin\genericplot.plt %%I.tab %datedeb% %datefin% >nul
    copy /y %%I.png quipo\datefin% >nul

    move %%I.* "%moisfin%" >nul
  copy "%moisfin%\%%I.txt" .  >nul
  copy "%moisfin%\%%I.csv" .  >nul
  
sed -n "1p" %%I.txt > %%I_Designation.txt
sed -n "3,$p" %%I.txt > %%I_Commentaire.txt
copy %%I_*.txt quipo\%datefin%
REM @echo on
REM @echo mise à jour du graphique %%I
REM @echo code '%%I'
REM @echo Sujet %~n0
dir /-c ..\StatsIS\%%I* |grep %date%
rem c'est pas ici qu'on doit intégrer les graphiques dans la bdd car cela empêche d'annuler en cas de détection d'anomalie lors de la vérification
rem sqlite3 "%userprofile%\Documents\ALT\I&S\StatsIS\quipo\SQLite\quipo.db" "insert or replace into SFPFluxStock(code,Image,Designation,Sujet,Commentaire) values('%%I',readfile('%%I.png'),readfile('%%I_Designation.txt'),'%~n0',readfile('%%I_Commentaire.txt')) ;"
REM pause
@echo off
)
REM Génération des page web correspondant à chaque stat
rem inutile depuis que les graphiques sont gérés sous sqlite
REM gawk -f ..\bin\newgenHTMLlink.awk sfpListe.txt
REM copy /y *.htm quipo\%datefin%
REM pause


:fin
popd
REM pause
goto :eof

:errfich
msg /w %username% Le fichier sfpStats.csv est absent
:errsize
goto fin
msg /w %username% Le fichier sfpStats.csv a une taille nulle
goto fin
:gnuplot
msg /w %username% Le chemin de gnuplot n'est pas transmis
pause
goto fin
:errdossier
msg /w %username% "Impossible de créer le dossier %datefin% suis quipo"
pause
goto fin


:eof