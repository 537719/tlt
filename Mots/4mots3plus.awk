# 4mots3plus.awk
# d'après mots3plus.awk
# d'après # wordocccount.awk
# affiche une suite de 4 mots de plus de 3 lettres choisis aléatoirement dans un texte
BEGIN {
	nbmots=0
	pwd=""
}
# {#MAIN
	# for (i=1;i<=NF;i++) {
		# if (length($i)>3) {
			# mot[$i]++
			# nbmots++
		# }
	# }
# }
{ #MAIN
	# gsub(/,|\'|\.|;|\?|\"|\{|\}|\[|\]|\(|\)|\<|\>|:|!|\*|-/," ")
	gsub(/,|\.|\(|\)/," ")
	for (i=1;i<=NF;i++) {
		if (length($i)>3) {
			mot[$i]++
			nbmots++
		}
	}
}
END {
	nbmots++
	srand(systime())
	# print nbmots
	j=0
	for (i in mot) {
		if (length(i)>3) {
			liste[j]=i
			j++
			# print(i)
		}
	}
	# for (i in liste) {
		# print i OFS liste[i] OFS i
	# }
	loops=0
	pwd=""
	while(length(pwd)+loops<25) {
		j=int(nbmots*rand())
		if (length(liste[j])>3) {
			pwd=pwd " " liste[j]
			# print liste[j] OFS j
			loops++
		}
	}
	# for (i=1;i<=4;i++) {
		# j=int(nbmots*rand())
		# pwd=pwd " " j " " liste[j]
		# print liste[j] OFS j
	# }
	print pwd
}

