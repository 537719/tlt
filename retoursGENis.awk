#retoursGENis.awk
#02/03/2015 14:37
#affiche les retours sans numéro de dossiers parmi les réceptions I&S

# identifier retours de
	# matériel non neuf ($2 !~ /^[A-Z][A-Z][A-Z][0-9][0-9]N....$/)
	# sans numéro d'apt ($5 == "")
	# sans numéro de dossier ($6 !~ /IM[0-9][0-9][0-9][0-9][0-9][0-9][0-9]/ || $6 !~ /RM[0-9][0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9]/ || $6 !~ /[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]/)
	# ne correspondant pas à une livraison ($6 !~ ^[0-9].* *- *)
	# ne provenant pas d'un retour de réparation (pas de LVI ni SPC dans $6)

BEGIN {
	FS=";"
	OFS=";"
}
	
{ #MAIN
	# neuf=gensub(/(^[A-Z][A-Z][A-Z][0-9][0-9]N....$)/,"\\1","g",$2)
	# apt=gensub(/(..*)/,"\\1","g",$5)
	
	# im=gensub(/(IM[0-9][0-9][0-9][0-9][0-9][0-9][0-9])/,"\\1","g",$6)
	# rm=gensub(/(RM[0-9][0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9])/,"\\1","g",$6)
	# glpi=gensub(/([1-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9])/,"\\1","g",$6)
	# livr=gensub(/^([0-9].* *- *)/,"\\1","g",$6)
	
	# refliv=im rm glpi livr
	# print NR OFS neuf OFS apt refliv OFS dossier OFS $0

	neuf=($2 ~ /^[A-Z][A-Z][A-Z][0-9][0-9]N....$/)
	apt=($5 ~ /./)
	dossier=($6 ~ /IM[0-9][0-9][0-9][0-9][0-9][0-9][0-9]/ || $6 ~ /RM[0-9][0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9]/ || $6 ~ /[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]/ || $6 ~ /^[0-9].* *- */ || $6 ~ /LVI/ || $6 ~/SPC/)
	
	if (neuf+apt+dossier==0) print NR OFS $0
}