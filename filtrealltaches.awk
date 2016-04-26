#filtrealltaches.awk
#16:27 jeudi 7 avril 2016
#d'après filtretaches.awk
#mais travaille sur un flot de fichiers au lieu d'un fichier unique
#
# MODIF 10:38 lundi 11 avril 2016 remplace "glpi" par "Libellé" dans l'en-tête du fichier résultat pour que les join ultérieurs puissent prendre l'en-tête
# MODIF 18:16 mardi 12 avril 2016 extrait les noms de pc par l'utilisation d'un split à 4 arguments (comme dans recupportablchr.awk)
BEGIN {
	FS="\t"
	OFS=";"
	IGNORECASE=1
	firstprint=1
}

{	#MAIN
	if (FNR==1||$0 ~ /^id\t/)  {
		# print FILENAME
		
		sortie=dossier centrecout user
		if (sortie ~ /./) {
			if (firstprint==1) {
				print "Libellé" OFS "CentreCout" OFS "Utilisateur" OFS "Poste(s)"
				firstprint=0
			}
			# print dossier OFS centrecout OFS user OFS listeposte
			# print "glpi" OFS dossier OFS "glpi"
			# print "centrecout" OFS centrecout OFS "centrecout"
			# print "utilisateur" OFS user OFS "utilisateur"
			# print "poste(s)" OFS listeposte OFS "poste(s)"
			# print dossier OFS centrecout OFS user OFS substr(listeposte,3)
			print dossier OFS centrecout OFS user OFS listeposte
		}
		
		nom=""
		prenom=""
		user=""
		centrecout=""
		dossier=""
		delete postes
		pc=""
		listeposte=""
	}
	# centrecout=gensub(/\\n- CENTRE_COUT_BENEF = ([0-9][0-9][0-9][0-9][0-9][0-9]).*/,"\\1",1)
	# if (dossier !~ /./) dossier = gensub(/.*\t([0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9])\t.*/,"\\1",1)
	# if ($0 ~ /P[M|B|G|L|P][I|G|P|Y] *[0-9][0-9][0-9][0-9][0-9]/) {
		# pc=toupper(gensub(/.*(P[M|B|G|L|P][I|G|P|Y]) *([0-9][0-9][0-9][0-9][0-9]).*/,"\\1\\2","g",$0))
		# if (index(listeposte,pc)==0) listeposte=listeposte ", " pc
#		# print "pc " OFS NR OFS pc
	# }
					n=split($0,garbage,/P[M|B|G|L|P][I|G|P|Y] *:* *[O|0-9]{5}/,postes)
					asort(postes)
					for (i in postes) {
						postes[i]=gensub(/ |:/,"","g",postes[i])
						postes[i]=toupper(gensub(/O/,"0","g",postes[i]))
						# print dossier OFS postes[i]
						k=index(pc,postes[i])
						# if (k==0) pc = pc OFS k " " postes[i]
						if (k==0) pc = pc "," postes[i]
						# print dossier OFS i OFS pc
						# if (i==1) pc = postes[i]
						# pc = pc OFS k " " postes[i]
					}
					listeposte=substr(pc,2)
	
	
	
	n=split($0,ligne,/\\n/)
	if (n>1) {

		for (i=1;i<=n;i++) {
			if (ligne[i]~/CENTRE_COUT_BENEF/) {
				centrecout=gensub(/.*CENTRE_COUT_BENEF.*([0-9][0-9][0-9][0-9][0-9][0-9]).*/,"\\1",1,ligne[i])
			}
			if (dossier !~ /./) dossier = gensub(/.*\t([0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9])\t.*/,"\\1",1,ligne[i])
			if (ligne[i] ~ /ficiaire de la demande/) {
				user=""
				nom=""
				prenom=""
				# print "ligne ficiaire " OFS NR OFS i OFS user OFS ligne[i]
			}
			if (user=="") {
				# print "user vide" OFS NR OFS i OFS user OFS ligne[i]
				if (ligne[i] ~/- NOM = /) {
					# nom=gensub(/- NOM = *(.*)./,"\\1",1,ligne[i])
					nom=gensub(/- NOM =[ |\-]*(.*)/,"\\1",1,ligne[i])
					sub(/\r/,"",nom)
					sub(/^ */,"",nom)
					# print "nom" OFS NR OFS i OFS user OFS ligne[i]
				}
				if (ligne[i] ~/- PRENOM = /) {
					# prenom=gensub(/- PRENOM = *(.*)./,"\\1",1,ligne[i])
					prenom=gensub(/- PRENOM = *(.*)/,"\\1",1,ligne[i])
					sub(/\r/,"",prenom)
					sub(/^ */,"",prenom)
					# print "prenom" OFS NR OFS i OFS user OFS ligne[i]
					# print OFS nom OFS prenom OFS
					if (nom ~ /./) {
						user=nom ", " prenom
						# print "user défini" OFS NR OFS i OFS user OFS ligne[i]
						# i=n+1 # d'une part, pas besoin de continuer à scanner le tableau alors qu'on a déjà tous les éléments
						# d'autre part, on évite ainsi de valider à tort un autre couple "nom prenom"
					}
				}
			}
			# print user
		}
	}
}
END {
	# print "glpi" OFS "CentreCout" OFS "Utilisateur" OFS "Poste(s)"
			if (firstprint==1) {
				print "Libellé" OFS "CentreCout" OFS "Utilisateur" OFS "Poste(s)"
				firstprint=0
			}

	# print dossier OFS centrecout OFS user OFS listeposte
	# print "glpi" OFS dossier OFS "glpi"
	# print "centrecout" OFS centrecout OFS "centrecout"
	# print "utilisateur" OFS user OFS "utilisateur"
	# print "poste(s)" OFS listeposte OFS "poste(s)"
	# print dossier OFS centrecout OFS user OFS substr(listeposte,3)
	print dossier OFS centrecout OFS user OFS listeposte
}

