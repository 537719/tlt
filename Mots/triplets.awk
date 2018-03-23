# paires.awk
# dresse une table des suites de 2 caractères consécutifs dans le flot d'entrée

BEGIN {
	FS=""
	OFS="@"
}
{ #MAIN
	for (i=1; i<=NF; i++) {
		# print NR OFS i OFS $i $(i+1) $(i+2) OFS
		paire=$i $(i+1)
		paires[paire] ++
	}
}
END {
	# n=asort(paires,resultat)
	# for (i=1;i<=n;i++) {
		# print i OFS paires[i] OFS resultat[i]
	# }
	for (i in paires) {
		print i OFS paires[i]
	}
	print "fini"
}