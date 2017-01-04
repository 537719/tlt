#nbrecond.awk
#d'après 28/01/2016  11:17              1060 nbatelier.awk
#compte le nombre de pc reconditionnés (ie préparations/masterisations) faites par I&S
#Entrée : fichier d'export des réceptions effectuées
#sortie : tout PC reconditionné sauf chronoship => $2 ~ /^[A-Z][A-Z][A-Z]1[0-1]R[^S]/

#MODIF 09:53 mercredi 15 juin 2016 Ajout d'un test sur le type de fichier

BEGIN {
	nbrecond=0
	codesortie=0
	
	FS=";"
	OFS=";"
}

{	#MAIN
	if (NR==1) {
		if ( NF !=8 && NF != 9 && NF != 10 ) {
			print "Ce fichier n'est pas du type requis car il contient " NF " champs."
			codesortie = NF
		}
		if ($10 ~ /./) {
			print "Ce fichier n'est pas du type requis car il contient un champ " $10 "."
			codesortie = NF
		}
	} else { 
		if ($2 !~ /^P5$/) {
			if ($2 ~ /^[A-Z][A-Z][A-Z]1[0-1]R[^S]/) {nbrecond++ ; if (debug) print}
		}
	}
}
END {
	if (codesortie) exit codesortie
	print nbrecond " reconditionnements"
	print NR-1 " articles en reception"
}