@echo off
goto :debut
cataltstock.cmd
CREE    08/11/2018 - 11:43:19 - produit la liste des r‚f‚rences connues du catalogue Alturing, nettoy‚es des notions de neuf/reconditionn‚ et projet/fil de l'eau
MODIF   28/11/2018 - 15:43:47 - utilise un fichier d'entr‚e dont le nom est de la forme is_catalogue* au lieu de catalogue* afin de coller avec le produti de exportis.awk
MODIF       16:48 05/04/2021    met de c“t‚ le csv afin de l'exploiter ult‚rieurement
BUG         09:17 07/04/2021    convertit le csv au format utf8 (pas d'int‚raction avec le xml qui doit rester en Latin 1)

PREREQUIS :
    utilitaires GNU dans le path (inclus dans git)
    dont    GAWK (gnu awk)
            SORT (ici renomm‚ en usort)
    SQLITE dans le path (ici dans sa version 3)
    
    Pr‚sence dans le dossier ..\Data du catalogue des produits r‚f‚renc‚s I&S (export‚ de l'extranet I&S) sous un nom de la forme catalogue*.csv
    Pr‚sence dans le dossier ..\bin du script cataltstock.sql
    
PRODUIT :
    Fichier stockparfamilles.csv

:debut
if not exist ..\data\stock\TEexport_*.csv goto errnostock
dir /b /od ..\data\stock\TEexport_*.csv |tail -1 > %temp%\file.tmp
set /p inputfile=<%temp%\file.tmp
pushd ..\data\stock
gawk -F; "$2 ~ /^TLT[0-9][0-Z][N|R][F|P][0-Z]{3}$/||NR==1 {print $2 FS substr($2,4,2) FS substr($2,8,3) FS $4 FS $9 FS $3}"  %inputfile% > ..\..\work\stockalt.csv
:: ||NR==1 pour produire la ligne d'en-tÃªte
popd

if not exist ..\data\is_catalogue*.csv goto errnocat
dir /b /od ..\data\is_catalogue*.csv |tail -1 > %temp%\file.tmp
set /p inputfile=<%temp%\file.tmp
pushd ..\data
gawk -F;  "$1 ~ /^TLT[0-9][0-Z][N|R][F|P][0-Z]{3}$/ {print substr($1,1,5) dots substr($1,8,3) FS substr($1,4,2) FS substr($1,8,3) FS 0 FS 0 FS $6}" dots=".." %inputfile% |usort -u >>..\work\stockalt.csv
popd

pushd ..\work
sqlite3 <..\bin\cataltstock.sql
cat ..\work\stockALTparfamilles.csv |iconv -f L1 -t UTF-8 > ..\StatsIS\quipo\SQLite\stockALTparfamilles.csv
:: n‚cessit‚ de convertir le codepage au passage

gawk -f csvfamille2xml.awk stockALTparfamilles.csv >stockfamille.xml
@uecho -n le r‚sultat est dans  
for %%I in (stockfamille.xml) do @echo  %%~dI%%~pI%%I du %%~tI taille : %%~zI octets
popd

goto :eof
:errnocat
msg /w %username% Pas de fichier catalogue
goto :eof
:errnostock
msg /w %username% Pas de fichier stock
goto :eof
