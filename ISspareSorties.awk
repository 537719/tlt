# ISspareSorties.awk
# 17:00 mardi 29 novembre 2016
# d'apr�s ISsuivisorties.awk 07:27 21/04/2016 MODIF 15:41 vendredi 4 novembre 2016
# Sorties de stock I&S synth�tis�es par famille demandant un suivi de r�appro des stocks de spare
# � la date de cr�ation du script, concerne :
# les sorties d'imprimantes expeditor vs le stock d'�tiquettes colissimo
# les sorties d'uc colissimp et chronopost reconditionn�es vs les stocks respectifs de claviers et souris

# Entr�e : fichier csv d'export des produits exp�di�s par I&S
#	1 GLPI
#	2 Priorit�
#	3 Provenance
#	4 DateCr�ation
#	5 CentreCout
#	6 Reference
#	7 Description
#	8 Date BL
#	9 D�pot
#	10 sDepot
#	11 Num Serie
#	12 Nom Client L
#	13 Adr1 L
#	14 Adr2 L
#	15 Adr3 L
#	16 CP L
#	17 Dep
#	18 Ville L
# 19 Tagis
# 20 Societe L
# 21 NumeroOfl
# 22  Pays de destination

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


# ATTENTION : N�cessite une version r�cente de GAWK pour fonctionner
#  (utilisation de switch/case et du compteur d'occurences {} dans les expressions r�guli�res�
#  OK avec la GNU Awk 4.1.3 fournie avec MSYS32/MSYS64

# HISTORIQUE : applique les m�mes r�gles que 12/02/2016  12:55             14653 test.awk mais avec les diff�rences suivantes :
# test.awk :
#	s'adapte indiff�remment � trois types de fichiers d'entr�e (entr�es, sorties, �tat des stocks)
#	travaille sur une seule famille � la fois, sp�cifi� en tant qu'option sur la ligne de commande
#	fournit un r�sultat sous forme de texte s�par� par tabulations (csv sur demande)
#	ne fournit pas de compte d'�l�ments non cat�goris�s
# ISsuivisorties.awk :
#	ne travaille que sur les fichiers de sortie de stocks (d'autres scripts �quivalents seront � faire pour traiter les entr�es et les stocks), sans options sur la ligne de commande
#	fournit un r�sultat sous forme de csv
#	comptabilise les �l�ments ne rentrant dans aucune cat�gorie, ainsi que le total d'�l�ments n'appartenant pas aux familles de produits suivies
# MODIF 29/01/2018 - 14:45:04 apr�s crash disque : prise en compte des champs 20 � 22 dans le fichier d'entr�e


BEGIN {
	FS=";"
	OFS=";"
	IGNORECASE=1
	codesortie=0
	
	# Obligation de pr�-d�finir les array afin de maitriser l'ordre de pr�sentation des r�sultats
	types[1]="incident"
	types[2]="demande"
	types[3]="RMA"
	types[4]="destruction"
	types[5]="undef"
	
	# familles[1]="COLPV"
	# familles[2]="COLGV"
	# familles[3]="COLMET"
	# familles[4]="PFMA"
	# familles[5]="COLUC"
	# familles[6]="COLPORT"
	# familles[7]="WIFICISCO"
	# familles[8]="CHRRP"
	# familles[9]="CHRUC"
	# familles[10]="CHRPORT"
	# familles[11]="SERVEURS"
	# familles[12]="PSMM3"
	# familles[13]="UCSHIP"
	# familles[14]="ZPL"
	# familles[15]="FINGERPRINT"
	# familles[16]="SERIALISE"
	# familles[17]="DIVERS"
	familles[18]="EXPEDITOR"
	familles[19]="COLRECOND"
	familles[20]="CHRRECOND"
	
	for (i in familles) for (j in types) nbsorties[familles[i] types[j]]=0 # afin de ne pas avoir de "cases vides" � la sortie

}
{ #MAIN
	# d�finition des champs 
	priorite=$2
	reference=$6
	dossier=$1
	codep=$16
	dest=$12
	sn=$11
	
	if (NR==1) {
		if ( NF != 18 && NF != 19  && NF != 22 ) {
			print "Ce fichier n'est pas du type requis car il contient " NF " champs."
			codesortie=NF
			# exit NF
		}
	} else {
		
		# d�termination du type de sortie
	#	d�terminer automatiquement si la sortie concerne un incident, une demande, une rma ou une destruction 
	#		DEL :	P5 et premier champ contient "DESTRUCTION"
	#		RMA : 	P5 "non DEL" ou (P4 et code postal = 91019 (SPC) ou 94043 (LVI)) ou (P2 et codepostal=94360 (Athesi))
	#		dem :	P3 (shipping) P4 (m�tier)
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
		
		# d�termination de la famille de produits
		switch (reference) { # corriger les expressions r�guli�res en fonction des crit�res pr�cis
			case /^CLP34[N|R]S/ :
			{
				famille="EXPEDITOR"
				break
			}
			case /^CLP10R/ :
			{
				famille="COLRECOND"
				break
			}
			case /^CHR10R[F|P|I]/ :
			{
				famille="CHRRECOND"
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
	# print ligne
	for (i in familles) {
		ligne= familles[i] 
		# ligne= FILENAME OFS familles[i] 
		for (j=1;j<=5;j++) ligne=ligne OFS nbsorties[familles[i] types[j]]
		print ligne
	}
}
