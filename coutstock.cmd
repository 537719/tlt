:: coutstock.cmd
goto :debut
script de pilotage de la requˆte coutstock.sql visant … calculer,par famille de produit et par BU, les co–ts de stockage hebdomadaires et cumul‚s depuis l'entr‚e des produits en stock I&S d'aprŠs un fichier d'export de stock I&S
CREATION 16:02 mercredi 29 janvier 2020
PREREQUIS   requˆte coutstock.sql en ..\bin
                    extraction des stocks  et du catalogue I&S en ..\data
                    pr‚sence du tarif en ..\data
                    bdd IetS.db en ..\data au format SQLite
                    accŠs … SQLite
                    accŠs aux utilitaires GNU
                    Ce script doit ˆtre encod‚ en OEM863 (French) pour que les accents soient rendus correctement dans le graphique en sortie
BUG             La n‚cessit‚ de prot‚ger les accents circonflexes a mis en ‚vidence un bug dans gawk qui encapsule en sortie de telles chaines par deux paires de double-quotes au lieu d'une et impose de les filtrer par SED ensuite (pas trouv‚ comment le faire dans le script gawk)
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

REM actualisation des donn‚es brutes
call "%isdir%\bin\exportIS.cmd"


REM positionnement dans le dossier de donn‚es
pushd ..\data

REM d‚termination des fichier d'extraction de stock et de catalogue les plus r‚cents
dir is_stock_????????-????????.csv /o /b |tail -1 >%temp%\workfile.txt
set /p workfile=<%temp%\workfile.txt
copy /y %workfile% is_stock.csv
REM la requˆte SQLite s'attend … trouver uniquement un fichier is_stock.csv en entr‚e

dir is_catalogue_????????.csv /o /b |tail -1 >%temp%\workfile.txt
set /p workfile=<%temp%\workfile.txt
copy /y %workfile% is_catalogue.csv
REM la requˆte SQLite s'attend … trouver uniquement un fichier is_stock.csv en entr‚e
 REM @echo on
if not exist is_stock.csv goto :errstock
if not exist is_catalogue.csv goto :errcatalogue
if not exist tarif.csv goto :errtarif
 for %%I in (is_stock is_catalogue tarif)  do if %%~zI == 0 goto errsize
 
 :: lance la requˆte SQLite en s'attendant … ce qu'elle porte le mˆme nom que le pr‚sent script mais avec une extension diff‚rente
 
 for %%I in (%0) do sqlite3 <..\bin\%%~nI.sql
 
 :: finalisation des donn‚es
 set /p nomresultat=<nomresultat.txt

 :: histocoutstock.csv est la concat‚nation de l'historique des co–ts de stockage
sed -i "/%nomresultat:~0,7%/d" histocoutstock.csv
:: ^^ purge de l'historique les donn‚es qu'il contenait d‚j… pour le mois en cours
REM pause
 grep %nomresultat% resultats.csv >> histocoutstock.csv
:: ^^ rajoute les derniers r‚sulats … l'historisation

rem transposition des donn‚es pour pr‚parer la g‚n‚ration du graphique
gawk -f ..\bin\transpose.awk histocoutstock.csv > graphdata.csv

rem d‚termination des bornes temporelles
gawk -F; "$1 !~ /[A-z]/ {print $1}" graphdata.csv |usort |head -1 >%temp%\datedeb.tmp
set /p datedeb=<%temp%\datedeb.tmp
gawk -F; "$1 !~ /[A-z]/ {print $1}" graphdata.csv |usort |tail -1 >%temp%\datefin.tmp
set /p datefin=<%temp%\datefin.tmp
REM set date
REM pause
REM @echo on

rem g‚n‚ration des graphiques
:: le SED est obligatoire en cas de pr‚sence de la lettre "–" sinon le texte est encapsul‚ par deux paires de double-quotes au lieu d'une
:: pas propre mais pas trouv‚ moyen de faire autrement
:: attention, ‡a empˆche d'avoir des chaines vides en sortie
for %%I in (CHR COL TEL) do (
gawk -f ..\bin\genCumulaire.awk -v BU="%%I" -v titre1="Ventilation des co–ts de stockage" -v titre2="hebdomadaires par type de produit pour %%I" graphdata.csv |sed "s/\"\"/\""/g" > %%I13mois.plt
:: la s‚paration du titre en deux segments permet d'inserrer un saut de ligne entre les deux
:: MAIS SURTOUT
:: permet de g‚rer la pr‚sence … la fois d'une apostrophe dans le premier segment et d'un & dans le second (noter la maniŠre de le prot‚ger … la fois de gawk et de gnuplot)
:: voir les commentaires dans genCumulaire.awk ainsi que dans le script .
%gnuplot%  -c %%I13mois.plt %%I %datedeb% %datefin% 
)

move /y ???13mois.png ..\StatsIS\Quipo\CoutStock
for %%I in (..\StatsIS\Quipo\CoutStock\???13mois.png) do %%I

 goto :fin
 :: traitement des erreurs
 :errstock
 msg /w %username% Le fichier des stocks est absent
@echo Le fichier des stocks est absent
 goto :fin
 :errcatalogue
 msg /w %username% Le fichier catalogue est absent
@echo  Le fichier catalogue est absent
 goto :fin
 :errtarif
 msg /w %username% Le fichier des tarifs est absent
@echo Le fichier des tarifs est absent
 goto :fin
 :errsize
 msg /w %username% Un des fichiers de donn‚es a une taille nulle
@echo Un des fichiers de donn‚es a une taille nulle
  goto :fin
 
 :fin
 popd
 