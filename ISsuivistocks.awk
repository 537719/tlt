# ISsuivistocks.awk
# 14:11 lundi 25 avril 2016
# d'apr�s
# ISsuivisorties.awk
# 07:27 21/04/2016
# Etat des stock I&S synth�tis� par famille

# Entr�e : fichier csv d'�tat des stocks I&S
# 1 Projet
# 2 Reference
# 3 Designation
# 4 OkDispo
# 5 OkReserve
# 6 SAV
# 7 Maintenance
# 8 Destruction
# 9 A livrer

# Sortie : Table ventilant pour chaque famille la quantit� d'articles dans chacun des �tats suivants : OkDispo	OkReserve	SAV	Maintenance	Destruction	A livrer
# stock\TEexport_20160424.csv;OKdispo;OKreserve;SAV;Maintenance;Destruction;aLivrer
# COLPV;346;0;4;10;0;369
# COLGV;126;0;0;0;0;4
# COLMET;26;0;2;1;0;11
# PFMA;4;0;0;0;0;3
# COLUC;31;4;0;2;28;18
# COLPORT;1;0;0;2;2;5
# WIFICISCO;0;0;0;10;0;0
# CHRRP;10;1;0;1;18;0
# CHRUC;294;6;0;3;1;206
# CHRPORT;4;4;3;0;1;162
# SERVEURS;77;0;0;0;0;2
# PSMM3;48;1;0;0;0;56
# UCSHIP;25;0;0;21;80;50
# ZPL;461;2;0;16;0;20
# FINGERPRINT;860;0;0;17;95;0
# SERIALISE;105;2;4;8;11;86
# DIVERS;16011;571;12;70;307;3866


# ATTENTION : N�cessite une version r�cente de GAWK pour fonctionner
#  (utilisation de switch/case et du compteur d'occurences {} dans les expressions r�guli�res�
#  OK avec la GNU Awk 4.1.3 fournie avec MSYS32/MSYS64

# HISTORIQUE : applique les m�mes r�gles que 12/02/2016  12:55             14653 test.awk mais avec les diff�rences suivantes :
# test.awk :
#	s'adapte indiff�remment � trois types de fichiers d'entr�e (entr�es, sorties, �tat des stocks)
#	travaille sur une seule famille � la fois, sp�cifi� en tant qu'option sur la ligne de commande
#	fournit un r�sultat sous forme de texte s�par� par tabulations (csv sur demande)
#	ne fournit pas de compte d'�l�ments non cat�goris�s
# ISsuivistocks.awk :
#	ne travaille que sur les fichiers d'�tat des stocks (d'autres scripts �quivalents seront � faire pour traiter les entr�es et les sorties), sans options sur la ligne de commande
#	fournit un r�sultat sous forme de csv
#	comptabilise le total d'�l�ments n'appartenant pas aux familles de produits suivies

# MODIF 11:08 lundi 13 juin 2016 prise en compte de l'ajout du num�ro de tag I&S dans l'export des sorties, qui peut maintenant compter autant de champs que l'�tat des stocks
# BUG 11:17 lundi 13 juin 2016correction du fait que EXIT ne fonctionne pas au coeur de la section "MAIN" (mais ok dans END)
# MODIF 10:09 mardi 20 septembre 2016 rajoute la prise en compte des UC dites "d�veloppeur" (M73 i7 et M700) ainsi que des UC DELL
#  la raison du rajout des uc dev est double
#    d'une part des m73 i5 (non dev) ont �t� mis par erreur sous la ref des i7 (alors qu'il n'y en a plus en stock)
#    d'autre part compte tenu de la nomenclature des r�f�rence et de l'ajout des nouveaux mod�les, maintenir la distinction entretenait lourdeur et complexit�, source de bugs
# MODIF 15:41 vendredi 4 novembre 2016 ajout des nouvelles r�f de portables COLI
# MODIF 14:49 lundi 9 janvier 2017 correction de la cat�gorie des PM43C Shipping, qui sont en fait Fingerprint et non ZPL
# MODIF 15/02/2018 - 15:33:53 exporte dans un module externe � inclure toutes les routines communes � la famille "ISstatsXXX"

    @include "ISsuiviInclude.awk"
BEGIN {
	FS=";"
	OFS=";"
	IGNORECASE=1
	codesortie=0
	
	# Obligation de pr�-d�finir les array afin de maitriser l'ordre de pr�sentation des r�sultats
	# num�rotation � partir de 4 afin de coller avec l'indexation des champs
	types[4]="OKdispo"
	types[5]="OKreserve"
	types[6]="SAV"
	types[7]="Maintenance"
	types[8]="Destruction"
	types[9]="aLivrer"
	
    initfamilles()
    zerofamilles()
}
{ #MAIN
	# d�finition des champs 
	reference=$2
	
	if (NR==1) {
		if (NF!=9) {
			erreurnf(NF)
			codesortie = NF
		} else {
			if ($0 !~ /Ok/ ) {
				print "Ce fichier n'est pas un �tat des stocks"
				codesortie = NF
			}
		}
	} else {
		
		# Ventilation selon l'�tat en stock
		OKdispo=$4
		OKreserve=$5
		SAV=$6
		Maint=$7
		Destr=$8
		Aliv=$9

        famille=selectfamille(reference) # d�termination de la famille de produits, la r�f�rence du produit �tant pass�e en param�tre
		for (i in types) {
			nbstock[famille i] = nbstock[famille i]+$i
		}
		# print NR OFS type OFS types[type] OFS famille OFS familles[famille]
	}
}

END {
	if (codesortie !=0) exit codesortie
	
	ligne= "!" FILENAME 
	for (j=4;j<=9;j++) ligne= ligne OFS types[j] 
	print ligne
	for (i in familles) {
		ligne= familles[i] 
		# for (j=4;j<=9;j++) ligne=ligne OFS nbstock[familles[i] types[j]]
		for (j in types) ligne = ligne OFS nbstock[familles[i] j]
		print ligne
	}
}