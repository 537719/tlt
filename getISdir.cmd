::getISdir.cmd
::détermine l'arborescence de travail liée à I&S
@echo off
goto :debut
PREREQUIS :
    Outils Linux (fournis avec GIT pour windows)
    grep, head, sort (ici renommé en usort)
: DEBUT 31/01/2018 - 11:42:05,43 version initiale
@echo Recherche du dossier de travail d'I^&S en cours
dir /s /b /ad "\*I&S*" |grep -e "I&S$" |usort|head -1 >%temp%\isdir.tmp
set /p ISdir=<%temp%\isdir.tmp
del %temp%\isdir.tmp
set ISdir