::creestats.cmd
::12/05/2016 11:41:59,27
::cr�e les stats de suivi I&S
REM @echo off
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
MODIF 20/04/2018 - 14:12:45 sauvegarde les donn�es servant � �laborer les stats
MODIF 12/10/2018 - 11:26:59 g�n�re la page de suivi du mat�riel exp�di� sur les projets
MODIF 26/10/2018 - 15:46:53 remplace la modif pr�c�dente par l'actualisation des donn�es XML de la page de visu des projets
MODIF 16/11/2018 -  9:55:21 Rajout de l'invocation � la m�j des donn�es brutes, qui �tait jusqu'ici lanc�e manuellement au pr�alable donc souvent oubli�e
BUG   29/11/2018 - 11:37:31 Restauration de l'invocation de ISstatloop qui avait saut� lors de la modif pr�c�dente 
MODIF 03/12/2018 - 11:13:14 g�n�re les donn�es de suivi du stock Alturing
MODIF 18/01/2019 - 15:25:26 adaptation au contexte d'un nouveau poste de travail : changement des dossiers utilisateur et d'installation de certains programmes
MODIF 14:31 mardi 22 janvier 2019 le code de g�n�ration des graphiques a �t� remplac� par un sous-programme externe
MODIF 17:21 mercredi 30 octobre 2019 renomme en quipo\dateindex.html l'ancien index.html
MODIF 17:21 mercredi 30 octobre 2019 utilise � la place une page de menu qui reste fixe 
                                                     et s'actualise en prenant les donn�es variables dans un fichier xml externe
BUG   13:18 lundi 4 novembre 2019 le fichier XML externe en question n'�tait pas g�n�r� au bon endroit
MODIF 12:19 28/02/2020 int�gre la g�n�ration de nouvelles stats qui �taient auparavant lanc�es individuellement
MODIF 12:04 13/10/2020 remplace l'ancien syst�me de g�n�ration des graphiques avec gawk par une extraction sqlite
                       entraine la disparition de sections d�sormais inutiles
MODIF 10:04 15/10/2020 diff�re la m�j du quipo lors de l'invocation de exportis afin de ne pas l'effectuer deux fois
MODIF 11:34 23/10/2020 journalise l'actualit� des stats sous format csv
BUG   11:01 02/11/2020 rajoute l'en-t�te lors de l'extration qui permet de g�n�rer la page d'index, faute de quoi le premier item n'�tait pas index�
BUG   11:46 20/11/2020 Lors de leur copie, les donn�es web �taient concat�n�es en un seul fichier au lieu d'�tre pouss�es dans un r�pertoire
BUG   10:15 04/12/2020 Le bug pr�cedent n'�tait pas encore totalement r�solu, la cause se trouvant dans plotloopnew
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
:: on saute temporairement les sections non modifi�es, pour debug seulement

REM actualisation des donn�es brutes
touch %temp%\differe.maj
:: ^^ pour qu'exportIS n'embraye pas sur la mise � jour du quipo
call "%isdir%\bin\exportIS.cmd"

REM g�n�ration des stats - certains de ces scripts ouvrent une image et un fichier texte afin d'y proc�der � des annotations.
pushd "%isdir%\Data"
@echo Incidents de production I^&S
Call ..\bin\IncProdIS.cmd
echo Ventilation neuff/reconditionn�
Call ..\bin\VentileNR.cmd
echo Age des produits d�stock�s
Call ..\bin\AgeStock.cmd
echo Dur�e de vie des produits en stock
Call ..\bin\VieStock.cmd
echo Co�ts de stockage
Call ..\bin\CoutStock.cmd

:sorties
REM mise en forme des donn�e brutes dans le format de traitement
:: call "%isdir%\bin\ISstatloop.cmd"
rem inutile ^^ depuis la MODIF 12:04 13/10/2020

REM g�n�ration pr�alable des fichiers de stats des familles de produits chez I&S
pushd "%isdir%\StatsIS"

REM agr�ge les deux stats en un seul fichier
:: paste -d; is-out.csv is-stock.csv is-seuil.csv >is-data.csv
rem inutile ^^ depuis la MODIF 12:04 13/10/2020
REM ATTENTION 1 ceci n'est possible que parce que les deux fichiers ont le m�me nombre de lignes, dans le m�me ordre. Sinon il faut trier puis utiliser join
REM ATTENTION on se retrouve avec une colonne de titre en trop au milieu du fichier, � prendre en compte lors de la cr�ation du graphique

    
:: head -1 is-data.csv |sed "s/.*_\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)\..*/\1-\2-\3/" >%temp%\moisfin.tmp
REM MODIF 11:08 mardi 17 mai 2016 utilise un format de date aaaa-mm-jj au lieu de mm/aaaa

REM nouvelle formulation suite � MODIF 12:04 13/10/2020
sqlite3 ..\Data\sandbox.db "select dateimport from  v_teexport limit 1;"  >%temp%\moisfin.tmp
set /p moisfin=<%temp%\moisfin.tmp

rd /s /q %moisfin% 2>nul

md %moisfin% 2>nul
REM dossier ^^ o� seront stock�es les fichiers cr��s

del %temp%\moisdeb.tmp 2>nul

REM set gnuplot=%programfiles%\gnuplot\bin\gnuplot.exe  
set gnuplot=%userprofile%\bin\gnuplot\bin\gnuplot.exe  

REM @echo on

rem for /F "delims=;" %%I in (.\is-data.csv) do call ..\bin\plotloop.cmd %%I
rem rem 14:31 mardi 22 janvier 2019 le code de g�n�ration des graphiques a �t� remplac� par un sous-programme externe
rem remplac� par MODIF 12:06 13/10/2020 par un nouveau syst�me qui utilise sqlite en one shot et non plus dans une boucle
echo g�n�ration des stats par produit
call ..\bin\plotloopnew.cmd

REM @echo plotloopnew fini
REM pause

REM tout ce qui concerne nblgn est d�tect� comme �tant inutile lors de la MODIF 12:06 13/10/2020
REM wc -l is-seuil.csv >%temp%\wc-l.txt
REM set /p nblgn=<%temp%\wc-l.txt
REM set /a nblgn=nblgn-2
REM �limination ^^ des deux derni�res lignes, qui ne correspondent pas � de vrais produits
rem head -%nblgn% is-seuil.csv |gawk -f genHTMLindex.awk -v statdate="%moisfin%" >index.html
REM Nouvelle formulation du 15:05 06/12/2016 car les lignes � �liminer ne sont plus les derni�res
rem mais sont les seules � contenir "mat�riel"

pushd ..\bin
rem repositionnemnt n�cessaire sans quoi le script awk ne trouve pas le module � inclure
:: cat ..\StatsIS\is-seuil.csv |grep -v riel |gawk -f ..\bin\genHTMLindex.awk -v statdate="%moisfin%" >..\StatsIS\index.html
REM nouvelle formulation suite � MODIF 12:04 13/10/2020
sqlite3 ..\data\sandbox.db ".separator ;" ".headers on" "select Codestat , Seuil , Libstat from sfpliste;" |gawk -f ..\bin\genHTMLindex.awk -v statdate="%moisfin%" >..\StatsIS\index.html
popd
md webresources 2>nul
:: ^^ cr�e le dossier webresources s'il a disparu entre temps
:: cat is-seuil.csv |grep -v riel |gawk -f ..\bin\genressourcesindex.awk >webresources\index.html
REM nouvelle formulation suite � MODIF 12:04 13/10/2020
sqlite3 ..\data\sandbox.db ".separator ;" "select Codestat , Seuil , Libstat from sfpliste;" |gawk -f ..\bin\genressourcesindex.awk >webresources\index.html
REM g�n�ration de la page d'en-t�te pour toutes les familles suivies

move /y index.html %moisfin%

REM @echo index mis dans %moisfin%
REM pause

REM d�placement de l'�tat du stock alturing dans un dossier ad hoc

REM g�n�re la page de suivi du mat�riel exp�di� sur les projets
REM call ..\bin\projexped.cmd
REM move ..\work\projexped.html %moisfin%


REM Actualise la page de suivi des projets
REM call ..\bin\projets.cmd
REM xcopy /y ..\work\projexped.xml  ..\StatsIS\quipo\projets

echo g�n�re les donn�es de suivi du stock Alturing
    call ..\bin\cataltstock.cmd
xcopy /y ..\work\stockfamille.xml  ..\StatsIS\quipo\stockalt

REM g�n�re les donn�es de b�n�ficiairss d'uc
REM call ..\bin\SNxCC.cmd ..\work\is_out_all.csv
REM xcopy /y ..\work\snxcc.xml  ..\StatsIS\quipo\snxcc\fichier.xml

rem cet �tat a �t� g�n�r� dans isstatloop
md "%isdir%\StatsIS\quipo\%moisfin%"
move alt-*.csv %moisfin%

@echo on
REM @echo REM mise � jour des webresources
pushd "%isdir%\StatsIS\webresources"
md data 2>nul
xcopy /m /y ..\*.* .\data\*.*
cd data
REM @echo v�rif taille nulle
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
REM @echo REM ^^ sauvegarde des donn�es servant � �laborer les stats
xcopy /s /c /h /e /m /y *.* ..\quipo\webresources\*.* 
REM pause
popd
rem @echo off

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
xcopy /y /I . "%web%\%moisfin%\*.*"
xcopy *.txt .. /y
popd

rem d�placement des donn�es produites vers le dossier web
:movedata
@echo on
del %temp%\erreur.txt 2>nul
pushd "%isdir%\StatsIS\%moisfin%"
md ..\quipo\%moisfin% 2>%temp%\erreur.txt
move /y *.* ..\quipo\%moisfin% 2>>%temp%\erreur.txt
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
dir  ..\StatsIS\quipo |gawk -f genDateIndex.awk >..\StatsIS\quipo\dateindex.html
REM simple liste des dates tri�e par ordre d�croissant

rem g�n�ration du fichier xml servant � mettre � jour les donn�es variables dans le nouveau syst�me de menus
dir ..\StatsIS\quipo|gawk -v OFS=";" 'BEGIN {print "date" OFS "dossier"} $4 ~ /[0-9]{4}-[0-9]{2}-[0-9]{2}/ {split($4,tdate,"-");print tdate[3] "-" tdate[2] "-" tdate[1] OFS $4}' |usort -t; -k2 -r  |gawk -f csv2xml.awk > ..\StatsIS\quipo\data.xml

popd
:quipoput

REM �laboration de la liste des nouveaut�s pour le mail de reporting
@echo Modifications du %date% >> whatsnew.log
for /F "tokens=4" %%I in ('dir  /o *.txt ^|find "%date%"') do cat %%I >>whatsnew.log
sed -i "/^%moisfin%/d" SFPlog.csv
for /F "tokens=4" %%I in ('dir  /o *.txt ^|find "%date%"') do gawk -v datestat=%moisfin% -f ..\bin\TXT2CSV.awk %%I >> SFPlog.csv
gawk -f ..\bin\csv2xml.awk SFPlog.csv > fichier.xml
convertcp 65001 28591 /i fichier.xml /o quipo\SFPlog\fichier.xml
:: traduit les accents de mani�re � ce qu'ils soient lisibles puis place le fichier � son emplacement de publication
@echo %moisfin%>quipo\SFPlog\date.txt
:: ^^ produit une log au format xml pour affichage en ajax

del %temp%\differe.maj 2>nul
:: d�sactive ^^ l'inhibition du quipo �ventuellement �tablie
call ..\bin\quipoput.cmd
@echo on
if exist %moisfin%\nul @echo Lib�rer le dossier "%cd%\%moisfin%"


"C:\Program Files\Notepad++\notepad++.exe" whatsnew.log
popd
