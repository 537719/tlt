@echo off
goto :debut
ISstatloop.cmd
12/02/2016 09:57
OBJET : Lancement des scripts d'état hebdomadaire des flux et stocks de matériel gérés par I&S

MODIF 16:30 lundi 25 avril 2016 : Exécution 6 fois plus rapide
	remplacement de l'invocation du script "test.awk" pour chaque famille de produit
	par l'invocation des scripts ISsuivientrees.awk   ISsuivisorties.awk   ISsuivistocks.awk pour toutes les familles à la fois

:debut
rem on prend 
rem		le dernier des stock\TEexport_*.csv
rem		le dernier des is_out_*.csv

rem stat des sorties
dir /od /b is_out_*.csv|tail -1 >%temp%\file.tmp
set /p inputfile=<%temp%\file.tmp
REM set outputfile=isflux.txt
set outputfile=isflux.csv
del %outputfile% 2>nul
REM for %%I in (pv gv clpmet pfma clpuc clptp cisco chrrp chruc chrtp serveur m3 ship zpl finger) do gawk -f test.awk -v materiel="%%I" %inputfile% >>%outputfile%
rem ^^ formulation d'avant lundi 25 avril 2016
gawk -f ISsuivisorties.awk %inputfile% >>%outputfile%
start %outputfile%

rem stat des réceptions
dir /od /b is_in_*.csv|tail -1 >%temp%\file.tmp
set /p inputfile=<%temp%\file.tmp
REM set outputfile=isrecep.txt
set outputfile=isrecep.csv
del %outputfile% 2>nul
REM for %%I in (pv gv clpmet pfma clpuc clptp cisco chrrp chruc chrtp serveur m3 ship zpl finger) do gawk -f test.awk -v materiel="%%I" %inputfile% >>%outputfile%
rem ^^ formulation d'avant lundi 25 avril 2016
gawk -f ISsuivientrees.awk %inputfile% >>%outputfile%
start %outputfile%

rem stat des stocks
dir /od /b stock\TEexport_*.csv|tail -1 >%temp%\file.tmp
set /p inputfile=<%temp%\file.tmp
set inputfile=stock\%inputfile%
REM set outputfile=isstock.txt 2>nul
set outputfile=isstock.csv
del %outputfile% 2>nul
REM for %%I in (pv gv clpmet pfma clpuc clptp cisco chrrp chruc chrtp serveur m3 ship zpl finger) do gawk -f test.awk -v materiel="%%I" %inputfile% >>%outputfile%
rem ^^ formulation d'avant lundi 25 avril 2016
gawk -f ISsuivistocks.awk %inputfile% >>%outputfile%
start %outputfile%
