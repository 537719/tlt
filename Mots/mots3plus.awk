# mots3plus.awk
# d'après # wordocccount.awk
# liste les mots de plus de 3 lettres dans un texte
{ #MAIN
	for (i=1;i<=NF;i++) {
		if (length($i)>3) {
			m[$i]++
		}
	}
}
END {
	for (i in m) print(i)
}
