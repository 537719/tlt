@echo off
:: VentileNR.cmd
goto :debut
CREE    11:47 jeudi 26 septembre 2019 aggr‚gation de l'extraction, de l'aggr‚gation et de la repr‚sentation graphique des informations suivantes :
            ventilation selon la qualit‚ de neuf ou de reconditionn‚ des produits d‚stock‚s par I&S stock‚s par famille
            Utilise les modules suivants :
                ventileNR.awk   nombre d'articles de chaque famille sortis en neuf/reconditionn?s ventil‚s par stock
                ventileNR.sqlite aggr‚gation du nombre de produits sortis par famille selon qu'ils soient neufs ou reconditionn‚s
                histocumul.plt    histogramme montrant une barre par ligne de fichier comportant deux valeurs à cumuler.
MODIF   14:39 mercredi 2 octobre 2019 le titre du graphique est d‚sormais pass‚ en paramŠtre
BUG     10:33 lundi 4 novembre 2019 convertit l'encodage du script en OEM:863 afin d'afficher correctement les accents dans le graphique gnuplot
MODIF   15:49 vendredi 17 janvier 2020 prend comme fichier d'entr‚e tous les is_out_aaaamm.csv de l'ann‚e aaaa en cours
MODIF   13:37 06/01/2021 Refonte totale, utilise la bdd sqlite standard au lieu d'en cr‚er une ad hoc. Rend obsolŠtel les scripts awk et sqlite ‚ponymes
MODIF   08:55 07/01/2021 R‚‚criture de la ligne de querysqlite en sp‚cifiant les champs … produire suite au rajout dans la vue utilis‚e du nom de la BU, qui n'est pas utilis‚ ici
MODIF   16:33 08/01/2021 remplace la copie du graphique PNG dans le dossier de publication par un d‚placement depuis le dossier de g‚n‚ration
MODIF   21:21 12/04/2021 archive l'image dans la table de graphiques de la bdd de stats
MODIF   10:51 22/04/2021 le graphique est d‚sormais archib‚ dans la BDD de stat sous le nom du mill‚sime au lieu de juste "histogramme"
BUG     10:53 22/04/2021 un mauvais graphique ‚tait publi‚ et archiv‚ pour cause d'homonymie, corrig‚ en rempla‡ant un "ren" par un "move /y"
:debut
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


set gnuplot=%userprofile%\bin\gnuplot\bin\gnuplot.exe  

                
:: calcul de l'ann‚e en cours
set annee=%date:~6,4%
goto :skipobsolete
:: 13:37 06/01/2021 Refonte totale, utilise la bdd sqlite standard au lieu d'en cr‚er une ad hoc. Rend obsolŠtel le traitement par awk

if not exist is_out_%annee%??.csv goto :erreurdata


:: Extraction des donn‚es
pushd "%isdir%\Data"
gawk -f ..\bin\ventileNR.awk is_out_%annee%??.csv > ..\work\ventileNR.csv

:: Aggr‚gation des totaux par famille et statut
cd ..\work
sqlite3 < ..\bin\ventileNR.sqlite

:skipobsolete
pushd "%isdir%\Data"
sqlite3 -separator ; -header sandbox.db "select  Annee,Produit, Neuf, Recond from v_VentileNR where BU = 'CHR' AND annee='%annee%';" > ..\work\ventilNRan.csv
sqlite3 -separator ; -noheader sandbox.db "select min(datebl) from v_sorties where datebl LIKE '%annee%' || CHAR(37);select max(datebl) from v_sorties where datebl like '%annee%' || CHAR(37);" > ..\work\Bornes.txt
:: CHAR(37) = caractŠre "%" qui pose des problŠme si utilis‚ tel quel dans un batch (pas des souci en ligne de commande)
cd ..\work
set fichierdonnees=ventilNRan.csv

:: D‚limitation des bornes pour la l‚gende
head -1 bornes.txt > %temp%\datedeb.tmp
tail    -1 bornes.txt > %temp%\datefin.tmp

set /p datedeb=<%temp%\datedeb.tmp
set /p datefin=<%temp%\datefin.tmp

:: g‚n‚ration du graphique
set titregraphique1=R‚partition des d‚stockages selon mat‚riel neuf et reconditionn‚
set titregraphique2=entre 
%gnuplot% -c ..\bin\histocumul.plt %fichierdonnees% %datedeb% %datefin% "%titregraphique1%" "%titregraphique2%"

move /y  histo_%datedeb%_%datefin%.png histo.png
copy /y histo.png "%isdir%\StatsIS\quipo\VentilNR\"
sqlite3 "%userprofile%\Documents\ALT\I&S\\StatsIS\quipo\SQLite\quipo.db" "insert or replace into graphiques(code,Image,Designation,Sujet) values('%annee%',readfile('histo.png'),'Ventilation selon la qualit‚ de neuf ou de reconditionn‚ des produits d‚stock‚s par I&S stock‚s par famille','%~n0') ;"
popd

goto :eof
:erreurdata
msg /w %username% fichier(s) is_out_%annee%??.csv absent(s)
@echo  fichier(s) is_out_%annee%??.csv absent(s)
:eof
popd
