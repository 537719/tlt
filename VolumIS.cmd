@echo off
goto debut
VolumIS.cmd
CREATION    18:33 15/01/2021 G‚nŠre les graphique de suivi de la volum‚trie de l'activit‚ I&S
MODIF       13:24 23/03/2021 Multicourbes (jour semaine mois) au lieu de monocourbe, g‚n‚ration des op‚rations graphiques plut“t que s‚quenc‚es et d‚sactivation de la synchro, faite par ailleurs
MODIF       11:22 25/03/2021 calcul du temps d'‚cution de chaque phase
MODIF       10:41 26/03/2021 n‚cessite que gnuplot soit pr‚sent dans le path (donc install‚ "normalement" plut“t que juste copi‚) au lieu d'en d‚finir le chemin dans une variable 
MODIF       15:26 12/04/2021 archive des graphiques dans la table de graphiques de la bdd de stats
MODIF       11:40 16/04/2021 s'assure de ne pas copier des graphiques vides (on garde alors l'ancienne version)
MODIF       10:56 22/04/2021 archive ‚galement le commentaire du graphique dans la bdd de stats
MODIF       21:01 26/04/2021 supprime l'‚criture de la d‚signation dans le graphique puisqu'elle est toujours la mˆme et que ‡a pose des problŠmes de gestion des accents


:debut
@echo Graphiques de suivi de la volum‚trie
if "@%isdir%@" NEQ "@@" goto isdirok
if exist ..\bin\getisdir.cmd (
call ..\bin\getisdir.cmd
goto isdirok
) else if exist .\bin\getisdir.cmd (
call ..\bin\getisdir.cmd
goto isdirok
)

msg /w %username% Impossible de trouver le dossier I^&S
goto :eof
:isdirok
REM set gnuplot=%userprofile%\bin\gnuplot\bin\gnuplot.exe  
pushd "%isdir%\Data"

@echo Extraction des donn‚es
udate "+%%s" > %temp%\DateDeb.tmp
set /p deb=<%temp%\DateDeb.tmp
Uecho -n Ordinateurs : d‚but  %time%
sqlite3 -header -separator ; -cmd ".output ../work/ordinateurs.csv" sandbox.db "select * from v2_SortiesOrdis ;" 
udate "+%%s" > %temp%\DateFin.tmp
set /p fin=<%temp%\DateFin.tmp
Uecho -n " - fin %time%"
uecho -n " - Dur‚e "
set /a mn=(%fin%-%deb%)/60
set /a ss=(%fin%-%deb%)-%mn%*60
@echo %mn%'%ss%"
REM gawk -v OFS=" " -v deb="%deb%"  -v fin="%fin%" -v pattern="%%T" "BEGIN {print strftime(pattern,fin-deb)}"

udate "+%%s" > %temp%\DateDeb.tmp
set /p deb=<%temp%\DateDeb.tmp
Uecho -n Sorties : d‚but  %time%
sqlite3 -header -separator ; -cmd ".output ../work/sorties.csv" sandbox.db "select * from v2_SortiesProduits ;" 
udate "+%%s" > %temp%\DateFin.tmp
set /p fin=<%temp%\DateFin.tmp
Uecho -n " - fin %time%"
uecho -n " - Dur‚e "
set /a mn=(%fin%-%deb%)/60
set /a ss=(%fin%-%deb%)-%mn%*60
@echo %mn%'%ss%"
REM gawk -v OFS=" " -v deb="%deb%"  -v fin="%fin%" -v pattern="%%T" "BEGIN {print strftime(pattern,fin-deb)}"

udate "+%%s" > %temp%\DateDeb.tmp
set /p deb=<%temp%\DateDeb.tmp
Uecho -n Audit : d‚but %time%
sqlite3 -header -separator ; -cmd ".output  ../work/audits.csv" sandbox.db "select * from v3_Audit ;" 
udate "+%%s" > %temp%\DateFin.tmp
set /p fin=<%temp%\DateFin.tmp
Uecho -n " - fin %time%"
uecho -n " - Dur‚e "
set /a mn=(%fin%-%deb%)/60
set /a ss=(%fin%-%deb%)-%mn%*60
@echo %mn%'%ss%"
REM gawk -v OFS=" " -v deb="%deb%"  -v fin="%fin%" -v pattern="%%T" "BEGIN {print strftime(pattern,fin-deb)}"

udate "+%%s" > %temp%\DateDeb.tmp
set /p deb=<%temp%\DateDeb.tmp
Uecho -n Dossiers : d‚but %time%
sqlite3 -header -separator ; -cmd ".output ../work/dossiers.csv" sandbox.db "select * from v4_SortiesDossiers ;" 
udate "+%%s" > %temp%\DateFin.tmp
set /p fin=<%temp%\DateFin.tmp
Uecho -n " - fin %time%"
uecho -n " - Dur‚e "
set /a mn=(%fin%-%deb%)/60
set /a ss=(%fin%-%deb%)-%mn%*60
@echo %mn%'%ss%"
REM gawk -v OFS=" " -v deb="%deb%"  -v fin="%fin%" -v pattern="%%T" "BEGIN {print strftime(pattern,fin-deb)}"

udate "+%%s" > %temp%\DateDeb.tmp
set /p deb=<%temp%\DateDeb.tmp
Uecho -n Entr‚es : d‚but %time%
sqlite3 -header -separator ; -cmd ".output ../work/entrees.csv" sandbox.db "select * from v3_Receptions ;"
udate "+%%s" > %temp%\DateFin.tmp
set /p fin=<%temp%\DateFin.tmp
Uecho -n " - fin %time%"
uecho -n " - Dur‚e "
set /a mn=(%fin%-%deb%)/60
set /a ss=(%fin%-%deb%)-%mn%*60
@echo %mn%'%ss%"
REM gawk -v OFS=" " -v deb="%deb%"  -v fin="%fin%" -v pattern="%%T" "BEGIN {print strftime(pattern,fin-deb)}"

@echo g‚n‚ration des graphiques
cd ..\work
for %%I in (Dossiers Sorties Ordinateurs Audits Entrees) do (
del %%I.png
if %%~zI.csv GTR 0 (
gawk -f ..\bin\GenMultiCourbes.awk %%I.csv  > %%I.plt
gnuplot -c %%I.plt  "%%I"
)
REM pause
:: s'assure de ne pas copier des graphiques vides (on garde alors l'ancienne version)
if %%~zI.png GTR 0 (
copy /y %%I.png ..\StatsIS\quipo\VolumIS
sqlite3 ..\StatsIS\quipo\SQLite\quipo.db "insert or replace into graphiques(code,Image,Commentaire,Sujet) values('%%I',readfile('%%I.png'),readfile('..\StatsIS\quipo\%~n0\%%I.txt','%~n0') ;"
)
)
popd
REM call ..\bin\quipoput.cmd
