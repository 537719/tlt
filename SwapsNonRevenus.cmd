@echo off
goto :debut
SwapsNonRevenus.cmd
CREATION    15:08 09/04/2021 Donne la liste des dossiers pour lequel le mat‚riel swapp‚ n'est pas revenu
MODIF       10:52 16/04/2021 gŠre un signal de verrouillage afin d'‚viter que d'autres scripts essaient d'‚crire dessus en mˆme temps
:debut

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


pushd ..\Data
REM goto finalisation
del %temp%\retours.txt 2>nul
uecho -n -e attendre environ 1/4 d'heure … partir de\x20
udate "+%%T"

sqlite3 -noheader sandbox.db "select * from v_Retours_NonRecus_NoObj;" > %temp%\retours.cmd
REM for %%I in (%temp%\retours.txt) do IF %%~zI GTR 2 (
:: s'il n'y a pas de retour, le fichier r‚sultat contient juste un CRLF donc sa taille est de 2 octets
REM @echo on
uecho -n -e premiŠre partie termin‚e …\x20
udate "+%%T"

call %temp%\retours.cmd
REM )

msg /w %username% "Exporter la liste des colis distribu‚s en tant que %CD%\servletAuguste (tel que propos‚ par d‚faut)"

pause

REM signal de blocage
:testblocage
if exist %temp%\bdd.maj (
set /p blocagebdd=<%temp%\bdd.maj
for %%I in ("%temp%\bdd.maj") do @echo Un signal de blocage a ‚t‚ ‚mis … %%~tI par %blocagebdd%
sleep 1m    
)
if exist %temp%\bdd.maj goto testblocage
@echo %~n0 > %temp%\bdd.maj %temp%\bdd.maj
:: ^^ pour pr‚venir qu'il faut attendre que la bdd soit lib‚r‚e avant de pouvoir ‚crire dessus


sqlite3 -separator "	" sandbox.db ".import servletAuguste RetoursRecus" 2>nul
del %temp%\bdd.maj
:: lŠve le signal de blocage

uecho -n -e attendre environ 1/4 d'heure … partir de\x20
udate "+%%T"
sqlite3 -header -separator ; sandbox.db  "select * from v_Retours_NonRecus_Detail;" > ..\work\%~n0.csv
uecho -n -e premiŠre partie termin‚e …\x20
udate "+%%T"

:finalisation
 :: finalisation des donn‚es
cd ..\work
copy /y %~n0.csv ..\StatsIS\quipo\SQLite
for %%I in (%0) do gawk -f ..\bin\csv2xml.awk %%~nI.csv |sed "s/&/\&amp;/pg" > ..\StatsIS\quipo\%%~nI\fichier.xml
dir /-c %~n0.csv |gawk "$1 ~ /[0-9]{2}\/[0-9]{2}\/[0-9]{4}/ {print $1}"  > ..\StatsIS\quipo\%~n0\date.txt
dir /-c %~n0.csv |gawk "$1 ~ /[0-9]{2}\/[0-9]{2}\/[0-9]{4}/ {print $1}"  > ..\StatsIS\quipo\SQLite\%~n0.txt
:: date d'actualisation des donn‚es, afin de l'afficher dans la page web ^^

:fin
popd