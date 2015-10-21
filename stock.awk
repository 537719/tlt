# stock.awk
# 10/11/2014-11:53:16
# consolide l'état des stocks I&S tels que définis dans le bundle
# de la manière suivante :
# Pour chaque référence ($1)
#  additionne la quantité en stock ($4) et la qté à livrer ($5)
# entrée : texte séparé par point virgule
	# Reference
	# Stock
	# Designation
	# Qte
	# QteALivrer
# sortie : texte séparé par point virgule
	# Reference
	# Designation
	# Qte
BEGIN {
FS=";"
OFS=";"
refe=$1
design=$3
qte=0
}
{ #MAIN
	if ($1 > "!") {
		if ($1 != refe) {
			print refe OFS design OFS qte
			refe=$1
			design=$3
			qte=$4+$5
		} else {
			qte=qte+$4+$5
		}
	}	
}
