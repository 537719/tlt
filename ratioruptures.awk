#ratioruptures.awk
# calcule, pour chaque entité, le ratio du nombre de dossiers en achat_probleme parmi ceux qui sont passés chez I&S 
# Source : fichier csv de calcul d'autonomie tel que produit par glpi
# contrainte : certains champs contiennent des ruptures de lignes, le fichier dont donc être préprocessé auparavant pour les éliminer.
# solution : batch effectuant un cat glpi.csv |tr \r \000 |tr \n \000 |ssed -e "s/;\d0\d34/\n\d34/g" -e "s/\d0/<crlf>/g" -e "s/\d34;\d34/\d34\d0\d34/g" -e "s/&gt;/>/g" >glpi.txt
# 	remplace les  sauts de ligne (uniquement des LF) par des zéros binaires (absents du fichier  d'origine),
#	reconstruit les vrais saut de lignes (ceux qui sont placés après un ; et avant un ")
#	remplace les autres par une chaine spécifique
#	remplace les séparateurs de champs par des zéros binaires, sans toucher aux point-virgules qui ne sont pas séparateurs de champs
#	le zéro binaire sera donc le séparateur de champs en entrée
#
# MODIF 11:15 mardi 15 mars 2016
#   tri de l'affichage en sortie de la même manière que ce qui est fait par statscoli.awk


BEGIN {
	FS="\0"
	OFS=";"
}
{ #MAIN
	if (NR==1) { #identification des champs (il arrive que la structure du fichier varie)
		for (i=1;i<=NF;i++) {
			# print i OFS $i
			if ($i ~ /ntit/) fentit=i # Entité
			if ($i ~ /istorique/) fhisto=i # Historique des attributions
	# print fentit OFS fhisto
	# print NR
		}
	} else {
	# }

	# {
		if ($fhisto ~ /I&S/) { #comptabilise, pour chaque entité, le nombre de dossiers passés par I&S
			is[$fentit]++
			if ($fhisto ~ /ACHAT_PROBLEME/) hapb[$fentit]++ #comptabilise, pour chaque entité, le nombre de dossiers passés par I&S ayant connu un ACHAT_PROBLEME
			# print NR OFS is[$fentit] OFS $fentit
		}
		# print NR OFS NF OFS $1 OFS $fhisto
	}
}
END { # Affichage des résultats
	print "Entite" OFS "HAPB" OFS "I&S" OFS "Ratio"
	# n=asorti(ita,oita)
	# for (i=1;i<=n;i++) print oita[i] OFS ita[oita[i]]
	n=asorti(hapb,ohapb)
	# print n OFS "hapb"
	# for (i=1;i<=n;i++) print ohapb[i] OFS hapb[ohapb[i]]
	n=asorti(is,ois)
	# print n OFS "I&S"
	for (i=1;i<=n;i++) {
		entite=gensub(/\"(.*racine > )*/,"","g",ois[i]) # supprime les guillemets et le texte générique inutile dans le nom de l'entité
		printf "%s" OFS "%3d" OFS "%3d" OFS "%4.2f%%\n", entite , hapb[ohapb[i]] , is[ois[i]], 100*hapb[ohapb[i]] / is[ois[i]]
	}
}
