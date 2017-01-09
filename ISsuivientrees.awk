# ISsuivientrees.awk
# 15:38 lundi 25 avril 2016
# d'apr�s
# ISsuivisorties.awk
# 07:27 21/04/2016
# Entr�es en stock I&S synth�tis�es par famille

# Entr�e : fichier csv d'export des produits re�us par I&S
# 1 Projet
# 2 Reference
# 3 Numero Serie
# 4 DateEntree
# 5 APT
# 6 Libell�
# 7 BonTransport
# 8 RefAppro
# 9 NumTag (� partir de 06/2016)
#10 (vide) (dans la ligne d'en-t�te uniquement)

# Sortie : Table ventilant pour chaque famille : Livraisons/retours cient/retours RMA/
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


# ATTENTION : N�cessite une version r�cente de GAWK pour fonctionner
#  (utilisation de switch/case et du compteur d'occurences {} dans les expressions r�guli�res�
#  OK avec la GNU Awk 4.1.3 fournie avec MSYS32/MSYS64

# HISTORIQUE : applique les m�mes r�gles que 12/02/2016  12:55             14653 test.awk mais avec les diff�rences suivantes :
# test.awk :
#	s'adapte indiff�remment � trois types de fichiers d'entr�e (entr�es, sorties, �tat des stocks)
#	travaille sur une seule famille � la fois, sp�cifi� en tant qu'option sur la ligne de commande
#	fournit un r�sultat sous forme de texte s�par� par tabulations (csv sur demande)
#	ne fournit pas de compte d'�l�ments non cat�goris�s
# ISsuivientrees.awk :
#	ne travaille que sur les fichiers d'entr�e en stock (d'autres scripts �quivalents traitent les sorties et les stocks), sans options sur la ligne de commande
#	fournit un r�sultat sous forme de csv
#	comptabilise les �l�ments ne rentrant dans aucune cat�gorie, ainsi que le total d'�l�ments n'appartenant pas aux familles de produits suivies

# MODIF 10:44 jeudi 9 juin 2016 prise en compte de l'ajout du num�ro de tag I&S dans le champ $9 NumTag (et prise en compte d'une erreur dans le fichier de donn�es qui contient un 1� champ, vide)
# BUG 11:17 lundi 13 juin 2016correction du fait que EXIT ne fonctionne pas au coeur de la section "MAIN" (mais ok dans END)
# MODIF 11:30 jeudi 23 juin 2016 (temporaire) sous ventilation rp5700/rp5800 pour �tude de la pertinence de la r�utilisation de tel ou tel mod�le (incompatible avec la ventilation group�e de tous les RP)
# MODIF 10:09 mardi 20 septembre 2016 rajoute la prise en compte des UC dites "d�veloppeur" (M73 i7 et M700) ainsi que des UC DELL
#  la raison du rajout des uc dev est double
#    d'une part des m73 i5 (non dev) ont �t� mis par erreur sous la ref des i7 (alors qu'il n'y en a plus en stock)
#    d'autre part compte tenu de la nomenclature des r�f�rence et de l'ajout des nouveaux mod�les, maintenir la distinction entretenait lourdeur et complexit�, source de bugs
# MODIF 15:41 vendredi 4 novembre 2016 ajout des nouvelles r�f de portables COLI
# MODIF 14:49 lundi 9 janvier 2017 correction de la cat�gorie des PM43C Shipping, qui sont en fait Fingerprint et non ZPL

BEGIN {
	FS=";"
	OFS=";"
	IGNORECASE=1
	codesortie=0
	
	# Obligation de pr�-d�finir les array afin de maitriser l'ordre de pr�sentation des r�sultats
	types[1]="Livraison"
	types[2]="Retour"
	types[3]="RMA"
	types[4]="undef"
	
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
	familles[18]="RP5700"
	familles[19]="RP5800"
	
	for (i in familles) for (j in types) nbentrees[familles[i] types[j]]=0 # afin de ne pas avoir de "cases vides" � la sortie

	}
{ #MAIN
	# d�finition des champs 
		reference=$2
		apt=$5
		lib=$6
		status=""
		type="undef"
	
	if (NR==1) {
		if ( NF !=8 && NF != 9 && NF != 10 ) {
			print "Ce fichier n'est pas du type requis car il contient " NF " champs."
			codesortie = NF
		}
		# if ($10 ~ /./) {
			# print "Ce fichier n'est pas du type requis car il contient un champ " $10 "."
			# codesortie = NF
		# }
	} else {
		
		# d�termination du type d'entr�e 
#	d�terminer automatiquement si la r�ception concerne un appro, un retour client ou un retour de rma
#		RMA : 	Retour de RMA ou transfert : $2 (r�f�rence) contient un R en 6� position et $5 (APT) n'est pas vide et $6 (libell�) ne commence pas par RETOUR et est diff�rent de 10  chiffres
#		RMA : 	Retour de RMA ou transfert : $2 (r�f�rence) contient un R en 6� position et $5 (APT) n'est pas vide et $6 (libell�) commence par RETOUR ou contient RMA ou SPC, ou est compos� de 10  chiffres et contient  SPC
#		CLI : 	Retour de RMA ou transfert : $2 (r�f�rence) contient un R en 6� position et $5 (APT) n'est pas vide et $6 (libell�) commence par RETOUR ou est compos� de 10  chiffres et ne contient pas SPC ni RMA
#		LIV :	Livraison de mat�riel neuf : $2 (r�f�rence) contient un N en 6� position et $5 (APT) n'est pas vide
#		LIV :	Livraison de mat�riel neuf : $2 (r�f�rence) contient un N en 6� position et $5 (APT) est vide et $6 (libell�) ne commence pas par RETOUR et est diff�rent de 10  chiffres
#		CLI :	Retour client :              $2 (r�f�rence) contient un R en 6� position et $5 (APT) n'est pas est vide et $6 (libell�) commence par RETOUR ou est �gal � 10  chiffres
#		CLI :	Retour client :              $2 (r�f�rence) contient un N en 6� position et $5 (APT) est vide et $6 (libell�) commence par RETOUR ou est �gal � 10  chiffres
#		CLI :	Retour client :              $2 (r�f�rence) contient un R en 6� position et $5 (APT) est vide
		if (reference ~ /^[A-Z][A-Z][A-Z][0-9][0-9]R/) {	# R en 6� position de la r�f�rence I&S
			status="recond"
			if (apt ~ /./) { # APT non vide
				status = status OFS "avec apt"
				if (lib ~ /^RETOUR|[0-9]{10}/) { # Libell� commence par RETOUR ou est compos� de 10 chiffres
					if (lib ~ /SPC|RMA/) {
						type="RMA"
					} else {
						type="Retour"
					}
				} else {
					type="RMA"
				}					
			} else {
				type="Retour"
			}
		}
		if (reference ~ /^[A-Z]{3}[0-9][0-Z]N/) {	# N en 6� position de la r�f�rence I&S
			if (apt ~ /./) { # APT non vide
				if (lib ~ /^RETOUR|RMA|[0-9]{10}$/) { # Libell� commence par RETOUR, contient RMA ou  se termine par 10 chiffres
					type="Retour"
				} else {
					type="Livraison"
				}
			} else {
				if (lib ~ /^RETOUR|[0-9]{10}$/) { # Libell� commence par RETOUR ou se termine par 10 chiffres
					type="Retour"
				} else {
					type="Livraison"
				}
			}
		}
		
		# d�termination de la famille de produits
		switch (reference) { # corriger les expressions r�guli�res en fonction des crit�res pr�cis
			case /CHR34[N|R]S19M|CHR34RS18R|CHR34NS18R|CHR34RSZXT|CHR34NS0TK|CHR34RS0IT|CHR34RSZXS|CHR34NS0IT|CHR34RSZXZ|CHR34RSZY1|CHR34NS0LN|CHR34NS0KR|CHR34NS15B|CHR34RSZXV/ :
			{
				famille="FINGERPRINT"
				break
			}
			case /CHR34[N|R].18[P|Q]/ : # pc43d ZPL
			{
				famille="ZPL"
				break
			}
			case /CLP34[N|R]S0CN|CLP34[N|R]S1A[4|H|N|P]|CLP34RS0E1|CLP34[N|R]S1B1/ : 
			{
				famille="COLPV"
				break
			}
			case /^CHR10.[^S]1[A-D]/ : # inclut toutes les UC Lenovo M78/M79 y compris les poses d�veloppeurs (M73 i7 et m700) ainsi que les uc dell, et hors shipping
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
			case /CLP11[N|R][F|P]189|CLP11[N|R]F18K|CLP11[N|R][F|P]1[8|9]T|CLP11[N|R][F|P]19[0|R|S]|CLP11[N|R][F|P]1D./ : 
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
			case /CHR10[N|R][F|P]0[DT|VK]|CHR10[N|R][F|I|P]183|CHR10[N|R][F|P]164|CHR10RFZX6|CHR10RIKFX/ :
			{
				famille="RP5700"
				# break
			}
			case /CHR10[N|R][F|I|P]18M/ :
			{
				famille="RP5800"
				# break
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
		nbentrees[famille type]++
		# print NR OFS type OFS types[type] OFS famille OFS familles[famille]
	}
}

END {
	if (codesortie !=0) exit codesortie
	
	ligne= FILENAME 
	for (j=1;j<=4;j++) ligne= ligne OFS types[j] 
	print ligne
	for (i in familles) {
		ligne= familles[i] 
		for (j=1;j<=4;j++) ligne=ligne OFS nbentrees[familles[i] types[j]]
		print ligne
	}
}
