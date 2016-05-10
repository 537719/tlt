# ventilSNPCdate.awk
# 10:43 mardi 10 mai 2018
# ventilation des pc � restituer

# usage : gawk -f ventilSNPCdate.awk *.csv
# avec les *.csv �tant des fichiers de r�ception (8 champs) ou d'exp�dition (18 champs) m�lang�s

# aide au choix de la destin�e des pc et portables retourn�s � I&S
# pc ayant moins de 3 ans => � restituer au loueur
# pc de 3 ans et plus => � d�truire

# crit�re : premi�re date d'apparition chez I&S
# type de mouvement :
# entr�e (8 champs)
	# filtre = ref ~ /^CHR1[0-1].[^S]/ (toutes uc et portables non shipping) $2
	# clef =s/n $3 (ou r�f�rence $2 compl�te si s/n vide)
	# pour chaque clef
		# dispatcher date d'entr�e en valeur num�rique $4
		# conserver, pour ce sn :
		# les 3 derniers caract�res de la r�f�rence $2
		# apt, libell�, refappro $5 $6 $8

# sortie (18 champs)
	# filtre = ref ~ /^CHR1[0-1].[^S]/ (toutes uc et portables non shipping) $6
	# clef =s/n $11 (ou r�f�rence $6 compl�te si s/, vide)
	# pour chaque clef
		# dispatcher date bl en valeur num�rique $8
		# conserver, pour ce sn :
			# les 3 derniers caract�res de la r�f�rence $6
			# numdossier, description, centrecout $1 $7 $5

BEGIN {
	FS=";"
	OFS=FS
}
BEGINFILE {
				ref=""
				sn=""
				datemvt=""
				datecrea=datemvt
				ref1="" # num dossier
				ref2="" # centre de cout
				ref3="" # Description
				sens="undef"
				
				# clear tabdate
				# clear arrdate
				# clear arrprod
				# clear arrref3
				# clear arrref2
				# clear arrref1

}
{ #MAIN
	if (FNR==1) {# d�termine le type de fichier
	# impossible d'utiliser ici la structure BEGINFILE car elle n'est invoqu�e qu'avant la lecture du premier enregistrement
	# on passe ici � chaque d�but de lecture de nouveau fichier
	
	# r�gles :
	# 15 ou 18 champs => sortie
	# 8 champs => entr�e
	# autres => rejet
		switch (NF) {
			case /15/ :
			{
				cas="15"
				sens="sortie"
				break
			}
			case /18/ :
			{
				cas="18"
				sens="sortie"
				break
			}
			case /^8$/ :
			{
				cas="8"
				sens="entr�e"
				break
			}
			default :
				# print FILENAME OFS nbfields OFS "rejet"
				nextfile

		}
		# nextfile
	}
	switch (cas) {
			case /15/ :
			{
				ref=$3
				sn=$8
				datemvt=$5
				datecrea=datemvt
				ref1=$2 # centre de cout
				ref2=$1 # num dossier
				ref3=$4 # Description
				# print FILENAME OFS nbfields OFS "sortie"				
				break
			}
			case /18/ :
			{
				ref=$6
				sn=$11
				datemvt=$8
				datecrea=$4
				ref1=$5 # centre de cout
				ref2=$1 # num dossier
				ref3=$7 # Description
				# print FILENAME OFS nbfields OFS "sortie"
				break
			}
			case /^8$/ :
			{
				ref=$2
				sn=$3
				datemvt=$4
				datecrea=datemvt
				ref1=$5 #apt
				ref2=$6 #libell�
				ref3=$8 #refappro
				# print FILENAME OFS nbfields OFS "entr�e"
				break
			}
			default :
				print FILENAME OFS nbfields OFS "rejet"
				nextfile

		}
	
	
	if (ref ~ /^CHR1[0-1].[^S]/) { toutes uc et portables non shipping
	# if (ref ~ /^CHR48.[^S]/) { # tout �quipement r�seau et serveurs
		# conversion en num�rique de la date du mouvement
		if (datemvt=="") datemvt=datecrea
		# valdate=split(datemvt,tabdate,"/")
		valdate=split(datemvt,tabdate,/\/| |:/)

		# debug
		# print NR OFS ref OFS sn OFS datemvt ODS datecrea OFS ref1 OFS ref2 OFS ref3 OFS valdate OFS
		# print NR OFS datemvt OFS clef OFS numdate OFS substr(ref,8) OFS ref1 OFS ref2 OFS ref3 OFS datemvt OFS cas

		# if (valdate < 3) next # si format de date invalide, pas la peine d'examiner l'enregistrement
		if (tabdate[4] == "") {
			tabdate[4]=12
			tabdate[5]=0
		}
		if (tabdate[3]<100) tabdate[3]=2000+tabdate[1]
		timestring=tabdate[3] " " tabdate[2] " " tabdate[1] " " tabdate[4] " " tabdate[5] " 00"
		timestring=timestring " 00"
		numdate=mktime(timestring)
		
		#debug
		# print NR OFS $4 OFS datemvt OFS timestring OFS numdate
		
		
		# d�termination de la clef
		if (sn ~ /[0-z]/) {
			clef=sn
		} else {
			clef=ref
		}
		if (arrdate[clef] =="") arrdate[clef]=2147483647 # date maximale
		if (arrdate[clef] > numdate) { # l'enregistrement courant est le plus ancien pour ce produit et devient donc la r�f�rence
			arrdate[clef]=numdate 
			arrprod[clef]=substr(ref,8) # les trois derniers caract�res de la r�f�rence identifient le type d'article
			arrref1[clef] = ref1
			arrref2[clef] = ref2
			arrref3[clef] = ref3
			arrsens[clef] = sens
		}
		

	}
}
END {
	print "s/n" OFS "anciennet�" OFS "produit" OFS "D�signation" OFS "sens" OFS "Dossier ou commande" OFS "APT ou CentreCout"
	for (clef in arrdate) {
		print clef OFS strftime("%F %H:%M:%S",arrdate[clef]) OFS arrprod[clef] OFS arrref3[clef] OFS arrsens[clef] OFS arrref2[clef] OFS arrref1[clef]
	}
}