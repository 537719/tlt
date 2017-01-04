# ISsuivisorties.awk
# 07:27 21/04/2016
# Sorties de stock I&S synthétisées par famille

# Entrée : fichier csv d'export des produits expédiés par I&S
#	1 GLPI
#	2 Priorité
#	3 Provenance
#	4 DateCréation
#	5 CentreCout
#	6 Reference
#	7 Description
#	8 Date BL
#	9 Dépot
#	10 sDepot
#	11 Num Serie
#	12 Nom Client L
#	13 Adr1 L
#	14 Adr2 L
#	15 Adr3 L
#	16 CP L
#	17 Dep
#	18 Ville L

# Sortie : Table ventilant pour chaque famille : incidents/demandes/rma/destruction
# Famille;incident;demande;RMA;destruction;undef
# COLPV;34;49;30;0;0
# COLGV;7;2;3;0;0
# COLMET;1;0;1;0;0
# PFMA;0;0;0;0;0
# COLUC;0;5;0;0;0
# COLPORT;0;0;0;0;0
# WIFICISCO;4;0;0;0;0
# CHRRP;4;0;0;0;0
# CHRUC;4;72;0;0;0
# CHRPORT;0;9;0;0;0
# SERVEURS;0;3;0;0;0
# PSMM3;3;12;5;0;0
# UCSHIP;8;8;0;0;0
# ZPL;12;48;4;0;0
# FINGERPRINT;15;11;30;0;0
# SERIALISE;9;319;2;0;0
# DIVERS;6;885;0;0;0


# ATTENTION : Nécessite une version récente de GAWK pour fonctionner
#  (utilisation de switch/case et du compteur d'occurences {} dans les expressions régulièresà
#  OK avec la GNU Awk 4.1.3 fournie avec MSYS32/MSYS64

# HISTORIQUE : applique les mêmes règles que 12/02/2016  12:55             14653 test.awk mais avec les différences suivantes :
# test.awk :
#	s'adapte indifféremment à trois types de fichiers d'entrée (entrées, sorties, état des stocks)
#	travaille sur une seule famille à la fois, spécifié en tant qu'option sur la ligne de commande
#	fournit un résultat sous forme de texte séparé par tabulations (csv sur demande)
#	ne fournit pas de compte d'éléments non catégorisés
# ISsuivisorties.awk :
#	ne travaille que sur les fichiers de sortie de stocks (d'autres scripts équivalents seront à faire pour traiter les entrées et les stocks), sans options sur la ligne de commande
#	fournit un résultat sous forme de csv
#	comptabilise les éléments ne rentrant dans aucune catégorie, ainsi que le total d'éléments n'appartenant pas aux familles de produits suivies


# MODIF 11:19 lundi 25 avril 2016 : Affiche le nom du fichier d'entrée dans l'en-tête du fichier résultat
# BUG 11:19 lundi 25 avril 2016 : Correction d'une erreur dans le code postal de SPC qui conduisait à une affectation en "undef" de sorties de "RMA"
# BUG 11:49 lundi 25 avril 2016 : Correction des références à parser pour affectation à certaines familles
# MODIF 11:59 lundi 25 avril 2016 : changement de l'ordre de l'examen des case afin de sortir par un break le plus vite possible => gain de 5 à 10 % en vitesse d'exécution
# BUG 15:44 lundi 25 avril 2016 : correction de la sélection d'UC "COL"
# MODIF 11:15 lundi 13 juin 2016 prise en compte de l'ajout du numéro de tag I&S dans le champ $19 (dont le libellé NumTag n'apparait pas dans la ligne d'en-tête)
# BUG 11:17 lundi 13 juin 2016correction du fait que EXIT ne fonctionne pas au coeur de la section "MAIN" (mais ok dans END)

BEGIN {
	FS=";"
	OFS=";"
	IGNORECASE=1
	codesortie=0
	
	# Obligation de pré-définir les array afin de maitriser l'ordre de présentation des résultats
	types[1]="incident"
	types[2]="demande"
	types[3]="RMA"
	types[4]="destruction"
	types[5]="undef"
	
	familles[1]="COLPV"
	familles[2]="COLGV"
	familles[3]="COLMET"
	familles[4]="PFMA"
	familles[5]="COLUC"
	familles[6]="COLPORT"
	familles[7]="WIFICISCO"
	familles[8]="CHRRP"
	familles[9]="CHRUC"
	familles[10]="CHRPORT"
	familles[11]="SERVEURS"
	familles[12]="PSMM3"
	familles[13]="UCSHIP"
	familles[14]="ZPL"
	familles[15]="FINGERPRINT"
	familles[16]="SERIALISE"
	familles[17]="DIVERS"
	
	for (i in familles) for (j in types) nbsorties[familles[i] types[j]]=0 # afin de ne pas avoir de "cases vides" à la sortie

}
{ #MAIN
	# définition des champs 
	priorite=$2
	reference=$6
	dossier=$1
	codep=$16
	dest=$12
	sn=$11
	
	if (NR==1) {
		if ( NF != 18 && NF != 19 ) {
			print "Ce fichier n'est pas du type requis car il contient " NF " champs."
			codesortie=NF
			# exit NF
		}
	} else {
		
		# détermination du type de sortie
	#	déterminer automatiquement si la sortie concerne un incident, une demande, une rma ou une destruction 
	#		DEL :	P5 et premier champ contient "DESTRUCTION"
	#		RMA : 	P5 "non DEL" ou (P4 et code postal = 91019 (SPC) ou 94043 (LVI)) ou (P2 et codepostal=94360 (Athesi))
	#		dem :	P3 (shipping) P4 (métier)
	#		inc :	P2
		switch (priorite) {
			case /P[3-4]/ : 
			{
				type="demande"
				if (codep==91019||codep==94043) type="RMA"
				break
			}
			case /P2/ :
			{
				type="incident"
				if (codep==94360) type="RMA"
				break
			}
			case /P5/ :
			{
				switch (dossier) {
					case /NAVETTE|RMA|PSM|LVI|SPC/ :
					{
						type="RMA"
						break;
					}
					case /DESTRUCT/ :
					{
						type="destruction"
						break;
					}
					default :
					{
						type="undef"
					}
				}
				if (type=="undef") switch (codep) {
					case /91019/ : #SPC
					{
						type="RMA"
						break;
					}
					case /94360/ : # ATHESI
					{
						type="RMA"
						break;
					}
					case /9444[0-3]/ : # LVI
					{
						type="RMA"
						break;
					}
					default :
					{
						type="undef"
					}
				}
				break
			}
			default :
			{
				type="undef"
			}
		}
		
		# détermination de la famille de produits
		switch (reference) { # corriger les expressions régulières en fonction des critères précis
			case /CHR34RS18R|CHR34NS18R|CHR34RSZXT|CHR34NS0TK|CHR34RS0IT|CHR34RSZXS|CHR34NS0IT|CHR34RSZXZ|CHR34RSZY1|CHR34NS0LN|CHR34NS0KR|CHR34NS15B|CHR34RSZXV/ :
			{
				famille="FINGERPRINT"
				break
			}
			case /CHR34[N|R]S19M|CHR34[N|R].18[P|Q]/ : # pc43d ZPL et pm43c
			{
				famille="ZPL"
				break
			}
			case /CLP34[N|R]S0CN|CLP34[N|R]S1A[4|H|N|P]|CLP34RS0E1|CLP34[N|R]S1B1/ : 
			{
				famille="COLPV"
				break
			}
			case /^CHR10.[^S]1[A-C]/ : # inclut toutes les UC Lenovo M78/M79 mais pas les M73, et hors shipping - rajouter les dell
			{
				famille="CHRUC"
				break
			}
			case /CHR10.S/ :
			{
				famille="UCSHIP"
				break
			}
			case /^CLP10/ : 
			{
				famille="COLUC"
				break
			}
			case /CLP11[N|R][F|P]189|CLP11[N|R]F18K|CLP11[N|R][F|P]1[8|9]T|CLP11[N|R][F|P]19[0|R|S]/ : 
			{
				famille="COLPORT"
				break
			}
			case /CLP34[N|R][F|P|S]1A[I|M|O]|CLP34[N|R]S194/ : 
			{
				famille="COLGV"
				break
			}
			case /CLP34[N|R][F|P]194|CLP34[N|R][F|P]1BD/ :
			{
				famille="PFMA"
				break
			}
			case /CLP34[N|R][F|S|P]0E2|CLP34[N|R][F|P|S]15P|CLP34[N|R][F|P]1BC|CLP34[N|R][F|P]13K/ :
			{
				famille="COLMET"
				break
			}
			case /CHR10[N|R][F|P]0[DT|VK]|CHR10[N|R][F|I|P]18[3|M]|CHR10[N|R][F|P]164|CHR10RFZX6|CHR10RIKFX/ :
			{
				famille="CHRRP"
				break
			}
			case /CHR47[N|R][F|P]0T7/ :
			{
				famille="WIFICISCO"
				break
			}
			case /CHR11[N|R][F|P]1../ : # - rajouter les dell
			{
				famille="CHRPORT"
				break
			}
			case /^CHR48/ :
			{
				famille="SERVEURS"
				break
			}
			case /CHR63[N|R][P|F]1AD/ :
			{
				famille="PSMM3"
				break
			}

			default :
			{
				if (sn ~ /./) {
					famille="SERIALISE"
				} else {
					famille="DIVERS"
				}
			}
		}
		# types[type]++
		# familles[famille]++
		nbsorties[famille type]++
		# print NR OFS type OFS types[type] OFS famille OFS familles[famille]
	}
}

END {
	if (codesortie !=0) exit codesortie
	
	ligne= FILENAME 
	for (j=1;j<=5;j++) ligne= ligne OFS types[j] 
	print ligne
	for (i in familles) {
		ligne= familles[i] 
		for (j=1;j<=5;j++) ligne=ligne OFS nbsorties[familles[i] types[j]]
		print ligne
	}
}
