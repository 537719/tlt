@echo off
goto :debut
randomword.cmd
affiche une ligne au hasard sélectionnée dans le fichier donnée en paramètre

Historique :
11/02/2016  18:33 version initiale
10:54 mercredi 3 mai 2017 remplacement de sed (ssed) par awk (gawk) afin de faire que le premier caractère de la sortie soit une majuscule (si c'est une lettre)
:debut
if exist %1 goto :onfait
@echo Le fichier %1 n'existe pas
msg %username% Le fichier %1 n'existe pas
goto :eof
:onfait
wc -l <%1 >%temp%\nblgn.txt
set /p nblgn= <%temp%\nblgn.txt
set /a ligne=%random%*%nblgn%/32767
REM ssed -n "%ligne%p" %1 
gawk "NR==%ligne% {print toupper(substr($0,1,1)) substr($0,2,length($0)-1)}" %1
set nblgn=
set ligne=
del %temp%\nblgn.txt
