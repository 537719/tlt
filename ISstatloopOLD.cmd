rem @echo off
goto :debut
ISstatloop.cmd
12/02/2016 09:57
Lancement en boucle des scripts d'état hebdomadaire d'état des flux et stocs de matériel stockés/déstockés par I&S
:debut
rem on prend 
rem		le dernier des stock\TEexport_*.csv
rem		le dernier des is_out_*.csv

rem stat des sorties
dir /od /b is_out_*.csv|tail -1 >%temp%\file.tmp
set /p inputfile=<%temp%\file.tmp
set outputfile=isflux.txt
del %outputfile% 2>nul
for %%I in (pv gv clpmet pfma clpuc clptp cisco chrrp chruc chrtp serveur m3 ship zpl finger) do gawk -f test.awk -v materiel="%%I" %inputfile% >>%outputfile%
start %outputfile%

rem stat des réceptions
dir /od /b is_in_*.csv|tail -1 >%temp%\file.tmp
set /p inputfile=<%temp%\file.tmp
set outputfile=isrecep.txt
del %outputfile% 2>nul
for %%I in (pv gv clpmet pfma clpuc clptp cisco chrrp chruc chrtp serveur m3 ship zpl finger) do gawk -f test.awk -v materiel="%%I" %inputfile% >>%outputfile%
start %outputfile%

rem stat des stocks
dir /od /b stock\TEexport_*.csv|tail -1 >%temp%\file.tmp
set /p inputfile=<%temp%\file.tmp
set inputfile=stock\%inputfile%
set outputfile=isstock.txt 2>nul
del %outputfile%
for %%I in (pv gv clpmet pfma clpuc clptp cisco chrrp chruc chrtp serveur m3 ship zpl finger) do gawk -f test.awk -v materiel="%%I" %inputfile% >>%outputfile%
start %outputfile%
