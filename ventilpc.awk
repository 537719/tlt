# ventilpc.awk
# donne la répartition des UC sorties de chez I&S
# d'après un fichier d'export des produits expédiés
# selon la ventilaton suivante :
# BU $9
# Incidents / demandes / rma ou destruction $2 et $3
# parmi les incidents et demandes, nb fixes / portables
# parmi les fixe et portables nb neufs / reconditionnés

BEGIN {
	FS=";"
	OFS=" = "
	IGNORECASE=1
}

{ #MAIN
	dossier=$1
	pri=$2
	prov=$3
	refer=$6
	bu=$9 " "
	type="nul"
	etat="NA"
	
	if (refer ~ /^...1[0|1][N|R][F|P]...$/) { # sinon, pas un pc  de production donc on fait rien
		if (pri~/P2/) type="incident "
		if (pri~/P4/) type="demande "
		if (pri~/P5/) type="destruct "
		
		if (prov~/SWAP/) type="incident "
		if (prov~/DEPL/) type="demande "
		if (prov~/DEST/) type="destruct "

		if (pri~/P3/) type="demande " #normalement sans objet puisque ne concerne que le shipping, déjà exclu par la regexp donc ça ne concerne que les erreurs de saisie
		if (type~/nul/) if ($0~/BOCAGE/) type="destruct "
		# attention, ^^ l'ordre est important

		
		if (refer ~ /^...10.....$/) { # sinon, pas un pc donc on fait rien
			uc="fixe "
		}
		if (refer ~ /^...11.....$/) { # sinon, pas un pc donc on fait rien
			uc="portable "
		}
			
		if (refer ~ /^...1.N....$/) { #neuf
			etat="neuf "
		}
		if (refer ~ /^...1.R....$/) { #neuf
			etat="recond "
		}
		
		# if (type~/destruct/) if (etat~/neuf/) print
			
if (type~/nul/) print

		nb[bu type uc etat]++
	} 
}
END {
	for (i in nb) {
		print i OFS nb[i]
	}
}