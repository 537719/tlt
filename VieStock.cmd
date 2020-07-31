::VieStock.cmd
goto :debut
CREE    15:21 vendredi 17 janvier 2020 d'après 04/11/2019  10:35             2229 VentileNR.cmd
            aggrégation de l'extraction, de l'aggrégation et de la repréentation graphique des informations suivantes :
            Ventilation de produits expédiés par classe d'ordre de grandeur de durée avant déstockage, sur une période déterminée
            Utilise les modules suivants :
                VieStock.awk   calcul du temps que chaque produit déstocké par I&S aura passé en stock
                VieStock.sqlite Ventilation par ordre de grandeur de la durée de stockage des sorties effectuées par I&S
                histocumul.plt    histogramme montrant une barre par ligne de fichier comportant deux valeurs à cumuler. (on n'en utilise qu'une ici)
            Données en entrée : 
                tous les fichiers is_out_aaaamm de l'année aaaa en cours
                
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

:: calcul de l'année en cours
set annee=%date:~6,4%

if not exist is_out_%annee%??.csv goto :erreurdata

:: Extraction des données
pushd "%isdir%\Data"
gawk -f ..\bin\VieStock.awk is_out_%annee%??.csv > ..\work\VieStock.csv

if errorlevel 1 goto erreur

:: Aggrégation des totaux par famille et statut
cd ..\work
sqlite3 < ..\bin\VieStock.sqlite
set fichierdonnees=resultats.csv

:: Délimitation des bornes pour la légende
head -1 bornes.txt > %temp%\datedeb.tmp
tail    -1 bornes.txt > %temp%\datefin.tmp

set /p datedeb=<%temp%\datedeb.tmp
set /p datefin=<%temp%\datefin.tmp

:: génération du graphique
set titregraphique1=Ventilation par ordre de grandeur du temps que chaque produit aura passe en stock
set titregraphique2=pour les sorties effectuees entre  
%gnuplot% -c ..\bin\histocumul.plt %fichierdonnees% %datedeb% %datefin% "%titregraphique1%" "%titregraphique2%"

copy /y histo_%datedeb%_%datefin%.png "%isdir%\StatsIS\quipo\VieStock\histo.png"
popd

goto :eof
:erreurdata
msg /w %username% fichier(s) is_out_%annee%??.csv absent(s)
:eof
popd

:erreur
msg /w %username% Le fichier %annee% comporte %errorlevel% champs alors qu'on en attendait 22