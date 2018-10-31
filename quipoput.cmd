@echo off
goto :debut
22/03/2018  13:27                36 quipoput.cmd

FINALITE : place dans le dossier ad hoc du serveur de rebond les fichiers devant être publiés par le serveur web quipo

PREREQUIS :
    utilitaires GNU sous WIndows (inclus dans GIT)
    WinSCP (accessible dans le %path%)
    accès SSH au serveur de rebond.TLT
    script getpwrebond.cmd dans le même dossier que le présent script
    

BUG   23/03/2018 - 17:18:29 rajoute une vérification de bon positionnement des répertoires avant invocation => dans le répertoire des stats I&S et présence du repository quipo
BUG   29/03/2018 - 14:04:49 détecte une erreur dans le cas où l'historisation des mdp n'est pas trouvée
MODIF 30/03/2018 - 15:12:30 exporte la récupération du mdp de connexion au serveur de rebond dans le script getpwrebond.cmd
MODIF 26/10/2018 - 10:43:13 déplace la log au niveau de directory précédent afin d'éviter de la transférer

:debut
if "@%isdir%@" NEQ "@@" goto isdirok
if exist ..\bin\getisdir.cmd (
call ..\bin\getisdir.cmd
goto isdirok
) else if exist .\bin\getisdir.cmd (
call ..\bin\getisdir.cmd
goto isdirok
)

msg /w %username% Impossible de trouver le dossier I^&S
goto :eof
:isdirok
if not exist "%isdir%\StatsIS\quipo" goto :errrep
cd /d "%isdir%\StatsIS"

rem recherche du mdp de connexion au serveur de rebond
set pwdold=
call "%~p0getpwrebond.cmd"
:: %~p0 donne le répertoire où se situe le présent script, et les doubles quotes protègent la présence du signe & dans le chemin d'accès
if @%pwdold%@==@@ goto :pwdnull

rem génération du script winscp
@echo #%~n0.scp >%~n0.scp
@echo #%date% - %time% >>%~n0.scp
@echo #place dans les données web à héberger dans le dossier quipo sur le serveur de rebond >>%~n0.scp
@echo # >>%~n0.scp
@echo echo #1 ouverture de la session >>%~n0.scp
@echo open sftp://gmetais:%pwdold%@rebond.tlt >>%~n0.scp
@echo echo #2 synchronisation du distant par rapport au local >>%~n0.scp
@echo synchronize  -delete remote quipo quipo>>%~n0.scp
@echo echo #3 récupération des données de vérification >>%~n0.scp
@echo call ls -R -l quipo ^>quipo.dir>>%~n0.scp
rem un ^ avant le > pour le protéger car il fait partie de la ligne à produire, ce n'est pas vers là qu'il faut envoyer les données de la ligne
@echo get quipo.dir>>%~n0.scp
@echo call rm quipo.dir>>%~n0.scp
@echo exit >>%~n0.scp

@echo invocation du script winscp
winscp /script=%~n0.scp /log=..\%~n0.log
@echo partie winscp terminee
if errorlevel 1 goto :errscp
@echo sans erreur

rem vérification du bon déroulé des opérations
@echo Comparaison des nombres de fichier, de dossiers et de cumul de taille des fichiers entre local et distant
rem comparaison du nombre de fichiers
ls -l -R quipo|wc -l |gawk "{print $1}" >%temp%\local.tmp
cat quipo.dir|wc -l |gawk "{print $1}" >%temp%\distant.tmp
set /p local=<%temp%\local.tmp
set /p distant=<%temp%\distant.tmp
if not @%local%@==@%distant%@ goto :errnbfile
@echo nombre de fichiers identiques entre distant et local

rem comparaison  du nombre de dossiers
ls -l -R quipo|gawk "/\// {nb++} END {print nb}" >%temp%\local.tmp
cat quipo.dir|gawk "/\// {nb++} END {print nb}" >%temp%\distant.tmp
set /p local=<%temp%\local.tmp
set /p distant=<%temp%\distant.tmp
if not @%local%@==@%distant%@ goto :errnbfolders
@echo nombre de dossiers identiques entre distant et local

rem comparaison  de la taille totale des fichiers
ls -l -R quipo|gawk "/^-/ {cumul=cumul+$5} END {print cumul}" >%temp%\local.tmp
cat quipo.dir|gawk "/^-/ {cumul=cumul+$5} END {print cumul}" >%temp%\distant.tmp
rem on ne considère que les entrées de type "fichier"
set /p local=<%temp%\local.tmp
set /p distant=<%temp%\distant.tmp
if not @%local%@==@%distant%@ goto :errsize
@echo taille des fichiers identiques entre distant et local

REM grep -v error %~n0.log
REM if errorlevel 1 @echo erreur inconnue
REM pause

goto :eof

:pwddiff
@echo il y a une anomalie dans la sauvegarde du mdp
goto :eof

:winscpko
@echo winscp n'a pas pu uploader les fichiers
goto :eof

:winscpok
@echo winscp a pu uploader les fichiers
rem call chpwrebond.cmd
goto :eof

:errsize
@echo la taille des fichiers locaux %local% est différente de celle des fichiers distants %distant%
goto :eof

:errnbfile
@echo le nombre de fichiers locaux %local% est différent de celui des fichiers distants %distant%
goto :eof

:errnbfolders
@echo le nombre de dossiers locaux %local% est différent de celui des dossiers distants %distant%
goto :eof

:errscp
gawk "/fail|deni|error/ {print NR}" ..\%~n0.log|tail -1>%temp%\errline.txt
set /p errline=<%temp%\errline.txt
@echo winscp a rencontré une erreur, voir ligne %errline% de %~n0.log
msg %username% winscp a rencontré une erreur, voir ligne %errline% de %~n0.log
"C:\Program Files\Notepad++\notepad++.exe" -n%errline% ..\%~n0.log
goto :eof

:errrep
@echo Le dossier "%isdir%\StatsIS\quipo" n'existe pas
goto :eof

:pwdnull
@echo mot de passe non trouvé
@echo %date% - %time% : mot de passe non trouvé >>%temp%\errrebond.pwd
goto :eof
