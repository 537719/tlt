@echo off
goto :debut
22/03/2018  13:27                36 quipoput.cmd

FINALITE : place dans le dossier ad hoc du serveur de rebond les fichiers devant �tre publi�s par le serveur web quipo

PREREQUIS :
    utilitaires GNU sous WIndows (inclus dans GIT)
    WinSCP (accessible dans le %path%)
    acc�s SSH au serveur de rebond.TLT
    script getpwrebond.cmd dans le m�me dossier que le pr�sent script
    

BUG   23/03/2018 - 17:18:29 rajoute une v�rification de bon positionnement des r�pertoires avant invocation => dans le r�pertoire des stats I&S et pr�sence du repository quipo
BUG   29/03/2018 - 14:04:49 d�tecte une erreur dans le cas o� l'historisation des mdp n'est pas trouv�e
MODIF 30/03/2018 - 15:12:30 exporte la r�cup�ration du mdp de connexion au serveur de rebond dans le script getpwrebond.cmd
MODIF 26/10/2018 - 10:43:13 d�place la log au niveau de directory pr�c�dent afin d'�viter de la transf�rer
MODIF 29/11/2018 - 13:53:51 test du nouveau serveur "jump" � la place du "rebond"
MODIF 09/01/2019 - 10:39:39 rajout d'une clause de d�tection d'erreur dans la log
MODIF 14:20 mardi 22 janvier 2019 supprime la partie de recherche du mdp dans les fichiers temp qui n'a plus lieu d'�tre depuis le remplacement de rebond par jump
MODIF 14:27 mardi 22 janvier 2019 adaptation au fait que winscp n'est plus dans le path et qu'il faut donc d�finir son chemin d'acc�s dans une variable d'environnement
MODIF 10:35 lundi 29 juin 2020 v�rifie que la connexion au serveur distant est �tablie (besoin �tabli depuis la mise en place du t�l�travail, n�cessitant l'activation d'une connexion VPN
MODIF 10:02 15/10/2020  Ne fait rien en cas de d�tection d'un flag demandant � ne rien faire afin de ne pas �tre lanc� inutilement dans une cha�ne de batches
MODIF 10:15 15/10/2020  Force la pagecode OEM863:French afin d'afficher correctment les accents
MODIF 09:05 23/10/2020  Affiche le texte de l'erreur en cas d'erreur WinSCP et corrige le chemin d'acc�s � notepad++ pour l'afficher dans son contexte
MODIF 09:20 23/10/2020  Replace dans le dossier d'origine apr�s ex�cution m�me en cas d'erreur
MODIF 10:32 07/12/2020  prend les identifiants de connexion au serveur de rebond dans un fichier de param�tre au lieu de les encoder en dur dans ce script
BUG   21:14 19/01/2021 la disponibilit� du lien r�seau se faisait en pingant toujours jump.tlt et non le serveur d�fini comme �tant celui auquel il fallait acc�der. Bug r�v�l� par la n�cessit� inopin�e de remplacer jump par wallaby
MODIF 19:31 08/02/2021 adaptation au nouvel emplacement de winscp suite � changement de pc et � la syntaxe de la nouvelle version de winscp (/console obligatoire avant /script en ligne de commande)

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
goto :fin
:isdirok
if not exist "%isdir%\StatsIS\quipo" goto :errrep
pushd "%isdir%\StatsIS"

if exist %temp%\differe.maj goto differemaj

set /p serveur= < "%isdir%\data\rebond.par"
ping -n 1 %serveur%
if errorlevel 1 goto :noping

:: r�cup�ration des param�tres d'authentification au serveur de rebond
set /p compte= < "%isdir%\data\jumplogin.par"
set /p pwd= < "%isdir%\data\jumppwd.par"
goto :genscript
rem recherche du mdp de connexion au serveur de rebond
set pwdold=
call "%~p0getpwrebond.cmd"
:: %~p0 donne le r�pertoire o� se situe le pr�sent script, et les doubles quotes prot�gent la pr�sence du signe & dans le chemin d'acc�s
if @%pwdold%@==@@ goto :pwdnull

:genscript
rem g�n�ration du script winscp
:: /!\ Attention la pr�sence d'accent plante le script.scp si on est en pagecode 863
@echo #%~n0.scp >%~n0.scp
@echo #%date% - %time% >>%~n0.scp
@echo #place dans les donnees web a heberger dans le dossier quipo sur le serveur de rebond >>%~n0.scp
@echo # >>%~n0.scp
@echo echo #1 ouverture de la session >>%~n0.scp
REM @echo open sftp://%compte%:%pwdold%@%serveur% >>%~n0.scp
@echo open sftp://%compte%:%pwd%@%serveur% >>%~n0.scp
@echo echo #2 synchronisation du distant par rapport au local >>%~n0.scp
@echo synchronize  -delete remote quipo quipo>>%~n0.scp
@echo echo #3 recuperation des donnees de verification >>%~n0.scp
@echo call ls -R -l quipo ^>quipo.dir>>%~n0.scp
rem un ^ avant le > pour le prot�ger car il fait partie de la ligne � produire, ce n'est pas vers l� qu'il faut envoyer les donn�es de la ligne
@echo get quipo.dir>>%~n0.scp
@echo call rm quipo.dir>>%~n0.scp
@echo exit >>%~n0.scp

@echo invocation du script winscp
REM set winscp=%userprofile%\bin\winscp\winscp.exe
set winscp="c:\Program Files (x86)\WinSCP\WinSCP.exe"
%winscp% /console /script=%~n0.scp /log=..\%~n0.log
@echo partie winscp terminee
if errorlevel 1 (
set erreur=%errorlevel%
goto :errscp
)
@echo sans erreur

rem v�rification du bon d�roul� des op�rations
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
rem on ne consid�re que les entr�es de type "fichier"
set /p local=<%temp%\local.tmp
set /p distant=<%temp%\distant.tmp
if not @%local%@==@%distant%@ goto :errsize
@echo taille des fichiers identiques entre distant et local

REM grep -v error %~n0.log
REM if errorlevel 1 @echo erreur inconnue
REM pause

goto :fin

:noping
@echo la connexion au serveur n'est pas �tablie
goto :fin

:pwddiff
@echo il y a une anomalie dans la sauvegarde du mdp
goto :fin

:winscpko
@echo winscp n'a pas pu uploader les fichiers
goto :fin

:winscpok
@echo winscp a pu uploader les fichiers
call chpwrebond.cmd
goto :fin

:errsize
@echo la taille des fichiers locaux %local% est diff�rente de celle des fichiers distants %distant%
goto :fin

:errnbfile
@echo le nombre de fichiers locaux %local% est diff�rent de celui des fichiers distants %distant%
goto :fin

:errnbfolders
@echo le nombre de dossiers locaux %local% est diff�rent de celui des dossiers distants %distant%
goto :fin

:errscp
gawk "/fail|deni|error|exit status/ {print NR}" ..\%~n0.log|tail -1>%temp%\errline.txt
set /p errline=<%temp%\errline.txt
@echo winscp a rencontr� une erreur, voir ligne %errline% de %~n0.log
sed -n -e "%errline% s/\(.*\)/WinSCP a subi une erreur %erreur% :\n\1/p" ..\quipoput.log | msg %username%
"C:\Program Files (x86)\Notepad++\notepad++.exe" -n%errline% ..\%~n0.log
goto :fin

:errrep
@echo Le dossier "%isdir%\StatsIS\quipo" n'existe pas
goto :fin

:pwdnull
@echo mot de passe non trouv�
@echo %date% - %time% : mot de passe non trouv� >>%temp%\errrebond.pwd
goto :fin
:differemaj
for %%I in (%temp%\differe.maj) do @echo une mise � jour diff�r�e a �t� initi�e le %%~tI
goto :fin

:fin
popd