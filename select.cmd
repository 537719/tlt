@echo off
goto :debut
select.cmd
CREATION    17:57 10/02/2021
FONCTION    remédier aux cas où une requête SQLite aurait été tapée dans la fenêtre de ligne de commandes plutôt que dans SQLite

:debut
pushd ..\data
dir /od /b *.db |tail -1 > %temp%\database.txt
set /P database=<%temp%\database.txt
shift
REM @echo on
sqlite3 -header -box -cmd ".timer on" -cmd ".progress 28000000 -reset" %database% "select %0 %1 %2 %3 %4 %5 %6 %7 %8 %9"
popd
