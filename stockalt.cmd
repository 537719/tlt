@echo off
goto :debut
stockalt.cmd
05/07/2018 - 10:16:29 extrait la partie concernant uniquement Alturing … partir d'un fichier CSV d'‚tat des stocks I&S

PREREQUIS : (inclus dans la distribution de git)
            gawk
            uecho (echo.exe renommé)
            grep
:debut
if "%1"=="" goto :noargs
if not exist "%1" goto :fnf
set filename="%~dp1ALT_%~n1%~x1"
gawk -F; "NR==1 || $1 ~ /TELINTRANS/ {print $2 FS $3 FS $4}" "%1" >"%~dp1ALT_%~n1%~x1"
uecho -n "le resultat est dans : "
dir /-c "%~dp1ALT_%~n1%~x1" |grep -e "ALT.%~n1"
goto :eof
:noargs
@echo fournir en argument le nom du fichier d'‚tat de stock … traiter
goto :eof
:fnf
@echo le fichier %1 n'a pas ‚t‚ trouv‚
goto :eof
