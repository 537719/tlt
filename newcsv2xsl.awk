# csv2xsl.awk
# cree  06/12/2018 - 10:30:09   d'apr�s statchampscsv.awk cree  04/12/2018 - 16:22:52 
#                               produit la feuille de style xsl d'affichage des donn�es d'un fichier csv qui sera converti en xml
#                               le fichier r�sultant sera � dupliquer et modifier de mani�re � g�rer les tris croissant et d�croissant
#                               et ce autant de fois qu'il y a de champ (en adaptant le titre et le crit�re de tri � chaque fois)
# MODIF 07/12/2018 - 14:36:19   rajoute les stats sur les types de champs en commentaire en fin de sortie afin d'aider � d�coder de modifier le type le cas �ch�ant.
# MODIF 07/12/2018 - 14:36:19   modifie le calcul d'indicateur de qualit� afin qu'il porte sur toutes les donn�es non vide au lieu de comparer le plus fort � celui qui le suit
# MODIF 11:28 21/02/2019   assouplit les conditions de validit� de l'enregistrement de titre
# MODIF 17:18 20/02/2020   assouplit les motifs de d�tection des types num�riques (int et float) de mani�re � accepter les cadrages � droite (chiffres pr�c�d�s d'espaces)
# BUG   17:07 23/10/2020   l'oubli d'une double quote dans le "foreach" emp�chait l'affichage du fichier xml li�
# MODIF 17:08 23/10/2020   g�n�re toutes les feuilles de style et non plus une seule, cela modifie la proc�dure d'appel puisqu'il n'y a plus � rediriger la sortie vers un fichier
# MODIF 09:41 24/10/2020   remplace la chaine fixe d�finissant le nom du script par la r�cup�ration de la ligne de commande appelante
# MODIF 19:17 26/10/2020 (en cours) : d�termine si l'un des champs contient en g�n�ral des donn�es succeptibles de g�n�rer un lien html (typiquement : incident/demande/changement glpi et num�ro de colis chronopost)
# BUG   16:55 02/11/2020 Les espaces, tabus et sauts de lignes �taient concat�n�s � l'URL g�n�r�s si le <xsl:attribute href n'�tait pas ouvert et ferm� sur une seule ligne (bug chrome uniquement, ok dans firefox)
# MODIF 19:04 06/11/2020 Le lien g�n�r� pour le suivi de colis chronopost am�ne d�sormais vers la page de d�tail du suivi auguste et non vers la page de preuve de distribution

# ATTENTION le fichier d'entr�e doit �tre filtr� afin que les caract�res accentu�s soient manipulables
# typiquement : cat [fichier].csv |iconv -f CP1250 -t UTF-8 |gawk -f statchampscsv.awk

function pourcent(float)    # retourne le sprint du float sous la forme d'un pourcentage � deux d�cimales
{
    return sprintf("%3i%%",((0+float)*100/nbrecords)+0.5) # attention nbrecords est une variable GLOBALE
}
BEGIN {
    FS=";"
    OFS=" "
    antislash="\\"
    
    lientype[4]="dossier"
    lientype[3]="changement"
    lientype[2]="colis"
    lientype[1]="divers"
    lientype[0]="vide"    
    
    if (outputdir) outputdir=outputdir antislash # fourniture �ventuelle sur la ligne de commande d'un r�pertoire dans lequel placer les fichiers produits
    
    
    for (i in PROCINFO["argv"]) { generator=generator PROCINFO["argv"][i]" "} # r�cup�re toute la ligne de commande contrairement � ARGV[]
    
    signesens[1]="+"
    signesens[2]="-"
    libsens[1]="croissant"
    libsens[2]="d�croissant"
    order[1]="ascending"
    order[2]="descending"
}

BEGINFILE {
    nomfich=gensub(/.*\\/,vide,"g",FILENAME) # extraction du nom du fichier d'entr�e proprement dit, sans son �ventuel chemin d'acc�s
}

NR==1 { # traitement de la ligne d'en-t�te
    if ($1 !~ /[^0-9][A-z]+$/) if ($1 !~ /[0-9]{4}/) { # 1� champ ne commence pas par un chiffre puis ne contient que des lettres ET 1� champ n'est pas une ann�e
        print "ERREUR : Manque l'intitul� des champs " NR "@" $1 "@"
        exit 1
    }

    nbchamps=NF # d�termine le nombre de champs du fichier
    for (i=1;i<=NF;i++) {    # sauvegarde les noms des champs avec accents et espaces, pour affichage
        accent[i]=$i
    }
    gsub(/ /,"_") # remplace tous les espaces par des _
    gsub(/.\251/,"e") # 251 = conversion en octal de 169 en d�cimal, code ascii du � - le . avant le \251 est l� parce que ce caract�re est cod� sur 2 digits
    for (i=1;i<=NF;i++) {    # d�termine les noms des champs, sans accents ni espaces, pour traitement des donn�es
        entete[i]=$i
        if ($i !~ /./) { # cas particulier des champs dont l'en-t�te est vide
            entete[i] = "champ_" i
        }
        longmax[i]=0
        longmin[i]=999
    }
    next
}
NR==1 {
    for (i=1;i<=NF;i++) {
        nom[i]=$i
    }
}


NR>1 {  # traitement des donn�es
    
    for (i=1;i<=NF;i++) {
        li=length($i)
        long[i] = long[i]+li
        if (li) {
            if (li>longmax[i]) longmax[i]=li
            if (li<longmin[i]) longmin[i]=li
        }
        switch($i) { # D�termination du fait qu'un champ soit linkable (c'est � dire : dossier glpi, changement glpi, colis chronopost)
            case /^ *[1-2][0-9][0-1][0-9]{7} *$/ :
            {
                linkable[i,4]++ # dossier glpi
                break
            }
            case /^ *1[0-9]{4} *$/ :
            {
                linkable[i,3]++ # changement glpi
                break
            }
            case /[A-Z]{2}[0-9]{9}[A-Z]{2}/ :
            {
                linkable[i,2]++ # colis chronopost
                break
            }
            case /./ :
            {
                linkable[i,1]++ # non linkable
                break
            }
            default :
            {
                linkable[i,0]++ # vide
            }
        }
        
        switch($i) { # d�termination du type de champ
            case /^ *[0-9]+$/ :
            {
            # print NR,i,"entier"
                entier[i]++
                break
            }
            
            case /^ *[0-9]*\.[0-9]*$/ :
            {
            # print NR,i,"float"
                float[i]++
                break
            }
            
            case /^[0-9]+[-|\/][0-9]+[-|\/][0-9]+ +[0-9]+:[0-9]+:*[0-9]*$/ :
            {
            # print NR,i,"dateheure"
                dateheure[i]++
                break
            }
            
            case /^[0-9]+:[0-9]+:*[0-9]*$/ :
            {
            # print NR,i,"heure"
                heure[i]++
                break
            }
            
            case /^[0-9| |_]+[-|\/][0-9| |_]+[-|\/][0-9| |_]+*/ :
            {
            # print NR,i,"date"
                date[i]++
                break
            }
            
            default :
            {
                if (li) {
                # print NR,i,"texte"
                    text[i]++
                } else {
                # print NR,i,"void"
                    void[i]++
                }
            }
        }
    }
}

END {   #   Restitution des r�sultats
    nbrecords=NR-1 # -1 � cause de la ligne d'en-t�te
    for (i in entete) { # d�termination des champs linkables
        meilleurlien[i]=0
        tauxmeilleurlien[i]=0
        for (j in lientype)  if (j) {
            lientaux[i,j] = linkable[i,j] / (nbrecords - linkable[i,0]) # On ne calcule le taux que sur les enregistrements non vides
            # print "champ No" i,entete[i] " linkable a " lientaux[i,j] " pour le type " lientype[j]
            if (lientaux[i,j] > tauxmeilleurlien[i]) {
                tauxmeilleurlien[i]=lientaux[i,j]
                meilleurlien[i]=j
            }
        }
        # if (meilleurlien[i]>1)         print "champ No " i,entete[i] " linkable a " tauxmeilleurlien[i] " pour le type " lientype[meilleurlien[i]]
    }
    for (i in entete) { # d�termination du type et de la largeur de chaque champ
        delete taux
        
        # remplissage de la table d'estimation du type de champ
        # le % de donn�es de chaque type est concat�n� au nom du type
        taux["entier"]=pourcent(entier[i]) "entier"
        taux["float"]=pourcent(float[i]) "float"
        taux["dateheure"]=pourcent(dateheure[i]) "horodate"
        taux["date"]=pourcent(date[i]) "date"
        taux["heure"]=pourcent(heure[i]) "heure"
        taux["texte"]=pourcent(text[i]) "texte"
        # puis tri� : le dernier de la liste est donc le bon
        asort(taux)
        split(taux[6],taux6,"%")
        # split(taux[5],taux5,"%")
        # print taux6[1],taux5[1]
        qualite=taux6[1]/(NR-1-void[i])
        # �pur�
#        gsub(/.*%/,"",taux[6])
        # et mis en forme
        taux[6]=toupper(sprintf("%8s",taux[6]))
        switch (taux[6]) {
            # px = largeur en pixels du champ de tableau concern�
            # class = classe css � appliquer dans la feuille de style associ�e. Sert � d�terminer en particulier si la donn�e sera cadr�e � droite ou � gauche
            case /ENTIER/ :
            {
                 px[i]=10*longmax[i]
               # px[i]=9*long[i]/(NR-1-void[i])
                class[i]="num"
                break
            }
           case /DATE|HEURE/ :
            {
                px[i]=8*long[i]/(NR-1-void[i]) # test� pour les dates uniquement, pas trouv� de cas de dateheure ni heure � afficher
                class[i]="num"
                break
            }
            case /FLOAT/ :
            {
                px[i]=9*longmax[i] # pas test� car pas de donn�es correspondantes
                class[i]="num"
                break
            }
            case /TEXT/ :
            {
                px[i]=10*longmax[i]
                # px[i]=int(9*long[i]/(NR-1-void[i])+0.5) # pas pertinent
                class[i]="txt"
                break
            }
        }
        if (px[i]>240) px[i]=240 # born� � 240 maxi
        
        # r�cap des donn�es vestige de statchampscsv.awk # report� en fin de fichier
        # print sprintf("%2d",i) OFS "min:" sprintf("%3s",longmin[i]) OFS "moy:" sprintf("%6.2f",long[i]/(NR-1-void[i])) OFS "max:" sprintf("%3d",longmax[i]) OFS "int:" pourcent(entier[i]) OFS "float:" pourcent(float[i]) OFS "dateheure:" pourcent(dateheure[i]) OFS "heure:" pourcent(heure[i]) OFS "date:" pourcent(date[i]) OFS "texte:" pourcent(text[i]) OFS "vide:" pourcent(void[i]) OFS taux[6] OFS sprintf("%3i%%",(qualite*100)+.5) OFS entete[i] # car 6 types de champ � analyser
        
        if (FILENAME == "") {
            fichier= "fichier d'entr�e " FILENAME
        } else {
            fichier="flot d'entr�e"
        }
    }
    for (j in entete) {
    for (k in signesens) {
        outfile=outputdir "fam" signesens[k] entete[j] ".xsl"
        { # sortie des r�sultats
            print "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>" > outfile
            print "<xsl:stylesheet version=\"1.0\" xmlns:xsl=\"http://www.w3.org/1999/XSL/Transform\">" > outfile
            print "	<xsl:template match=\"/\">" > outfile
            print "		<html>" > outfile
            print "			<head>" > outfile
            print "				<title>" nomfich " - Tri par " entete[j] " " libsens[k] "</title><!-- modifier ici -->" > outfile
            print "			</head>" > outfile
            print "			<body>" > outfile
            print "					<div id=\"titre\">" > outfile
            print "				<table border=\"3\"  cellspacing=\"4\" cellpadding=\"2\" align=\"center\">" > outfile
            print "					<caption align=\"center\">" nomfich "<!-- modifier ici -->" > outfile
            print "						Tri par " entete[j] " " libsens[k]  > outfile
            print "					</caption>" > outfile
            print "					<colgroup>" > outfile
            for (i in entete) { # �criture des lignes fixant la largeur des colonnes de titre
                print "\t\t\t\t\t\t<col style=\"width:" px[i] "px\"  />" > outfile
            }
            print "					</colgroup>" > outfile
            print "					<tr>" > outfile
            for (i in entete) { # �criture des en-t�tes de colonnes
                print "\t\t\t\t\t\t<th id=\"" entete[i] "\" abbr=\"" entete[i] "\">" gensub(/_/," ","g",accent[i]) "</th>"  > outfile # gensub reste n�cessaire dans le cas des champs contenant d�j� des _
            }
            print "					</tr>" > outfile
            print "					</table>" > outfile
            print "					</div>" > outfile
            print "				<table border=\"3\"  cellspacing=\"4\" cellpadding=\"2\" align=\"center\">" > outfile
            print "					<colgroup>" > outfile
            for (i in entete) { # �criture des lignes fixant la largeur des colonnes de donn�es
                print "\t\t\t\t\t\t<col style=\"width:" px[i] "px\"  />" > outfile
            }
            print "					</colgroup>" > outfile
            print "					<xsl:for-each select=\"fichier/enregistrement\">" > outfile
            print "					<xsl:sort select=\"" entete[j] "\" order=\"" order[k] "\" /><!-- modifier ici -->" > outfile
            print "						<tr>" > outfile
            print "							<xsl:if test=\"position() mod 2 != 1\">" > outfile
            print "								<xsl:attribute name=\"class\">pair" > outfile
            print "								</xsl:attribute>" > outfile
            print "							</xsl:if>" > outfile
            print "							<xsl:if test=\"position() mod 2 != 0\">" > outfile
            print "								<xsl:attribute name=\"class\">impair" > outfile
            print "								</xsl:attribute>" > outfile
            print "							</xsl:if>" > outfile
            for (i in entete) { # �criture des lignes d'affichage des donn�es
                    # if (meilleurlien[i]>1)         print "champ No " i,entete[i] " linkable a " tauxmeilleurlien[i] " pour le type " lientype[meilleurlien[i]]
                    switch(meilleurlien[i]) {   #si le champ a �t� identifi� comme linkable on le produit comme tel, sinon comme normal
                        case /4/ :  # dossier glpi
                        {
            print "\t\t\t\t\t\t\t<td class=\"" class[i] "\">" > outfile
            print "\t\t\t\t\t\t\t\t<xsl:element name=\"a\">" > outfile
            print "\t\t\t\t\t\t\t\t\t<xsl:attribute name=\"target\">blank</xsl:attribute>" > outfile
            print "\t\t\t\t\t\t\t\t\t<xsl:attribute name=\"href\">http://glpi.telintrans.fr/front/ticket.form.php?id=<xsl:value-of select=\"" entete[i] "\"/></xsl:attribute>" > outfile
            # print "\t\t\t\t\t\t\t\t\t<xsl:attribute name=\"href\">http://glpi.telintrans.fr/front/ticket.form.php?id=id=<xsl:value-of select=\"" entete[i] "\"/></xsl:attribute>" > outfile
            print "\t\t\t\t\t\t\t\t\t<xsl:value-of select=\"" entete[i] "\"/>" > outfile
            print "\t\t\t\t\t\t\t\t</xsl:element>" > outfile
            print "\t\t\t\t\t\t\t</td>" > outfile
                            break
                        }
                        case /3/ :  # changement glpi
                        {
            print "\t\t\t\t\t\t\t<td class=\"" class[i] "\">" > outfile
            print "\t\t\t\t\t\t\t\t<xsl:element name=\"a\">" > outfile
            print "\t\t\t\t\t\t\t\t\t<xsl:attribute name=\"target\">blank</xsl:attribute>" > outfile
            print "\t\t\t\t\t\t\t\t\t<xsl:attribute name=\"href\">https://glpi.alturing.eu/front/change.form.php?id=<xsl:value-of select=\"" entete[i] "\"/></xsl:attribute>" > outfile
            print "\t\t\t\t\t\t\t\t\t<xsl:value-of select=\"" entete[i] "\"/>" > outfile
            print "\t\t\t\t\t\t\t\t</xsl:element>" > outfile
            print "\t\t\t\t\t\t\t</td>" > outfile
                            break
                        }
                        case /2/ :  # colis
                        {
            print "\t\t\t\t\t\t\t<td class=\"" class[i] "\">" > outfile
            print "\t\t\t\t\t\t\t\t<xsl:element name=\"a\">" > outfile
            print "\t\t\t\t\t\t\t\t\t<xsl:attribute name=\"target\">blank</xsl:attribute>" > outfile
            # print "\t\t\t\t\t\t\t\t\t<xsl:attribute name=\"href\">http://suivi.chronopost.fr/servletAuguste?Hrequete=afficherColis&amp;Hlangue=fr_FR&amp;numeroLT=<xsl:value-of select=\"" entete[i] "\"/>"</xsl:attribute>" > outfile
            print "\t\t\t\t\t\t\t\t\t<xsl:attribute name=\"href\">http://suivi.chronopost.fr/servletAuguste?Hrequete=recherche&amp;TAlisteNumeroLT=<xsl:value-of select=\"" entete[i] "\"/>&amp;RBresultats=ecran&amp;TFNumeroLTPartiel=&amp;StypeCalcul=commun&amp;StypeRecherche=tous</xsl:attribute>" > outfile
            print "\t\t\t\t\t\t\t\t\t<xsl:value-of select=\"" entete[i] "\"/>" > outfile
            print "\t\t\t\t\t\t\t\t</xsl:element>" > outfile
            print "\t\t\t\t\t\t\t</td>" > outfile
                            break
                        }
                        default :
                        {
                print "\t\t\t\t\t\t\t<td class=\"" class[i] "\"><xsl:value-of select=\"" entete[i] "\"/></td> " > outfile # <!-- " longmax[i] " " long[i]/(NR-1-void[i]) " nombres de caract�res max et moyen d�tect�s dans les donn�es -->"
                        }
                    }

            }
            print "						</tr>" > outfile
            print "					</xsl:for-each>" > outfile
            print "				</table>" > outfile
            print "			</body>" > outfile
            print "		</html>" > outfile
            print "	</xsl:template>" > outfile
            print "</xsl:stylesheet>" > outfile
            print "<!-- penser a dupliquer ce fichier pour tenir compte de l'ordre de tri , ligne xsl:sort -->" > outfile
            print "<!-- et a le multiplier autant de fois qu'il y a de champs soit : -->" > outfile
            for (i in entete) {
                print "\t<!-- " entete[i] " -->" > outfile
            }
            print "<!-- les lignes a modifier sont rep�r�es par le commentaire suivant : --> <!-- modifier ici -->" > outfile
            # r�cap des donn�es vestige de statchampscsv.awk
            for (i in entete) { # l'avant derni�re colonne donne un r�sultat erron�, � corriger
                print "<!-- " sprintf("%2d",i) OFS "min:" sprintf("%3s",longmin[i]) OFS "moy:" sprintf("%6.2f",long[i]/(NR-1-void[i])) OFS "max:" sprintf("%3d",longmax[i]) OFS "int:" pourcent(entier[i]) OFS "float:" pourcent(float[i]) OFS "dateheure:" pourcent(dateheure[i]) OFS "heure:" pourcent(heure[i]) OFS "date:" pourcent(date[i]) OFS "texte:" pourcent(text[i]) OFS "vide:" pourcent(void[i]) OFS taux[i] OFS sprintf("%3i%%",(qualite*100)+.5) OFS entete[i] " -->"  > outfile # car 6 types de champ � analyser
            }
     
            print "<!-- creation par " generator " le " strftime("%c",systime()) " -->" > outfile
        }
     }
     }
}


