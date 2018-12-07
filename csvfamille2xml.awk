# csvfamille2xml.awk
# d'après csvproj2xml.awk 24/10/2018 - 18:23:49
# CREE  09/11/2018 - 13:39:04 convertit en xml le fichier csv récapitulant le stock par famille de produits

function special2html(chaine) # convertit les caractères spéciaux en caractères html
{
    gensub(/\&/,"&amp;","g",chaine)
	gensub(/á/,"&aacute;","g",chaine)
	gensub(/á/,"&aacute;","g",chaine)
	gensub(/â/,"&acirc;","g",chaine)
	gensub(/â/,"&acirc;","g",chaine)
	gensub(/à/,"&agrave;","g",chaine)
	gensub(/é/,"&eacute;","g",chaine)
	gensub(/ê/,"&ecirc;","g",chaine)
	gensub(/è/,"&egrave;","g",chaine)
	gensub(/ô/,"&ocirc;","g",chaine)
	gensub(/ö/,"&ouml;","g",chaine)
	gensub(/ù/,"&ugrave;","g",chaine)
    
    return chaine
}
BEGIN {
    FS=";"
    tabu="\t"
    nbchamps=4

    print "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>"
    print "<stock>"
}

NR==1 { #vérification de la structure du fichier CSV
    if ($1 !~ /^Dispo$/) {
        print "ERREUR : Manque l'intitulé des champs"
        exit 1
    }
    if (NF!=nbchamps) {
        print "ERREUR : Ce cichier contient " NF " champs au lieu de " nbchamps " attendus"
        exit NF
    }
}

$1 ~ /^[0-9]*$/   {#MAIN
    gsub(/<\/br>/,"") # les sauts de lignes ne sont pas digérés par la moulinette ajax qui traite le fichier généré
    # gsub(/\&/,"&amp\;") # les sauts de lignes ne sont pas digérés par la moulinette ajax qui traite le fichier généré
    print tabu "<famille>"
    print tabu tabu "<qdispo>" sprintf("%03i",$1+0) "</qdispo>" # s'assure que les quantité sont formatées sous la forme de 3 chiffres afin que le tri effectué plus tard par le xsl soit pertinent
    print tabu tabu "<qattendu>" sprintf("%03i",$5+0) "</qattendu>"
    print tabu tabu "<codefamille>" $3 "</codefamille>"
    print tabu tabu "<libfamille>" special2html($4) "</libfamille>"
    print tabu "</famille>"
}

END {
    print "</stock>"
}