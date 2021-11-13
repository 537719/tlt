@echo off
goto :debut
CREATION    31/03/2021  15:18   enchaŒne l'ex‚cution de tous les scripts longs … s'ex‚cuter de maniŠre … en grouper le lancement dans une seule session a ex‚cution planifi‚e
MODIF       21:50 09/04/2021    Ajout du suivi de retour des swaps et des stats bas‚es sur l'export du calcul d'autonomie glpi

:debut
REM @echo off
:: d‚termination du dossier de travail
if "@%isdir%@" NEQ "@@" goto isdirok
if exist ..\bin\getisdir.cmd (
call ..\bin\getisdir.cmd
goto isdirok
) else if exist .\bin\getisdir.cmd (
call ..\bin\getisdir.cmd
goto isdirok
)

msg /w %username% Impossible de trouver le dossier I^&S
goto :fin
:isdirok
REM call SwapsNonRevenus.cmd
timethis SortiesHPdom.cmd
timethis StockCLP34.cmd
timethis AutonomieStock.cmd
timethis EtatStock.cmd
timethis EnAttente.cmd  
timethis StatStock.cmd
timethis CoutStock.cmd
timethis VolumIS.cmd
pushd ..\..\Stats
timethis escalis.cmd
timethis statsspx.cmd
popd
timethis quipoput.cmd

 :fin
REM pause