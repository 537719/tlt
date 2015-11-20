#test.awk
# liste le nombre d'items correspondant à une séries de références dans un export de mouvements I&S
# reste à faire :
#	filtrer les retours à lignes intempestifs
	#	déjà fait dans un autre script, à exécuter au préalable
	#	08/09/2015  16:48               555 filtreCRLF.cmd
#	déterminer automatiquement si on lit un fichier d'entrées ou de sorties => fait le 09/09/2015 11:53
#		8 champs  => entrée => référence en $2
#		18 champs => sortie => référence en $6
#	déterminer automatiquement si la sortie concerne un incident, une demande, une rma ou une destruction => fait le 09/09/2015 15:53
#		DEL :	P5 et premier champ contient "DESTRUCTION"
#		RMA : 	P5 "non DEL" ou (P4 et code postal = 91019 (SPC) ou 94043 (LVI) ou ??? (Athesi))
#		dem :	P3 (shipping) P4 (métier)
#		inc :	P2
#	déterminer automatiquement si la réception concerne un appro, un retour client ou un retour de rma
#		RMA : 	Retour de RMA ou transfert : $2 (référence) contient un R en 6° position et $5 (APT) n'est pas vide et $6 (libellé) ne commence pas par RETOUR et est différent de 10  chiffres
#		RMA : 	Retour de RMA ou transfert : $2 (référence) contient un R en 6° position et $5 (APT) n'est pas vide et $6 (libellé) commence par RETOUR ou est composé de 10  chiffres et contient  SPC
#		CLI : 	Retour de RMA ou transfert : $2 (référence) contient un R en 6° position et $5 (APT) n'est pas vide et $6 (libellé) commence par RETOUR ou est composé de 10  chiffres et ne contient pas SPC
#		LIV :	Livraison de matériel neuf : $2 (référence) contient un N en 6° position et $5 (APT) n'est pas vide
#		LIV :	Livraison de matériel neuf : $2 (référence) contient un N en 6° position et $5 (APT) est vide et $6 (libellé) ne commence pas par RETOUR et est différent de 10  chiffres
#		CLI :	Retour client :              $2 (référence) contient un R en 6° position et $5 (APT) n'est pas est vide et $6 (libellé) commence par RETOUR ou est égal à 10  chiffres
#		CLI :	Retour client :              $2 (référence) contient un N en 6° position et $5 (APT) est vide et $6 (libellé) commence par RETOUR ou est égal à 10  chiffres
#		CLI :	Retour client :              $2 (référence) contient un R en 6° position et $5 (APT) est vide
#	faire un sous total par mois
#
# 30/09/2015 : #MODIF prise en compte de toutes les imprimantes Expeditor PV au lieu des seules e4204
# 21/08/2015 : #AJOUT prise en compte des références d'uc fixes Chronopost métier (hors UC HP pour PMC Wifi)
# 30/10/2015 : #AJOUT prise en compte des serveurs Chronopost, prise en compte des Datamax I4212 Coliposte
# 19/11/2015 : #AJOUT prise en compte du format "état des stocks"
# 19/11/2015 : #MODIF remplacement des références produit par les expressions régulières équivalentes
#
# exemples d'Invocation
#del stocks.txt&&for %I in (pv gv clpmet pfma clptp cisco rp chruc chrtp serveurs m3 ship zpl finger) do gawk -f test.awk -v materiel="%I"   stock\TEexport_20151119.csv >>stocks.txt
#del flux.txt&&for %I in (pv gv clpmet pfma clptp cisco rp chruc chrtp serveurs m3 ship zpl finger) do gawk -f test.awk -v materiel="%I"   IS_out_201511.csv >>flux.txt

BEGIN {
	if (mode=="") mode="RUN"
	# mode="DEBUG"
	FS=";"
	OFS="\t"
	if (mode==DEBUG) OFS=FS

	IGNORECASE=1 # spécifique à gawk

	fichier=""
	# nbligne=0
	
	nbfile=0
	nbvu=0
	champ=0
	nbrma=0
	nbdem=0
	nbinc=0
	nbdel=0
	nbliv=0
	nbcli=0
	
	# datemin="2037 12 31 23 59 59"	
	# datemax="1970 01 01 00 00 00"
	
	if (materiel =="" ) materiel="PFMA"
	
	#liste des références considérées comme concernant un même produit
	if (materiel ~ /PFMA/) {
		# listeref="Coliposte Imprimantes PFMA;CLP34NF194;CLP34RF194;CLP34NP194;CLP34NF1BD;CLP34RF1BD;CLP34NP1BD"
		listeref="Coliposte Imprimantes PFMA;CLP34[N|R][F|P]194;CLP34[N|R][F|P]1BD"
	} else if (materiel ~ /e420/||materiel ~ /PV/) {
		# listeref="Coliposte Expeditor PV;CLP34NS0CN;CLP34NS1AH;CLP34NS1AN;CLP34NS1AP;CLP34RS0CN;CLP34RS0E1;CLP34RS1A4;CLP34RS1AH;CLP34RS1AN;CLP34RS1AP;CLP34RS1B1"
		listeref="Coliposte Expeditor PV;CLP34[N|R]S0CN;CLP34[N|R]S1A[4|H|N|P];CLP34RS0E1;CLP34[N|R]S1B1"
	} else if (materiel ~ /4208|4212|CLPMET|DMXMET/) {
		# listeref="Coliposte Datamax Métier;CLP34NF0E2;CLP34NF15P;CLP34NP0E2;CLP34NP15P;CLP34NS0E2;CLP34RF15P;CLP34RP15P;CLP34RS0E2;CLP34RS15P;CLP34NF1BC;CLP34RF1BC;CLP34NP1BC;CLP34RP1BC"
		listeref="Coliposte Datamax Métier;CLP34[N|R][F|S|P]0E2;CLP34[N|R][F|P|S]15P;CLP34[N|R][F|P]1BC"
	} else if (materiel ~ /4206/||materiel ~ /GV/) {
		# listeref="Coliposte Expeditor GV;CLP34NF1AI;CLP34NP194;CLP34NP1AI;CLP34NS194;CLP34NS1AI;CLP34NS1AM;CLP34NS1AO;CLP34RF1AI;CLP34RS194;CLP34RS1AI;CLP34RS1AM;CLP34RS1AO"
		listeref="Coliposte Expeditor GV;CLP34[N|R][F|P|S]1A[I|M|O];CLP34[N|R][P|S]194"
	} else if (materiel ~ /inkpad|TP|rtable/) {
		if (materiel ~ /CLP/) {
			# listeref="Coliposte Portables;CLP11NF189;CLP11NF18K;CLP11NF18T;CLP11NF190;CLP11NF19S;CLP11NF19T;CLP11NP189;CLP11NP18T;CLP11NP19R;CLP11NP19S;CLP11NP19T;CLP11RF189;CLP11RF18K;CLP11RF18T;CLP11RF19T"
			listeref="Coliposte Portables;CLP11[N|R][F|P]189;CLP11[N|R]F18K;CLP11[N|R][F|P]1[8|9]T;CLP11[N|R][F|P]19[0|R|S]"
		} else if (materiel ~ /CHR/) {
			# listeref="Chronopost Portables;CHR11NF0X3;CHR11NF18A;CHR11NF18L;CHR11NF18S;CHR11NF18T;CHR11NF19S;CHR11NF19T;CHR11NF1BB;CHR11NF1BC;CHR11RF18A;CHR11RF18L;CHR11RF18S"
			listeref="Chronopost Portables;CHR11[N|R]F18[A|L|S|T];CHR11[N|R]F19[S|T];CHR11[N|R]F1B[B|C]"
		}		
	} else if (materiel ~ /UC/) {
		if (materiel ~ /CLP/) {
			listeref="Coliposte UC Métier;#undef"
		} else if (materiel ~ /CHR/) {
			listeref="Chronopost UC Métier;^CHR10.[^S]1A" # inclut toutes les UC Lenovo M78/M79 mais pas les M73, et hors shipping
		}		
	} else if (materiel ~ /RP|5[7-8]00/) {
		# listeref="Chronopost HP RP5700/RP5800;CHR10NF0DT;CHR10NF0VK;CHR10NF164;CHR10NF183;CHR10NF18M;CHR10NP0VK;CHR10NP164;CHR10NP18M;CHR10RF0DT;CHR10RF0VK;CHR10RF18M;CHR10RFZX6;CHR10RIKFX"
		listeref="Chronopost HP RP5700/RP5800;CHR10[N|R][F|P]0[DT|VK];CHR10[N|R][F|I|P]18[3|M];CHR10[N|R][F|P]164;CHR10RFZX6;CHR10RIKFX"
	} else if (materiel ~ /ifi|isco/) {
		# listeref="Chronopost cartes Wifi Cisco;CHR47NF0T7;CHR47NP0T7;CHR47RF0T7"
		listeref="Chronopost cartes Wifi Cisco;CHR47[N|R][F|P]0T7"
	} else if (materiel ~ /erveur/) {
		listeref="Chronopost Serveurs;^CHR48"
	} else if (materiel ~ /M3/) {
		# listeref="Chronopost PSM M3 Alaska;CHR63NP1AD;CHR63RP1AD"
		listeref="Chronopost PSM M3 Alaska;CHR63[N|R][P|F]1AD"
	} else if (materiel ~ /ship/) {
		# listeref="Chronopost UC Chronoship;^CHR10NS;^CHR10RS" # nouvelle formulation, indépendante des ajouts et suppressions de références
		listeref="Chronopost UC Chronoship;^CHR10[N|R]S" # nouvelle formulation, indépendante des ajouts et suppressions de références
	} else if (materiel ~ /ZPL/) {
		# listeref="Chronopost Chronoship ZPL;CHR34NS19M;CHR34RS19MCHR34RF18Q;CHR34NP18P;CHR34NF18Q;CHR34RS18Q;CHR34NS18Q;CHR34RF18P;CHR34RS18P;CHR34NF18P;CHR34NS18P"
		listeref="Chronopost Chronoship ZPL;CHR34[N|R]S19M;CHR34[N|R].18[P|Q]"
	} else if (materiel ~ /inger/) {
		# listeref="Chronopost Chronoship FingerPrint;CHR34RS18R;CHR34NS18R;CHR34RSZXT;CHR34NS0TK;CHR34RS0IT;CHR34RSZXS;CHR34NS0IT;CHR34RSZXZ;CHR34RSZY1;CHR34NS0LN;CHR34NS0KR;CHR34NS15B;CHR34RSZXV"
		listeref="Chronopost Chronoship FingerPrint;CHR34RS18R;CHR34NS18R;CHR34RSZXT;CHR34NS0TK;CHR34RS0IT;CHR34RSZXS;CHR34NS0IT;CHR34RSZXZ;CHR34RSZY1;CHR34NS0LN;CHR34NS0KR;CHR34NS15B;CHR34RSZXV"
	} else {
		print "materiel " materiel " non reconnu"
		print "cette routine ne fonctionne que pour les matériels suivants :"
		print "Coliposte : PFMA, PV, GV, 4208, Portable CLP"
		print "Chronopost : RP 5700 et RP 5800 , Wifi Cisco, Portable CHR, M3, UC Chronoship, Thermiques ZPL, Thermiques Fingerprint"
		exit 2
	}
	
	split(listeref,article,";")
	if (mode=="DEBUG") {
		for (i in ref) { # pour debug seulement
			print i OFS ref[i]
		}
	}

}
{	#MAIN
	if (DEBUG) print fichier OFS FILENAME OFS 
	if (fichier=="") fichier=FILENAME
	if (fichier != FILENAME ) {
		if (mode != "BATCH") print nbvu OFS article[1] OFS sens OFS "dont :"
		if (champ==2) { #fichier de réceptions
			if (mode != "BATCH") print "livraison" OFS "retours" OFS "RMA"
			print fichier OFS nbliv OFS nbcli OFS nbrma
		}
		if (champ==6) { #fichier d'expéditions
			if (mode != "BATCH") print "incidents" OFS "demandes" OFS "RMA" OFS "Destructions"
			print  fichier OFS nbinc OFS nbdem OFS nbrma OFS nbdel
		}
		nbvu=0
		champ=0
		nbrma=0
		nbdem=0
		nbinc=0
		nbdel=0
		nbliv=0
		nbcli=0
		nbOKdispo=0
		nbOKreserve=0
		nbSAV=0
		nbMaint=0
		nbDestr=0
		nbAliv=0
		
		fichier=FILENAME
	}
		
	if (NR==1) {
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
				if (mode=="DEBUG") print
			}
		}
		if (vu > 0) {	# catégorisation des cas
			if (sens=="en sortie") { # catégorisation des expéditions
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
			if (sens=="en réception") { # catégorisation des réceptions
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
			if (sens=="en stock") { #fichier d'état des stocks
				nbOKdispo=nbOKdispo+$4
				nbOKreserve=nbOKreserve+$5
				nbSAV=nbSAV+$6
				nbMaint=nbMaint+$7
				nbDestr=nbDestr+$8
				nbAliv=nbAliv+$9
			}
			# datebl=mktime(datestring)
			# if (datebl>datemax) datemax=datebl
			# if (datebl<datemin) datemin=datebl
		}
	}
}

END {
	# print "periode du " strftime(datemin) " au " strftime(datemax)
	if (mode != "BATCH") print nbvu OFS article[1] OFS sens OFS "dont :"
	if (sens=="en réception") { #fichier de réceptions
		if (mode != "BATCH") print "Fichier" OFS "livraison" OFS "retours" OFS "RMA"
		print FILENAME OFS nbliv OFS nbcli OFS nbrma
	}
	if (sens=="en stock") { #fichier d'état des stocks
		if (mode != "BATCH") print "Fichier" OFS "OkDispo" OFS "OkReserve" OFS "SAV" OFS "Maintenance" OFS "Destruction" OFS "A livrer"
		print FILENAME OFS nbOKdispo OFS nbOKreserve OFS nbSAV OFS nbMaint OFS nbDestr OFS nbAliv
	}
	if (sens=="en sortie") { #fichier d'expéditions
		if (mode != "BATCH") print "incidents" OFS "demandes" OFS "RMA" OFS "Destructions"
		print FILENAME OFS nbinc OFS nbdem OFS nbrma OFS nbdel
	}
	print ""

	# if (nbinc>0) print nbinc " incidents"
	# if (nbdem>0) print nbdem " demandes"
	# if (nbliv>0) print nbliv " livraisons"
	# if (nbcli>0) print nbcli " retours"
	# if (nbrma>0) print nbrma " RMA"
	# if (nbdel>0) print nbdel " Destructions"
}
