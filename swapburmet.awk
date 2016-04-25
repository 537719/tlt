#swapburmet.awk
# Ventilation entre bureautique/métier/shipping des postes de travail produits en swap par I&S
# travaille sur les exports des expéditions depuis l'extranet I&S
#
# critères :
# sortir uniquement si swap => $2="P2"
# 
# etat par défaut => inc
# portables et tablettes $6 ~ /^...1[1|2]/ => bur
# UC $6 ~ /^CHR1/ &&  $10 = "CHRONOPOST SHIPPING" => shp
# UC $6 ~ /^CHR1/ && $7 ~ /RP|5[7|8]00/ => met
# UC $6 ~ /^CHR1/ && $16=86360 => bur
# UC $6 ~ /^CHR1/ && $16~/490[0-1]0/ => bur
# UC $6 ~ /^CHR1/ && $18~/^GENTILLY/ => bur
# UC $6 ~ /^TLT1/  => bur
# UC $6 ~ /^CLP1/ && $18  ~ /^ISSY|^PARIS|^NOISY/ => bur

#
# sortie = etat OFS $0 

BEGIN {
	if (mode=="") mode="RUN"
	# mode="DEBUG"
	FS=";"
	# OFS="\t"
	OFS=";"
	if (mode==DEBUG) OFS=FS

	IGNORECASE=1 # spécifique à gawk
}
{ #MAIN
	if (DEBUG) print fichier OFS FILENAME OFS 
	if (NR==1) {
		champ=0
		if (NF==18) { # export des expéditions
			champ=6
		}
		if (champ==0) {
			print NF " champs : ce n'est pas un fichier d'expéditions I&S"
			exit 1
		}
		print "etat" OFS $0
	} else {
		if ($2 ~/^P2$/) if ($6 ~ /^...1[0-2]/){
			etat="---"
			if ($6 ~ /...1[1-2]/) etat="bur"
			if ($6 ~ /^CHR1/) {
				if ($10 ~ /^CHRONOPOST SHIPPING$/) etat="shp"
				if ($7 ~ /RP|5[7|8]00/) etat="bur"
				if ($16==86360) etat="bur"
				if ($16~/^490[0-1]0$/) etat="bur"
				if ($18~/^GENTILLY/ ) etat="bur"
			}
			if ($6~/^TLT1/) etat="bur"
			if ($6 ~ /^CLP1/) {
				if ($18~/^ISSY|^PARIS|^NOISY/ ) etat="bur"
			}
			print etat OFS $0
		}
	}
}
