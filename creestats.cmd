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
BUG   13:18 lundi 4 novembre 2019 le fichier XML externe en question n'était pas généré au bon endroit
MODIF 12:19 28/02/2020 intègre la génération de nouvelles stats qui étaient auparavant lancées individuellement
MODIF 12:04 13/10/2020 remplace l'ancien système de génération des graphiques avec gawk par une extraction sqlite
                       entraine la disparition de sections désormais inutiles
MODIF 10:04 15/10/2020 diffère la màj du quipo lors de l'invocation de exportis afin de ne pas l'effectuer deux fois
MODIF 11:34 23/10/2020 journalise l'actualité des stats sous format csv
BUG   11:01 02/11/2020 rajoute l'en-tête lors de l'extration qui permet de générer la page d'index, faute de quoi le premier item n'était pas indexé
BUG   11:46 20/11/2020 Lors de leur copie, les données web étaient concaténées en un seul fichier au lieu d'être poussées dans un répertoire
BUG   10:15 04/12/2020 Le bug précedent n'était pas encore totalement résolu, la cause se trouvant dans plotloopnew
MODIF 14:17 06/01/2021 plotloopnew.cmd renommé en plotloop.cmd
MODIF 14:19 06/01/2021 ventileNR.cmd désormais lancé au niveau de l'exportIS.cmd
MODIF 13:16 11/01/2021 vieStock.cmd désormais lancé au niveau de l'exportIS.cmd
MODIF 18:00 11/01/2021 complément à la génération des pages de stats par famille de produit (SFP) avec l'ajout d'un filtre sur le statut d'activité de chaque famille de produit
MODIF 11:34 29/01/2021 Désactivation de l'appel à incprodis.cmd cette stat étant désormais obsolète (remplacée par escalis.cmd)
BUG   22:34 05/02/2021 coutstock.cmd et statstock.cmd sont déportées de exportis.cmd vers creestat.cmd car, longues à exécuter, elles verrouillent les màj de la bdd et donc perturbent la génération des stats si elles sont lancées ici
MODIF 14:56 26/03/2021 Copie des dernières stats dans un dossier dédié et fixé en plus d'un dossier lié à la date
MODIF 18:11 26/03/2021 Désactivation de l'invocation de coutstock et statstock désormais lancées via le planificateur de tâches
MODIF 11:12 16/04/2021 gère un signal de verrouillage afin d'éviter que d'autres scripts essaient d'écrire dessus en même temps
MODIF 09:55 10/05/2021 place la log des stats dans le dossier de sqlite afin de l'intégrer à la BDD
MODIF 14:58 18/06/2021 met à jour les graphiques dans la BDD après leur vérification au lieu de le faire dès leur génération comme précédemment
BUG   17:24 18/06/2021 une faute d'orthographe empêchait la mise à jour de la log de l'historique des faits marquants
MODIF 11:32 21/06/2021 désactivation de la gestion en ajax de la liste des faits marquants

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
REM goto sorties
:: on saute temporairement les sections non modifiées, pour debug seulement

REM actualisation des données brutes
touch %temp%\differe.maj
:: ^^ pour qu'exportIS n'embraye pas sur la mise à jour du quipo
call "%isdir%\bin\exportIS.cmd"

REM génération des stats - certains de ces scripts ouvrent une image et un fichier texte afin d'y procéder à des annotations.
pushd "%isdir%\Data"
REM @echo Incidents de production I^&S
REM Call ..\bin\IncProdIS.cmd
REM echo Ventilation neuff/reconditionné
REM Call ..\bin\VentileNR.cmd
REM echo Age des produits déstockés
REM Call ..\bin\AgeStock.cmd
REM echo Durée de vie des produits en stock
REM Call ..\bin\VieStock.cmd
REM echo Coûts de stockage
REM Call ..\bin\CoutStock.cmd
:: inviqué ici cela bloque le script pendant longtemps donc il est déplacé plus loin après la génération des stats afin de s'exécuter pendant la pause où on les vérifie

:sorties
REM mise en forme des donnée brutes dans le format de traitement
:: call "%isdir%\bin\ISstatloop.cmd"
rem inutile ^^ depuis la MODIF 12:04 13/10/2020

REM génération préalable des fichiers de stats des familles de produits chez I&S
pushd "%isdir%\StatsIS"

REM agrège les deux stats en un seul fichier
:: paste -d; is-out.csv is-stock.csv is-seuil.csv >is-data.csv
rem inutile ^^ depuis la MODIF 12:04 13/10/2020
REM ATTENTION 1 ceci n'est possible que parce que les deux fichiers ont le même nombre de lignes, dans le même ordre. Sinon il faut trier puis utiliser join
REM ATTENTION on se retrouve avec une colonne de titre en trop au milieu du fichier, à prendre en compte lors de la création du graphique

    
:: head -1 is-data.csv |sed "s/.*_\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)\..*/\1-\2-\3/" >%temp%\moisfin.tmp
REM MODIF 11:08 mardi 17 mai 2016 utilise un format de date aaaa-mm-jj au lieu de mm/aaaa

REM nouvelle formulation suite à MODIF 12:04 13/10/2020
sqlite3 ..\Data\sandbox.db "select dateimport from  v_teexport limit 1;"  >%temp%\moisfin.tmp
set /p moisfin=<%temp%\moisfin.tmp

rd /s /q %moisfin% 2>nul

md %moisfin% 2>nul
REM dossier ^^ où seront stockées les fichiers créés

del %temp%\moisdeb.tmp 2>nul

REM set gnuplot=%programfiles%\gnuplot\bin\gnuplot.exe  
set gnuplot=%userprofile%\bin\gnuplot\bin\gnuplot.exe  

REM @echo on

rem for /F "delims=;" %%I in (.\is-data.csv) do call ..\bin\plotloop.cmd %%I
rem rem 14:31 mardi 22 janvier 2019 le code de génération des graphiques a été remplacé par un sous-programme externe
rem remplacé par MODIF 12:06 13/10/2020 par un nouveau système qui utilise sqlite en one shot et non plus dans une boucle
echo génération des stats par produit
:testblocage
if exist %temp%\bdd.maj (
set /p blocagebdd=<%temp%\bdd.maj
for %%I in ("%temp%\bdd.maj") do msg /w %username% "Un signal de blocage a été émis à %%~tI par %blocagebdd%"
pause
)
if exist %temp%\bdd.maj goto testblocage
@echo %0 > %temp%\bdd.maj
:: ^^ pour prévenir qu'il faut attendre que la bdd soit libérée avant de pouvoir écrire dessus
:: géré ici plutôt que dans plotloop afin de bloquer la base pendant toute la durée de màj de toutes les stats
call ..\bin\plotloop.cmd
del %temp%\bdd.maj

:: lève le blocage de la bdd

REM tout ce qui concerne nblgn est détecté comme étant inutile lors de la MODIF 12:06 13/10/2020
REM wc -l is-seuil.csv >%temp%\wc-l.txt
REM set /p nblgn=<%temp%\wc-l.txt
REM set /a nblgn=nblgn-2
REM élimination ^^ des deux dernières lignes, qui ne correspondent pas à de vrais produits
rem head -%nblgn% is-seuil.csv |gawk -f genHTMLindex.awk -v statdate="%moisfin%" >index.html
REM Nouvelle formulation du 15:05 06/12/2016 car les lignes à éliminer ne sont plus les dernières
rem mais sont les seules à contenir "matériel"

pushd ..\bin
rem repositionnemnt nécessaire sans quoi le script awk ne trouve pas le module à inclure
:: cat ..\StatsIS\is-seuil.csv |grep -v riel |gawk -f ..\bin\genHTMLindex.awk -v statdate="%moisfin%" >..\StatsIS\index.html
REM nouvelle formulation suite à MODIF 12:04 13/10/2020
sqlite3 -separator ; -header ..\data\sandbox.db "SELECT Codestat , Seuil , Libstat FROM sfpliste WHERE Active='Oui';" |gawk -f ..\bin\genHTMLindex.awk -v statdate="%moisfin%" >..\StatsIS\index.html
popd
md webresources 2>nul
:: ^^ crée le dossier webresources s'il a disparu entre temps
:: cat is-seuil.csv |grep -v riel |gawk -f ..\bin\genressourcesindex.awk >webresources\index.html
REM nouvelle formulation suite à MODIF 12:04 13/10/2020
sqlite3 -separator ; -header ..\data\sandbox.db "SELECT Codestat , Seuil , Libstat FROM sfpliste WHERE Active='Oui';" |gawk -f ..\bin\genressourcesindex.awk >webresources\index.html
REM génération de la page d'en-tête pour toutes les familles suivies

move /y index.html %moisfin%

REM @echo index mis dans %moisfin%
REM pause

REM déplacement de l'état du stock alturing dans un dossier ad hoc

REM génère la page de suivi du matériel expédié sur les projets
REM call ..\bin\projexped.cmd
REM move ..\work\projexped.html %moisfin%


REM Actualise la page de suivi des projets
REM call ..\bin\projets.cmd
REM xcopy /y ..\work\projexped.xml  ..\StatsIS\quipo\projets

echo génère les données de suivi du stock Alturing
    call ..\bin\cataltstock.cmd
xcopy /y ..\work\stockfamille.xml  ..\StatsIS\quipo\stockalt

REM génère les données de bénéficiairss d'uc
REM call ..\bin\SNxCC.cmd ..\work\is_out_all.csv
REM xcopy /y ..\work\snxcc.xml  ..\StatsIS\quipo\snxcc\fichier.xml

rem cet état a été généré dans isstatloop
md "%isdir%\StatsIS\quipo\%moisfin%"
move alt-*.csv %moisfin%

@echo on
REM @echo REM mise à jour des webresources
pushd "%isdir%\StatsIS\webresources"
md data 2>nul
xcopy /m /y ..\*.* .\data\*.*
cd data
REM @echo vérif taille nulle
REM pause
@echo off
rem del quipoput.log 2>nul
for %%I in (*.*) do if %%~zI==0 (
msg /w %username% "le fichier %%I a une taille nulle"
dir %%I
pause
)
REM @echo taille nulle ok
REM pause
REM @echo on
cd ..
REM @echo REM ^^ sauvegarde des données servant à élaborer les stats
xcopy /s /c /h /e /m /y *.* ..\quipo\webresources\*.* 
REM pause
popd
rem @echo off

:: placée ici car longue à établir donc pas gênant de le faire pendant qu'on vérifie et corrige les commentaires de la stat précédente
REM call ..\bin\StatStock.cmd reporté maintenant au niveau de l'exportis
REM @echo Calcul du coût de stockage cumulé des articles en stock
REM start /ABOVENORMAL "coût de stockage hebdomadaire des articles en stock" CMD.EXE /C ..\bin\CoutStock.cmd
:: utilisation d'un start afin de ne pas bloquer le script appelant par l'exécution du script appelé qui est très longue
:: invocation via un cmd /c car sinon ça se comporte comme un cmd /k donc sans fermeture de la fenêtre de commande ouverte à l'occasion
:: le résultat ne sera pas donné avant la fin d'exécution de ce script mais c'est pas grave ce sera actualisé au prochain passage
:: se termine une quarantaine de secondes après l'exécution du script appelant

REM @echo stat de suivi de l'état du matériel en stock
REM :: utilisation d'un start afin de ne pas bloquer le script appelant par l'exécution du script appelé qui est très longue
REM start /ABOVENORMAL  "suivi de l'état du matériel en stock" CMD.EXE /C  ..\bin\StatStock.cmd
:: se termine une vingtaine de secondes après l'exécution du script appelant



set web=%userprofile%\Dropbox\EasyPHP-DevServer-14.1VC11\data\localweb\StatsIS
REM move /y %moisfin% %web%
rd /s /q "%web%\%moisfin%" 2>nul
@echo Vérifier et corriger les commentaires texte dans le dossier %moisfin%
msg %username% Vérifier et corriger les commentaires texte dans le dossier %moisfin%
REM MODIF 10:57 lundi 29 août 2016 implémentation de la vérification manuelle des commentaires textuels

pushd %moisfin%
REM 12:11 18/06/2021 nouvelle formulation pour exclure les minitextes de titre et de description
REM for %%I in (*.txt *.png) do start %%I
for %%I in (*.png) do start %%I
for /f %%I in ('dir /b *.txt ^|find /v "_"') do start %%I
pause
xcopy /y /I . "%web%\%moisfin%\*.*"
xcopy *.txt .. /y
popd

rem déplacement des données produites vers le dossier web
:movedata
@echo on
del %temp%\erreur.txt 2>nul
pushd "%isdir%\StatsIS\%moisfin%"
md ..\quipo\%moisfin% 2>%temp%\erreur.txt
md ..\quipo\DernierEtat 2>nul
xcopy /y *.* ..\quipo\DernierEtat
:: copie ^^ dans le dossier de référence
move  /y *.* ..\quipo\%moisfin% 2>>%temp%\erreur.txt
@echo %moisfin%> ..\quipo\DernierEtat\datemaj.txt
rem mise-à-jour des graphiques dans la bdd
REM Attention, ne prend pas en compte un éventuel ajout de nouveau code de stat, qui devra être fait à la main
cd ..\quipo\SQLite
REM sqlite3 quipo.db ".tables"
REM pause
sqlite3 quipo.db "update SFPFluxStock set image=readfile('../DernierEtat/' || code || '.png'),    Designation=readfile('../DernierEtat/' || code || '_Designation.txt'),    Commentaire=readfile('../DernierEtat/' || code || '_Commentaire.txt'),    Mise_a_jour=readfile('../DernierEtat/datemaj.txt');"
REM pause
popd
rd %moisfin%
REM pause
if not exist %temp%\erreur.txt goto :genindex
if exist quipo\%moisfin%\nul goto :genindex
@echo Libérer le dossier "%cd%\%moisfin%" >>%temp%\erreur.txt
cat %temp%\erreur.txt |msg /W %username% 

goto :movedata
:genindex
pushd "%isdir%\bin"
rem génération de l'index des stats précédentes, pour consultation de l'historique
rem repositionnemnt nécessaire sans quoi le script awk ne trouve pas le module à inclure
dir  ..\StatsIS\quipo |gawk -f genDateIndex.awk >..\StatsIS\quipo\dateindex.html
REM simple liste des dates triée par ordre décroissant

rem génération du fichier xml servant à mettre à jour les données variables dans le nouveau système de menus
rem inutile depuis le passage sous sqlite
REM dir ..\StatsIS\quipo|gawk -v OFS=";" 'BEGIN {print "date" OFS "dossier"} $4 ~ /[0-9]{4}-[0-9]{2}-[0-9]{2}/ {split($4,tdate,"-");print tdate[3] "-" tdate[2] "-" tdate[1] OFS $4}' |usort -t; -k2 -r  |gawk -f csv2xml.awk > ..\StatsIS\quipo\data.xml

popd
:quipoput

REM élaboration de la liste des nouveautés pour le mail de reporting
REM pause
REM @echo on
@echo Modifications du %date% >> whatsnew.log
del sfpListe.txt 2>nul
:: ^^ fichier non signigficatif pour la log
for /F "tokens=4" %%I in ('dir  /o *.txt ^|find /v "_" ^|find "%date%"') do cat %%I >>whatsnew.log
sed -i "/^%moisfin%/d" SFPlog.csv
for /F "tokens=4" %%I in ('dir  /o *.txt ^|find /v "_" ^|find "%date%"') do gawk -v datestat=%moisfin% -f ..\bin\TXT2CSV.awk %%I >> "%isdir%\StatsIS\quipo\SQLite\SFPlog.csv"
REM gawk -f ..\bin\csv2xml.awk "%sidir%\StatsIS\quipo\SQLite\SFPlog.csv" > fichier.xml
REM convertcp 65001 28591 /i fichier.xml /o quipo\SFPlog\fichier.xml
:: ^^ fichier.xml inutile depuis que la log est gérée sous sqlite
:: traduit les accents de manière à ce qu'ils soient lisibles puis place le fichier à son emplacement de publication
@echo %moisfin%>quipo\SFPlog\date.txt
:: ^^ produit une log au format xml pour affichage en ajax
REM pause

del %temp%\differe.maj 2>nul
:: désactive ^^ l'inhibition du quipo éventuellement établie
call ..\bin\quipoput.cmd
@echo on
if exist %moisfin%\nul @echo Libérer le dossier "%cd%\%moisfin%"


"C:\Program Files\Notepad++\notepad++.exe" whatsnew.log
popd
popd
