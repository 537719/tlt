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
	udate (date unix recompilé windows et renommé)
#MODIF 15:46 vendredi 1 juillet 2016 : Affiche en fin de traitement le numéro de la semaine en cours (pour inclusion dans le titre du fichier excel de stats)
:debut
dir /s /b /od glpi*.csv |tail -1 >%temp%\file.tmp
set /p fichier=<%temp%\file.tmp
call filtrestat.cmd %fichier%
dir /s /b /od glpi*.txt|tail -1 >%temp%\file.tmp
set /p fichier=<%temp%\file.tmp
gawk -f statscoli.awk %fichier% >statscoli.csv
REM statscoli.csv
goto :eof
set fichier=
del %temp%\file.tmp
@echo Nous sommes dans la semaine
udate +%V
