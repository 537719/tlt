@echo off
goto :debut
creedossiersPM.cmd
CREATION    21:19 02/10/2020    Place dans le presse-papier le texte de description des dossiers de demande pour le d‚ploiement des Postes MaŒtres Linux pour Colissimo
PREREQUIS                       scripts creedossiersPM.awk creedossiersPM.sql et base de donn‚e sandbox.db de traitement des donn‚es I&S
ATTENTION   Encodage OEM863.French afin d'afficher correctement les accents            
MODIF       10:51 13/10/2020    Prend en compte le report du num‚ro de dossier nouvellement cr‚‚ dans la google sheet de suivi
MODIF       19:20 19/10/2020    Ne suspend l'ex‚cution que s'il y a lieu de reporter un num‚ro de dossier nouvellement cr‚‚
:debut
pushd ..\data
sqlite3 sandbox.db < ..\bin\creedossiersPM.sql
..\work\CreationDossier.txt
grep -v Prochain ..\work\CreationDossier.txt |wc -l> %temp%\creedossiersPM.tmp
set /p fairepause=<%temp%\creedossiersPM.tmp
if @%fairepause%@==@0@ goto pausefaite

MSG /w %username% Reporter le num‚ro de dossier dans le google sheet et l'exporter en TSV
@echo Reporter le num‚ro de dossier dans le google sheet et l'exporter en TSV puis
pause

:pausefaite
cd  ..\CLP
dir /od /b *.tsv |tail -1 >%temp%\dir.tmp
REM set fairepause=
set /p fichier=<%temp%\dir.tmp
gawk -f ..\bin\SuivreDossiersPM.awk %fichier% > SuiviDossiers.csv
popd
