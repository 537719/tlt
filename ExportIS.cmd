@echo off
goto :debut
ExportIS.cmd
Gilles M‚tais 19/01/2018 - 14:48:52
R‚cupŠre un fichier d'export I&S, le classe et le renomme en fonction des dates et selon qu'il s'agisse d'un fichier des produits exp‚di‚s ou re‡us

CONTEXTE :
Les fichiers d'exports I&S s'appellent toujours export*.csv et sont r‚cup‚r‚s par d‚faut dans le r‚pertoire "T‚l‚hargements" de l'utilisateur
Ce sont des fichiers d‚limit‚s par point-virgule, comportant un nombre de champs bien d‚finis et en particulier un champ "date" … un emplacement connu.

PREREQUIS
AWK (ici dans sa version GNU Gawk 4, issu de la distrib de GIT)
FIND unix (ici renomm‚ ufind afin de ne pas le confondre avec le find windows)

MODIF : 23/02/2018 - 11:00:00 finalisation
:debut
REM @echo on
if "@%isdir%@" NEQ "@@" goto isdirok
if exist ..\bin\getisdir.cmd (
call ..\bin\getisdir.cmd
goto isdirok
)
msg /w %username% Impossible de trouver le dossier I^&S
goto :eof
:isdirok
if not exist %userprofile%\downloads\export*.csv goto :raf

REM Boucle de scan des fichiers d'export
for /F %%I in ('ufind "%userprofile%\downloads" -name "expo*.csv" ^|sed "s/\\//\\\/g"') do (gawk -f "%isdir%\bin\ExportIS.awk" "%%I" &&del "%%I")
REM uFind pr‚f‚rable … un dir /s qui ne permet pas d'avoir … la fois le chemin d'accŠs complet et le filtre sur la date
REM mais il faut quand mˆme en ‚diter la sortie sinon le del ne marche pas
REM (alors que le gawk marche)

goto :eof
:raf
@echo Aucun fichier d'export trouv‚ dans le dossier de t‚l‚chargement
goto :eof
