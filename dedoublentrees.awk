#dedoublentrees.awk
#14:57 21/07/2015
# élimine les doublons de réception de matériel dans un fichier les entrée et sorties chez I&S
# critère : si un matériel est rentré plusieurs fois de suite avant d'être sorti, on ne garde que la plus ancienne des dates d'entrée
# prérequis : fichier outfile.csv trié par numéro de série croissant puis date croissante
# format du fichier d'entrée :
#Entree;Projet;Reference;#Num Serie;DateEntree;APT;Libellé;BonTransport;RefAppro

BEGIN {
	sn=""
	sens=""
}
{ #MAIN
	sortir = 1
	if (sens==$1) {
		if (sn==$4) {
			sortir=0
		}
	}
	sens=$1
	sn=$4
	if (sortir) print
}
