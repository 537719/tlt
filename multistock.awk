# multistock.awk
# 09/11/2015
# d'après multifile.awk # 30/10/2015 et test.awk
# comptabilise fichier par fichier les stocks d'un groupe de référence donnés
# sur un lot de fichiers d'export de stock I&S
# test sur la famille "serveurs" = référence en /^CHR48/
# invocation : gawk -f multistock.awk *.csv
# résultat attendu : affichage du nom de chaque fichiers et du nombre d'enregistrements de chaque fichier
BEGIN {
	if (mode=="") mode="RUN"
	# mode="DEBUG"
	FS=";"
	OFS="\t"
	if (mode==DEBUG) OFS=FS

	IGNORECASE=1 # spécifique à gawk

	currentfile=""
	nbligne=0
	
		listeref="Chronopost Serveurs;^CHR48"
		split(listeref,article,";")
		champ=0

}
{ #MAIN
	if (currentfile=="") currentfile=FILENAME
	if (currentfile != FILENAME) {
		print currentfile OFS nbligne
		currentfile=FILENAME
		nbligne=0
	}
	if (nbligne==0) {
		if (NF==8) { # export des réceptions
			champ=2
			sens = "en réception"
		}
		if (NF==9) { # extract du stock
			champ=2
			sens = "en stock"
		}
		if (NF==18) { # export des expéditions
			champ=6
			sens = "en sortie"
		}
		if (champ==0) {
			print NF " champs : ce n'est pas un fichier d'expéditions, de réceptions ni d'état des stocks I&S"
			exit 1
		}
		fichier=FILENAME
	} else {
		vu=0
		for (i in article) {
			if ($champ ~ article[i]) {
				nbvu=nbvu+1
				vu++
			}
		}
		if (vu > 0) {	# catégorisation des cas
			if (champ==6) { # catégorisation des expéditions
				# datestring=gensub("\/"," ","g",$8) "00 00 00" 
				
				
				prio=$2
				if (prio=="P2") nbinc++
				if (prio=="P3") nbdem ++
				if (prio=="P4") {
					codep=$16
					if ( codep == 91019 || codep == 94043) {
						nbrma++
					} else {
						nbdem++
					}
				}
				if (prio=="P5") {
					if ($1 ~ /DESTRUCTION/ ) {
						nbdel++
					} else {
						nbrma++
					}
				}
			}
			if (champ==2) { # catégorisation des réceptions
				# datestring=gensub("\/|\:"," ","g",$4) 

			
			
				reference=$2
				apt=$5
				lib=$6
				status=""
				if (reference ~ /^[A-Z][A-Z][A-Z][0-9][0-9]R/) {	# R en 6° position de la référence I&S
					status="recond"
					if (apt ~ /./) { # APT non vide
						status = status OFS "avec apt"
						if (lib ~ /^RETOUR/ || lib ~ /[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]/) { # Libellé commence par RETOUR ou est composé de 10 chiffres
							status = status OFS "retour"
							if (lib ~ /SPC/) {
								status = status OFS "SPC"
								nbrma ++ # retour sous numéro d'apt de RMA chez SPC
								status = "rma" OFS status
							} else {
								status = status OFS "client"
								nbcli ++ # retour sous numéro d'apt de matériel client
								status = "cli" OFS status
							}
						} else {
							status = status OFS "retour RMA"
							nbrma ++ # retour sous numéro d'apt de rma ou transfert de stock de matériel reconditionné venant d'un autre prestataire
							status = "rma" OFS status
						}					
					} else {
						status = status OFS "sans apt"
						nbcli ++ # réception de matériel client
						status = "cli" OFS status
					}
				}
				if (reference ~ /^[A-Z][A-Z][A-Z][0-9][0-9]N/) {	# N en 6° position de la référence I&S
					status="neuf"
					if (apt ~ /./) { # APT non vide
						status=status OFS "avec apt"
						if (lib ~ /^RETOUR/ || lib ~ /[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]$/) { # Libellé commence par RETOUR ou  se termine par 10 chiffres
							status = status OFS "remise en stock de matériel neuf non utilisé" 
							nbcli ++ # remise en stock de matériel neuf non utilisé
							status = "cli" OFS status
						} else {					
							nbliv ++ # livraison de matériel neuf sous numéro d'apt
							status = "liv" OFS status
						}
					} else {
						status=status OFS "sans apt"
						if (lib ~ /^RETOUR/ || lib ~ /[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]$/) { # Libellé commence par RETOUR ou se termine par 10 chiffres
							status = status OFS "remise en stock de matériel neuf non utilisé" 
							nbcli ++ # remise en stock de matériel neuf non utilisé
							status = "cli" OFS status
						} else {
							status = status OFS "livraison de matériel neuf sans numéro d'apt enregistré"
							nbliv ++ # livraison de matériel neuf sans numéro d'apt enregistré
							status = "liv" OFS status
						}
					}
				}
				if (mode=="DEBUG") {
					print  NR OFS $0 OFS status # pour debug seulement (mettre OFS à ";" 
				}
			}

			# datebl=mktime(datestring)
			# if (datebl>datemax) datemax=datebl
			# if (datebl<datemin) datemin=datebl
		}
	}

	nbligne++
}
END {
		print currentfile OFS nbligne
}
