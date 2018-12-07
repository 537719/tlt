@echo off
goto :debut
cataltstock.cmd
CREE    08/11/2018 - 11:43:19 - produit la liste des références connues du catalogue Alturing, nettoyées des notions de neuf/reconditionné et projet/fil de l'eau
MODIF   28/11/2018 - 15:43:47 - utilise un fichier d'entrée dont le nom est de la forme is_catalogue* au lieu de catalogue* afin de coller avec le produti de exportis.awk

PREREQUIS :
    utilitaires GNU dans le path (inclus dans git)
    dont    GAWK (gnu awk)
            SORT (ici renommé en usort)
    SQLITE dans le path (ici dans sa version 3)
    
    Présence dans le dossier ..\Data du catalogue des produits référencés I&S (exporté de l'extranet I&S) sous un nom de la forme catalogue*.csv
    Présence dans le dossier ..\bin du script cataltstock.sql
    
PRODUIT :
    Fichier stockparfamilles.csv

:debut
if not exist ..\data\stock\TEexport_*.csv goto errnostock
dir /b /od ..\data\stock\TEexport_*.csv |tail -1 > %temp%\file.tmp
set /p inputfile=<%temp%\file.tmp
pushd ..\data\stock
gawk -F; "$2 ~ /^TLT[0-9][0-Z][N|R][F|P][0-Z]{3}$/||NR==1 {print $2 FS substr($2,4,2) FS substr($2,8,3) FS $4 FS $9 FS $3}"  %inputfile% > ..\..\work\stockalt.csv
:: ||NR==1 pour produire la ligne d'en-tête
popd

if not exist ..\data\is_catalogue*.csv goto errnocat
dir /b /od ..\data\is_catalogue*.csv |tail -1 > %temp%\file.tmp
set /p inputfile=<%temp%\file.tmp
pushd ..\data
gawk -F;  "$1 ~ /^TLT[0-9][0-Z][N|R][F|P][0-Z]{3}$/ {print substr($1,1,5) dots substr($1,8,3) FS substr($1,4,2) FS substr($1,8,3) FS 0 FS 0 FS $6}" dots=".." %inputfile% |usort -u >>..\work\stockalt.csv
popd

pushd ..\work
sqlite3 <..\bin\cataltstock.sql
gawk -f csvfamille2xml.awk stockALTparfamilles.csv >stockfamille.xml
@uecho -n le résultat est dans  
for %%I in (stockfamille.xml) do @echo  %%~dI%%~pI%%I du %%~tI taille : %%~zI octets
popd

goto :eof
:errnocat
msg /w %username% Pas de fichier catalogue
goto :eof
:errnostock
msg /w %username% Pas de fichier stock
goto :eof
