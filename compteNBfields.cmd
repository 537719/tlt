@echo off
goto :debut
compteNBfields.cmd
compte le nombre de champs dans le fichier CSV fourni en paramètre

PREREQUIS :
    awk (ici dans sa version gawk (GNU awk) - founi avec git
FONCTIONNEMENT :
    retourne en tant que errorlevel le nombre de champs du fichier csv fourni en paramètre

CREATION 18/04/2018 - 17:18:06 pour invocation depuis le script erreursCC.cmd
:debut

gawk -F; "NR==1 {exit NF}" %1