@echo off
goto :debut
ISstatloop.cmd
12/02/2016 09:57
OBJET : Lancement des scripts d'état hebdomadaire des flux et stocks de matériel gérés par I&S

MODIF 16:30 lundi 25 avril 2016 : Exécution 6 fois plus rapide
	remplacement de l'invocation du script "test.awk" pour chaque famille de produit
	par l'invocation des scripts ISsuivientrees.awk   ISsuivisorties.awk   ISsuivistocks.awk pour toutes les familles à la fois

MODIF 14:39 jeudi 28 avril 2016
	modification des noms des fichiers de sortie
	suppression de l'invocation des fichiers générés (inutile depuis qu'un import automatique dans excel évite de faire un copier-coller manuel depuis un éditeur de texte)
	=> l'exécution est désormais 50 fois plus rapide qu'avant la modif du 16:30 lundi 25 avril 2016
MODIF 15:03 vendredi 2 décembre 2016
	rajout de la gestion des spares (impr expeditor vs rouleaux d'étiquettes, uc reconditionnées vs souris)
MODIF 30/01/2018 - 11:12:00 reprise après crash disque : adaptation à une autre organisation disque (supprimer les :: pour activer les modifs et supprimer les anciens équivalents)
MODIF 31/01/2018 - 11:28:08 mise en application des adaptations ajoutées la veille : suppression des :: et mise en :: des anciennes instructions
TESTE 01/02/2018 - 16:33:58 semble OK, aucun bug détecté sur des données réelles
MODIF 13/02/2018 - 11:54:22 modification des positionnements dans l'arborescence afin de gérer les bibliothèques de fonction via @include
BUG   06/04/2018 - 15:04:21 rajoute un filtre sed lors des recherches des fichiers à utiliser afin d'être certain que leurs noms corresponde à la nomenclature
MODIF 05/07/2018 - 11:53:47 :  extraction du stock alturing
MODIF 06/07/2018 - 10:12:43 n'affiche pas les articles dont la qté dispo est nulle
:debut
REM @echo on
if "@%isdir%@" NEQ "@@" goto isdirok
if exist ..\bin\getisdir.cmd (
call ..\bin\getisdir.cmd
goto isdirok
)
msg /w %username% Impossible de trouver le dossier I^&S
goto :eof
:isdirok

REM @echo isdirok
REM set AWKPATH=.;.\bin\;..\bin\;%isdir%\bin\
pushd "%isdir%\bin"
REM pause
rem on prend 
rem		le dernier des stock\TEexport_*.csv
rem		le dernier des is_out_*.csv

rem stat des sorties
:: dir /od /b is_out_*.csv|tail -1 >%temp%\file.tmp
dir /o /s /b ..\is_out_??????.csv|sed -n "/is_out_[0-9]\{6\}\.csv$/Ip"|tail -1>%temp%\file.tmp
REM rajout du SED pour être certain d'avoir un fichier dont le nom correspond à la nomenclature

set /p inputfile=<%temp%\file.tmp
REM set outputfile=isflux.txt
set outputfile="%isdir%\StatsIS\is-out.csv"
del %outputfile% 2>nul
REM for %%I in (pv gv clpmet pfma clpuc clptp cisco chrrp chruc chrtp serveur m3 ship zpl finger) do gawk -f test.awk -v materiel="%%I" %inputfile% >>%outputfile%
rem ^^ formulation d'avant lundi 25 avril 2016
:: gawk -f ISsuivisorties.awk %inputfile% >>%outputfile%
:: gawk -f ISspareSorties.awk %inputfile% >>%outputfile%

gawk -f ISsuivisorties.awk "%inputfile%" >> %outputfile%
gawk -f ISsparesorties.awk "%inputfile%" >> %outputfile%

usort -o %outputfile% %outputfile%
:: REM ^^ on trie la sortie de manière à en maîtriser l'ordre

rem start %outputfile%

rem stat des réceptions
:: dir /od /b is_in_*.csv|tail -1 >%temp%\file.tmp
dir /o /b /s ..\is_in_*.csv|sed -n "/is_in_[0-9]\{6\}\.csv$/Ip"|tail -1 >%temp%\file.tmp
REM rajout du SED pour être certain d'avoir un fichier dont le nom correspond à la nomenclature
set /p inputfile=<%temp%\file.tmp
REM set outputfile=isrecep.txt
set outputfile="%isdir%\StatsIS\is-in.csv"
del %outputfile% 2>nul
REM for %%I in (pv gv clpmet pfma clpuc clptp cisco chrrp chruc chrtp serveur m3 ship zpl finger) do gawk -f test.awk -v materiel="%%I" %inputfile% >>%outputfile%
rem ^^ formulation d'avant lundi 25 avril 2016
:: gawk -f ISsuivientrees.awk %inputfile% >>%outputfile%
gawk -f ISsuivientrees.awk "%inputfile%" >>%outputfile%
usort -o %outputfile% %outputfile%
:: REM ^^ on trie la sortie de manière à en maîtriser l'ordre
REM gawk -f ISspareentrees.awk %inputfile% >>%outputfile% (ce script awk n'existe pas pour l'instant)
rem start %outputfile%

rem stat des stocks
:: dir /od /b stock\TEexport_*.csv|tail -1 >%temp%\file.tmp
dir /o /b /s ..\TEexport_*.csv|tail -1 |sed "s/^\(.*\)$/\d34\1\d34/" >%temp%\file.tmp
REM encadre le chemin de fichier par des guillemets afin de protéger le I&S
:: vérifier comment ça se passe pour les cas précédents => fait, il faut protéger aussi

set /p inputfile=<%temp%\file.tmp
:: set inputfile=stock\%inputfile%
:: supprimer le set inputfile=stock\%inputfile%


REM verrue du 05/07/2018 - 11:53:47 :  extraction du stock alturing
for %%I in (%inputfile%) do set filename=%%~nI
set outputfile="%isdir%\StatsIS\alt-stock.csv"
cat %inputfile% |gawk -F; "NR==1 || $1 ~ /TELINTRANS/ {if ($4) {print $2 FS $3 FS $4}}" >%outputfile%
REM fin verrue



REM set outputfile=isstock.txt 2>nul
set outputfile="%isdir%\StatsIS\is-stock.csv"
del %outputfile% 2>nul
REM for %%I in (pv gv clpmet pfma clpuc clptp cisco chrrp chruc chrtp serveur m3 ship zpl finger) do gawk -f test.awk -v materiel="%%I" %inputfile% >>%outputfile%
rem ^^ formulation d'avant lundi 25 avril 2016
:: gawk -f ISsuivistocks.awk %inputfile% >>%outputfile%
:: gawk -f ISsparestocks.awk %inputfile% >>%outputfile%
gawk -f ISsuivistocks.awk %inputfile% >>%outputfile%
gawk -f ISsparestocks.awk %inputfile% >>%outputfile%
usort -o %outputfile% %outputfile%
REM ^^ on trie la sortie de manière à en maîtriser l'ordre
rem start %outputfile%
popd