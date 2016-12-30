::creestats.cmd
::12/05/2016 11:41:59,27
::crée les stats de suivi I&S

call ISstatloop.cmd
REM génération préalable des fichiers de stats des familles de produits chez I&S

REM agrège les deux stats en un seul fichier
paste -d; is-out.csv is-stock.csv is-seuil.csv >is-data.csv
REM ATTENTION 1 ceci n'est possible que parce que les deux fichiers ont le même nombre de lignes, dans le même ordre. Sinon il faut trier puis utiliser join
REM ATTENTION on se retrouve avec une colonne de titre en trop au milieu du fichier, à prendre en compte lors de la création du graphique
REM MODIF 16:21 jeudi 19 mai 2016 ajoute aussi le seuil d'alerte
REM MODIF 10:47 lundi 30 mai 2016 déplace les fichiers générés vers le dossier web correspondant
REM MODIF 10:57 lundi 29 août 2016 implémentation de la vérification manuelle des commentaires textuels
REM BUG 11:04 mardi 6 décembre 2016 n'extrait la borne de date inférieure que si elle a un format valide
REM BUG ^^ 11:37 mardi 6 décembre 2016 élimination des \ dans la ligne d'en-tête, dont la présence perturbe genericplot
  REM BUG 12:19 vendredi 30 décembre 2016 réécrit au format aaaa-mm-jj les dates éventuellement écrites au format jj/mm/aa
  REM ce qui peut arriver si on manipule le csv avec un tableur

:sorties
head -1 is-data.csv |ssed "s/.*_\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)\..*/\1-\2-\3/" >%temp%\moisfin.tmp
REM MODIF 11:08 mardi 17 mai 2016 utilise un format de date aaaa-mm-jj au lieu de mm/aaaa
set /p moisfin=<%temp%\moisfin.tmp

rd /s /q %moisfin% 2>nul
md %moisfin%
REM dossier ^^ où seront stockées les fichiers créés

del %temp%\moisdeb.tmp 2>nul

for /F "delims=;" %%I in (is-data.csv) do if exist %%I.csv (
REM Construit pour chaque famille de produit les fichiers de données pour alimenter gnuplot
  head -1 %%I.csv |ssed -e "s/;/\t/g" -e "s/\\/-/g" > %%I.tab
  REM BUG ^^ 11:37 mardi 6 décembre 2016 élimination des \ dans la ligne d'en-tête, dont la présence perturbe genericplot
  REM en-tête ^^

  REM cat %%I.csv |grep -v "%moisfin:~0,-3%" |tail -13 |ssed "s/;/\t/g" >> %%I.tab
  REM élimination ^^ de l'occurence précédente pour le moisfin en cours et conservation des 12 mois précédents
  REM cat %%I.csv |ssed -e "/%moisfin:~0,-3%/d" -e "s/;/\t/g" |tail -13 >> %%I.tab
  cat %%I.csv |ssed -e "s/\([0-9][0-9]\)\/\([0-9][0-9]\)\/\([0-9][0-9][0-9][0-9]\)/\3-\2-\1/" -e "/%moisfin:~0,-3%/d" -e "s/;/\t/g" |tail -13 >> %%I.tab
  REM Maintenant que la date ne contient plus de "/" c'est plus simple et plus rapide de ne plus utiliser grep
  REM BUG 12:19 vendredi 30 décembre 2016 réécrit au format aaaa-mm-jj les dates éventuellement écrites au format jj/mm/aa
  REM ce qui peut arriver si on manipule le csv avec un tableur
  
  gawk -F; -v OFS="\t" "{if (sub(/%%I/,\"%moisfin%\",$1)) print}" is-data.csv >> %%I.tab
  REM Rajout de l'occurence actuelle pour le moisfin en cours

  REM Reconstitue un csv à jour
  cat %%I.csv |grep -v "%moisfin:~0,-3%" >%%I.tmp
  ssed -n "s/^%%I/%moisfin%/p" is-data.csv >>%%I.tmp

  move /y %%I.csv %%I.bak.csv
  move /y %%I.tmp %%I.csv

  
  if not exist %temp%\moisdeb.tmp gawk -F\t "{if (NR==2) if ($1 ~/[0-9]{4}-[0-9]{2}-[0-9]{2}/) print $1}" %%I.tab >%temp%\moisdeb.tmp
  REM ^^ BUG 11:04 mardi 6 décembre 2016 n'extrait la borne de date inférieure que si elle a un format valide

  set /p moisdeb=<%temp%\moisdeb.tmp
  REM détermination de la borne temporelle inférieure pour le graphique
  
  gnuplot  -c genericplot.plt %%I.tab %moisdeb% %moisfin%
  REM Crée le graphique
  
  gawk -f genHTMLlink.awk %%I.png >%%I.htm
  REM génération de la page web affichant le graphique
  move %%I.* "%moisfin%"
  copy "%moisfin%\%%I.txt" .
  copy "%moisfin%\%%I.csv" .
  REM move %%I.htm "%moisfin%"
)
wc -l is-seuil.csv >%temp%\wc-l.txt
set /p nblgn=<%temp%\wc-l.txt
set /a nblgn=nblgn-2
REM élimination ^^ des deux dernières lignes, qui ne correspondent pas à de vrais produits
rem head -%nblgn% is-seuil.csv |gawk -f genHTMLindex.awk -v statdate="%moisfin%" >index.html
REM Nouvelle formulation du 15:05 06/12/2016 car les lignes à éliminer ne sont plus les dernières
rem mais sont les seules à contenir "matériel"
cat is-seuil.csv |grep -v riel |gawk -f genHTMLindex.awk -v statdate="%moisfin%" >index.html
REM génération de la page d'en-tête pour toutes les familles suivies

move index.html %moisfin%

set web=C:\Users\admin\Dropbox\EasyPHP-DevServer-14.1VC11\data\localweb\StatsIS
REM move /y %moisfin% %web%
rd /s /q "%web%\%moisfin%" 2>nul
@echo Vérifier et corriger les commentaires texte dans le dossier %moisfin%
msg %username% Vérifier et corriger les commentaires texte dans le dossier %moisfin%
REM MODIF 10:57 lundi 29 août 2016 implémentation de la vérification manuelle des commentaires textuels
@echo on
pushd %moisfin%
for %%I in (*.txt *.png) do start %%I
pause
xcopy /y /I . "%web%\%moisfin%"
xcopy *.txt .. /y
popd
REM élaboration de la liste des nouveautés pour le mail de reporting
@echo Modifications du %date% >> whatsnew.txt
for /F "tokens=4" %%I in ('dir  /o *.txt ^|find "%date%"') do cat %%I >>whatsnew.txt
whatsnew.txt