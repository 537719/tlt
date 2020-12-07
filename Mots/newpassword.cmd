REM @echo off
goto :debut
newpassword.cmd
produit un nouveau mot de passe par concaténation de 4 mots choisis aléatoirement

MODIF 20/03/2018 - 16:55:28 rajoute la date du jour, ne met plus d'espace entre les mots, ne met plus d'autre texte que le mot de passe dans le fichier résultat et ne supprime plus le fichier résultat
:debut
if exist %1 goto :onfait
if NOT (%1)==() goto :onfait
@echo Le fichier %1 n'existe pas
msg %username% "Le fichier %1 n'existe pas"
goto :eof
:onfait
set jour=%date:/=-%
REM del %temp%\tmp.pwd 2>nul
del %temp%\???.pwd 2>nul
for /L %%I in (1 1 4) do call randomword %1 >>%temp%\tmp.pwd
@echo %jour%>>%temp%\tmp.pwd
rem pas d'espace avant le >> sinon il se retrouve dans le fichier produit
REM @echo Le nouveau mot de passe est >%temp%\new.pwd
rem type %temp%\tmp.pwd |tr -d \r |tr \n \040 >>%temp%\new.pwd
type %temp%\tmp.pwd |tr -d \r |tr -d \n >>%temp%\new.pwd
type %temp%\new.pwd
REM msg %username% <%temp%\new.pwd
REM @echo Baisé >%temp%\tmp.pwd
REM @echo Baisé >%temp%\new.pwd
REM del %temp%\???.pwd
