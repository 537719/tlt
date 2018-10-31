# csvproj2xml.awk
# CREE  19/10/2018 - 11:46:02 convertit en xml le fichier csv récapitulant le matériel expédié ou non sur les projets
# BUG   24/10/2018 - 18:23:49 filtre les caractères "&" qui plantent le XML

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

    print "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>"
    print "<projets>"
    # print "<siege>"
}

NR==1 { #vérification de la structure du fichier CSV
    if ($1 !~ /^GLPI$/) {
        print "ERREUR : Manque l'intitulé des champs"
        exit 1
    }
    if (NF!=7) {
        print "ERREUR : Ce cichier contient " NF " champs au lieu de 7 attendus"
        exit NF
    }
}

$1 ~ /^[0-9]{10}$/   {#MAIN
    gsub(/<\/br>/,"") # les sauts de lignes ne sont pas digérés par la moulinette ajax qui traite le fichier généré
    # gsub(/\&/,"&amp\;") # les sauts de lignes ne sont pas digérés par la moulinette ajax qui traite le fichier généré
    print tabu "<article>"
    print tabu tabu "<glpi>"$1"</glpi>"
    print tabu tabu "<env>"$2"</env>"
    print tabu tabu "<proj>" special2html($3) "</proj>"
    print tabu tabu "<lieu>"$4"</lieu>"
    print tabu tabu "<qte>" sprintf("%03i",$5+0) "</qte>" # s'assure que les quantité sont formatées sous la forme de 3 chiffres afin que le tri effectué plus tard par le xsl soit pertinent
    print tabu tabu "<ref>"$6"</ref>"
    print tabu tabu "<lib>" special2html($7) "</lib>"
    print tabu "</article>"
}

END {
    print "</projets>"
}