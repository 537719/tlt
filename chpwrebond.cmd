@echo off
goto :debut
20/03/2018  17:06                38 chpwrebond.cmd
FINALITE : Change le mot de passe sur le serveur de rebond

PREREQUIS :
    utilitaires GNU sous WIndows (inclus dans GIT)
    WinSCP (accessible dans le %path%)
    accès SSH au serveur de rebond.TLT
    script NEWPASSWORD.CMD et ses dépendances
    
MODIF 22/03/2018 - 13:08:35 conserve un historique des mdp utilisés et vérifie que le nouveau mdp n'y figure pas
MODIF 22/03/2018 - 15:57:39 remplace le dossier "test" local par "temp" sans toucher au nom du dossier distant, et le purge après usage
MODIF 23/03/2018 - 15:28:52 exploite les logs pour pointer les éventuelles erreurs d'exécution
MODIF 26/03/2018 - 14:10:10 utilise la même méthode de récupération du mdp que dans quipoput.cmd, plus robuste

:debut
if exist %temp%\errrebond.pwd goto :errpwd
REM vestige d'une précédente erreur de mdp à corriger avant de griller le mdp

goto :loop test de la manière dont quipoput.cmp importe l'ancien mdp, plus robuste
rem remise en mémoire de l'ancien mot de passe
if not exist %temp%\oldrebond.pwd goto :noold
set /p pwdold=<%temp%\oldrebond.pwd

:loop
rem recherche du mdp de connexion au serveur de rebond
rem celui-ci se trouve dans 3 localisations différentes :
rem - %temp%\oldrebond.pwd
rem - en tant que dernière ligne de %temp%\history.pwd
rem - après la mention # new dans le script chpwrebond.scp (usage déprécié)
set /p pwd1=<%temp%\oldrebond.pwd
tail -1 %temp%\history.pwd>%temp%\tmp.pwd
set /p pwd2=<%temp%\tmp.pwd
if not @%pwd1%@==@%pwd2%@ goto :pwddiff

set pwdold=%pwd1%

rem génération d'un nouveau mot de passe
:gennewpw
pushd "%userprofile%\Documents\Mots"
call newpassword.cmd sansaccents.txt >nul
REM call newpassword.cmd sansaccents.txt
rem on masque l'affichage du mdp généré
popd

if not exist %temp%\new.pwd goto :nonew
for %%I in (%temp%\new.pwd) do if %%~zI==0 goto :nonew
set /p pwdnew=<%temp%\new.pwd

rem vérification d'une précédente utilisation du mdp venant d'être généré
grep %pwdnew% %temp%\history.pwd
if errorlevel 1 goto :pasvu
rem si on passe ici c'est que le mdp venant d'être généré a déjà été utilisé, il faut donc en générer un différent
goto :gennewpw

:pasvu
rem génération du fichier de changement de mot de passe
rem une fois l'ancien et deux fois le nouveau
@echo %pwdold%>%temp%\chgt.pwd
@echo %pwdnew%>>%temp%\chgt.pwd
@echo %pwdnew%>>%temp%\chgt.pwd
rem pas d'espace avant le >> sinon ils sont dans le fichier produit
rem sauts de ligne "unix"
dos2unix -q %temp%\chgt.pwd >nul
rem option -q pour ne pas avoir d'affichage sans valeur ajoutée
rem mise à disposition du fichier de mdp
rd /s /q test 2>nul
md temp
move /y %temp%\chgt.pwd temp\toto.txt >nul
rem redirection vers nul pour ne pas avoir d'affichage sans valeur ajoutée


rem génération du script winscp
@echo #%~n0.scp >%~n0.scp
@echo #%date% - %time% >>%~n0.scp
@echo #change mon mot de passe sur le serveur de rebond >>%~n0.scp
@echo # >>%~n0.scp
@echo echo #1 ouverture de la session >>%~n0.scp
@echo open sftp://gmetais:%pwdold%@rebond.tlt >>%~n0.scp
@echo echo #2 copie le fichier contenant le nouveau mot de passe >>%~n0.scp
@echo call rm -r test 2^>nul.tmp >>%~n0.scp
rem un ^ avant le > pour le protéger car il fait partie de la ligne à produire, ce n'est pas vers là qu'il faut envoyer les données de la ligne
@echo mkdir test>>%~n0.scp
@echo put .\temp\*.* ./test/*.* >>%~n0.scp
@echo ls ./test>>%~n0.scp
@echo echo #3 exécute l'instruction de changement de mot de passe >>%~n0.scp
@echo call passwd ^<test/toto.txt >>%~n0.scp
rem un ^ avant le < pour le protéger car il fait partie de la ligne à produire, ce n'est pas de là qu'il faut prendre les données d'alimentation de la ligne
@echo echo #4 purge les données temporaires >>%~n0.scp
@echo call rm test/t*.txt >>%~n0.scp
@echo call rmdir test >>%~n0.scp
@echo call rm nul.tmp >>%~n0.scp
@echo exit >>%~n0.scp
@echo # new %pwdnew% >>%~n0.scp

@echo invocation du script winscp
winscp /script=%~n0.scp /log=%~n0.log
@echo partie winscp terminee
if errorlevel 1 goto :errscp
@echo sans erreur
goto :winscpok

rem affichage du mdp pour vérification, ne doit normalement pas être exécuté
cat %temp%\oldrebond.pwd

goto :eof
:noold
@echo le fichier de l'ancien mot de passe n'existe pas
goto :eof

:nonew
@echo le fichier de nouveau mot de passe n'existe pas
goto :eof

:winscpko
@echo winscp n'a pas pu changer le mot de passe
goto :eof

:winscpok
@echo winscp a pu changer le mot de passe

rem sauvegarde du mdp
@echo %pwdnew%>%temp%\oldrebond.pwd
@echo %pwdnew%>>%temp%\history.pwd
rem pas d'espace avant le >> sinon ils sont dans le fichier produit

rem purge du mdp temporaires
rd /s /q temp 2>nul
rd /s /q test 2>nul
goto :eof

:errscp
@echo ANOMALIE DE MDP A CORRIGER AVANT NOUVELLE TENTATIVE>%temp%\errrebond.pwd
msg %username% <%temp%\errrebond.pwd
gawk "/fail|deni|error/ {print NR}" %~n0.log|tail -1>%temp%\errline.txt
set /p errline=<%temp%\errline.txt
@echo winscp a rencontré une erreur, voir ligne %errline% de %~n0.log
msg %username% winscp a rencontré une erreur, voir ligne %errline% de %~n0.log
"C:\Program Files\Notepad++\notepad++.exe" -n%errline% %~n0.log
goto :eof

:errpwd
msg %username% <%temp%\errrebond.pwd
goto :eof

:pwddiff
@echo il y a une anomalie dans la sauvegarde du mdp
goto :eof
