:: IncProdIS.cmd
goto :debut
D'aprŠs 03/02/2020  11:13             3820 coutstock.cmd
Remplace totalement l'ancienne version de IncProdIS.cmd rendue obsolŠte suite … la suppression de l'accŠs MySql via ODBC
L'ancienne version est renomm‚e en IncProdIS2019.cmd et ne doit plus ˆtre utilis‚e

script de pilotage de la requˆte IncProdIS.sql visant … calculer, par cat‚gorie, le nombre d'incidents de production rencontr‚s mensuellement par I&S
CREATION    17:06 04/02/2020
PREREQUIS  requˆte IncProdIS.sql en ..\bin
                    extraction en ..\IncProdIS du fichier glpi.csv obtenu d'aprŠs la requˆte suivante :
--                          "Tâches - Date" aprŠs "01-01-2020 00:00"
--                    ET  "Tâches - Date" avant "01-02-2020 00:00"
--                    ET  "Tâches - Description" contient "isi-"
-- ATTENTION : ne pas prendre de p‚riode … cheval sur plusieurs mois
-- "isi-" est le pr‚fixe des codes indiqu‚s par I&S en cas d'erreur de production
                    accŠs … SQLite
                    accŠs aux utilitaires GNU
                    Ce script doit ˆtre encod‚ en OEM863 (French) pour que les accents soient rendus correctement dans le graphique en sortie
BUG             N‚cessit‚ de prot‚ger le & de I&S ce qui a introduit celle de prot‚ger le \ qui le protŠge, puis l'apostrophe et enfin les accents circonflexes
MODIF          G‚nŠre un fichier XML pour l'affichage des data sous forme de tableau xml+xsl
MODIF          11:35 28/02/2020 laisse les donn‚es g‚n‚r‚es dans le r‚pertoire de travail et les recopie dans le dossier de publication, au lieu de les d‚placer
                    Affiche le graphique et le texte d'accompagnement afin de permettre de tenir … jour l'un en fonction des ‚volutions de l'autre.
BUG     09:44 17/07/2020 suppression d'une double-quote en trop dans l'instruction SED en pipe avec le gawk
BUG     11:21 11/09/2020 ‚clatement sur 2 lignes l'instruction SED en pipe avec le gawk car elle marche en ligne de commandes mais pas en script

:debut
@echo off
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


REM positionnement dans le dossier de donn‚es
pushd ..\IncProdIS

REM la requˆte SQLite s'attend … trouver uniquement un fichier glpi.csv en entr‚e
if not exist glpi.csv goto :errfile
for %%I in (glpi.csv)  do if %%~zI == 0 goto errsize
 
 :: lance la requˆte SQLite en s'attendant … ce qu'elle porte le mˆme nom que le pr‚sent script mais avec une extension diff‚rente
 
for %%I in (%0) do sqlite3 <..\bin\%%~nI.sql
 
 :: finalisation des donn‚es
 set /p nomresultat=<nomresultat.txt

 :: histostatincprod.csv est la concat‚nation de l'historique des stats d'incident de production
REM @echo histostatincprod
REM pause
 sed -i "/%nomresultat:~0,7%/d" histostatincprod.csv
:: ^^ purge de l'historique les donn‚es qu'il contenait d‚j… pour le mois en cours
REM @echo purge
REM pause
sed "s/%nomresultat:~0,7%-[0-3][0-9]/%nomresultat%/" resultats.csv >> histostatincprod.csv
:: ^^ rajoute les derniers r‚sulats … l'historisation en remplaçant les diverses dates par la plus r‚cente
@echo historisation
REM pause

usort -h -o histostatincprod.csv histostatincprod.csv 
:: ^^ trie le fichier par ordre de dates croissantes en conservant l'en-tˆte

rem transposition des donn‚es pour pr‚parer la g‚n‚ration du graphique
gawk -f ..\bin\transpose.awk histostatincprod.csv > graphdata.csv

rem g‚n‚ration du fichier XML pour l'affichage web
gawk  'NR==1{gsub(/ /,"-")}{print}' graphdata.csv |gawk -f csv2xml.awk > ..\StatsIS\quipo\incprodis\fichier.xml
:: n‚cessit‚ de remplacer les espaces par des tirets

rem d‚termination des bornes temporelles
gawk -F; "$1 !~ /[A-z]/ {print $1}" graphdata.csv |usort |head -1 >%temp%\datedeb.tmp
set /p datedeb=<%temp%\datedeb.tmp
gawk -F; "$1 !~ /[A-z]/ {print $1}" graphdata.csv |usort |tail -1 >%temp%\datefin.tmp
set /p datefin=<%temp%\datefin.tmp
REM set date
REM pause
REM @echo on

@echo rem g‚n‚ration des graphiques
:: le SED est obligatoire en cas de pr‚sence de la lettre "–" sinon le texte est encapsul‚ par deux paires de double-quotes au lieu d'une
:: pas propre mais pas trouv‚ moyen de faire autrement
:: attention, ‡a empˆche d'avoir des chaines vides en sortie
REM gawk -f ..\bin\genCumulaire.awk -v BU="ISI" -v titre1="Ventilation des causes d'incidents" -v titre2="de production chez I\\\&S" graphdata.csv |sed "s/\"\"/\"/g" > ISI13mois.plt
rem cette instruction ^^ n'acceptant pas la redirection > terminale en mode script alors que ‡a passe en ligne de commande, on la scinde en deux commandes successives :
gawk -f ..\bin\genCumulaire.awk -v BU="ISI" -v titre1="Ventilation des causes d'incidents" -v titre2="de production chez I\\\&S" graphdata.csv > ISI13mois.plt
sed -i "s/\"\"/\"/g" ISI13mois.plt
REM pause
:: la s‚paration du titre en deux segments permet d'inserrer un saut de ligne entre les deux
:: MAIS SURTOUT
:: permet de g‚rer la pr‚sence … la fois d'une apostrophe dans le premier segment et d'un & dans le second (noter la maniŠre de le prot‚ger … la fois de gawk et de gnuplot)
:: voir les commentaires dans genCumulaire.awk ainsi que dans le script .
%gnuplot%  -c ISI13mois.plt ISI %datedeb% %datefin%  

del *.plt

for %%I in (???13mois.???) do start %%I
copy /y ???13mois.* ..\StatsIS\quipo\incprodis

 goto :fin
 :: traitement des erreurs
 :errfile
 msg /w %username% Le fichier d'extraction GLPI est absent
@echo e fichier d'extraction GLPI est absent
 goto :fin
 :errsize
 msg /w %username% Un des fichiers de donn‚es a une taille nulle
@echo Un des fichiers de donn‚es a une taille nulle
  goto :fin
 
 :fin
 popd
 