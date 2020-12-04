# typechampcsv.awk
# CREATION  20:50 24/10/2020 Détermine si chacun des champs du csv fourni en fichier d'entrée est de type date, numérique ou autre (1° ligne = noms des champs)

BEGIN {
    IGNORECASE=1
    FS=";"
    OFS=","
    
    libtype[7]="date"
    libtype[6]="heure"
    libtype[5]="dateheure"
    libtype[4]="entier"
    libtype[3]="flottant"
    libtype[2]="pourcent"
    libtype[1]="texte"
    libtype[0]="vide"
    
    generator=""
    for (i in PROCINFO["argv"]) { generator=generator PROCINFO["argv"][i]" "} # récupère toute la ligne de commande contrairement à ARGV[]
    
  print "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitionnal//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">"
  print "<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"fr\" lang=\"fr\">"
  print "	<head>"
  print "		<meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\" />"
  print "		<meta http-equiv=\"Content-Script-Type\" content=\"text/javascript\" />"
  print "		<meta http-equiv=\"Content-Style-Type\" content=\"text/css\" />"
  print "		<script  type=\"text/javascript\" src=\"../webresources/FamFunction.js\"></script>"
  print "		<link rel=\"icon\" type=\"image/png\" href=\"../webresources/favicon.png\" />"
  print "		<link rel=stylesheet type=text/css media=screen href=\"../webresources/style.css\">"
  print "		<link rel=stylesheet type=text/css media=screen href=\"../webresources/main.css\">"
  print "		<meta name=\"Content-Language\" content=\"fr\">"
  print "		<meta name=\"Copyright\" content=\"Alturing\">"
  print "		<meta name=\"Author\" content=\"Gilles Métais\">"
  print "		<meta name=\"Publisher\" content=\"Gilles Métais\">"
  print "		<meta name=\"Identifier-Url\" content=\"http://quipo.alt\">"
  print "		<meta name=\"Reply-To\" content=\"gilles.metais@alturing.eu\">"
  print "		<meta name=\"Rating\" content=\"restricted\">"
  print "		<meta name=\"Distribution\" content=\"iu\">"
  print "		<meta name=\"Geography\" content=\"92120 Montrouge, France\">"
  print "		<meta name=\"generator\" content=\" " generator "\" />"
  print "		<meta name=\"date\" content=\"" strftime("%Y-%m-%d",systime()) "\" scheme=\"YYYY-MM-DD\" />"
  print "		<meta name=\"Expires\" content=\"" strftime("%Y-%m-%d",systime()+3600*24*8) "\" scheme=\"YYYY-MM-DD\" />"
  # Header non clos : il reste Ã Â  écrire le tag Keywords Ã Â  partr des en-têtes de champs et pour Ã Â§a il faut avoir lu la première ligne du fichier
}

NR==1 { # traitement de la ligne d'en-tête
  print "		<title>" FILENAME "</title> <!-- modifier ici -->"
  print "		<meta name=\"Description\" content=\"" FILENAME "\"> <!-- modifier ici -->"
  print "		<meta name=\"Subject\" content=\"" FILENAME "\"> <!-- modifier ici -->"
    if ($1 !~ /[^0-9][A-z]+$/) if ($1 !~ /[0-9]{4}/) { # 1° champ ne commence pas par un chiffre puis ne contient que des lettres ET 1° champ n'est pas une année
        print "ERREUR : Manque l'intitulé des champs " NR "@" $1 "@"
        exit 1
    }

    nbchamps=NF # détermine le nombre de champs du fichier
    for (i=1;i<=NF;i++) {    # sauvegarde les noms des champs avec accents et espaces, pour affichage
        accent[i]=$i
    }
    gsub(/ /,"_") # remplace tous les espaces par des _
    gsub(/.\251/,"e") # 251 = conversion en octal de 169 en décimal, code ascii du é - le . avant le \251 est là  parce que ce caractère est codé sur 2 digits
    for (i=1;i<=NF;i++) {    # détermine les noms des champs, sans accents ni espaces, pour traitement des données
        entete[i]=$i
        if ($i !~ /./) { # cas particulier des champs dont l'en-tête est vide
            entete[i] = "champ_" i
        }
    }
    keywordlist=""
    for (i=1;i<=NF;i++) {
        keywordlist=keywordlist OFS entete[i]
    }
  print "		<meta name=\"Keywords\" content=\"statistiques,Alturing,Liste" keywordlist "\">"
  print "	</head>"
  print ""
  # next
}


NR==1 {
    for (i=1;i<=NF;i++) {
        nom[i]=$i
    }
}


NR > 1 { #MAIN - Détermine le type de chaque champ
    for (i=1;i<=NF;i++) {
        gsub(/^ */,"",$i)
        gsub(/ *$/,"",$i)
        if ($i) switch($i) {
            case /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/ :
            {   #date
                type[i,7]++
                break
            }
            case /^[0-9]{2}:[0-9]{2}:[0-9]{2}$/ :
            {   #heure
                type[i,6]++
                break
            }
            case /^[0-9]{4}-[0-9]{2}-[0-9]{2} +[0-9]{2}:[0-9]{2}:[0-9]{2}$/ :
            {   #dateheure
                type[i,5]++
                break
            }
            case /^[0-9]+$/ :
            {   #int
                type[i,4]++
                break
            }
            case /^[0-9| ]+[,|\.][0-9| ]+$/ :
            {   #float
                type[i,3]++
                break
            }
            case /^[0-9| |,|\.]+%$/ :
            {   # %
                type[i,2]++
                break
            }
            default :
            {   # txt
                type[i,1]++
            }
        } else {
            # vide
            type[i,0]++
        }
    } 
}

END {
    meilleurindex=0
    tauxmeilleurindex=0
    typemeilleurindex=0
    for (i in nom) {
        meilleurtype[i]=0
        meilleurtaux[i]=0
        for (j=1;j<=7;j++) {
            if (type[i,j]) {
                taux[i,j]=(type[i,j])/(NR-1-type[i,0])    # calcul de la fréquence de chaque type parmi les valeurs non nulles
                if (taux[i,j] > meilleurtaux[i]) {
                    meilleurtaux[i]=taux[i,j]
                    meilleurtype[i]=j
                }
            } else {
                taux[i,j]=0
            }
        }
        # print ">>" i,entete[i],libtype[meilleurtype[i]],meilleurtaux[i]
       if (meilleurtaux[i] > tauxmeilleurindex) {
            meilleurindex=i
            tauxmeilleurindex=meilleurtaux[i]
            typemeilleurindex=meilleurtype[i]
       } else {
            if (meilleurtype[i] > typemeilleurindex) {
                if (meilleurtaux[i] = tauxmeilleurindex) {
                    meilleurindex=i
                    typemeilleurindex=meilleurtype[i]
                }
            }
       }
    }
    print "<!-- Le meilleur index repéré est le champ No " meilleurindex " dont le nom est " entete[meilleurindex] " avec un taux de cohérence de " tauxmeilleurindex " par rapport au type '" libtype[typemeilleurindex] "' -->"

    if (typemeilleurindex > 1) { # le meilleur index est une valeur temporelle ou numérique, on trie dessus par ordre décroissant
    print "	<body onload=\"init('fichier.xml', 'fam-" entete[meilleurindex] ".xsl', 'transform')\">"
  } else {
    print "	<body onload=\"init('fichier.xml', 'fam+" entete[meilleurindex] ".xsl', 'transform')\">"
  }
  print "		<div id=\"main\">"
  print "			<div id=\"top\">"
  print "				<table border=0 cellpadding=0 cellspacing=0 align=\"center\"  width=\"100%\">"
  print "					<tr>"
  print "						<td class=\"titre\" width=\"225\" align=\"left\">"
  print "							<a  href =\"..\">"
  print "							<img src=\"../webresources/logo_alturing_80.png\" height=\"84\" width=\"225\">"
  print "							</a>"
  print "						</td>"
  print "						<td class=\"titre\" colspan=\"3\" style=\"vertical align: middle;\">"
  print "							<h2>" FILENAME "<!-- modifier ici --> au "
  print "								<object type=\"text/plain\" data=\"date.txt\" style=\"overflow: hidden;\" border=\"0\" height=\"20\" width=\"130\"></object>"
  print "							</h2>"
  print "							<form name=\"choix\" action=\"\" style=\"text-align:center\">"
  print "								<select name=\"tri\">"
  for (i=1;i<=NF;i++) {
    print "									<option value=\"" entete[i] "\">" entete[i] "</option>"
  }
  print "								</select>"
  if (typemeilleurindex > 1) { # le meilleur index est une valeur temporelle ou numérique, on trie dessus par ordre décroissant
      print "								<input type=\"radio\" name=\"ordre\" value=\"+\" />Croissant&nbsp;"
      print "								<input type=\"radio\" name=\"ordre\" value=\"-\" checked=\"checked\" />D&eacute;croissant&nbsp;"
  } else {
      print "								<input type=\"radio\" name=\"ordre\" value=\"+\" checked=\"checked\" />Croissant&nbsp;"
      print "								<input type=\"radio\" name=\"ordre\" value=\"-\" />D&eacute;croissant&nbsp;"
  }
  print "								<input type=\"button\" value=\"Afficher\" onclick=\"formulaire(choix)\" />"
  print "							</form>"
  print "						</td>"
  print "						<td class=\"titre\" width=\"238\" align=\"right\">"
  print "							<a  href =\"aide.html\">Aide</a>"
  print "						</td>"
  print "					<tr>"
  print "					</tr>"
  print "				</table>"
  print "			</div>"
  print "			<div id=\"transform\">"
  print "			</div>"
  print "		</div>"
  print "	</body>"
  print "</html>"

}