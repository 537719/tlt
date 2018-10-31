# special2html.awk
# CREE  26/10/2018 - 13:47:29 convertit les caractères spéciaux en caractères html

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
    OFS=FS
}

{ #MAIN
    ligne=""
    for (i=1;i<=NF;i++) {
        if (i==1) {
            ligne=special2html($1)
        } else {
            ligne=ligne OFS special2html($i)
        }
    }
    print ligne
}