@echo off
goto :debut
cataltstock.cmd
d'après cataltref.cmd 08/11/2018 - 11:43:19 produit la liste des références connues du catalogue Alturing, nettoyées des notions de neuf/reconditionné et projet/fil de l'eau
09/11/2018 - 11:24:14 produit les quantités en stock et attendues de tous les articles en stock ayant une référence alturing

PREREQUIS :
    utilitaires GNU dans le path (inclus dans git)
    dont    GAWK (gnu awk)
            SORT (ici renommé en usort)
    
    Présence dans le dossier ..\Data\stock d'états de stock ayant un nom de la forme TEexport_aaaammjj.csv

:debut
if not exist ..\data\stock\TEexport_*.csv goto errnofich
dir /b /od ..\data\stock\TEexport_*.csv |tail -1 > %temp%\file.tmp
set /p inputfile=<%temp%\file.tmp
pushd ..\data\stock
gawk -F; "$2 ~ /^TLT[0-9][0-Z][N|R][F|P][0-Z]{3}$/||NR==1 {print $2 FS substr($2,4,2) FS substr($2,8,3) FS $4 FS $9 FS $3}"  %inputfile% > ..\..\work\stockalt.csv
:: ||NR==1 pour produire la ligne d'en-tête
:: usort -n pour préserver l'en-tête lors du tri
:: usort -r pour avoir en tout dernier la ligne ne concernant pas le matériel reconditionné
popd
goto :eof
:errnofich
msg /w %username% Pas de fichier stock
goto :eof
