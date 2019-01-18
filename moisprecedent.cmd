@echo off
goto :debut
10/12/2018  11:27               303 moisprecedent.cmd calcule les dates de début de mois au format mysql
:debut
set mm=%date:~3,2%
set aa=%date:~6,4%

set debmoiscourant=%aa%-%mm%-01
set /a mm=%mm%-1
if %mm%==0 (
set mm=12
set /a aa=%aa%-1
)
set mm=0%mm%
set mm=%mm:~2,2%
set debmoisprecedent=%aa%-%mm%-01