données sur les portables à récupérer
1°) génération du fichier csv des dossiers concernés
	for /F %I in ('dir /ad /b ..\..\Stats\') do gawk -f ..\recupportablchr.awk ..\..\Stats\%I\glpi.txt >dossiersrecup%I.csv
2°) génération du source sql d'export des taches
	for /F %I in ('dir /ad /b ..\..\Stats\') do gawk -f ..\sqlrecupportablchr.awk ..\..\Stats\%I\glpi.txt >dossiersrecup%I.sql
3°) extraction du fichier des taches des dossiers concernés
	for %I in (*.sql) do call myglpi <%I 2>>erreursql.log 1>taches%~nI.txt
4°) génération du fichier csv des taches concernées
	cat tachesdossiersrecup*.txt |gawk -f filtrealltaches.awk |usort -u -n -t; -k1 -o tachesrecup.csv //  usort -u pour éliminer les doublons
5°) vérification du retour en stock
	gawk -F; "{print $1}" tachesrecup.csv >searchdossiers.txt
	//option : extraire à la main les s/n des pc attendus, les chercher dans le matériel réceptionné et les rajouter à la liste ci-dessus
	if exist sn.txt cat sn.txt >>searchdossiers.txt
	grep -i -h -f searchdossiers.txt ..\is_in_20????.csv |gawk -F; -v OFS=";" "{dossier=gensub(/RETOUR */,rien,1,$6);if (dossier ~ /[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]|GENERIQUE|Libel/) if ($0 ~ /;CHR1/||$0 ~ /Libell/) {dossier=gensub(/GENERIQUE/,9999999999,1,dossier); print  dossier OFS $1 OFS $2 OFS $3 OFS $4 OFS $8}}"|usort -t; -k1 -u -n -o portableseus.csv
6°) croisement des dossiers et taches de ce qui est à récupérer
	usort -n -u -o dossiers.csv dossiersrecup*.csv
	usort -n -o tachesrecup.csv tachesrecup.csv
	join -t; -1 1 -2 1 dossiers.csv  tachesrecup.csv > portablesdus.csv 
7°) join -a1 -t;  -1 1 -2 1 portablesdus.csv portableseus.csv > portablesrecup.csv
gawk 
5. lydia salvana