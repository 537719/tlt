@echo off
goto :debut
statscoli.cmd
15:53 lundi 14 mars 2016
d'après ratioruptures.cmd 11/03/2016 11:34:25,14

Produit les données permettant d'alimenter le rapport statistique mensuel pour Colissimo
suppose que l'on vienne de demander à GLPI d'exporter au format csv la stat de calcul d'autonomie

PREREQUIS :
	awk (ici dans sa version gnuwin32 : gawk) # obsolète au 04/05/2018 - 10:16:25
	script statscoli.awk # obsolète au 04/05/2018 - 10:16:25
    SQLite (ici dans sa version sqlite3)
    script StatsColi.sql
	le plus récent des fichier glpi.csv situés dans l'arborescence en dessous du répertoire courant
	udate (date unix recompilé windows et renommé)
#MODIF 15:46 vendredi 1 juillet 2016 : Affiche en fin de traitement le numéro de la semaine en cours (pour inclusion dans le titre du fichier excel de stats)
#MODIF 04/05/2018 - 10:16:25 - remplacement l'utilisation de GAWK par celle de SQLITE suite à modification des valeurs dans les données aboutissant à des stats erronnées (disparition de la mention EXPEDITOR)
:debut 
dir /s /b /od glpi*.csv |tail -1 >%temp%\file.tmp
set /p fichier=<%temp%\file.tmp
goto :skipbosolete section obsolète suite à remplacement de gawk par sqlite
call filtrestat.cmd %fichier%
dir /s /b /od glpi*.txt|tail -1 >%temp%\file.tmp
set /p fichier=<%temp%\file.tmp
gawk -f statscoli.awk %fichier% >statscoli.csv
goto :fin
:skipbosolete
set fichier=%fichier:\=\/%
sed -i "s/import.*/import %fichier% STATSCOLI/" StatsColi.sql
sqlite3 <statscoli.sql
dir *.csv /od
@echo Actualiser ensuite les données dans le tableau de stats mensuel
:fin
REM statscoli.csv
@echo Nous sommes dans la semaine
udate +%%V
goto :eof
set fichier=
del %temp%\file.tmp
ena 