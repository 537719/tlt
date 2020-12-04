REM @echo off
goto :debut
suivredepl.cmd
CREATION    09:03 08/10/2020    Rajoute le num‚ro de dossier au couple codesite/code projet de la table des d‚ploiements, aprŠs cr‚ation du dossier
ATTENTION /!\ ENCODAGE en OEM863:French afin d'afficher correctement les accents
:debut
REM v‚rification de la coh‚rence des paramŠtres
gawk 'BEGIN {if ("%1" !~ /^^[0-9]{6}$/) {print "Code site invalide %1";exit 2} if ("%3" !~ /^^[0-9]{10}$/) {print "Dossier invalide %3";exit 4} if ("%2" !~ /^^[0-9]{10}$^|^^[A-Z]+$/) {print "Projet invalide %2";exit 3}}'
if errorlevel 4 goto :erreur3
if errorlevel 3 goto :erreur2
if errorlevel 2 goto :erreur1
if errorlevel 1 goto :erreur

REM Mise … jour des donn‚es
sqlite3 ..\data\sandbox.db "update suivideploiements set dossier='%3' where codesite= '%1' and codeprojet='%2';"

REM v‚rification de la mise … jour
sqlite3 ..\data\sandbox.db "select * from suivideploiements where codesite= '%1' and codeprojet='%2' and dossier='%3';" |wc -l > %temp%\nb.txt
set /p nb=< %temp%\nb.txt

IF NOT %nb%==1 goto :erreurNB
@echo Suivi mis … jour
sqlite3 ..\data\sandbox.db "select 'Dossier suivi',* from suivideploiements where codesite= '%1' and codeprojet='%2' and dossier='%3';" |tr "|" " "|msg /w %username%

shift
shift
shift

call suivre %0 %1 %2 %3 %4 %5 %6 %7 %8 %9

goto :eof
:erreur
msg /w %username% "autre erreur"
goto :eof

:erreur1
msg /w %username% "le code site %1 doit ˆtre sur six chiffres"
goto :eof
:erreur2
msg /w %username% "le code projet %2 doit ˆtre un num‚ro de dossier ou un code en majuscules"
goto :eof
:erreur3
msg /w %username% "le num‚ro de dossier %3 doit ˆtre sur dix chiffres"
goto :eof
:erreurNB
msg /w %username% "%nb% dossiers mis … jour %1 %2 %3"
goto :eof