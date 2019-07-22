@echo off
goto :debut
plotloop.cmd
creation       12:53 mardi 22 janvier 2019 report dans un script externe de la boucle de création dans creestat.cmd des éléments nécessaires au tracé des graphiques
bug             16:44 mardi 22 janvier 2019 inhibation de la vérification de la transmission de la variable d'environnement %moisdeb% parce qu'en fait elle est calculée dans ce script

:debut
REM @echo %0 %1
:verifparams
if @%1@==@@ goto :noargs
if not exist %1.csv goto :nofile
set item=%1
for %%I in (%item%.csv) do if %%~zI==0 goto :zerofile


if @%moisfin%@==@@ goto :moisfin

rem if @%moisdeb%@==@@ goto :moisdeb
rem désactivé car moisdeb n'est pas transmis mais calculé ici

if not exist %gnuplot% goto :gnuplot
:: %gnuplot% est censé contenir le chemin d'accès complet à l'exécutable de gnuplot
:: le if exist est donc plus efficace que le test de la simple existence de la variable
:: (et en plus ce test ne marche pas pour une raison sur laquelle je ne vais pas passer plus de temps pour la déterminer)


:main
@echo traitement de %item% en cours
REM Construit pour chaque famille de produit les fichiers de données pour alimenter gnuplot
  head -1 %item%.csv |sed -e "s/;/\t/g" -e "s/\\\/-/g" > %item%.tab
  cat %item%.csv |sed -e "/^[A-z]/d" -e "s/\([0-9][0-9]\)\/\([0-9][0-9]\)\/\([0-9][0-9][0-9][0-9]\)/\3-\2-\1/" -e "/%moisfin:~0,-3%/d" -e "s/;/\t/g"|usort -u |tail -13 >> %item%.tab
  gawk -F; -v OFS="\t" "{if (sub(/%item%/,\"%moisfin%\",$1)) print}" is-data.csv >> %item%.tab
  REM Rajout de l'occurence actuelle pour le moisfin en cours

  REM Reconstitue un csv à jour
  cat %item%.csv |grep -v "%moisfin:~0,-3%" >%item%.tmp
  sed -n "s/^%item%/%moisfin%/p" is-data.csv >>%item%.tmp

  move /y %item%.csv %item%.bak.csv >nul
  move /y %item%.tmp %item%.csv >nul

  if exist %item%.tab (
      if not exist %temp%\moisdeb.tmp gawk -F\t "{if (NR==2) if ($1 ~/[0-9]{4}-[0-9]{2}-[0-9]{2}/) print $1}" %item%.tab >%temp%\moisdeb.tmp
      REM ^^ BUG 11:04 mardi 6 décembre 2016 n'extrait la borne de date inférieure que si elle a un format valide

      REM détermination de la borne temporelle inférieure pour le graphique
      set /p moisdeb=<%temp%\moisdeb.tmp

       REM Crée le graphique
      "%gnuplot%"  -c ..\bin\genericplot.plt %item%.tab %moisdeb% %moisfin% >nul
      rem redirection vers nul sinon ça affiche le chemin du répertoire en cours
  )

pushd ..\bin
rem repositionnemnt nécessaire sans quoi le script awk ne trouve pas le module à inclure
  gawk -f ..\bin\genHTMLlink.awk -v fichier="%item%" -v moisfin="%moisfin%" ..\StatsIS\is-seuil.csv >..\StatsIS\%item%.htm
popd
  REM pause
  REM génération de la page web affichant le graphique
  move %item%.* "%moisfin%" >nul
  copy "%moisfin%\%item%.txt" .  >nul
  copy "%moisfin%\%item%.csv" .  >nul

:finmain

goto :eof

:traiteerreurs
:noargs
msg /w %username% fournir un item de stat en argument
goto :eof
:nofile
rem si pas de fichier, pas de traitement, c'est aussi simple que ça
rem msg /w %username% Le fichier %1.csv est absent de %cd:&=^&%
REM nécessité de protéger le & de I&S sinon ce caractère est interprété ce qui ne convient pas dans ce contexte
goto :eof
:zerofile
msg /w %username% Le fichier %item%.csv a une taille nulle

:moisdeb
msg /w %username% Le mois de debut n'est pas transmis
goto :eof
:moisfin
msg /w %username% Le mois de fin n'est pas transmis
goto :eof
:gnuplot
msg /w %username% Le chemin de gnuplot n'est pas transmis
goto :eof

