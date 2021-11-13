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
MODIF : 08/06/2018 - 15:20:24 r‚solution d'un conflit pour cause de pr‚sence d'un & dans le chemin du dossier d‚fini par %isdir%
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
MODIF : 12:35 18/02/2021 g‚nŠre le lien auguste des derniers retours d'UC afin de voir v‚rifier dans leur suivi si elles ‚taient attendues (surveillance du renvoi d'UC xp)
MODIF : 15:29 23/02/2021 remplace l'affichage texte de l'url de suivi de colis par une invocation de l'url dans chrome
BUG   : 13:26 24f/02/2021 correction d'une erreur dans la maniŠre de passer … Chrome l'URL … ouvrir
MODIF : 14:09 12/03/2021 l'url concerne maintenant tous les retours de r‚f‚rences "sensibles" et non juste les UC (donc inclut les serveurs)
MODIF : 16:55 05/04/2021 met de c“t‚ les CSV servant … g‚n‚rer les xml afin de les exploiter ult‚rieuremetn
MODIF : 10:18 16/04/2021 gŠre un signal de verrouillage afin d'‚viter que d'autres scripts essaient d'‚crire dessus en mˆme temps
BUG   : 20:34 19/04/2021 le suivi des retours se fait via un script plut“t que par l'invocation d'une url
MODIF : 18:33 11/05/2021 n'affiche pas le fichier des livraisons magnetik s'il n'y en a pas, mais un message d'avertissement … la place
MODIF : 11:39 30/08/2021 actualise la liste des produits exp‚di‚s (prˆt depuis plusieurs mois mais oubli‚ d'ajouter)
MODIF : 15:09 06/09/2021 actualisation de l'‚tat du stock non ok. Voir s'il faut le laisser ici o— l'ex‚cuter … part
BUG   : 21:10 17/10/2021 ajout d'une clause "delims=*" dans la boucle de scan des fichiers export‚s afin de prendre en compte la pr‚sence ‚ventuelle d'espaces (si provenant de chrome par exemple)
MODIF : 13:45 09/11/2021 ajoute la production de la liste de sites linux
MODIF : 13:45 09/11/2021 ajoute la production de la liste de PC linux exp‚di‚s mais non enregistr‚s comme revenus au stock
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

REM signal de blocage
:testblocage
if exist %temp%\bdd.maj (
set /p blocagebdd=<%temp%\bdd.maj
for %%I in ("%temp%\bdd.maj") do msg /w %username% "Un signal de blocage a ‚t‚ ‚mis … %%~tI par %blocagebdd%"
pause
)
if exist %temp%\bdd.maj goto testblocage
@echo %0 > %temp%\bdd.maj
:: ^^ pour pr‚venir qu'il faut attendre que la bdd soit lib‚r‚e avant de pouvoir ‚crire dessus


if not exist %userprofile%\downloads\export*.csv goto :raf

pushd "%isdir%\bin"

del ..\data\derniers.cmd 2>nul
touch ..\data\derniers.cmd

@echo Boucle de scan des fichiers d'export
REM for /F %%I in ('ufind "%userprofile%\downloads" -name "expo*.csv" ^|sed "s/\\//\\\/g"') do (gawk -f "%isdir%\bin\ExportIS.awk" "%%I" &&del "%%I")
for /F "delims=*" %%I in ('ufind "%userprofile%\downloads" -name "expo*.csv" ^|sed "s/\\//\\\/g"') do (gawk -f "ExportIS.awk" "%%I" &&del "%%I")

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
REM @echo Actualisation de l'‚tat des stocks
REM CALL ..\bin\EtatStock.cmd
:: en commentaire car d‚sormais ex‚cut‚ dans une tƒche planifi‚e
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

REM @echo on
@echo actualisation de la BDD SQLite
REM pause
REM MODIF : 11:03 27/05/2020 enchaŒne avec l'actualisation de la BDD SQLite des donn‚es I&S
sqlite3 sandbox.db < ..\bin\majdbIS.sql 2> %temp%\erreurs.sql
uecho -n -e Nombre de conflit d\x27import :\x20
:: -n pour ne pas finir par un saut de ligne (ainsi le r‚sultat du wc s'affiche sur la mˆme ligne)
:: -e pour interpr‚ter le \xHH comme des caractŠres dont le code est donn‚ en hexad‚cimal

wc -l %temp%\erreurs.sql | sed "s/^ *\([0-9]*\).*/\1/"
REM pause
@echo Suivi des retours d'UC
:: pour retra‡age des retours d'UC XP attendus
del %temp%\Suivi_Dernier_Retour_UC.txt 2>nul
sqlite3 -noheader sandbox.db "select * from v_Suivi_Dernier_Retour_Sensible_CMD;" > %temp%\Suivi_Dernier_Retour.cmd
CALL %temp%\Suivi_Dernier_Retour.cmd

@echo Actualisation du suivi des mouvements logistiques sous surveillance
CALL ..\bin\SuiviMvt.cmd

sqlite3 sandbox.db "select max(indate) from v_stock;" > ..\StatsIS\quipo\CumulCoutStockage\date.txt
sqlite3 -header -separator ; sandbox.db "select * from vvvvv_CoutStockageProduit;" > "..\StatsIS\quipo\SQLite\CumulCoutStockage.csv"
gawk -f ..\bin\csv2xml.awk "..\StatsIS\quipo\SQLite\CumulCoutStockage.csv" |sed "s/&/&amp;/g"> ..\StatsIS\quipo\CumulCoutStockage\fichier.xml

@Echo liste des derniers envois r‚alis‚s vers le siŠge
REM MODIF : 11:12 27/05/2020 enchaŒne avec la liste des derniers envois r‚alis‚s par I&S vers le siŠge
sqlite3 sandbox.db < ..\bin\lastlivmagnetik.sql
xcopy /y livmgk.csv ..\StatsIS\quipo\SQLite
gawk -f ..\bin\csvproj2xml.awk livmgk.csv |sed -e "s/\[//g" -e "s/\]//g" -e "s/&/et/g" > ..\StatsIS\quipo\LivMgk\projexped.xml
REM le SED pour rendre les num‚ros de colis cliquables dans Auguste
REM R‚utilisation de ce qui avait ‚t‚ fait pour le suvi du mat‚riel des projets sans autres modifications que des ajustements mineurs dans la partie html/xsl
for %%I in (lastlivmagnetik.txt) do if %%~zI GTR 0 start lastlivmagnetik.txt
for %%I in (lastlivmagnetik.txt) do if %%~zI == 0 msg %username% pas de d'envoi vers Magnetik aujourd'hui

@echo V‚rification de la coh‚rence de la date des tables mises … jour
sqlite3 -line sandbox.db  "select * from v_synchrotables;"| msg %username%


@echo surveillance de l'apparition de nouvelles r‚f‚rences
sqlite3 -line sandbox.db "select * from v_nouvref;" |msg /w %username%

@echo actualisation de la liste des produits exp‚di‚s
call SuiviSorties.cmd
xcopy /y ..\work\SuiviSorties.csv ..\StatsIS\quipo\SQLite

@echo actualisation de la liste des sites Linux
sqlite3 -separator ; -header sandbox.db "select * from vvv_SitesLinux;" > ..\work\SitesLinux.csv
xcopy /y ..\work\SitesLinux.csv ..\StatsIS\quipo\SQLite

@echo actualisation du parc Linux
sqlite3 -separator ; -header sandbox.db "select * from vv_ParcLinux;" > ..\work\ParcLinux.csv
xcopy /y ..\work\ParcLinux.csv ..\StatsIS\quipo\SQLite

@echo actualisation de la liste des ýnum‚ros de s‚rie revenus au stock
sqlite3 -separator ; -header sandbox.db "select * from v_SN_Retours;" > ..\work\SNRetours.csv
xcopy /y ..\work\SNRetours.csv ..\StatsIS\quipo\SQLite

@echo actualisation de l'‚tat du stock non ok
sqlite3 ..\Data\sandbox.db < ..\bin\Stock_NonOK.sql
xcopy /y ..\work\Stock_NonOK.csv ..\StatsIS\quipo\SQLite

REM @echo stat sur la surveillance de l'‚tat des produits en stocks
REM sqlite3 sandbox.db < ..\bin\genstatstockgraphs.sql

REM @echo Calcul de l'autonomie du stock
REM CALL ..\bin\autonomieStock.cmd
:: ^^ en commentaire car d‚sormais ex‚cut‚ au travers d'une tƒche planifi‚e

@echo mise … jour des histogrammes
call ..\bin\VentileNR.cmd
call ..\bin\VieStock.cmd
call ..\bin\AgeStock.cmd
REM pause

REM @echo on
@echo actualisation de la BDD de publication des stats
call quipoDBupdate.cmd
@echo Actualisation du repository
call ..\bin\quipoput.cmd

rem call ..\bin\creedossiersPM.cmd
rem ^^ temporairement, tant qu'il y a des dossiers … cr‚er pour ce d‚ploiement
rem d‚sactiv‚ le 17:49 05/11/2020 aprŠs cr‚ation de tous les dossiers de la phase "R‚gion parisienne"

popd
del %temp%\bdd.maj 2>nul
:: d‚sactive ^^ le signal de blocage de la bdd

goto :eof
