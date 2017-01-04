@echo off
goto :debut
pbfootprints.cmd
15:52 jeudi 17 mars 2016
parcourt l'arborescence en dessous du répertoire courant afin d'appliquer à tous les fichiers trouvés un même script de détection des incidents footprints
:debut
del %temp%\result.txt 2>nul
for /F "delims=*" %%I in ('dir glpi.txt /s /b /x') do (@echo %%I >>%temp%\result.txt&& gawk -f %~n0.awk %%I >>%temp%\result.txt)
REM for /F "delims=*" %%I in ('dir glpi.txt /s /b /x') do (@echo %%I)
rem ^^ pour un résultat fichier par fichier
goto :eof
rem variante:
del %temp%\tout.txt
for /F "delims=*" %%I in ('dir glpi.txt /s /b /x') do cat %%I >>%temp%\tout.txt
gawk -f script.awk %temp%\result.txt
rem ^^ pour un résultat cumulé sur l'ensemble des fichiers
goto :eof
avec script.awk qui cherche
parmi les lignes de type incident
dont l'historique indique qu'elles sont passées par planif_met
que la ligne contient soit "footprints" soit "prise en main" (ou les deux), case insensitive
