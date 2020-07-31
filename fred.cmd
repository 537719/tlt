@echo off
goto :debut
fred.cmd
11:33 19/02/2020 Extraction depuis un export csv de GLPI selon Le besoin :
Compter par Client (CHR - COL - BIO) pour les différentes ressources (N2 Systèmes - N2 DBA - N2 APPLICATIONS) les différents Changement (RFC puis RFCPA) sur chaque jour de la semaine (Lundi - mardi - mercredi - jeudi - vendredi - samedi - dimanche).:

Fichier d'entrée Extraction_2019.csv
1 Titre
2 Entité
3 Date d'ouverture
4 ID
5 Attribué à - Groupe d'attribution
6 Attribué à - Technicien
7 Statut
8 Catégorie
9 Description
10 Dernière modification


Problème : le champ "Description" est multilignes, chaque ligne étant séparée par un LF
Solution : les enregistrements étant séparés par un CRLF cela se résoud par des outils de conversion
:debut


REM Remplacement des LF par des tabulations et remise en état des sauts de ligne
cat Extraction_2019.csv  |tr \n \t > Extraction_2019_tab.csv
mac2unix -o Extraction_2019_tab.csv
sed -i -e "s/^\t//" -e "s/ *: */:/g" -e "s/ *, */,/g" -e "s/&amp;/\&/g" -e "s/ ;\t*/,/g" Extraction_2019_tab.csv
REM sed  -e "s/^\t//" -e "s/ *: */:/g" -e "s/ *, */,/g" -e "s/&amp;/\&/g" -e "s/ ;\t*/,/g" Extraction_2019_tab.csv  > Extraction_2019_tab_10.csv
REM gawk -F; -v virgule="\t" "NF>10 {for (i=10;i<=NF;i++) {$10=$10 virgule $i;$i="";print}} NF==10 {print}"  Extraction_2019_tab_10.csv  > Extraction_2019_tab.csv
unix2dos -o Extraction_2019_tab.csv
REM cat Extraction_2019.csv  |tr \n \t|mac2unix|unix2dos|sed -e "s/^\t//"
REM cat Extraction_2019.csv  |tr \n \t|mac2unix|unix2dos|sed -e "s/^\t//"  > Extraction_2019_tab.csv
:: CAT => liste le fichier à traiter
:: tr \n \t => remplace les sauts de ligne par des tabulations, y compris ceux qui, associés à un CR matérialisent la fin de l'enregistrements
:: on se retrouve alors avec un fichier de type "mac" (fins de lignes matérialisées par des CR seuls) et dont toutes les lignes sauf la première commencent par des tabus
:: mac2unix|unix2dos => remplace les fins de lignes "mac" par des fins de lignes "windows" (pourrait remplacé par un mac2dos si disponible)
:: sed "s/^\t//" => élimine la tabu placée en début de ligne par le TR initial


REM  Il ne reste plus qu'à traiter le fichier avec gawk en cherchant les informations suivantes :
:: CLIENT : champ $2 "Entité"
:: différents Changement : champ $9 "description" /- Type de la demande : "RFC" ou "RFCPA"
:: jour de la semaine : calcul sur champ $9 "description" /- Date de d?but : 22/10/2019 06:00
:: ressources : champ $9 "description" /- Type de ressources N2 : Support proximit?, N2 OUTILS, N2 RESEAU, N2 SYSTEME, N2 TLD
:: Mauvaise nouvelle : le champ "description" peut contenir des ; qui faussent le compteur de nombre de champs
:: Bonne nouvelle : on s'en fout, on parse la description via le séparateur tabu pour trouver les sous-champs désirés
:: autre difficulté : le sous-champ "resources" contient plusieurs valeurs séparées par des virgules

