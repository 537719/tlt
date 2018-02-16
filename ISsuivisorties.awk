# ISsuivisorties.awk
# 07:27 21/04/2016
# Sorties de stock I&S synth�tis�es par famille

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


# MODIF 11:19 lundi 25 avril 2016 : Affiche le nom du fichier d'entr�e dans l'en-t�te du fichier r�sultat
# BUG 11:19 lundi 25 avril 2016 : Correction d'une erreur dans le code postal de SPC qui conduisait � une affectation en "undef" de sorties de "RMA"
# BUG 11:49 lundi 25 avril 2016 : Correction des r�f�rences � parser pour affectation � certaines familles
# MODIF 11:59 lundi 25 avril 2016 : changement de l'ordre de l'examen des case afin de sortir par un break le plus vite possible => gain de 5 � 10 % en vitesse d'ex�cution
# BUG 15:44 lundi 25 avril 2016 : correction de la s�lection d'UC "COL"
# MODIF 11:15 lundi 13 juin 2016 prise en compte de l'ajout du num�ro de tag I&S dans le champ $19 (dont le libell� NumTag n'apparait pas dans la ligne d'en-t�te)
# BUG 11:17 lundi 13 juin 2016correction du fait que EXIT ne fonctionne pas au coeur de la section "MAIN" (mais ok dans END)
# MODIF 10:09 mardi 20 septembre 2016 rajoute la prise en compte des UC dites "d�veloppeur" (M73 i7 et M700) ainsi que des UC DELL
#  la raison du rajout des uc dev est double
#    d'une part des m73 i5 (non dev) ont �t� mis par erreur sous la ref des i7 (alors qu'il n'y en a plus en stock)
#    d'autre part compte tenu de la nomenclature des r�f�rence et de l'ajout des nouveaux mod�les, maintenir la distinction entretenait lourdeur et complexit�, source de bugs
# MODIF 15:41 vendredi 4 novembre 2016 ajout des nouvelles r�f de portables COLI
# MODIF 14:49 lundi 9 janvier 2017 correction de la cat�gorie des PM43C Shipping, qui sont en fait Fingerprint et non ZPL
# MODIF 29/01/2018 - 14:45:04 apr�s crash disque : prise en compte des champs 20 � 22 dans le fichier d'entr�e
# MODIF 12/02/2018 - 16:06:19 exporte dans un module externe � inclure toutes les routines communes � la famille "ISstatsXXX"

    @include "ISsuiviInclude.awk"
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
	
    initfamilles()
    zerofamilles()
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
			erreurnf(NF)
            codesortie=NF
		}
	} else {
		switch (priorite) { # d�termination du type de sortie
	#	d�terminer automatiquement si la sortie concerne un incident, une demande, une rma ou une destruction 
	#		DEL :	P5 et premier champ contient "DESTRUCTION"
	#		RMA : 	P5 "non DEL" ou (P4 et code postal = 91019 (SPC) ou 94043 (LVI)) ou (P2 et codepostal=94360 (Athesi))
	#		dem :	P3 (shipping) P4 (m�tier)
	#		inc :	P2
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
        famille=selectfamille(reference) # d�termination de la famille de produits, la r�f�rence du produit �tant pass�e en param�tre
		nbsorties[famille type]++
	}
}

END {
	if (codesortie !=0) exit codesortie
	affiche(1,5,types,familles,nbsorties)
}
