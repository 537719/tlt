# csvproj2xml.awk
# CREE  03/12/2018 - 12:57:04 d'après csvproj2xml.awk : convertit en xml tout fichier csv
# MODIF 11:28 21/02/2019   assouplit les conditions de validité de l'enregistrement de titre
# BUG   14:33 11/02/2020 le remplacement des & ne marche pas. Non résolu, contourner par un sed en sortie
# BUG   15:06 26/10/2020 la fonction printchamp réduisait à "rien qu'une date" tout champ contenant une date, au mépris des textes longs contenant des dates
# MODIF 15:10 26/10/2020 remplace le format de date en sortie de aaaa/mm/jj en aaaa-mm-jj
# BUG	21:29 05/02/2021 le passage de gawk 4 à gawk 5 impose de remplacer \& par  dans la fonction special2html

function special2html(chaine) # convertit les caractères spéciaux en caractères html
{
return chaine
    # spx=gensub(/\&/,"&amp;","g",chaine)
	gensub(/&/,"&amp;","g",chaine)
    # spx=gensub(/\\&/,"et;","g",chaine)
	spx=spx+gensub(/á/,"&aacute;","g",chaine)
	spx=spx+gensub(/á/,"&aacute;","g",chaine)
	spx=spx+gensub(/â/,"&acirc;","g",chaine)
	spx=spx+gensub(/â/,"&acirc;","g",chaine)
	spx=spx+gensub(/à/,"&agrave;","g",chaine)
	spx=spx+gensub(/é/,"&eacute;","g",chaine)
	spx=spx+gensub(/ê/,"&ecirc;","g",chaine)
	spx=spx+gensub(/è/,"&egrave;","g",chaine)
	spx=spx+gensub(/ô/,"&ocirc;","g",chaine)
	spx=spx+gensub(/ö/,"&ouml;","g",chaine)
	spx=spx+gensub(/ù/,"&ugrave;","g",chaine)
    
    return chaine 
    # return chaine " contenait " spx " speciaux"
}

function print3spacespadded(champ,chaine,     longchaine) # rajoute le nombre d'espaces nécessaires en tête de la chaine (ne l'invoquer que si elle fait moins de 3 caractères et est exclusivement numérique)
{
    chaine="  " chaine
    chaine=gensub(/.*(...)$/,"\\1",1,chaine)
    printxml(champ,chaine)
}

function printtexte(champ,chaine) # convertit les caractères spéciaux avant d'imprimer
{
        printxml(champ,special2html(chaine))
}

function printdate(champ,chaine,    localarray) # affiche au format aaaa/mm/jj une date jj/mm/aa et laisse les autres formats inchangés
{
    if (match(chaine,"([0-3]{0,1}[0-9])/([0-1]{0,1}[0-9])/([0-9]{4})",localarray)) {
        if (localarray[3]>999) {
            chaine=localarray[3] "-" localarray[2] "-" localarray[1]
        }
    }
    printxml(champ,chaine)
}

function printchamp(champ,chaine,       longchaine) # voit s'il faut imprimer en tant que nombre ou en tant que chaine
{
    longchaine=length(chaine)
    if (longchaine <3) {
        if (chaine + 0 == chaine) { # vrai si texte représente un nombre, faux sinon
            print3spacespadded(champ,chaine)
        } else {
            printtexte(champ,chaine)
        }
    } else {
       # if (index(chaine,"/") >2) {  # format date supposé, on tente de l'afficher en aaaa/mm/jj au lieu de jj/mm/aa
       if (chaine ~ /^ *[0-3]{0,1}[0-9])\/([0-1]{0,1}[0-9])\/([0-9]{4}) $/) {
            printdate(champ,chaine, localarray)
       } else {
            printtexte(champ,chaine)
       }
    }
}

function printxml(champ,chaine) # produit la ligne correspondant à un couple champ/valeur dans la sortie xml
{
    # gensub(/\\&/,"et","g",chaine)
    # spx=gsub(/\\&/,"et",chaine)
    print tabu tabu "<" champ ">" chaine  "</" champ ">"
}

BEGIN {
    FS=";"
    tabu="\t"
    
    # nbchamps=4
    
    print "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>"
    print "<fichier>"
 }

NR==1 { #vérification de la structure du fichier CSV
    if ($1 !~ /[^0-9][A-z]+$/) if ($1 !~ /[0-9]{4}/) { # 1° champ ne commence pas par un chiffre puis ne contient que des lettres ET 1° champ n'est pas une année
        print "ERREUR : Manque l'intitulé des champs " NR "@" $1 "@"
        exit 1
    }
    nbchamps=NF # détermine le nombre de champs du fichier
    gsub(/ /,"_") # remplace tous les espaces par des _
    for (i=1;i<=NF;i++) {    # détermine les noms des champs
        entete[i]=$i
        if ($i !~ /./) { # cas particulier des champs dont l'en-tête est vide
            entete[i] = "champ_" i
        }
    }
    next
}

NF== nbchamps   {#MAIN - on ne prend en compte que les enregistrements dont le nombre de champs colle avec l'en-tête du fichier
    gsub(/<\/br>/," \r\n") # les sauts de lignes ne sont pas digérés par la moulinette ajax qui traite le fichier généré
    print tabu "<enregistrement>"
        for (i=1;i<=NF;i++) {   #boucle d'écriture des champs de données
        # print i,entete[i],$i
            printchamp(entete[i],$i)
        }
    print tabu "</enregistrement>"
}

END {
    print "</fichier>"
}