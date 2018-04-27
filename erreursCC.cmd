@echo off
goto :debut
erreursCC.cmd
16/04/2018 - 17:47:14

OBJET :
    met en évidence les erreurs de saisie de centre de coût dans les exports de produits expédiés par I&S
    par comparaison entre un fichier d'export et le résultat de la requête sql genSQLccbGLPI.awk

PREREQUIS :
    sqlite (ici dans sa version sqlite3) dans le %path%
    fourniture en premier argument d'un fichier d'export des produits expédiés par I&S
    fourniture en 2nd argument d'un fichier résultant de l'exécution de la requête glpi_centrecout_beneficiaire.sql générée par le script genSQLccbGLPI.awk

MODIF 19/04/2018 - 11:30:24 amélioration du code SQL généré, redirection de la sortie vers un fichier, aperçu et comptage des résultats et/ou erreurs
    
:debut

if @%2@==@@ goto :aide

if @"%isdir%"@==@""@ call ..\bin\getisdir

call "%isdir%\bin\compteNBfields.cmd" %1
set nbchamps=%errorlevel%
if not %nbchamps%==22 goto :un
REM @echo %nbchamps% champs pour %1

call "%isdir%\bin\compteNBfields.cmd" %2
set nbchamps=%errorlevel%
if not %nbchamps%==4 goto :deux
REM @echo %nbchamps% champs pour %2

set fun=%1
set fdeux=%2

set fun=%fun:\=\\%
set fdeux=%fdeux:\=\\%
REM set f
REM pause
REM écriture du script pour invocation dans sqlite3
REM attention, s'il y a des chemins d'accès dans les noms de fichiers, les \ doivent être doublés
@echo -- erreursCC.sql %date%>erreursCC.sql
@echo -- vérifie les erreurs de saisie de centres de coûts dans les exports de produits expédiés par I^&S>>erreursCC.sql
@echo -- prérequis :>>erreursCC.sql
@echo -- - un fichier d'export des produits expédiés par I^&S>>erreursCC.sql
@echo -- - un résultat de la requête glpi_centrecout_beneficiaire.sql effectuée via MySQL sur la base GLPI et donnant les centre de coûts des dossiers>>erreursCC.sql
@echo .separator ;>>erreursCC.sql
@echo DROP TABLE tempEXP;>>erreursCC.sql
@echo DROP TABLE CC;>>erreursCC.sql
@echo .import %fun% tempEXP>>erreursCC.sql
@echo .import %fdeux% CC>>erreursCC.sql
@echo SELECT "Dossier","Valeur_I&S","Valeur_GLPI";>>erreursCC.sql
@echo SELECT tempEXP.GLPI, tempEXP.CentreCout,CC.Centre_De_Cout>>erreursCC.sql
@echo FROM tempEXP,CC>>erreursCC.sql
@echo WHERE tempEXP.GLPI = CC.NoDossier>>erreursCC.sql
@echo AND tempEXP.CentreCout != CC.Centre_De_Cout>>erreursCC.sql
@echo GROUP BY GLPI>>erreursCC.sql
@echo ;>>erreursCC.sql

REM pause
sqlite3 work.db ".read erreursCC.sql"  2>erreursCC.err 1>erreursCC.csv
for %%I in (erreursCC.err) do if NOT %%~zI==0 goto :errsql
head erreursCC.csv
wc -l erreursCC.csv
goto :eof

:errsql
head erreursCC.err
wc -l erreursCC.err
goto :eof

:un
@echo le fichier %1 ne convient pas car il contient %nbchamps% champs. Un fichier d'export des produits expédiés par I^&S était attendu à la place
goto :eof
:deux
@echo le fichier %2 ne convient pas car il contient %nbchamps% champs. Un fichier résultant de la requête glpi_centrecout_beneficiaire.sql était attendu à la place
goto :eof
:aide
@echo fournir en paramètres un fichier d'export des produits expédiés par I^&S et un fichier résultant de la requête glpi_centrecout_beneficiaire.sql
goto :eof

REM usort -u -o export.csv ..\Data\is_out_2018.csv
REM gawk -F; "{print $1 FS $2}" glpi_centrecout_beneficiaire.csv >cc.csv
REM sed -i "s/\"//g" cc.csv
REM usort -u -o cc.csv  cc.csv
