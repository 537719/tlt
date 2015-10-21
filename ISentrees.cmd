@echo off
set isfile=
goto :debut
ISentrees.cmd
Auteur : G. Métais 15:28 05/06/2015
corrige les sauts de lignes indésirables au milieu des lignes d'export csv des réceptions de matériel dans l'extranet I&S
une ligne en erreur se manifeste de la manière suivante :
  une ligne avec un 7° champ vide suivie par une ligne dont le premier champ est vide
  doivent être concaténées en une seule ligne.

Prérequis : présence dans le path ou le répertoire courant des utilitaires gnuwin32 suivants :
    grep
:debut
if not @%1@==@@ set isfile=%1
if @%isfile%@==@@ goto :noparam
for %%I in (%isfile%) do set outfile="%%~dI%%~pIok_%%~nI%%~xI"
msg /w %username% "travail sur le fichier %isfile% commence"
gawk -F; -v OFS=";" -v vide="" "{if (garde==vide) {if ($8==vide) {garde=$1 OFS $2 OFS $3 OFS $4 OFS $5 OFS $6} else print} else {print garde OFS $2 OFS $3;garde=vide}}" %isfile% >%outfile%
msg /w %username% "travail sur le fichier %outfile% fini"
%outfile%
set isfile=
goto :eof
:noparam
msg /W %username% "Faire un drag'n drop du CSV des receptions I&S vers l'icone de ce script"
