#nbstock.awk
#d'après nbatelier.awk 28/01/2016  11:17              1060
#compte le nombre d'articles en stock tout état confondu
#Entrée : fichier quotidien d'état des stocks
#sortie : nombre d'articles cumulés toutes catégories confondues, à l'exclusion des "à livrer"
# MODIF 09:57 mercredi 15 juin 2016 Ajout d'un test sur le type de fichier

BEGIN {
	nbdisp=0
	nbresa=0
	nbsav=0
	nbmaint=0
	nbdest=0
	
	FS=";"
	OFS=";"
	
	codesortie=0
}

{	#MAIN
	if (NR==1) {
		if (NF!=9) {
			print "Ce fichier n'est pas du type requis car il contient " NF " champs."
			# exit NF
			codesortie = NF
		} else {
			if ($0 !~ /Ok/ ) {
				print "Ce fichier n'est pas un état des stocks"
				codesortie = NF
			}
		}
	} else {
		nbdisp = nbdisp+$4
		nbresa = nbresa+$5
		nbsav = nbsav+$6
		nbmaint = nbmaint+$7
		nbdest = nbdest+$8
	}
}
END {
	if (codesortie) exit codesortie
	print "nb dispo " nbdisp
	print "nb resa " nbresa
	print "nb sav " nbsav
	print "nb maint " nbmaint
	print "nb dest " nbdest
	print nbdisp+nbresa+nbsav+nbmaint+nbdest " articles en stock"
}