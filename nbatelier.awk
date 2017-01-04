#nbatelier.awk
#28/01/2016  11:17              1060
#compte le nombre d'interventions atelier (ie préparations/masterisations) faites par I&S
#Entrée : fichier d'export des expéditions effectuées
#sortie : pour toute sortie "client" (ie non P5)
#	pc : tout sauf chronoship => $6 ~ /^[A-Z][A-Z][A-Z]1[0-2]/ et $10 !~ /SHIPPING/
#	imprimantes : tout sauf expeditor => $6 ~ /^[A-Z][A-Z][A-Z]3[0-4]/ et $10 !~ /COLIPOSTE SHIPPING/
#	serveurs : tout => $6 ~ /^[A-Z][A-Z][A-Z]48/ 
#	PSM : $6 ~/^CHR63.*1AD$/
# MODIF 11:51 mardi 26 avril 2016 ajout d'un commentaire bidon pour test de git
# MODIF 09:54 mercredi 15 juin 2016 Ajout d'un test sur le type de fichier

BEGIN {
	nbpc=0
	nbimp=0
	nbsrv=0
	nbpsm=0
	
	FS=";"
	OFS=";"
	
	codesortie=0
}

{	#MAIN
	if (NR==1) {
		if ( NF != 18 && NF != 19 ) {
			print "Ce fichier n'est pas du type requis car il contient " NF " champs."
			codesortie=NF
			# exit NF
		}
	} else {
		if ($2 !~ /^P5$/) {
			if ($6 ~ /^[A-Z][A-Z][A-Z]1[0-2]/) if ($10 !~ /SHIPPING/) {nbpc++ ; if (debug) print}
			if ($6 ~ /^[A-Z][A-Z][A-Z]3[0-4]/) if ($10 !~ /COLIPOSTE SHIPPING/) {nbimp++ ; if (debug) print}
			if ($6 ~ /^[A-Z][A-Z][A-Z]48/) { nbsrv++ ; if (debug) print}
			if ($6 ~ /^CHR63.*1AD$/) {nbpsm++ ; if (debug) print}
		}
	}
}
END {
	if (codesortie) exit codesortie
	print "nb pc " nbpc
	print "nb impr " nbimp
	print "nb srv " nbsrv
	print "nb psm " nbpsm
	print nbpc+nbimp+nbsrv+nbpsm " prestations d'atelier"
	print NR-1 " pickings effectués"
}