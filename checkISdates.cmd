:: checkISdates.cmd
:: 10:34 mardi 6 septembre 2016
:: vérifie que les extractions I&S utilisées pour les stats ont un horodatage compatible
@echo off
set dateerreur=
REM Date du fichier des sorties
for /F "delims=*" %%I in ('dir /od /tc /b is_out_??????.csv /od ^| tail -1') do @echo %%~tI |gawk "{print $1}"|gawk -F/ "{print $3 $2 $1}" >%temp%\filedate.tmp
set /p dateout=<%temp%\filedate.tmp
REM Date du fichier des entrées
for /F "delims=*" %%I in ('dir /od /tc /b is_in_??????.csv /od ^| tail -1') do @echo %%~tI |gawk "{print $1}"|gawk -F/ "{print $3 $2 $1}" >%temp%\filedate.tmp
set /p datein=<%temp%\filedate.tmp
REM Date du fichier de l'état des stocks
dir stock\TEexport_????????.csv /od /tc /b  |tail -1|ssed "s/[^0-9]//g" >%temp%\filedate.tmp
set /p datestock=<%temp%\filedate.tmp
del %temp%\filedate.tmp
if not %dateout%==%datein% (
msg %username% "out = %dateout% et in = %datein%"
set /A dateerreur=%dateerreur%+1
)
if not %dateout%==%datestock% (
msg %username% "out = %dateout% et stock = %datestock%"
set /A dateerreur=%dateerreur%+2
)
if not %datestock%==%datein% (
msg %username% "stock = %datestock% et in = %datein%"
set /A dateerreur=%dateerreur%+4
)
if @%dateerreur%@ == @@ goto :eof
@echo erreur de date No %dateerreur%
@echo faire un break pour interrompre ou
pause
