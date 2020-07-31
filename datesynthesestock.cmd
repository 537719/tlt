@echo off
goto :debut
datesynthesestock.cmd
PREREQUIS   tr pour convertir en tabulations les fins de ligne présents dans une liste de "dir"
            script gawk derniersynthesestock.awk
            dossier de données en ..\data
            données de synthèse de stock en ..\data\stockb
CREATION    10:36 20/05/2020 rajoute à un lot de fichiers quotidiens de synthèse des stocks la date concernée en dernière colonne en partant du principe que la date en question fait partie du nom de chacun des fichier
:debut
@echo on
for /F "delims=*" %%I in ('dir /s /b /o-d  Stock\TEexport_%1*.csv ^|tr -d \r ^|tr \n \t') do gawk -f ..\bin\datesynthesestock.awk %%I > ..\data\TEexport_date.csv
:: principe : prend tous les fichiers répondant au critère de date fourni en argument et les fournit comme liste de fichies à traiter au script awk qui les concatène en un seul fichier en ajoutant la date comme nouveau champ
:: l'astérique dans le delim a pour but de faire considérer la liste entière comme étant un seul argument %I
@echo off
