# structurecsvfull.awk
# 14:29 mardi 31 mai 2016
# affiche le nom des champs composant le fichier csv passé en argumument, ainsi que leur longueur maximale et leur type
BEGIN {
	FS=";"
	OFS="\t"
}

{ #MAIN
	if (NR==1) {
		for (i=1;i<=NF;i++) {
			champ[i]=$i
			type[i]="num"
			void[i]=0
			long[i]=0
		}
	} else {
		for (i=1;i<=NF;i++) {
			currentfield=$i
			if (length(currentfield) > long[i]) long[i]=length(currentfield)
			if (currentfield=="") {
				void[i]++
			} else {
				if (type[i]=="num") {
					if (currentfield + 0 != currentfield) {
						if (currentfield ~ /[0-9]*[-|\/][0-9]*[-|\/][0-9]*/) {
							type[i]="date"
						} else {
							if (currentfield ~ /[0-9]*:[0-9]*/) {
								type[i]="heure"
							} else {
								type[i]="text"
							}
						}
					}
				}
			}
		}
	}
}
END {
	print "No" OFS "Type" OFS "long" OFS "Vide" OFS "Champ"
	for (i in champ) {
		void[i]=int(10000*(void[i]/(NR-1)))/100
		print i OFS type[i] OFS long[i] OFS void[i] OFS champ[i]
		# printf "%4d %s %3d %3.2f\%  %s\r\n" i , type[i], long[i] , void[i] , champ[i]
	}
}