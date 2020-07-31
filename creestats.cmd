::creestats.cmd
::12/05/2016 11:41:59,27
::crée les stats de suivi I&S
REM @echo off
goto :debut
MODIF 16:21 jeudi 19 mai 2016 ajoute aussi le seuil d'alerte
MODIF 10:47 lundi 30 mai 2016 déplace les fichiers générés vers le dossier web correspondant
MODIF 10:57 lundi 29 août 2016 implémentation de la vérification manuelle des commentaires textuels
BUG 11:04 mardi 6 décembre 2016 n'extrait la borne de date inférieure que si elle a un format valide
BUG ^^ 11:37 mardi 6 décembre 2016 élimination des \ dans la ligne d'en-tête, dont la présence perturbe genericplot
BUG 12:19 vendredi 30 décembre 2016 réécrit au format aaaa-mm-jj les dates éventuellement écrites au format jj/mm/aa
  ce qui peut arriver si on manipule le csv avec un tableur
MODIF 30/01/2018 - 11:12:00 reprise après crash disque
    remplacement de ssed par sed
MODIF 30/01/2018 - 11:12:00 reprise après crash disque : adaptation à une autre organisation disque (supprimer les :: pour activer les modifs et supprimer les anciens équivalents)
MODIF 31/01/2018 - 11:28:08 mise en application des adaptations ajoutées la veille : suppression des :: et mise en :: des anciennes instructions
BUG 05/02/2018 - 10:46:41 rajoute un tri dédoublonné sur la date
BUG 16/02/2018 - 14:25:51 élimine la répétition de la ligne d'en-tête dans les données à tracer
MODIF 20/02/2018 - 16:37:34 change l'invocation de la génération de page web de manière à prendre des infos dans le ficier de seuil
MODIF 20/02/2018 - 17:22:20 transmet également la date concernée lors de la génératon de page web
MODIF 22/03/2018 - 17:19:31 déplace les données produites vers le dossier quipo qui sert de repository web
MODIF 23/03/2018 - 13:28:43 vérifie que le dossier en cours a bien été déplacé et lance le transfert vers le repository
MODIF 29/03/2018 - 15:54:01 génère un index pour les webresources et met le dossier à jour dans le repository
MODIF 29/03/2018 - 16:38:56 renomme le whatsnews.txt en *.log afin de ne pas l'auto-référencer
BUG   05/04/2018 - 16:54:21 corrige un commentaire mal défini qui créait des dossiers vides inutiles
MODIF 20/04/2018 - 14:12:45 sauvegarde les données servant à élaborer les stats
MODIF 12/10/2018 - 11:26:59 génère la page de suivi du matériel expédié sur les projets
MODIF 26/10/2018 - 15:46:53 remplace la modif précédente par l'actualisation des données XML de la page de visu des projets
MODIF 16/11/2018 -  9:55:21 Rajout de l'invocation à la màj des données brutes, qui était jusqu'ici lancée manuellement au préalable donc souvent oubliée
BUG   29/11/2018 - 11:37:31 Restauration de l'invocation de ISstatloop qui avait sauté lors de la modif précédente 
MODIF 03/12/2018 - 11:13:14 génère les données de suivi du stock Alturing
MODIF 18/01/2019 - 15:25:26 adaptation au contexte d'un nouveau poste de travail : changement des dossiers utilisateur et d'installation de certains programmes
MODIF 14:31 mardi 22 janvier 2019 le code de génération des graphiques a été remplacé par un sous-programme externe
MODIF 17:21 mercredi 30 octobre 2019 renomme en quipo\dateindex.html l'ancien index.html
MODIF 17:21 mercredi 30 octobre 2019 utilise à la place une page de menu qui reste fixe 
                                                     et s'actualise en prenant les données variables dans un fichier xml externe
BUG     13:18 lundi 4 novembre 2019 le fichier XML externe en question n'était pas généré au bon endroit
MODIF  12:19 28/02/2020 intègre la génération de nouvelles stats qui étaient auparavant lancées individuellement


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

REM actualisation des données brutes
call "%isdir%\bin\exportIS.cmd"

REM génération des stats - certains de ces scripts ouvrent une image et un fichier texte afin d'y procéder à des annotations.
pushd "%isdir%\Data"
REM Incidents de production I&S
Call ..\bin\IncProdIS.cmd
REM Ventilation neuff/reconditionné
Call ..\bin\VentileNR.cmd
REM Age des produits déstockés
Call ..\bin\AgeStock.cmd
REM Durée de vie des produits en stock
Call ..\bin\VieStock.cmd
REM Coûts de stockage
Call ..\bin\CoutStock.cmd

REM mise en forme des donnée brutes dans le format de traitement
call "%isdir%\bin\ISstatloop.cmd"

REM génération préalable des fichiers de stats des familles de produits chez I&S
pushd "%isdir%\StatsIS"

REM agrège les deux stats en un seul fichier
paste -d; is-out.csv is-stock.csv is-seuil.csv >is-data.csv
REM ATTENTION 1 ceci n'est possible que parce que les deux fichiers ont le même nombre de lignes, dans le même ordre. Sinon il faut trier puis utiliser join
REM ATTENTION on se retrouve avec une colonne de titre en trop au milieu du fichier, à prendre en compte lors de la création du graphique

    
:sorties
head -1 is-data.csv |sed "s/.*_\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)\..*/\1-\2-\3/" >%temp%\moisfin.tmp
REM MODIF 11:08 mardi 17 mai 2016 utilise un format de date aaaa-mm-jj au lieu de mm/aaaa
set /p moisfin=<%temp%\moisfin.tmp

rd /s /q %moisfin% 2>nul

md %moisfin% 2>nul
REM dossier ^^ où seront stockées les fichiers créés

del %temp%\moisdeb.tmp 2>nul

REM set gnuplot=%programfiles%\gnuplot\bin\gnuplot.exe  
set gnuplot=%userprofile%\bin\gnuplot\bin\gnuplot.exe  

REM @echo on

for /F "delims=;" %%I in (.\is-data.csv) do call ..\bin\plotloop.cmd %%I
rem 14:31 mardi 22 janvier 2019 le code de génération des graphiques a été remplacé par un sous-programme externe

wc -l is-seuil.csv >%temp%\wc-l.txt
set /p nblgn=<%temp%\wc-l.txt
set /a nblgn=nblgn-2
REM élimination ^^ des deux dernières lignes, qui ne correspondent pas à de vrais produits
rem head -%nblgn% is-seuil.csv |gawk -f genHTMLindex.awk -v statdate="%moisfin%" >index.html
REM Nouvelle formulation du 15:05 06/12/2016 car les lignes à éliminer ne sont plus les dernières
rem mais sont les seules à contenir "matériel"

pushd ..\bin
rem repositionnemnt nécessaire sans quoi le script awk ne trouve pas le module à inclure
cat ..\StatsIS\is-seuil.csv |grep -v riel |gawk -f ..\bin\genHTMLindex.awk -v statdate="%moisfin%" >..\StatsIS\index.html
popd
md webresources 2>nul
:: ^^ crée le dossier webresources s'il a disparu entre temps
cat is-seuil.csv |grep -v riel |gawk -f ..\bin\genressourcesindex.awk >webresources\index.html
REM génération de la page d'en-tête pour toutes les familles suivies

move index.html %moisfin%
REM déplacement de l'état du stock alturing dans un dossier ad hoc

REM génère la page de suivi du matériel expédié sur les projets
REM call ..\bin\projexped.cmd
REM move ..\work\projexped.html %moisfin%


REM Actualise la page de suivi des projets
REM call ..\bin\projets.cmd
REM xcopy /y ..\work\projexped.xml  ..\StatsIS\quipo\projets

REM génère les données de suivi du stock Alturing
call ..\bin\cataltstock.cmd
xcopy /y ..\work\stockfamille.xml  ..\StatsIS\quipo\stockalt

REM génère les données de bénéficiairss d'uc
REM call ..\bin\SNxCC.cmd ..\work\is_out_all.csv
REM xcopy /y ..\work\snxcc.xml  ..\StatsIS\quipo\snxcc\fichier.xml

rem cet état a été généré dans isstatloop
move alt-*.csv %moisfin%

@echo on
REM mise à jour des webresources
pushd "%isdir%\StatsIS\webresources"
md data 2>nul
xcopy /m /y ..\*.* .\data\*.*
cd data
rem del quipoput.log 2>nul
for %%I in (*.*) do if %%~zI==0 (
msg /w %username% "le fichier %%I a une taille nulle"
dir %%I
pause
)
cd ..
REM ^^ sauvegarde des données servant à élaborer les stats
xcopy /s /c /h /e /m /y *.* ..\quipo\webresources\*.* 

popd
rem @echo off

set web=%userprofile%\Dropbox\EasyPHP-DevServer-14.1VC11\data\localweb\StatsIS
REM move /y %moisfin% %web%
rd /s /q "%web%\%moisfin%" 2>nul
@echo Vérifier et corriger les commentaires texte dans le dossier %moisfin%
msg %username% Vérifier et corriger les commentaires texte dans le dossier %moisfin%
REM MODIF 10:57 lundi 29 août 2016 implémentation de la vérification manuelle des commentaires textuels
REM @echo on
pushd %moisfin%
for %%I in (*.txt *.png) do start %%I
pause
xcopy /y /I . "%web%\%moisfin%"
xcopy *.txt .. /y
popd

rem déplacement des données produites vers le dossier web
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
@echo Libérer le dossier "%cd%\%moisfin%" >>%temp%\erreur.txt
cat %temp%\erreur.txt |msg /W %username% 
pause
goto :movedata
:genindex
pushd "%isdir%\bin"
rem génération de l'index des stats précédentes, pour consultation de l'historique
rem repositionnemnt nécessaire sans quoi le script awk ne trouve pas le module à inclure
dir  ..\StatsIS\quipo |gawk -f genDateIndex.awk >..\StatsIS\quipo\dateindex.html
REM simple liste des dates triée par ordre décroissant

rem génération du fichier xml servant à mettre à jour les données variables dans le nouveau système de menus
dir ..\StatsIS\quipo|gawk -v OFS=";" 'BEGIN {print "date" OFS "dossier"} $4 ~ /[0-9]{4}-[0-9]{2}-[0-9]{2}/ {split($4,tdate,"-");print tdate[3] "-" tdate[2] "-" tdate[1] OFS $4}' |usort -t; -k2 -r  |gawk -f csv2xml.awk > ..\StatsIS\quipo\data.xml

popd
:quipoput
call ..\bin\quipoput.cmd
@echo on
if exist %moisfin%\nul @echo Libérer le dossier "%cd%\%moisfin%"

REM élaboration de la liste des nouveautés pour le mail de reporting
@echo Modifications du %date% >> whatsnew.log
for /F "tokens=4" %%I in ('dir  /o *.txt ^|find "%date%"') do cat %%I >>whatsnew.log
"C:\Program Files\Notepad++\notepad++.exe" whatsnew.log
popd
