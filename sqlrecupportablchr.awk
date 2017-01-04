#sqlrecupportablchr.awk
# 14:29 vendredi 8 avril 2016
# d'après recupportablchr.awk
# 15:51 vendredi 1 avril 2016
# idem que recupportablchr.awk mais produit un script MySql d'extraction des taches GLPI des dossiers concernés.
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

BEGIN {
	IGNORECASE=1
	FS="\0"
	OFS=";"
	# print "glpi" OFS "ouvert" OFS "clos" OFS "resolu" OFS "site" OFS "qui" OFS "pc" OFS "justif"
	
}
{	#MAIN
	if ($2 ~ /CHRONOPOST\"$/) {	#chronopost  "non shipping"
		if ($33 ~ /Demande/) if ($31 ~ /I&S_/) {
			if ($7 ~ /Demande de mat.*Nouveau poste de travail.* PORTABLE/) {
				if ($11 ~/Utilisateur existant/ && $11 !~ /Nouvel utilisateur/) {
					id=gensub(/\42/,"","g",$1)
					empl=gensub(/ &gt; /,">","g",$5)
					qui=gensub(/.*pour (.*)\"$/,"\\1",1,$10)
					pc=gensub(/.*(P[M|B|G|L|P][I|G|P|Y]) *([0-9][0-9][0-9][0-9][0-9]).*/,"\\1\\2","g",$0)
					pk=gensub(/.* - JUSTIFICATION =(.*)/,"\\1",1,$11)
					
					ouverture=$3
					cloture=$4
					solution=gensub(/.*([0-9][0-9]\/[0-9][0-9]\/[0-9][0-9][0-9][0-9]).*/,"\\1",1,$13)
					
					if (qui==$10) qui=""
					if (pc==$0) pc=""
					if (pk==$11) pk=""
					if (solution==$13) solution=""
					# print id OFS ouverture OFS cloture OFS solution OFS empl OFS qui OFS pc OFS pk
					print "SELECT * from glpi_tickettasks where tickets_id = '" id "';"
				}
			}
		}
	}
}