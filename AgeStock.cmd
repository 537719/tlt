::"C:\Users\004796\Documents\TLT\I&S\StatsIS\quipo\VieStock\histo.png".cmd
goto :debut
CREE    16:20 vendredi 17 janvier 2020 d'après 17/01/2020  16:18              2315 VieStock.cmd
            aggrégation de l'extraction, de l'aggrégation et de la repréentation graphique des informations suivantes :
            Ventilation des produits présents en stock par ordre de grandeur d'ancienneté
            Utilise les modules suivants :
                AgeStock.awk   calcul du temps que chaque produit déstocké par I&S aura passé en stock
                VieStock.sqlite Ventilation par ordre de grandeur de la durée de stockage des sorties effectuées par I&S (le mêmes script s'applique ici sans modification)
                histocumul.plt    histogramme montrant une barre par ligne de fichier comportant deux valeurs à cumuler. (on n'en utilise qu'une ici)
            Données en entrée : Le fichier is_stock_*.csv portant sur la période la plus récente
                
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

if not exist %1 goto erreurdata

set gnuplot=%userprofile%\bin\gnuplot\bin\gnuplot.exe  

REM :: calcul de l'année en cours
REM set annee=%date:~6,4%

:: Extraction des données
pushd "%isdir%\Data"
REM gawk -f ..\bin\VieStock.awk is_out_%annee%??.csv > ..\work\VieStock.csv
for /F "usebackq" %%I in (`"dir is_stock*.csv /o /b |tail -1"`) do gawk -f ..\bin\AgeStock.awk %%I > ..\work\VieStock.csv

set datedeb=
set datefin=
del %temp%\datedeb.tmp
del %temp%\datefin.tmp

:: Délimitation des bornes pour la légende
dir is_stock*.csv /o /b |tail -1 |sed "s/is_stock_\([0-9][0-9][0-9][0-9]\)\([0-9][0-9]\)\([0-9][0-9]\).*/\3-\2-\1/" > %temp%\datefin.tmp
dir is_stock*.csv /o /b |tail -1 |sed "s/.*\([0-9][0-9][0-9][0-9]\)\([0-9][0-9]\)\([0-9][0-9]\).*/\3-\2-\1/" > %temp%\datedeb.tmp
REM head -1 bornes.txt > %temp%\datedeb.tmp
REM tail    -1 bornes.txt > %temp%\datefin.tmp

set /p datedeb=<%temp%\datedeb.tmp
set /p datefin=<%temp%\datefin.tmp

::
:: Aggrégation des totaux par famille et statut
cd ..\work
sqlite3 < ..\bin\VieStock.sqlite
set fichierdonnees=resultats.csv

 génération du graphique
set titregraphique1=Ventilation par ordre de grandeur du temps de presence
set titregraphique2=pour les produits entrees en stock entre 
%gnuplot% -c ..\bin\histocumul.plt %fichierdonnees%  %datedeb% %datefin% "%titregraphique1%" "%titregraphique2%"

copy /y histo_%datedeb%_%datefin%.png "%isdir%\StatsIS\quipo\AgeStock\histo.png"
popd

goto :eof
:erreurdata
msg /w %username% fichier(s) %1 absent(s)
:eof
popd
