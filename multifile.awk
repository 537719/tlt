# multifile.awk
# 30/10/2015
# teste le passage d'un fichier à l'autre lors d'une invocation utilisant des jokers sur la ligne de commande
# invocation : gawk -f multifile.awk *.csv
# résultat attendu : affichage du nom de chaque fichiers et du nombre d'enregistrements de chaque fichier
BEGIN {
	currentfile=""
	nbligne=0
}
{ #MAIN
	if (currentfile=="") currentfile=FILENAME
	if (currentfile != FILENAME) {
		print NR OFS currentfile OFS nbligne
		currentfile=FILENAME
		nbligne=0
	}
	nbligne++
}
END {
		print currentfile OFS nbligne
}
