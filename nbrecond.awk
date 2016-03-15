#nbrecond.awk
#d'après 28/01/2016  11:17              1060 nbatelier.awk
#compte le nombre de pc reconditionnés (ie préparations/masterisations) faites par I&S
#Entrée : fichier d'export des réceptions effectuées
#sortie : tout PC reconditionné sauf chronoship => $2 ~ /^[A-Z][A-Z][A-Z]1[0-1]R[^S]/

BEGIN {
	nbrecond=0
	
	FS=";"
	OFS=";"
}

{	#MAIN
	if ($2 !~ /^P5$/) {
		if ($2 ~ /^[A-Z][A-Z][A-Z]1[0-1]R[^S]/) {nbrecond++ ; if (debug) print}
	}
}
END {
	print nbrecond " reconditionnements"
	print NR-1 " articles en reception"
}