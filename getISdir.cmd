::getISdir.cmd
::détermine l'arborescence de travail liée à I&S
@echo off
goto :debut
PREREQUIS :
    Outils Linux (fournis avec GIT pour windows)
    grep, head, sort (ici renommé en usort)
: DEBUT 31/01/2018 - 11:42:05,43 version initiale
: MODIF 18/04/2018 - 12:07:11 définit (enfin) AWKPATH par la même occasion
: MODIF 18/01/2019 - 14:55:08 remplacement de grep par sed, plus stable au niveau du traitement des expressions régulières
: BUG     18/01/2019 - 15:06:12 rajoute un traitement d'erreurs en cas d'anomalie
@echo Recherche du dossier de travail d'I^&S en cours
dir /s /b /ad "\*I&S*" |sed -n "/I&S$/p" |usort|head -1 >%temp%\isdir.tmp
for %%I in (%temp%\isdir.tmp) do if %%~zI==0 goto errdir
if not exist %temp%\isdir.tmp goto errdir
set /p ISdir=<%temp%\isdir.tmp
set AWKPATH=.;.\bin;..\bin;%userprofile%\bin;%isdir:&=^&%\bin
REM nécessité de protéger le & de I&S sinon ce caractère est interprété ce qui ne convient pas dans ce contexte
set AWKPATH
del %temp%\isdir.tmp
goto :eof
:errdir
msg /w %username% Dossier de travail non trouvé, dérouler le script à la main
 