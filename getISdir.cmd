::getISdir.cmd
::détermine l'arborescence de travail liée à I&S
@echo off
goto :debut
PREREQUIS :
    Outils Linux (fournis avec GIT pour windows)
    grep, head, sort (ici renommé en usort)
: DEBUT 31/01/2018 - 11:42:05,43 version initiale
: MODIF 18/04/2018 - 12:07:11 définit (enfin) AWKPATH par la même occasion
@echo Recherche du dossier de travail d'I^&S en cours
dir /s /b /ad "\*I&S*" |grep -e "I&S$" |usort|head -1 >%temp%\isdir.tmp
set /p ISdir=<%temp%\isdir.tmp
set AWKPATH=.;.\bin;..\bin;%isdir:&=^&%\bin
REM nécessité de protéger le & de I&S sinon ce caractère est interprété ce qui ne convient pas dans ce contexte
del %temp%\isdir.tmp
