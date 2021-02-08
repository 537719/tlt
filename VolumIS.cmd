@echo off
goto debut
VolumIS.cmd
CREATION    18:33 15/01/2021 Génère les graphique de suivi de la volumétrie de l'activité I&S
:debut
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
set gnuplot=%userprofile%\bin\gnuplot\bin\gnuplot.exe  

@echo Extraction des données
pushd "%isdir%\Data"

@echo Audit
sqlite3 -header -separator ; sandbox.db "select * from vvv_audit_1sem" > ..\work\audit.csv
@echo Entrées
sqlite3 -header -separator ; sandbox.db "select * from vvv_receptions_1sem" > ..\work\entrees.csv
@echo Dossiers
sqlite3 -header -separator ; sandbox.db "select * from vv_SortiesDossiers_1sem" > ..\work\dossiers.csv
@echo Sorties
sqlite3 -header -separator ; sandbox.db "select * from vv_SortiesProduits_1sem" > ..\work\sorties.csv

@echo génération des graphiques
cd ..\work
for %%I in (dossiers sorties audit entrees) do %gnuplot% -c ..\bin\monocourbe.plt %%I.csv  "%%I"
@echo publication des graphiques
for %%I in (dossiers sorties audit entrees) do move /y %%I.png ..\StatIS\quipo\VolumIS
popd
call ..\bin\quipoput.cmd
