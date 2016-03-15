@echo off
goto :debut
statscoli.cmd
15:53 lundi 14 mars 2016
d'après ratioruptures.cmd 11/03/2016 11:34:25,14

Produit les données permettant d'alimenter le rapport statistique mensuel pour Colissimo
suppose que l'on vienne de demander à GLPI d'exporter au format csv la stat de calcul d'autonomie

PREREQUIS :
	awk (ici dans sa version gnuwin32 : gawk)
	script statscoli.awk
	le plus récent des fichier glpi.csv situés dans l'arborescence en dessous du répertoire courant
:debut
dir /s /b /od glpi*.csv |tail -1 >%temp%\file.tmp
set /p fichier=<%temp%\file.tmp
call filtrestat.cmd %fichier%
dir /s /b /od glpi*.txt|tail -1 >%temp%\file.tmp
set /p fichier=<%temp%\file.tmp
gawk -f ratioruptures.awk %fichier% |sort /R
goto :eof
set fichier=
del %temp%\file.tmp
