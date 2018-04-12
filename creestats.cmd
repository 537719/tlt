::creestats.cmd
::12/05/2016 11:41:59,27
::cr�e les stats de suivi I&S
@echo off
goto :debut
MODIF 16:21 jeudi 19 mai 2016 ajoute aussi le seuil d'alerte
MODIF 10:47 lundi 30 mai 2016 d�place les fichiers g�n�r�s vers le dossier web correspondant
MODIF 10:57 lundi 29 ao�t 2016 impl�mentation de la v�rification manuelle des commentaires textuels
BUG 11:04 mardi 6 d�cembre 2016 n'extrait la borne de date inf�rieure que si elle a un format valide
BUG ^^ 11:37 mardi 6 d�cembre 2016 �limination des \ dans la ligne d'en-t�te, dont la pr�sence perturbe genericplot
  BUG 12:19 vendredi 30 d�cembre 2016 r��crit au format aaaa-mm-jj les dates �ventuellement �crites au format jj/mm/aa
  ce qui peut arriver si on manipule le csv avec un tableur
MODIF 30/01/2018 - 11:12:00 reprise apr�s crash disque
    remplacement de ssed par sed
MODIF 30/01/2018 - 11:12:00 reprise apr�s crash disque : adaptation � une autre organisation disque (supprimer les :: pour activer les modifs et supprimer les anciens �quivalents)
MODIF 31/01/2018 - 11:28:08 mise en application des adaptations ajout�es la veille : suppression des :: et mise en :: des anciennes instructions
BUG 05/02/2018 - 10:46:41 rajoute un tri d�doublonn� sur la date
BUG 16/02/2018 - 14:25:51 �limine la r�p�tition de la ligne d'en-t�te dans les donn�es � tracer
MODIF 20/02/2018 - 16:37:34 change l'invocation de la g�n�ration de page web de mani�re � prendre des infos dans le ficier de seuil
MODIF 20/02/2018 - 17:22:20 transmet �galement la date concern�e lors de la g�n�raton de page web
MODIF 22/03/2018 - 17:19:31 d�place les donn�es produites vers le dossier quipo qui sert de repository web
MODIF 23/03/2018 - 13:28:43 v�rifie que le dossier en cours a bien �t� d�plac� et lance le transfert vers le repository
MODIF 29/03/2018 - 15:54:01 g�n�re un index pour les webresources et met le dossier � jour dans le repository
MODIF 29/03/2018 - 16:38:56 renomme le whatsnews.txt en *.log afin de ne pas l'auto-r�f�rencer
BUG   05/04/2018 - 16:54:21 corrige un commentaire mal d�fini qui cr�ait des dossiers vides inutiles

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

call "%isdir%\bin\ISstatloop.cmd"
REM g�n�ration pr�alable des fichiers de stats des familles de produits chez I&S
pushd "%isdir%\StatsIS"

REM agr�ge les deux stats en un seul fichier
paste -d; is-out.csv is-stock.csv is-seuil.csv >is-data.csv
REM ATTENTION 1 ceci n'est possible que parce que les deux fichiers ont le m�me nombre de lignes, dans le m�me ordre. Sinon il faut trier puis utiliser join
REM ATTENTION on se retrouve avec une colonne de titre en trop au milieu du fichier, � prendre en compte lors de la cr�ation du graphique

    
:sorties
head -1 is-data.csv |sed "s/.*_\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)\..*/\1-\2-\3/" >%temp%\moisfin.tmp
REM MODIF 11:08 mardi 17 mai 2016 utilise un format de date aaaa-mm-jj au lieu de mm/aaaa
set /p moisfin=<%temp%\moisfin.tmp

rd /s /q %moisfin% 2>nul

md %moisfin% 2>nul
REM dossier ^^ o� seront stock�es les fichiers cr��s

del %temp%\moisdeb.tmp 2>nul

set gnuplot=%programfiles%\gnuplot\bin\gnuplot.exe  

:: for /F "delims=;" %%I in (is-data.csv) do if exist %%I.csv (
for /F "delims=;" %%I in (.\is-data.csv) do if exist %%I.csv (
REM Construit pour chaque famille de produit les fichiers de donn�es pour alimenter gnuplot
::   head -1 %%I.csv |ssed -e "s/;/\t/g" -e "s/\\/-/g" > %%I.tab
  head -1 %%I.csv |sed -e "s/;/\t/g" -e "s/\\\/-/g" > %%I.tab
  REM BUG ^^ 11:37 mardi 6 d�cembre 2016 �limination des \ dans la ligne d'en-t�te, dont la pr�sence perturbe genericplot
  REM en-t�te ^^

  REM cat %%I.csv |grep -v "%moisfin:~0,-3%" |tail -13 |ssed "s/;/\t/g" >> %%I.tab
  REM �limination ^^ de l'occurence pr�c�dente pour le moisfin en cours et conservation des 12 mois pr�c�dents
  REM cat %%I.csv |ssed -e "/%moisfin:~0,-3%/d" -e "s/;/\t/g" |tail -13 >> %%I.tab
::  cat %%I.csv |ssed -e "s/\([0-9][0-9]\)\/\([0-9][0-9]\)\/\([0-9][0-9][0-9][0-9]\)/\3-\2-\1/" -e "/%moisfin:~0,-3%/d" -e "s/;/\t/g" |tail -13 >> %%I.tab
  cat %%I.csv |sed -e "/^[A-z]/d" -e "s/\([0-9][0-9]\)\/\([0-9][0-9]\)\/\([0-9][0-9][0-9][0-9]\)/\3-\2-\1/" -e "/%moisfin:~0,-3%/d" -e "s/;/\t/g"|usort -u |tail -13 >> %%I.tab
  REM Maintenant que la date ne contient plus de "/" c'est plus simple et plus rapide de ne plus utiliser grep
  REM BUG 12:19 vendredi 30 d�cembre 2016 r��crit au format aaaa-mm-jj les dates �ventuellement �crites au format jj/mm/aa
  REM ce qui peut arriver si on manipule le csv avec un tableur
  REM BUG 05/02/2018 - 10:46:41 rajoute un tri d�doublonn� sur la date
  REM MODIF 06/04/2018 - 14:36:49 centralisation de fonctions dans un module � inclure dans les scripts de g�n�ration de page HTML et cr�ation d'une page d'index g�n�ral pour visu de l'historique
  
::  gawk -F; -v OFS="\t" "{if (sub(/%%I/,\"%moisfin%\",$1)) print}" is-data.csv >> %%I.tab
  gawk -F; -v OFS="\t" "{if (sub(/%%I/,\"%moisfin%\",$1)) print}" is-data.csv >> %%I.tab
  REM Rajout de l'occurence actuelle pour le moisfin en cours

  REM Reconstitue un csv � jour
  cat %%I.csv |grep -v "%moisfin:~0,-3%" >%%I.tmp
::  ssed -n "s/^%%I/%moisfin%/p" is-data.csv >>%%I.tmp
  sed -n "s/^%%I/%moisfin%/p" is-data.csv >>%%I.tmp

  move /y %%I.csv %%I.bak.csv
  move /y %%I.tmp %%I.csv

  
  if not exist %temp%\moisdeb.tmp gawk -F\t "{if (NR==2) if ($1 ~/[0-9]{4}-[0-9]{2}-[0-9]{2}/) print $1}" %%I.tab >%temp%\moisdeb.tmp
  REM ^^ BUG 11:04 mardi 6 d�cembre 2016 n'extrait la borne de date inf�rieure que si elle a un format valide

  set /p moisdeb=<%temp%\moisdeb.tmp
  REM d�termination de la borne temporelle inf�rieure pour le graphique
  "%gnuplot%"  -c ..\bin\genericplot.plt %%I.tab %moisdeb% %moisfin%
  REM Cr�e le graphique
  
REM @echo   gawk -f ..\bin\genHTMLlink.awk -v fichier="%%I" -v moisfin="%moisfin%" is-seuil.csv >%%I.htm
pushd ..\bin
rem repositionnemnt n�cessaire sans quoi le script awk ne trouve pas le module � inclure
  gawk -f ..\bin\genHTMLlink.awk -v fichier="%%I" -v moisfin="%moisfin%" ..\StatsIS\is-seuil.csv >..\StatsIS\%%I.htm
popd
  REM pause
  REM g�n�ration de la page web affichant le graphique
  move %%I.* "%moisfin%"
  copy "%moisfin%\%%I.txt" .
  copy "%moisfin%\%%I.csv" .
  REM move %%I.htm "%moisfin%"
)
wc -l is-seuil.csv >%temp%\wc-l.txt
set /p nblgn=<%temp%\wc-l.txt
set /a nblgn=nblgn-2
REM �limination ^^ des deux derni�res lignes, qui ne correspondent pas � de vrais produits
rem head -%nblgn% is-seuil.csv |gawk -f genHTMLindex.awk -v statdate="%moisfin%" >index.html
REM Nouvelle formulation du 15:05 06/12/2016 car les lignes � �liminer ne sont plus les derni�res
rem mais sont les seules � contenir "mat�riel"

pushd ..\bin
rem repositionnemnt n�cessaire sans quoi le script awk ne trouve pas le module � inclure
cat ..\StatsIS\is-seuil.csv |grep -v riel |gawk -f ..\bin\genHTMLindex.awk -v statdate="%moisfin%" >..\StatsIS\index.html
popd
md webresources 2>nul
:: ^^ cr�e le dossier webresources s'il a disparu entre temps
cat is-seuil.csv |grep -v riel |gawk -f ..\bin\genressourcesindex.awk >webresources\index.html
REM g�n�ration de la page d'en-t�te pour toutes les familles suivies

move index.html %moisfin%


@echo on
REM mise � jour des webresources
pushd "%isdir%\StatsIS\webresources"
xcopy /s /c /h /e /m /y *.* ..\quipo\webresources\*.* 
popd
@echo off

set web=%userprofile%\Dropbox\EasyPHP-DevServer-14.1VC11\data\localweb\StatsIS
REM move /y %moisfin% %web%
rd /s /q "%web%\%moisfin%" 2>nul
@echo V�rifier et corriger les commentaires texte dans le dossier %moisfin%
msg %username% V�rifier et corriger les commentaires texte dans le dossier %moisfin%
REM MODIF 10:57 lundi 29 ao�t 2016 impl�mentation de la v�rification manuelle des commentaires textuels
REM @echo on
pushd %moisfin%
for %%I in (*.txt *.png) do start %%I
pause
xcopy /y /I . "%web%\%moisfin%"
xcopy *.txt .. /y
popd

rem d�placement des donn�es produites vers le dossier web
:movedata
@echo on
del %temp%\erreur.txt 2>nul
pushd "%isdir%\StatsIS\%moisfin%"
md ..\quipo\%moisfin%
move /y *.* ..\quipo\%moisfin% 2>%temp%\erreur.txt
cd ..
rd %moisfin%
popd
if not exist %temp%\erreur.txt goto :genindex
if exist quipo\%moisfin%\nul goto :genindex
@echo Lib�rer le dossier "%cd%\%moisfin%" >>%temp%\erreur.txt
cat %temp%\erreur.txt |msg /W %username% 
pause
goto :movedata
:genindex
pushd "%isdir%\bin"
rem g�n�ration de l'index des stats pr�c�dentes, pour consultation de l'historique
rem repositionnemnt n�cessaire sans quoi le script awk ne trouve pas le module � inclure
dir  ..\StatsIS\quipo |gawk -f genDateIndex.awk >..\StatsIS\quipo\index.html
REM simple liste des dates tri�e par ordre d�croissant
popd
:quipoput
call ..\bin\quipoput.cmd
if exist %moisfin%\nul @echo Lib�rer le dossier "%cd%\%moisfin%"

REM �laboration de la liste des nouveaut�s pour le mail de reporting
@echo Modifications du %date% >> whatsnew.log
for /F "tokens=4" %%I in ('dir  /o *.txt ^|find "%date%"') do cat %%I >>whatsnew.log
"C:\Program Files\Notepad++\notepad++.exe" whatsnew.log
popd
