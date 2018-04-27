@echo off
goto :debut
getpwrebond.cmd
30/03/2018 - 15:12:30
récupère le mdp du serveur de rebond et le place en variable d'environnement
détecte et signale les anomalies empêchant de poursuivre

PREREQUIS : utilitaires GNU sous windows (inclus dans GIT)
USAGE : Invocation par CALL depuis les scripts chpwrebond.cmd et quipoput.cmd

:debut

REM la variable d'environnement pwdold est censée avoir été nettoyée avant invocation de ce script
REM si ce n'est pas le cas, il y a risque de conflit avec un mdp déjà calculé mais non sauvegardé
if NOT @%pwdold%@==@@ goto :pwdnonnull

REM s'il existe une trace d'erreur de mdp alors arrêter ici avant de risquer de créer une incohérence
if exist %temp%\errrebond.pwd goto :pwderror

rem recherche du mdp de connexion au serveur de rebond
rem celui-ci se trouve dans 3 localisations différentes :
rem - %temp%\oldrebond.pwd
rem - en tant que dernière ligne de %temp%\history.pwd
rem - après la mention # new dans le script chpwrebond.scp (usage déprécié)
set /p pwd1=<%temp%\oldrebond.pwd
tail -1 %temp%\history.pwd>%temp%\tmp.pwd
set /p pwd2=<%temp%\tmp.pwd
if not @%pwd1%@==@%pwd2%@ goto :pwddiff
if @%pwd1%@==@@ goto :pwdnull

set pwdold=%pwd1%
rem pwddold est la valeur attendur par le script appelant

goto :eof

:pwdnonnull
@echo mot de passe non purgé avant invocation, vérifier la cohérence du mdp
@echo %date% - %time% : mot de passe non purgé avant invocation, vérifier la cohérence du mdp >>%temp%\errrebond.pwd
goto :eof

:pwdnull
@echo mot de passe non trouvé
@echo %date% - %time% : mot de passe non trouvé >>%temp%\errrebond.pwd
goto :eof

:pwddiff
@echo il y a une anomalie dans la sauvegarde du mdp
@echo %date% - %time% : il y a une anomalie dans la sauvegarde du mdp >>%temp%\errrebond.pwd
goto :eof

:pwderror
@echo %date% - %time% : résoudre l'erreur de mdp avant d'aller plus loin >>%temp%\errrebond.pwd
msg /w %username% <%temp%\errrebond.pwd
goto :eof
