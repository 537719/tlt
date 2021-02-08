@echo off
goto :debut
tables.cmd
CREATION    10:19 09/01/2021    Liste les tables de la bdd donnée en argument et applique éventuellement un filtre sur le nom
:debut
pushd ..\data
dir *.db /od /b |tail -1 > %temp%\bddname.txt
set /p bddname=<%temp%\bddname.txt
if @%1@ == @@ goto noargs
sqlite3 %bddname% ".tables" |gawk "{print $1;print $2}" |usort |grep -i "%1"
goto :fin
:noargs
sqlite3 %bddname% ".tables" |gawk "{print $1;print $2}" |usort
:fin
popd
