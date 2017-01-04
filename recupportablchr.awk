# recupportablchr.awk
# 15:51 vendredi 1 avril 2016
#
# Parcours un export d'autonomie GLPI filtré de ses retours à la lignes parasites (glpi.txt produit par application d'un filtrestat.cmd sur un glpi.csv)
# de manière à en faire ressortir les pc portables à récupérer
# règle :  dossiers clos de demande de pc portables chronopost pour un utilisateur existant
# dossiers portables chrono clos
# $0	/(PMY *[0-9]{5})/g	\\1 = nom(s) de poste(s) (ancien et/ou nouveau)
# $1	id	N° glpi
# $2	Entité	/Chronopost$/
# $5	Emplacement
# $7	Catégorie	/^Demande de matériel &gt; Nouveau poste de travail &gt; Demande d'un PORTABLE /
# $10	Titre	/pour (.*)/	\\1 = nom d'utilisateur
# $11	Description	 !~ /Nouvel utilisateur/ && ~ /Utilisateur existant/	Confirmation du fait qu'il y a un portable à récupérer
# $11	Description	/Justification = (*)/	\\1 = nom d'utilisateur ou ancien poste
# $33	Type	/Demande/
# $31	Historique	/I&S_/	=> ne sélectionne que les dossiers passés chez I&S (on oublie donc ceux qui ont éventuellement été annulés avant)
#
# MODIF 16:09 vendredi 8 avril 2016 délectionne les dossiers n'étant pas passés chez I&S
# MODIF 16:09 vendredi 8 avril 2016 supprime les doubles quotes dans le numéro de dossier
# MODIF 10:38 lundi 11 avril 2016 remplace "glpi" par "Libell�" dans l'en-t�te du fichier r�sultat pour que les join ult�rieurs puissent prendre l'en-t�te
# MODIF 10:52 mardi 12 avril 2016 r�cup�re correctement tous les noms de pc mentionn�s et non juste quuelques uns - N�cessite GNU Awk 4.1.3

BEGIN {
	IGNORECASE=1
	FS="\0"
	OFS=";"
	print "Libell�" OFS "ouvert" OFS "clos" OFS "resolu" OFS "site" OFS "qui" OFS "pc" OFS "justif"
}
{	#MAIN
	if ($2 ~ /CHRONOPOST\"$/) {	#chronopost  "non shipping"
		if ($33 ~ /Demande/) if ($31 ~ /I&S_/) {
			if ($7 ~ /Demande de mat.*Nouveau poste de travail.* PORTABLE/) {
				if ($11 ~/Utilisateur existant/ && $11 !~ /Nouvel utilisateur/) {
					delete postes
					pc=""
					id=gensub(/\42/,"","g",$1)
					empl=gensub(/ &gt; /,">","g",$5)
					qui=gensub(/.*pour (.*)\"$/,"\\1",1,$10)
					# pc=gensub(/.*(P[M|B|G|L|P][I|G|P|Y]) *([0-9][0-9][0-9][0-9][0-9]).*/,"\\1\\2","g",$0)
					n=split($0,garbage,/P[M|B|G|L|P][I|G|P|Y] *:* *[O|0-9]{5}/,postes)
					asort(postes)
					for (i in postes) {
						postes[i]=gensub(/ |:/,"","g",postes[i])
						postes[i]=toupper(gensub(/O/,"0","g",postes[i]))
						k=index(pc,postes[i])
						# if (k==0) pc = pc OFS k " " postes[i]
						if (k==0) pc = pc "," postes[i]
						if (i==1) pc = postes[i]
						# pc = pc OFS k " " postes[i]
					}
					pk=gensub(/.* - JUSTIFICATION =(.*)/,"\\1",1,$11)
					
					ouverture=$3
					cloture=$4
					solution=gensub(/.*([0-9][0-9]\/[0-9][0-9]\/[0-9][0-9][0-9][0-9]).*/,"\\1",1,$13)
					
					if (qui==$10) qui=""
					# if (pc==$0) pc=""
					if (pk==$11) pk=""
					if (solution==$13) solution=""
					print id OFS ouverture OFS cloture OFS solution OFS empl OFS qui OFS pc OFS pk
					# print id OFS ouverture OFS cloture OFS solution OFS empl OFS qui OFS pc
				}
			}
		}
	}
}