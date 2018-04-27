goto :debut
::22/03/2018  13:13               347 testhistorypwd.cmd
:: teste si le mdp fouri en argument figure en historique
:: suppose que le mdp en question en contient pas de séparateur au sens "ligne de commande windows"
:debut
if not exist %temp%\history.pwd goto :nohistory
grep %1 %temp%\history.pwd
if errorlevel 1 goto :pasvu
:vu
@echo %1 a déjà été utilisé comme mdp
goto :eof
:pasvu
@echo %1 pas encore utilisé comme mdp
goto :eof
:nohistory
@echo le fichier d'historique des mdp n'existe pas
goto :eof