::derniersynthesestock.cmd
@echo off
goto debut
CREATION    13:42 18/05/2020    trouve le nom du dernier fichier de synthèse des stocks connus
MODIF       10:23 27/05/2020    n'en conserve que la date au format aaaammjj

:debut
dir /od /b ..\data\stock\TEexport_%1*.csv |tail -1| sed -n "/csv/ s/[^0-9]//gp" > ..\data\dernier_export.txt
@echo off
