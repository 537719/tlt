#stockIS.awk
# 17:39 16/06/2015
# convertit sous une forme exploitable le stock I&S copié de l'extranet vers excel puis sauvé en texte séparé par tabulations
#
# travaille en entrée sous un fichier de la forme :
# 8		Masquer détails pour DIVERS (DIVERS GENERIQUE)DIVERS (DIVERS GENERIQUE)																			
# 2		Masquer détails pour MaintenanceMaintenance																			
# 2		Masquer détails pour DisponibleDisponible																			
# 1						OF N°IS014020461					11/04/2014	TE1402270025	3076797U						T8-B.01.1	RCP RETOURS 26/02/2014	Routeur réceptionné au nom d'un portable
# 1						OF N°IS015020212					13/03/2015	TE1502250538	409336947						T8-B.01.1	RETOUR 1501090167	409336947
# 8		Masquer détails pour DIVERS (DIVERS GENERIQUE)DIVERS (DIVERS GENERIQUE)																			
# 2		Afficher détails pour MaintenanceMaintenance																			
# 6		Masquer détails pour OKOK																			
# 5		Masquer détails pour DisponibleDisponible																			
# 1						OF N°IS014020396					20/02/2014	TE1402140028	LBNNTMMD460J2W						P1-G.05.5	RETOUR RM026354-001	
# 1						OF N°IS014020396					20/02/2014	TE1402140027	LBNNTMMD441R84						P1-G.05.5	RETOUR RM026354-001	
# 1						OF N°IS014100262					20/02/2014	TE1402140026	LBNNTMMD441R9G						P1-G.05.5	RETOUR RM026354-001	
# 1						OF N°IS014100262					20/02/2014	TE1402140025	LBNNTMMD441R95						P1-G.05.5	RETOUR RM026354-001	
# 1						OF N°IS014110037					20/02/2014	TE1402140029	FG10CH3G09615475						P1-G.05.5	RETOUR RM026354-001	
# 
# Mode d'emploi :
# faire un copier-coller sous forme texte d'une vue de l'extranet I&S vers un tableau excel en incluant les en-têtes des lignes qu'il a fallu développer
# s'y reprendre autant de fois qu'il y a d'articles à visualiser, mais tout peut être mis à la queue dans un seul tableau
# pour finir ça doit ressembler à l'exemple ci-dessus ^^
# sauvegarder au format texte séparé par tabulation
# invoquer le script par :
# gawk -f [fichierdentree.txt] > [fichiersortie.csv]
# la sortie est au format csv.


BEGIN {
	FS="\t"
	OFS=";"
	print "ref" OFS "libelle" OFS "etat" OFS "OF" OFS "date" OFS "TagIS" OFS "S/N" OFS "Emplacement" OFS "BA" OFS "Audit" OFS "Produit"
}

{	# MAIN
	if ($3 != "") {
		if ($3 ~ /\(/) {
			refis=gensub(/.*\)(.*) \(.*/,"\\1","1",$3)
			lib=gensub(/.*\((.*)\)..*/,"\\1","1",$3)
			statut=""
			etat=""
		} else {
			nbwords=split($3,mots," ")
			nbcar=length(mots[nbwords])/2
			statut=substr(mots[nbwords],1,nbcar)
			etat=etat " " statut
			nbwords=split(etat,mots," ")
			if (nbwords>2) {
				etat=""
				for (i=nbwords-1 ; i<=nbwords; i++) {
					etat=etat " " mots[i]
				}
			}
			# if (nbwords >1) print OFS refis OFS lib OFS etat OFS nbwords
		}
	} else if ($7 !="" ) {
		print refis OFS lib OFS etat OFS $7 OFS $12 OFS $13 OFS $14 OFS $20 OFS $21 OFS $22 OFS $23
		# refis=""
		# etat=""
		# statut=""
	}
}
