#filtretaches.awk
#05/04/2016 14:42:12
# cherche dans un query texte des taches d'un dossier GLPI les informations suivantes :
# nom du poste (ancien et/ou nouveau)
# nom/pr‚nom de l'utilisateur
# centre de c“ut
# num‚ro de dossier
#
BEGIN {
	FS="\t"
	OFS=";"
	IGNORECASE=1

	nom=""
	prenom=""
	user=""
	centrecout=""
	dossier=""
	nompc[1]=""
	delete nompc
	userscan=0
	
}
{	#MAIN

	# centrecout=gensub(/\\n- CENTRE_COUT_BENEF = ([0-9][0-9][0-9][0-9][0-9][0-9]).*/,"\\1",1)
	# if (dossier !~ /./) dossier = gensub(/.*\t([0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9])\t.*/,"\\1",1)
	if ($0 ~ /P[M|B|G|L|P][I|G|P|Y] *[0-9][0-9][0-9][0-9][0-9]/) {
		pc=toupper(gensub(/.*(P[M|B|G|L|P][I|G|P|Y]) *([0-9][0-9][0-9][0-9][0-9]).*/,"\\1\\2","g",$0))
		nompc[pc]++
		# print "pc " OFS NR OFS pc
	}
	
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
					nom=gensub(/- NOM = *(.*)/,"\\1",1,ligne[i])
					sub(/\r/,"",nom)
					# print "nom" OFS NR OFS i OFS user OFS ligne[i]
				}
				if (ligne[i] ~/- PRENOM = /) {
					# prenom=gensub(/- PRENOM = *(.*)./,"\\1",1,ligne[i])
					prenom=gensub(/- PRENOM = *(.*)/,"\\1",1,ligne[i])
					sub(/\r/,"",prenom)
					# print "prenom" OFS NR OFS i OFS user OFS ligne[i]
					# print nom OFS prenom
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
	print "glpi" OFS "CentreCout" OFS "Utilisateur" OFS "Poste(s)"
	for (i in nompc) {
		# print i
		listeposte=i "," listeposte
	}
	listeposte=substr(listeposte,1,length(listeposte)-1)
	# print dossier OFS centrecout OFS user OFS listeposte
	# print "glpi" OFS dossier OFS "glpi"
	# print "centrecout" OFS centrecout OFS "centrecout"
	# print "utilisateur" OFS user OFS "utilisateur"
	# print "poste(s)" OFS listeposte OFS "poste(s)"
	print dossier OFS centrecout OFS user OFS listeposte
}

