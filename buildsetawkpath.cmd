@echo off
goto :debut
CREATION    15/09/2020  16:35               196 buildsetAWKPATH.cmd : v‚rifie l'existence et, le cas ‚ch‚ant, ‚tablit, la variable d'environnement permttant l'ex‚cution des sripts awk plac‚s dans les diff‚rents dossiers /bin/

:debut
if not "@%AWKPATH%@"=="@@" goto :rienafaire
@echo Constitution du AWKPATH en cours ...
dir /s /b %userprofile%\*.awk |grep -i "\\\bin\\\\"  |sed -n "s/\\\bin\\\\.*$/\\\bin/p" |usort -u |tr -d \r |tr \n ";" | sed -e "s/\&/\^\&/" -e "s/\(.*\)/SET AWKPATH=\1/" > %temp%\setAWKPATH.cmd
call %temp%\setAWKPATH.cmd
goto :fin
:rienafaire
@echo AWKPATH ‚tait d‚j… d‚fini … "%AWKPATH%"
goto :eof
:fin
@echo AWKPATH vient d'ˆtre d‚fini … "%AWKPATH%"

