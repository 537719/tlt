@echo off
goto :debut
quipoDBupdate.cmd
CREATION    16:57 06/04/2021 actualise les donn‚es dans la base sqlite de publication des stats
BUG         16:22 28/04/2021 purge toutes les tables et pas uniquement les tables de flux sinon les critŠres d'unicit‚ empˆchent les m…j
MODIF       18:21 28/04/2021 reporte les commentaires dans la bdd des graphiques
:debut
:: positionnement dans le dossier de la bdd de publication des stats
pushd ..\StatsIS\quipo\SQLite

:: purge de la log d'erreurs
del %temp%\erreurs.sql 2>nul

REM :: purge les tables de statut (par opposition aux tables de flux
REM for %%I in (*stock*.csv) do (
REM sqlite3 quipo.db "delete from %%~nI;"
REM )
:: purge les tables 
for %%I in (*.csv) do (
sqlite3 quipo.db "delete from %%~nI;"
)

:: boucle de mise … jour
for %%I in (*.csv) do (
sed -i "s/\&amp;/\&/g" %%I
REM les & avaient pr‚alablement du ˆtre convertis en &amp; afin de ne pas parasiter le xml pour l'affichage sous ajax - attention, modifier ce commentaire risque de planter le script

sqlite3 -separator ; quipo.db ".import %%I %%~nI" 2>> %temp%\erreurs.sql

REM constitution d'un fichier t‚moin de date de mise … jour - attention, modifier ce commentaire risque de planter le script
@echo %%~tI> %%~nI.txt
)
::mise … jour des commentaires des graphiques pour les sujets n'ayant qu'un seul graphique
for /F %%I in ('sqlite3 quipo.db "select sujet from graphiques group by sujet";') do if exist ..\%%I\commentaire.txt (
sqlite3 quipo.db "update graphiques set commentaire=readfile('..\%%I\commentaire.txt') where sujet='%%I';"
)

::mise … jour des commentaires des graphiques pour les sujets ayant plusieurs graphiques
:: on ne recherche pas les commentaires des sujets ayant uniquement un graphique par ann‚e
REM @echo on
for /F "tokens=1,2 delims=;" %%I in ('sqlite3 quipo.db ".separator ;" "with storage as (select sujet,count(*) as nb from graphiques where (cast(code as integer) = 0) group by sujet having nb > 1) select sujet,code from graphiques where sujet in (select sujet from storage);"') do if exist ..\%%I\%%J.txt (
sed -e "1,3d" -e "s/\(.*\)/\1<br\/>/" ..\%%I\%%J.txt > ..\%%I\%%J.html.txt
sqlite3 quipo.db "update graphiques set commentaire=readfile('..\%%I\%%J.html.txt') where sujet='%%I' and code='%%J';"
REM pause
)

uecho -n -e Nombre de conflit d\x27import :\x20
wc -l %temp%\erreurs.sql |gawk "{print $1}"
popd
