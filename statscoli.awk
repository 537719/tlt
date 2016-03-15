#statscoli.awk
# 09:34 lundi 14 mars 2016
# Produit les données permettant d'alimenter le rapport statistique mensuel pour Colissimo
# Source : fichier csv de calcul d'autonomie tel que produit par glpi
# contrainte : certains champs contiennent des ruptures de lignes, le fichier dont donc être préprocessé auparavant pour les éliminer.
# solution : batch effectuant un cat glpi.csv |tr \r \000 |tr \n \000 |ssed -e "s/;\d0\d34/\n\d34/g" -e "s/\d0/<crlf>/g" -e "s/\d34;\d34/\d34\d0\d34/g" -e "s/&gt;/>/g" >glpi.txt
# 	remplace les  sauts de ligne (uniquement des LF) par des zéros binaires (absents du fichier  d'origine),
#	reconstruit les vrais saut de lignes (ceux qui sont placés après un ; et avant un ")
#	remplace les autres par une chaine spécifique
#	remplace les séparateurs de champs par des zéros binaires, sans toucher aux point-virgules qui ne sont pas séparateurs de champs
#	le zéro binaire sera donc le séparateur de champs en entrée
#
# Données à produire :
# Nombre d'incidents par type de site (ACP	CLIENT EXPEDITOR	DOT	PFC	SAV+SIEGE	SOUS-TRAITANT	SPECIFIQUE)
# Nombre d'incidents par type d'activité, plus cumul pour les groupes d'activité EXPEDITOR	IMPRIMANTE	UC FIXE	UC PORTABLE	Autres
# Nombre de déploiement de PC (fixes et portables) par type de site (ACP PFC SIEGE+DOT+SAV)
BEGIN {
	FS="\0"
	OFS=";"
}
{ #MAIN
	entite=$2
	emplacement=$5
	categorie=$7
	historique=$31
	type=$33
	
	if (entite ~ /COLI/) if (historique~/CIL|PLANIF|SOLUTIONS30|I&S|ECONOCOM|CRII|OPS/)  {
		gsub(/\"/,"",categorie) # les guillemets parasitent le traitement et l'affichage des résultats
		gsub(/\"/,"",emplacement) # les guillemets parasitent le traitement et l'affichage des résultats
		if ( type ~ /ncident/) {
			nbinc++ #OK
			# calcul du nombre d'incidents par type de site (its) #OK
			split(emplacement,site,">")
			if (site[1] ~/SAV|SIEGE/) site[1]="SIEGE/SAV"
			its[site[1]]++ #its = incidents par type de site
			
			# ventilation du nombre d'incidents par type d'activité (ita)
			# autres++
			if (categorie ~ /^MATERIEL.*IMPRIMANTE THERMIQUE|EXPEDITOR/) {
				expeditor++ #OK
			} else { #OK
				if (categorie ~ /POSTE DE TRAVAIL.*IMPRIMANTE/) imprimante++
				if (categorie ~ /POSTE DE TRAVAIL.*FIXE/) ucfixe++
				if (categorie ~ /POSTE DE TRAVAIL.*(PORTABLE|TABLETTE)/) ucportable++
			}
			gsub(/&gt;/,">",categorie)
			ita[categorie]++
		} else { #demandes => calcul du nombre d'installation de PC "fil de l'eau" par type de site (fts)
			nbdem++ #OK
			if (categorie ~ /^Demande de ma.*ouveau poste de travail.* PC /) { #OK
				fde++
				split(emplacement,site,">")
				if (site[1] ~/SAV|SIEGE|DOT/) site[1]="ADM"
				fts[site[1]]++ #fts = fil de l'eau par type de site
			}
		}
	}
}
END {
	print"Repartition des dossiers :"
	print "Incidents" OFS nbinc
	print "Demandes" OFS nbdem
	
	print "\r\nIncidents par type de site" OFS nbinc
	n=asorti(its,oits)
	for (i=1;i<=n;i++) print oits[i] OFS its[oits[i]]
	
	autres=nbinc-expeditor-imprimante-ucfixe-ucportable
	print "\r\nIncidents par type d'activité" OFS nbinc
	print "Expeditor" OFS expeditor
	print "Imprimante" OFS imprimante
	print "UC Fixe" OFS ucfixe
	print "UC Portable" OFS ucportable
	print "Autres" OFS autres
	
	print "\r\nFil de l'eau par type de site" OFS fde
	n=asorti(fts,ofts)
	for (i=1;i<=n;i++) print ofts[i] OFS fts[ofts[i]]
	
	print "\r\nIncidents par catégorie" OFS nbinc
	n=asorti(ita,oita)
	for (i=1;i<=n;i++) print oita[i] OFS ita[oita[i]]
}


