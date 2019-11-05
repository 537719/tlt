# csvproj2xml.awk
# CREE  03/12/2018 - 12:57:04 d'après csvproj2xml.awk : convertit en xml tout fichier csv
# MODIF 11:28 21/02/2019   assouplit les conditions de validité de l'enregistrement de titre

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
            chaine=localarray[3] "/" localarray[2] "/" localarray[1]
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
       if (index(chaine,"/") >2) {  # format date supposé, on tente de l'afficher en aaaa/mm/jj au lieu de jj/mm/aa
            printdate(champ,chaine, localarray)
       } else {
            printtexte(champ,chaine)
       }
    }
}

function printxml(champ,chaine) # produit la ligne correspondant à un couple champ/valeur dans la sortie xml
{
    print tabu tabu "<" champ ">" chaine "</" champ ">"
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
    gsub(/<\/br>/,"") # les sauts de lignes ne sont pas digérés par la moulinette ajax qui traite le fichier généré
    print tabu "<enregistrement>"
        for (i=1;i<=NF;i++) {   #boucle d'écriture des champs de données
            printchamp(entete[i],$i)
        }
    print tabu "</enregistrement>"
}

END {
    print "</fichier>"
}