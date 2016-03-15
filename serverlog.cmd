@echo off
goto :debut
serverlog.cmd
version initiale 08/03/2016  16:35               283

OBJET : donne la liste des serveurs produits par I&S avec leur date de production

rem ancienne formulation, qui marche mais trop lente
wget.exe -r -l1 -P. http://10.37.115.225/pub/installer/master/uploads/
dir /-c /od .\10.37.115.225\pub\installer\master\uploads\*.log |gawk -v OFS="\t" -v repl="\\1" "{srv=gensub(/^(.*)\.tlt\..*$/,repl,1,$4);print $1 OFS $2 OFS srv}" |grep / |uniq

:debut
REM wget.exe -P. http://10.37.115.225/pub/installer/master/uploads/
>NUL url de pfi ^^ pour tests
wget.exe -P. http://lignv1.tlt/installer/master/uploads/
>NUL url de prod ^^ pour exécution
REM ^^ beaucoup plus rapide (et suffisant) de récupérer la liste des fichiers que les fichiers eux-mêmes
cat index.html |ssed -n "s/.*\.log\d34>\(.*\)\.tlt.*\([0-3][0-9]-[A-z][A-z][A-z]-[0-9][0-9][0-9][0-9] [0-9][0-9]:[0-9][0-9]\).*/\2 \1/p" >history.tmp
rem envoie ^^ le résultat dans un fichier temporaire
cat history.log history.tmp |usort -t- -k3 -k2 -k1 -M |uniq >history.new
move /y history.log history.old >nul
move /y history.new history.log >nul
rem concatène la liste courante ^^ à l'historique existant
cat history.log
del index.htm*
rem del history.tmp
rem ^^ détruit les fichiers de travail