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
MODIF : 12:15 11/12/2020 rajoute une v‚rif de la coh‚rence des dates et ex‚cute le suivi des mouvements en dernier
MODIF : 13:00 16/12/2020 convertit les fichiers d'export I&S de CP1252 vers UTF8 pour g‚rer correctement les accents sous SQLite
MODIF : 21:20 16/12/2020 affiche l'‚tat de synchro des tables sous forme de popup plut“t que perdu dans le flot de sortie du script
MODIF : 13:55 19/12/2020 gestion de la date du dernier import d'archive de stock (historisation des stocks pour analyse sur l'‚tat des articles en stock)
MODIF : 13:55 19/12/2020 gestion de la date du dernier import d'archive de catalogue (historisation des exports de catalogue pour alerte sur cr‚ations de r‚f‚rences)
MODIF : 10:39 20/12/2020 surveille l'apparition de nouvelles r‚f‚rences dans le catalogue
MODIF : 22:38 20/12/2020 Calcul du co–t de stockage cumul‚ des articles en stock
MODIF : 18:29 21/12/2020 g‚nŠre les graphiques de suivi de l'‚tat des produits en stock
MODIF : 21:45 26/12/2020 Rajoute la nouvelle mo–ture du calcul d'autonomie (dat‚e du mˆme jour)
BUG   : 15:50 29/12/2020 La partie "cumul des co–ts de stockage" ne sortait pas les articles ayant le caractŠre "&" dans leur d‚signation
MODIF : 13:17 11/01/2021 ex‚cute d‚sormais les scripts "ventilNR.cmd" et "vieStock.cmd" pr‚c‚demment lanc‚s via creestat.cmd
MODIF : 22:29 25/01/2021 ‚pure les guillemets gˆnants dans le fichier des sorties (bizarrement ils n'y a que l… qu'ils sont gˆnants)
MODIF : 17:02 01/02/2021 d‚sactivation de genstatstockgraphs trop long pour une invocation quotidienne et remont‚ au niveau de creestat.cmd
BUG   : 17:28 01/02/2021 l'invocation du script ventileNR.cmd se faisait avec une faute (omission du "e"), donc ne se faisait pas
MODIF : 18:28 04/02/2021 L'invocation du script CoutStock.cmd se fait d‚sormais via un "start" afin de ne pas bloquer ce script
                         Entraine la modification de l'ordre d'appel des sous scripts car la BDD est verrouill‚e
BUG	  : 21:29 05/02/2021 le passage de gawk 4 … gawk 5 impose de remplacer \& par  dans la fonction special2html
BUG   : 22:34 05/02/2021 coutstock.cmd et statstock.cmd sont d‚port‚es de exportis.cmd vers creestat.cmd car, longues … ex‚cuter, elles verrouillent les m…j de la bdd et donc perturbent la g‚n‚ration des stats si elles sont lanc‚es ici

:debut
REM @echo on
set gnuplot=%userprofile%\bin\gnuplot\bin\gnuplot.exe  
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

@echo Boucle de scan des fichiers d'export
REM for /F %%I in ('ufind "%userprofile%\downloads" -name "expo*.csv" ^|sed "s/\\//\\\/g"') do (gawk -f "%isdir%\bin\ExportIS.awk" "%%I" &&del "%%I")
for /F %%I in ('ufind "%userprofile%\downloads" -name "expo*.csv" ^|sed "s/\\//\\\/g"') do (gawk -f "ExportIS.awk" "%%I" &&del "%%I")

popd

pushd ..\data
REM ufind "." -name "is_*.csv" -cnewer derniers.cmd |sed -n "s/.*\(is_[A-z]*\)\(_[0-9]*-*.*\.csv\)/copy \/y \1\2 \1_dernier\.csv/p">> derniers.cmd
ufind "." -name "is_*.csv" -cnewer derniers.cmd |sed -n "s/.*\(is_[A-z]*\)\(_[0-9]*-*.*\.csv\)/convertcp 1252 65001 \/i \1\2 \/o \1_dernier\.csv/p">> derniers.cmd
:: ^^ dresse la liste des fichiers du r‚pertoire courant dont le nom commence par is_* et qui sont plus r‚cents que le fichier derniers.cmd puis ‚dite cette liste de maniŠre … en faire un script de copie de fichiers
call derniers.cmd

REM MODIF : 22:29 25/01/2021 ‚pure les guillemets gˆnants dans le fichier des sorties (bizarrement ils n'y a que l… qu'ils sont gˆnants)
gawk -f filtre034.awk is_out_dernier.csv > is_out_034.csv
move /y is_out_034.csv is_out_dernier.csv 

rem MODIF : 10:12 27/05/2020 convertit le plus r‚cent des ..\data\stock\te*.csv en TEexport_dernier.csv c'est … dire … l'identique + un champ indiquant la date de l'export
call ..\bin\derniersynthesestock.cmd
set /p datetemp=<dernier_export.txt
@echo off
call ..\bin\datesynthesestock.cmd %datetemp% >nul
@echo off
copy /y ..\data\TEexport_date.csv ..\data\TEexport_dernier.csv >nul


popd
@echo Actualisation de l'‚tat des stocks
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

@echo Actualisation de l'archive des stocks
REM for /F %%I in ('dir /o-d /b is_stock_*-*.csv ^|head -1') do gawk -f stockconcat.awk %%I > stockarchive.csv
del utf8-is_stock_*.csv 2>nul
for /F %%I in ('dir /o-d /b is_stock_*-*.csv ^|head -1') do convertcp 1252 65001 /i %%I /o utf8-%%I
gawk -f ..\bin\stockconcat.awk utf8-is_stock_*.csv > stockarchive.csv

@echo Actualisation de l'archive du catalogue
REM del utf8-is_catalogue_*.csv 2>nul
for %%I in (is_catalogue_dernier.csv) do gawk -v datefich="%%~tI" -f ..\bin\catalconcat.awk is_catalogue_dernier.csv > catarchive.csv

@echo actualisation de la BDD SQLite
REM MODIF : 11:03 27/05/2020 enchaŒne avec l'actualisation de la BDD SQLite des donn‚es I&S
sqlite3 sandbox.db < ..\bin\majdbIS.sql 2> %temp%\erreurs.sql
uecho -n -e Nombre de conflit d\x27import :\x20
:: -n pour ne pas finir par un saut de ligne (ainsi le r‚sultat du wc s'affiche sur la mˆme ligne)
:: -e pour interpr‚ter le \xHH comme des caractŠres dont le code est donn‚ en hexad‚cimal

wc -l %temp%\erreurs.sql | sed "s/^ *\([0-9]*\).*/\1/"

@echo Actualisation du suivi des mouvements logistiques sous surveillance
CALL ..\bin\SuiviMvt.cmd


sqlite3 sandbox.db "select max(indate) from v_stock;" > ..\StatsIS\quipo\CumulCoutStockage\date.txt
sqlite3 -header -separator ; sandbox.db "select * from vvvvv_CoutStockageProduit;" |gawk -f ..\bin\csv2xml.awk  |sed "s/&/&amp;/g"> ..\StatsIS\quipo\CumulCoutStockage\fichier.xml

@Echo liste des derniers envois r‚alis‚s vers le siŠge
REM MODIF : 11:12 27/05/2020 enchaŒne avec la liste des derniers envois r‚alis‚s par I&S vers le siŠge
sqlite3 sandbox.db < ..\bin\lastlivmagnetik.sql
gawk -f ..\bin\csvproj2xml.awk livmgk.csv |sed -e "s/\[//g" -e "s/\]//g" -e "s/&/et/g" > ..\StatsIS\quipo\LivMgk\projexped.xml
REM le SED pour rendre les numéros de colis cliquables dans Auguste
REM R‚utilisation de ce qui avait été fait pour le suvi du matériel des projets sans autres modifications que des ajustements mineurs dans la partie html/xsl
lastlivmagnetik.txt

@echo V‚rification de la coh‚rence de la date des tables mises … jour
sqlite3 -line sandbox.db  "select * from v_synchrotables;"| msg %username%


@echo surveillance de l'apparition de nouvelles r‚f‚rences
sqlite3 -line sandbox.db "select * from v_nouvref;" |msg /w %username%

REM @echo stat sur la surveillance de l'‚tat des produits en stocks
REM sqlite3 sandbox.db < ..\bin\genstatstockgraphs.sql

@echo Calcul de l'autonomie du stock
CALL ..\bin\autonomieStock.cmd

@echo mise … jour des histogrammes
call ..\bin\VentileNR.cmd
call ..\bin\VieStock.cmd
call ..\bin\AgeStock.cmd
REM pause

@echo on
@echo Actualisation du repository
call ..\bin\quipoput.cmd

rem call ..\bin\creedossiersPM.cmd
rem ^^ temporairement, tant qu'il y a des dossiers … cr‚er pour ce d‚ploiement
rem d‚sactiv‚ le 17:49 05/11/2020 aprŠs cr‚ation de tous les dossiers de la phase "R‚gion parisienne"

popd
goto :eof
