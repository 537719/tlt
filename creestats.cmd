::creestats.cmd
::12/05/2016 11:41:59,27
::cr�e les stats de suivi I&S

call ISstatloop.cmd
REM g�n�ration pr�alable des fichiers de stats des familles de produits chez I&S

REM agr�ge les deux stats en un seul fichier
paste -d; is-out.csv is-stock.csv is-seuil.csv >is-data.csv
REM ATTENTION 1 ceci n'est possible que parce que les deux fichiers ont le m�me nombre de lignes, dans le m�me ordre. Sinon il faut trier puis utiliser join
REM ATTENTION on se retrouve avec une colonne de titre en trop au milieu du fichier, � prendre en compte lors de la cr�ation du graphique
REM MODIF 16:21 jeudi 19 mai 2016 ajoute aussi le seuil d'alerte
REM MODIF 10:47 lundi 30 mai 2016 d�place les fichiers g�n�r�s vers le dossier web correspondant
REM MODIF 10:57 lundi 29 ao�t 2016 impl�mentation de la v�rification manuelle des commentaires textuels

:sorties
head -1 is-data.csv |ssed "s/.*_\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)\..*/\1-\2-\3/" >%temp%\moisfin.tmp
REM MODIF 11:08 mardi 17 mai 2016 utilise un format de date aaaa-mm-jj au lieu de mm/aaaa
set /p moisfin=<%temp%\moisfin.tmp

rd /s /q %moisfin% 2>nul
md %moisfin%
REM dossier ^^ o� seront stock�es les fichiers cr��s

for /F "delims=;" %%I in (is-data.csv) do if exist %%I.csv (
REM Construit pour chaque famille de produit les fichiers de donn�es pour alimenter gnuplot
  head -1 %%I.csv |ssed "s/;/\t/g" > %%I.tab
  REM en-t�te ^^

  REM cat %%I.csv |grep -v "%moisfin:~0,-3%" |tail -13 |ssed "s/;/\t/g" >> %%I.tab
  REM �limination ^^ de l'occurence pr�c�dente pour le moisfin en cours et conservation des 12 mois pr�c�dents
  cat %%I.csv |ssed -e "/%moisfin:~0,-3%/d" -e "s/;/\t/g" |tail -13 >> %%I.tab
  REM Maintenant que la date ne contient plus de "/" c'est plus simple et plus rapide de ne plus utiliser grep
  
  gawk -F; -v OFS="\t" "{if (sub(/%%I/,\"%moisfin%\",$1)) print}" is-data.csv >> %%I.tab
  REM Rajout de l'occurence actuelle pour le moisfin en cours

  REM Reconstitue un csv � jour
  cat %%I.csv |grep -v "%moisfin:~0,-3%" >%%I.tmp
  ssed -n "s/^%%I/%moisfin%/p" is-data.csv >>%%I.tmp

  move /y %%I.csv %%I.bak.csv
  move /y %%I.tmp %%I.csv

  
  gawk -F\t "{if (NR==2) print $1}" %%I.tab >%temp%\moisdeb.tmp
  set /p moisdeb=<%temp%\moisdeb.tmp
  REM d�termination de la borne temporelle inf�rieure pour le graphique
  
  gnuplot  -c genericplot.plt %%I.tab %moisdeb% %moisfin%
  REM Cr�e le graphique
  
  gawk -f genHTMLlink.awk %%I.png >%%I.htm
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
head -%nblgn% is-seuil.csv |gawk -f genHTMLindex.awk -v statdate="%moisfin%" >index.html
REM g�n�ration de la page d'en-t�te pour toutes les familles suivies

move index.html %moisfin%

set web=C:\Users\admin\Dropbox\EasyPHP-DevServer-14.1VC11\data\localweb\StatsIS
REM move /y %moisfin% %web%
rd /s /q "%web%\%moisfin%" 2>nul
@echo V�rifier et corriger les commentaires texte dans le dossier %moisfin%
msg %username% V�rifier et corriger les commentaires texte dans le dossier %moisfin%
REM MODIF 10:57 lundi 29 ao�t 2016 impl�mentation de la v�rification manuelle des commentaires textuels
@echo on
pushd %moisfin%
for %%I in (*.txt *.png) do %%I
pause
xcopy /y /I . "%web%\%moisfin%"
xcopy *.txt .. /y
popd

