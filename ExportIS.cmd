@echo off
goto :debut
ExportIS.cmd
encodage OEM 863:French pour lire les accents correctement
Gilles M‚tais 19/01/2018 - 14:48:52
R‚cupŠre un fichier d'export I&S, le classe et le renomme en fonction des dates et selon qu'il s'agisse d'un fichier des produits exp‚di‚s ou re‡us

CONTEXTE :
Les fichiers d'exports I&S s'appellent toujours export*.csv et sont r‚cup‚r‚s par d‚faut dans le r‚pertoire "T‚l‚hargements" de l'utilisateur
Ce sont des fichiers d‚limit‚s par point-virgule, comportant un nombre de champs bien d‚finis et en particulier un champ "date" … un emplacement connu.

PREREQUIS
AWK (ici dans sa version GNU Gawk 4, issu de la distrib de GIT)
FIND unix (ici renomm‚ ufind afin de ne pas le confondre avec le find windows)

MODIF : 23/02/2018 - 11:00:00 finalisation
MODIF : 08/06/2018 - 15:20:24 r‚solution d'un conflit pour cause de présence d'un & dans le chemin du dossier défini par %isdir%
MODIF : 18:25 30/03/2020 pour chaque fichier export‚, cr‚e une copie au nom statique en plus du nom horodat‚
MODIF : 10:12 27/05/2020 convertit le plus r‚cent des ..\data\stock\te*.csv en TEexport_dernier.csv c'est … dire … l'identique + un champ indiquant la date de l'export
MODIF : 11:03 27/05/2020 enchaŒne avec l'actualisation de la BDD SQLite des donn‚es I&S
MODIF : 11:12 27/05/2020 enchaŒne avec la liste des derniers envois r‚alis‚s par I&S vers le siŠge
MODIF : 16:22 27/05/2020 effectue les traŒtements SQLite mˆme s'il n'y a pas de nouvelles donn‚es … exporter
MODIF : 16:10 26/06/2020 rajoute une sortie sur 1 mois dau format CSV des livraisons vers magnetik pour alimentation du quipo
MODIF : 16:57 01/10/2020 rajoute la mise … jour du suivi des mouvements sous surveillance
MODIF : 10:02 05/10/2020 rajoute temporairement la cr‚ation de dossiers pour la migration des postes maŒtres Coli, sera d‚sactiv‚ aprŠs le d‚ploiement
MODIF : 17:49 05/11/2020 d‚sactivation de la modif du 10:02 05/10/2020 tous les dossiers "r‚gion parisienne" ayant ‚t‚ cr‚‚s
MODIF : 09:30 19/11/2020 rajoute la mise … jour de l'‚tat des stocks et de la liste des produits exp‚di‚s depuis moins d'un mois
MODIF : 09:57 03/12/2020 filtre les ‚ventuels signes & pr‚sents dans le fichier xml des exp‚ditions vers magnetik
:debut
REM @echo on
if "@%isdir%@" NEQ "@@" goto isdirok
if exist ..\bin\getisdir.cmd (
call ..\bin\getisdir.cmd
goto isdirok
)
msg /w %username% Impossible de trouver le dossier I^&S
goto :eof
:isdirok
@echo off


if not exist %userprofile%\downloads\export*.csv goto :raf

pushd "%isdir%\bin"

del ..\data\derniers.cmd 2>nul
touch ..\data\derniers.cmd

REM Boucle de scan des fichiers d'export
REM for /F %%I in ('ufind "%userprofile%\downloads" -name "expo*.csv" ^|sed "s/\\//\\\/g"') do (gawk -f "%isdir%\bin\ExportIS.awk" "%%I" &&del "%%I")
for /F %%I in ('ufind "%userprofile%\downloads" -name "expo*.csv" ^|sed "s/\\//\\\/g"') do (gawk -f "ExportIS.awk" "%%I" &&del "%%I")

popd

pushd ..\data
ufind "." -name "is_*.csv" -cnewer derniers.cmd |sed -n "s/.*\(is_[A-z]*\)\(_[0-9]*-*.*\.csv\)/copy \/y \1\2 \1_dernier\.csv/p">> derniers.cmd
:: ^^ dresse la liste des fichiers du r‚pertoire courant dont le nom commence par is_* et qui sont plus r‚cents que le fichier derniers.cmd puis ‚dite cette liste de maniŠre … en faire un script de copie de fichiers

call derniers.cmd
rem MODIF : 10:12 27/05/2020 convertit le plus r‚cent des ..\data\stock\te*.csv en TEexport_dernier.csv c'est … dire … l'identique + un champ indiquant la date de l'export
call ..\bin\derniersynthesestock.cmd
set /p datetemp=<dernier_export.txt
@echo off
call ..\bin\datesynthesestock.cmd %datetemp% >nul
@echo off
copy /y ..\data\TEexport_date.csv ..\data\TEexport_dernier.csv >nul

popd
REM Actualisation de l'‚tat des stocks
CALL ..\bin\EtatStock.cmd
:: utilise la variable %datetemp% d‚finie juste auparavant

REM uFind pr‚f‚rable … un dir /s qui ne permet pas d'avoir … la fois le chemin d'accŠs complet et le filtre sur la date
REM mais il faut quand mˆme en ‚diter la sortie sinon le del ne marche pas
REM (alors que le gawk marche)

goto :fin
:raf
@echo Aucun fichier d'export trouv‚ dans le dossier de t‚l‚chargement
:fin
pushd ..\data

rem MODIF : 11:03 27/05/2020 enchaŒne avec l'actualisation de la BDD SQLite des donn‚es I&S
sqlite3 sandbox.db < ..\bin\majdbIS.sql 2> %temp%\erreurs.sql
uecho -n -e Nombre de conflit d\x27import :\x20
:: -n pour ne pas finir par un saut de ligne (ainsi le r‚sultat du wc s'affiche sur la mˆme ligne)
:: -e pour interpr‚ter le \xHH comme des caractŠres dont le code est donn‚ en hexad‚cimal

wc -l %temp%\erreurs.sql | sed "s/^ *\([0-9]*\).*/\1/"


REM MODIF : 11:12 27/05/2020 enchaŒne avec la liste des derniers envois r‚alis‚s par I&S vers le siŠge
sqlite3 sandbox.db < ..\bin\lastlivmagnetik.sql
gawk -f ..\bin\csvproj2xml.awk livmgk.csv |sed -e "s/\[//g" -e "s/\]//g" -e "s/\&/et/g" > ..\StatsIS\quipo\LivMgk\projexped.xml
REM le SED pour rendre les numéros de colis cliquables dans Auguste
REM R‚utilisation de ce qui avait été fait pour le suvi du matériel des projets sans autres modifications que des ajustements mineurs dans la partie html/xsl
lastlivmagnetik.txt

REM Actualisation du suivi des mouvements logistiques sous surveillance
CALL ..\bin\SuiviMvt.cmd


REM Actualisation de la liste des produits exp‚di‚s depuis moins d'un mois
CALL ..\bin\SuiviSorties.cmd

REM Actualisation du repository
call ..\bin\quipoput.cmd

rem call ..\bin\creedossiersPM.cmd
rem ^^ temporairement, tant qu'il y a des dossiers … cr‚er pour ce d‚ploiement
rem d‚sactiv‚ le 17:49 05/11/2020 aprŠs cr‚ation de tous les dossiers de la phase "R‚gion parisienne"

popd
goto :eof
