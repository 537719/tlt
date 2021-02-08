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
MODIF   11:51 11/01/2021 Refonte totale, utilise la bdd sqlite standard au lieu d'en créer une ad hoc. Rend obsolŠtel le traitement par awk

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
goto :skipobsolete
:: 11:51 11/01/2021 Refonte totale, utilise la bdd sqlite standard au lieu d'en créer une ad hoc. Rend obsolŠtel le traitement par awk

if not exist is_out_%annee%??.csv goto :erreurdata

:: Extraction des données
pushd "%isdir%\Data"

gawk -f ..\bin\VieStock.awk is_out_%annee%??.csv > ..\work\VieStock.csv

if errorlevel 1 goto erreur

:: Aggrégation des totaux par famille et statut
cd ..\work
sqlite3 < ..\bin\VieStock.sqlite

:skipobsolete
pushd "%isdir%\Data"
sqlite3 -separator ; -header sandbox.db "select  Classe,LibClasse,Nb from vvvvv_VieStock WHERE annee='%annee%';" > ..\work\resultats.csv
sqlite3 -separator ; -noheader sandbox.db "select min(datebl) from v_sorties where datebl LIKE '%annee%' || CHAR(37);" > %temp%\datedeb.tmp
sqlite3 -separator ; -noheader sandbox.db "select max(datebl) from v_sorties where datebl like '%annee%' || CHAR(37);" > %temp%\datefin.tmp
:: CHAR(37) = caractŠre "%" qui pose des problŠme si utilis‚ tel quel dans un batch (pas des souci en ligne de commande)
set fichierdonnees=resultats.csv

:: Délimitation des bornes pour la légende
REM head -1 bornes.txt > %temp%\datedeb.tmp
REM tail    -1 bornes.txt > %temp%\datefin.tmp

set /p datedeb=<%temp%\datedeb.tmp
set /p datefin=<%temp%\datefin.tmp

:: génération du graphique
cd ..\work
set titregraphique1=Ventilation par ordre de grandeur du temps que chaque produit aura passe en stock
set titregraphique2=pour les sorties effectuees entre  
%gnuplot% -c ..\bin\histocumul.plt %fichierdonnees% %datedeb% %datefin% "%titregraphique1%" "%titregraphique2%"

ren histo_%datedeb%_%datefin%.png histo.png
move /y histo.png "%isdir%\StatsIS\quipo\VieStock\"
popd

goto :eof
:erreurdata
msg /w %username% fichier(s) is_out_%annee%??.csv absent(s)
:eof
popd

:erreur
msg /w %username% Le fichier %annee% comporte %errorlevel% champs alors qu'on en attendait 22