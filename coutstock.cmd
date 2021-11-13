@echo off
goto :debut
coutstock.cmd
CREATION    22:43 02/02/2021 Extraction, par mois, par famille de produit et pour chaque BU, des co�ts de stockage hebdomadaires 
PREREQUIS   bdd sandbox.sql � jour + requetes ad hoc
MODIF       18:05 03/02/2021 remplace la requete v4_Stat_CoutStock_13mois par v4_Stat_CoutStock_57semaines afin d'avoir un meilleur lissage des donn�es
MODIF       18:41 08/02/2021 rajoute un indicateur de progression sur la requ�te SQLite    
MODIF       13:28 23/03/2021 rajout de la v�rification du isdir afin d'�tre autonome
MODIF       10:41 26/03/2021 n�cessite que gnuplot soit pr�sent dans le path (donc install� "normalement" plut�t que juste copi�) au lieu d'en d�finir le chemin dans une variable 
BUG         18:28 26/03/2021 Suppression du "progress" dans l'extraction sqlite car il s'affichait dans le csv sorti et non sur la console
MODIF       15:26 12/04/2021 archive des graphiques dans la table de graphiques de la bdd de stats
MODIF       12:06 16/04/2021 s'assure de ne pas copier des graphiques vides (on garde alors l'ancienne version)
MODIF       10:56 22/04/2021 archive �galement le commentaire du graphique dans la bdd de stats

:debut
REM @echo on
@echo Extraction, par mois, par famille de produit et pour chaque BU, des co�ts de stockage hebdomadaires 
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
REM @echo on
pushd ..\data
REM goto :boucle
@echo Extraction des co�ts de stockage par famille de produit
sqlite3 -header -separator ; sandbox.db "select * from v4_Stat_CoutStock_57semaines ORDER BY DateStock ASC ;" > ..\work\CoutStock13mois.csv
:: Requ�te tr�s longue � ex�cuter donc on sort pour toutes les BU en une seule fois et on filtre ensuite

:boucle
@echo boucle de g�n�ration graphique
cd ..\work

for %%I in (CHR CLP TLT) do (
sed -n -e 1p -e "s/;%%I//p" CoutStock13mois.csv > %%I13mois.csv
:: ^^ �vite de faire autant d'appels � la requ�te SQLite qu'il y a de BU car elle est d'ex�cution longue
gawk -f genempilaire.awk %%I13mois.csv > %%I13mois.plt
gnuplot -c %%I13mois.plt

:: s'assure de ne pas copier des graphiques vides (on garde alors l'ancienne version)
for %%J in (%%I13mois.png) do if %%~zJ GTR 0 (

copy /y %%I13mois.png ..\StatsIS\quipo\CoutStock
sqlite3 ..\StatsIS\quipo\SQLite\quipo.db "insert or replace into graphiques(code,Image,Sujet) values('%%I13mois',readfile('%%I13mois.png'),'%~n0') ;"
)

REM dir %%I13mois.*
)
:fin
popd

REM pause