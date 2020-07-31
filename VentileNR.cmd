:: VentileNR.cmd
goto :debut
CREE    11:47 jeudi 26 septembre 2019 aggr‚gation de l'extraction, de l'aggr‚gation et de la repr‚sentation graphique des informations suivantes :
            ventilation selon la qualit‚ de neuf ou de reconditionn‚ des produits d‚stock‚s par I&S stock‚s par famille
            Utilise les modules suivants :
                ventileNR.awk   nombre d'articles de chaque famille sortis en neuf/reconditionn?s ventil‚s par stock
                ventileNR.sqlite aggr‚gation du nombre de produits sortis par famille selon qu'ils soient neufs ou reconditionn‚s
                histocumul.plt    histogramme montrant une barre par ligne de fichier comportant deux valeurs à cumuler.
MODIF   14:39 mercredi 2 octobre 2019 le titre du graphique est d‚sormais pass‚ en paramŠtre
BUG      10:33 lundi 4 novembre 2019 convertit l'encodage du script en OEM:863 afin d'afficher correctement les accents dans le graphique gnuplot
MODIF   15:49 vendredi 17 janvier 2020 prend comme fichier d'entr‚e tous les is_out_aaaamm.csv de l'ann‚e aaaa en cours
                
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

if not exist is_out_%annee%??.csv goto :erreurdata


:: Extraction des donn‚es
pushd "%isdir%\Data"
gawk -f ..\bin\ventileNR.awk is_out_%annee%??.csv > ..\work\ventileNR.csv

:: Aggr‚gation des totaux par famille et statut
cd ..\work
sqlite3 < ..\bin\ventileNR.sqlite
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

copy /y histo_%datedeb%_%datefin%.png "%isdir%\StatsIS\quipo\VentilNR\histo.png"
popd

goto :eof
:erreurdata
msg /w %username% fichier(s) is_out_%annee%??.csv absent(s)
@echo  fichier(s) is_out_%annee%??.csv absent(s)
:eof
popd
