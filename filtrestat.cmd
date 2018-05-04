@echo off
goto :debut
filtrestat.cmd
11/03/2016 10:44:22,28
purge de ses sauts de lignes parasites l'export .CSV de la stat de calcul d'autonomie de glpi
PREREQUIS :
  utilitaires GNUWIN32 : tr, sed (ici dans sa version ssed) et cat
ENTREE
  fichier glpi.csv tel que produit par la stat de calcul d'autonomie de glpi
SORTIE
  le même MAIS
  - avec un zéro binaire comme séparateur à la place des point-virgules
  - les sauts de lignes contenus à l'intérieur des champs sont remplacés par la mention <crlf>
  
MODIF 11 janvier 2018 : remplace ssed par sed suite à plantage disque et réinstallation des outils
MODIF 11 janvier 2018 : remplace <CRLF> par \r\n
:debut
@echo dossier %~p1 nom %~n1 extension %~x1
pushd %~p1
REM cat %~n1%~x1 |tr \r \000 |tr \n \000 |ssed -e "s/;\d0\d34/\n\d34/g" -e "s/\d0/<crlf>/g" -e "s/\d34;\d34/\d34\d0\d34/g" -e "s/&gt;/>/g"  >%~n1.txt
cat %~n1%~x1 |tr \r \000 |tr \n \000 |sed -e "s/;\d0\d34/\n\d34/g" -e "s/\d0/\\\r\\\n/g" -e "s/\d34;\d34/\d34\d0\d34/g" -e "s/&gt;/>/g"  >%~n1.txt
popd
@echo résultat dans %~p1%~n1.txt