@echo off
goto :debut
AUTEUR : G. Métais 15:17 mardi 12 avril 2016
OBJET fournit des données sur les portables Chrono à  récupérer
PREREQUIS :
	gawk (dans sa version 4 mininum, disponible au travers de Msys2 http://msys2.github.io/
	MySql ainsi que les informations de connexion en lecture à  la base GLPI au travers du batch MyGLPI.cmd
	cat (utilitaire gnuwin32)
	usort (utilitaire gnuwin32, sort unix renommé)
	grep (utilitaire gnuwin32) ATTENTION certaines versions sont incompatibles
	les scripts AWK suivants :
		filtrealltaches.awk
		recupportablchr.awk
		sqlrecupportablchr.awk

ATTENTION ce sript doit être encodé en ANSI pour des problèmes de concordance entre les en-têtes de colonnes pour le join

#MODIF 17:57 mardi 12 avril 2016
	filtrealltaches.awk => trier la liste des pc par nom croissant et supprimer l'espace après la virgule, vérifier que l'on sort bien tous les pc
	recupportablchr.awk => liste des pc triée par nom croissant
:debut
@echo 0°) purge des données
del dossiersrecup*.* 2>nul
del taches*.txt 2>nul
del tachesrecup.csv 2>nul
del searchdossiers.txt 2>nul
del portables*.csv 2>nul

@echo 1°) génération du fichier csv des dossiers concernés
REM  travaille sur les extractions mensuelles de la stat d'autonomie de GLPI au format CSV retraitées de manière à  en enlever les sauts de lignes parasites 
for /F %%I in ('dir /ad /b ..\..\Stats\') do gawk -f recupportablchr.awk ..\..\Stats\%%I\glpi.txt >dossiersrecup%%I.csv

@echo 2°) génération du source sql d'export des taches
for /F %%I in ('dir /ad /b ..\..\Stats\') do gawk -f sqlrecupportablchr.awk ..\..\Stats\%%I\glpi.txt >dossiersrecup%%I.sql

@echo 3°) extraction du fichier des taches des dossiers concernés
for %%I in (*.sql) do call myglpi <%%I 2>>erreursql.log 1>taches%%~nI.txt

@echo 4°) génération du fichier csv des taches des dossiers concernés
cat tachesdossiersrecup*.txt |gawk -f filtrealltaches.awk |usort -u -n -t; -k1 -o tachesrecup.csv
REM   usort -u pour éliminer les doublons ^^

@echo 5°) vérification du retour en stock
gawk -F; "{print $1}" tachesrecup.csv >searchdossiers.txt
REM  option : extraire à  la main les s/n des pc attendus, les chercher dans le matériel réceptionné et les rajouter à  la liste ci-dessus
@echo Vérifier dans la colonne "justif" des dossiersrecup*.csv si des numéros de série y sont mentionnés et les mettre dans ce fichier >sn.txt
@echo Vérifier dans la colonne "justif" des dossiersrecup*.csv si des numéros de série y sont mentionnés et les mettre dans le fichier sn.txt puis
cat snsauve.txt >>sauve.txt
start sn.txt
pause
if exist sn.txt cat sn.txt >>searchdossiers.txt
grep -i -h -f searchdossiers.txt ..\is_in_20????.csv |gawk -F; -v OFS=";" "{dossier=gensub(/RETOUR */,rien,1,$6);if (dossier ~ /[0-9]{10}|GENERIQUE|Libel/) if ($2 ~ /^CHR1/||$6 ~ /Libell/) {dossier=gensub(/GENERIQUE/,9999999999,1,dossier); print  dossier OFS $1 OFS $2 OFS $3 OFS $4 OFS $8}}"|usort -t; -k1 -u -n -o portableseus.csv
REM grep -i -h -f searchdossiers.txt ../is_in_20????.csv |gawk -F; -v OFS=";" "{dossier=gensub(/RETOUR */,rien,1,$6);if (dossier ~ /[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]|GENERIQUE|Libel/) if ($0 ~ /;CHR1/||$0 ~ /Libell/) {dossier=gensub(/GENERIQUE/,9999999999,1,dossier); print  dossier OFS $1 OFS $2 OFS $3 OFS $4 OFS $8}}"|usort -t; -k1 -u -n -o portableseus.csv
REM  ATTENTION selon la version des utilitaires GNUwin32 utilisés, il faut utiliser / ou \ dans les chemins de fichier

@echo 6°) croisement des dossiers et taches de ce qui est à  récupérer
usort -n -u -o dossiers.csv dossiersrecup*.csv
usort -n -o tachesrecup.csv tachesrecup.csv
REM  ^^ besoin de fichiers triés dans le màªme ordre et élimination des doublons
join -t; -1 1 -2 1 dossiers.csv  tachesrecup.csv > portablesdus.csv 
REM  on a ici ^^ tout ce qui a été produit

@echo 7°) croisement final
join -a1 -a2 -t;  -1 1 -2 1 portablesdus.csv portableseus.csv > portablesrecup.csv
REM  correspondance entre ce qui est sorti et ce qui a été reà§u en retour
@echo c'est fini, résultat dans portablesrecup.csv
@echo ATTENTION les matériels trouvés par s/n mais avec un numéro de dossier erroné apparaitrons décalés sur la gauche
@echo on les repère sur le critère "centrecout = vide"

