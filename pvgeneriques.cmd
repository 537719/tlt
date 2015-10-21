REM @echo off
goto :debut
pvgeneriques.cmd

produit la liste, pour tous les jours pour lesuqels on a des données, du nombre d'imprimantes expeditor en retour chez I&S mais non remises en stock
physiquement re‡ues d'une part, en attente d'autre part
se base sur l'export quotidien des stocks envoy‚s par I&S
ne fonctionne qu'… partir des donn‚es du 06/03/2015 sur des fichiers dont le nom est de la forme "TEexport_20150303.csv"

prerequis :
utilitaire GAWK (portage GNUWIN32 du GAWK unix)
script 1pvgenerique.cmd

usage : pvgenerique fichier_de_sortie
le fichier en question sera produit dans le répertoire courant
Si aucun nom n'est spécifié le nom pvgenerique.csv sera utilisé



16:56 17/04/2015 version initiale
:debut
set outfile=%1
if "%outfile%"=="" set outfile=pvgenerique.csv
if not exist %outfile% goto creefile
del erreur.txt
del %outfile% 2>erreur.txt
for %%I in (erreur.txt) do if %%~zI GTR 0  msg %username% "Verifier que le fichier %outfiile% n'est pas deja ouvert dans une autre application"	
:creefile
@echo date;reçues;à livrer;cumul >%outfile%

REM for %%I in (TEexport_????????.csv) do (@echo %%I&&call 1pvgenerique.cmd %%I >>%outfile%)
for %%I in (TEexport_????????.csv) do (@echo %%I&&call 1pvgenerique.cmd %%I >>%outfile%)
@echo nombre de lignes :
wc -l %outfile%
@echo le fichier %outfile% va maintenant être ouvert 
pause
%outfile%
set nblignes=
set outfile=
