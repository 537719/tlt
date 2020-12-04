# csv2aide.awk
# d'après csv2html.awk du 09:38 24/10/2020 

BEGIN { # Définition des parties du header qui peuvent être écrites dès maintenant
    IGNORECASE=1
    FS=";"
    OFS=","
    generator=""
    antislash="\\"
    
    if (outputdir) outputdir=outputdir antislash # fourniture éventuelle sur la ligne de commande d'un répertoire dans lequel placer les fichiers produits
    nomfich=gensub(/.*\\/,vide,"g",FILENAME) # extraction du nom du fichier d'entrée proprement dit, sans son éventuel chemin d'accès
    
    
    for (i in PROCINFO["argv"]) { generator=generator PROCINFO["argv"][i]" "} # récupère toute la ligne de commande contrairement à ARGV[]
  outfile=outputdir "aide.html"
  print "aide @" outfile "@"
    
  print "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitionnal//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">" >outfile
  print "<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"fr\" lang=\"fr\">" >outfile
  print "	<head>" >outfile
  print "		<meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\" />" >outfile
  print "		<meta http-equiv=\"Content-Script-Type\" content=\"text/javascript\" />" >outfile
  print "		<meta http-equiv=\"Content-Style-Type\" content=\"text/css\" />" >outfile
  print "		<script  type=\"text/javascript\" src=\"../webresources/FamFunction.js\"></script>" >outfile
  print "		<link rel=\"icon\" type=\"image/png\" href=\"../webresources/favicon.png\" />" >outfile
  print "		<link rel=stylesheet type=text/css media=screen href=\"../webresources/aide.css\">" >outfile
  print "		<link rel=stylesheet type=text/css media=screen href=\"../webresources/main.css\">" >outfile
  print "		<meta name=\"Content-Language\" content=\"fr\">" >outfile
  print "		<meta name=\"Copyright\" content=\"Alturing\">" >outfile
  print "		<meta name=\"Author\" content=\"Gilles Métais\">" >outfile
  print "		<meta name=\"Publisher\" content=\"Gilles Métais\">" >outfile
  print "		<meta name=\"Identifier-Url\" content=\"http://quipo.alt\">" >outfile
  print "		<meta name=\"Reply-To\" content=\"gilles.metais@alturing.eu\">" >outfile
  print "		<meta name=\"Rating\" content=\"restricted\">" >outfile
  print "		<meta name=\"Distribution\" content=\"iu\">" >outfile
  print "		<meta name=\"Geography\" content=\"92120 Montrouge, France\">" >outfile
  print "		<meta name=\"generator\" content=\" " generator "\" />" >outfile
  print "		<meta name=\"date\" content=\"" strftime("%Y-%m-%d",systime()) "\" scheme=\"YYYY-MM-DD\" />" >outfile
  print "		<meta name=\"Expires\" content=\"" strftime("%Y-%m-%d",systime()+3600*24*365) "\" scheme=\"YYYY-MM-DD\" />" >outfile
  # Header non clos : il reste Ã Â  écrire le tag Keywords Ã Â  partr des en-têtes de champs et pour Ã Â§a il faut avoir lu la première ligne du fichier
}
NR==1 { # traitement de la ligne d'en-tête
  print "		<title>Page d'aide pour " FILENAME "</title> <!-- modifier ici -->" >outfile
  print "		<meta name=\"Description\" content=\"Page d'aide pour " FILENAME "\"> <!-- modifier ici -->" >outfile
  print "		<meta name=\"Subject\" content=\"Page d'aide pour " FILENAME "\"> <!-- modifier ici -->" >outfile
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
  print "		<meta name=\"Keywords\" content=\"statistiques,Alturing,Liste" keywordlist "\">" >outfile
  print "	</head>" >outfile
  print "" >outfile

  print "	<body onload=\"init('aide.xml', '../webresources/fam+Ligne.xsl', 'transform')\">" >outfile
  print "		<div id=\"main\">" >outfile
  print "			<div id=\"top\">" >outfile
  print "				<table border=0 cellpadding=0 cellspacing=0 align=\"center\"  width=\"100%\">" >outfile
  print "				<tr>" >outfile
  print "					<td class=\"titre\" width=\"225\" align=\"left\">" >outfile
  print "						<a  href =\"..\">" >outfile
  print "						<img src=\"../webresources/logo_alturing_80.png\" height=\"84\" width=\"225\">" >outfile
  print "						</a>" >outfile
  print "					</td>" >outfile
  print "					<td class=\"titre\" colspan=\"3\" style=\"vertical align: middle;\">" >outfile
  print "						<h2>Page d'aide</h2>" >outfile
  print "					</td>" >outfile
  print "					<td class=\"titre\" width=\"238\" align=\"right\">" >outfile
  print "						<a  href =\".\">Retour" >outfile
  print "						</a>" >outfile
  print "					</td>" >outfile
  print "					</tr>" >outfile
  print "					<tr>" >outfile
  print "					</tr>" >outfile
  print "				</table>" >outfile
  print "			</div>" >outfile
  print "			<div id=\"transform\">" >outfile
  print "			</div>" >outfile
  print "		</div>" >outfile
  print "	</body>" >outfile
  print "</html>" >outfile

    outfile=outputdir "aide.xml"
  print "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>" >outfile
  print "<fichier>" >outfile
  print "	<enregistrement>" >outfile
  print "		<Ligne>  1</Ligne>" >outfile
  print "		<Texte></Texte>" >outfile
  print "	</enregistrement>" >outfile
  print "	<enregistrement>" >outfile
  print "		<Ligne>  2</Ligne>" >outfile
  print "		<Texte>Cette page liste le contenu de " FILENAME "</Texte>" >outfile
  print "	</enregistrement>" >outfile
  print "	<enregistrement>" >outfile
  print "		<Ligne> 20</Ligne>" >outfile
  print "		<Texte>Le bandeau supérieur permet de choisir l'ordre et la colonne de tri de l'affichage.</Texte>" >outfile
  print "	</enregistrement>" >outfile
  print "	<enregistrement>" >outfile
  print "		<Ligne> 21</Ligne>" >outfile
  print "		<Texte>selon les colonnes " substr(keywordlist,2) "</Texte>" >outfile
  print "	</enregistrement>" >outfile
  print "	<enregistrement>" >outfile
  print "		<Ligne> 31</Ligne>" >outfile
  print "		<Texte>Il n'est pas possible de faire une selection ni de combiner plusieurs critères de tri.</Texte>" >outfile
  print "	</enregistrement>" >outfile
  print "	<enregistrement>" >outfile
  print "		<Ligne> 32</Ligne>" >outfile
  print "		<Texte>Il est possible de combiner un ordre de tri avec une recherche par [ctrl+F]</Texte>" >outfile
  print "	</enregistrement>" >outfile
  print "</fichier>" >outfile
    
    

  next

  }