# csv2html.awk
# cr��  11:38 02/03/2020 cr�e la page html permettant d'acc�der aux donn�es ajax exploitant les donn�es issues du .csv fourni en param�tre
#                                    s'utilise en conjonction avec csv2xml.awk et csv2xsl.awk
# d�finir le titre comme valeur sur la ligne de commande (param�tre -v="titre de la page"
# BUG   13:53 29/09/2020 le nom du fichier xml utilis� par la fonction js doit �tre imp�rativement "fichier.xml" et non dynamique en fonction du fichier tra�t�
# BUG   14:08 29/09/2020 �largit la fen�tre d'affichage de la date d'actualisation + ajoute un commentaire incitant � l'enrichir
# BUG   14:54 23/10/2020 Erreur dans le code postal du tag Geography dans le header
# MODIF 21:15 23/10/2020 d�finit titre, sujet et description dans le header html comme �tant le nom du fichier d'entr�e
# MODIF 09:38 24/10/2020 d�finit le tag generator comme �tant l'int�gralit� de la ligne de commandes

BEGIN { # D�finition des parties du header qui peuvent �tre �crites d�s maintenant
    IGNORECASE=1
    FS=";"
    OFS=","
    generator=""
    for (i in PROCINFO["argv"]) { generator=generator PROCINFO["argv"][i]" "} # r�cup�re toute la ligne de commande contrairement � ARGV[]
    
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
  print "		<meta name=\"Author\" content=\"Gilles M�tais\">"
  print "		<meta name=\"Publisher\" content=\"Gilles M�tais\">"
  print "		<meta name=\"Identifier-Url\" content=\"http://quipo.alt\">"
  print "		<meta name=\"Reply-To\" content=\"gilles.metais@alturing.eu\">"
  print "		<meta name=\"Rating\" content=\"restricted\">"
  print "		<meta name=\"Distribution\" content=\"iu\">"
  print "		<meta name=\"Geography\" content=\"92120 Montrouge, France\">"
  print "		<meta name=\"generator\" content=\" " generator "\" />"
  print "		<meta name=\"date\" content=\"" strftime("%Y-%m-%d",systime()) "\" scheme=\"YYYY-MM-DD\" />"
  print "		<meta name=\"Expires\" content=\"" strftime("%Y-%m-%d",systime()+3600*24*8) "\" scheme=\"YYYY-MM-DD\" />"
  # Header non clos : il reste à  �crire le tag Keywords à  partr des en-t�tes de champs et pour à§a il faut avoir lu la premi�re ligne du fichier
}
NR==1 { # traitement de la ligne d'en-t�te
  print "		<title>" FILENAME "</title> <!-- modifier ici -->"
  print "		<meta name=\"Description\" content=\"" FILENAME "\"> <!-- modifier ici -->"
  print "		<meta name=\"Subject\" content=\"" FILENAME "\"> <!-- modifier ici -->"
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
    }
    keywordlist=""
    for (i=1;i<=NF;i++) {
        keywordlist=keywordlist OFS entete[i]
    }
  print "		<meta name=\"Keywords\" content=\"statistiques,Alturing,Liste" keywordlist "\">"
  print "	</head>"
  print ""
  # nomfich=gensub(/.*\\(.*)\..+$/,"\\1","g",FILENAME)
  # sub(/\.csv$/,".xml",nomfich)
  # print "	<body onload=\"init('" nomfich "', 'fam+" entete[1] ".xsl', 'transform')\">"
  print "	<body onload=\"init('fichier.xml', 'fam+" entete[1] ".xsl', 'transform')\">"

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
  print "								<input type=\"radio\" name=\"ordre\" value=\"+\" checked=\"checked\" />Croissant&nbsp;"
  print "								<input type=\"radio\" name=\"ordre\" value=\"-\" />D&eacute;croissant&nbsp;"
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
    
  next

  }