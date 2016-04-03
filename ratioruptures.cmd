::ratioruptures.cmd
::11/03/2016 11:34:25,14
::affiche pour chaque entité le taux de dossiers ayant connus une rupture depuis le début du mois
::suppose que l'on vienne de demander à GLPI d'exporter au format csv la stat de calcul d'autonomie
::
::MODIF 11:42 mardi 15 mars 2016 : n'applique plus de filtre de tri en sortie, le tri est désormais effectué au niveau du script awk.
::MODIF 03/04/2016 16:30:44,69 remplace le goto debut initial par une mise en commentaire :: de tout le header
@echo off
::goto :debut
:debut
dir /s /b /od glpi*.csv |tail -1 >%temp%\file.tmp
set /p fichier=<%temp%\file.tmp
call filtrestat.cmd %fichier%
dir /s /b /od glpi*.txt|tail -1 >%temp%\file.tmp
set /p fichier=<%temp%\file.tmp
REM gawk -f ratioruptures.awk %fichier% |sort /R
gawk -f ratioruptures.awk %fichier% |sort /R
REM goto :eof
set fichier=
del %temp%\file.tmp
