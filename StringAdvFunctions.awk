# StringAdvFunctions.awk
# CREE  02/11/2018 - 11:36:16 d'après ArticlesDemandesProjets.awk 02/11/2018 - 11:37:32

# OBJET : Centralisation dans un module commun des fonctions créées pour le traitement avancé des chaines de caractères dans Awk
# Premier usage : Invocation depuis ArticlesDemandesProjets.awk et VillesDemandesProjets.awk

# MODIF 28/11/2018 - 11:05:36 rajoute les fonctions leftstr(chaine,n) et rightstr(chaine,n) qui retournent les n caractères qui respectivement commencent ou terminent la chaine

function leftstr(chaine,n) # retourne les n premiers caractères de la chaine
{
    return substr(chaine,1,n)
}
function rightstr(chaine,n      ,l) # retourne les n derniers caractères de la chaine
{
    l=length(chaine)
    return substr(chaine,l-n+1,n)
}

function trim(chaine) #enlève les espaces (et ":") de début et de fin de chaine
{
    # sub(/^[ |:]+/,"",chaine)
    sub(/^[ |:]*/,"",chaine)
    sub(/ *$/,"",chaine) 
    # sub(/ +$/,"",chaine) # ne marche pas, on verra plus tard pourquoi
    return chaine
}

function tab2spc(chaine) #remplace les tabulations par des espaces dans une chaine
{
    gsub(/\t/," ",chaine)   # remplace les tabus par des espaces
    return chaine
}

function ddblspc(chaine) # remplace les multiples espaces consécutifs par un espace simple
{
    gsub(/ +/," ",chaine)
    return chaine
}

function epurechaine(chaine) # enlève certains caractères inutiles dans la chaine de caractères passée en paramètre
# tabulations, espaces aux extrémités, paire de parenthèses encdadrant la chaine 
{
    chaine=tab2spc(chaine)     # remplace les tabus par des espaces
    chaine=ddblspc(chaine)     # remplace les multiples espaces consécutifs par un espace simple
    # chtemp=gensub(/^\((.*)\)$/,"\\\1","g",chaine)  # si toute la chaine est encadrée par des parenthèses, les enlève
    # chaine=gensub(/^ *(*.*) *$/,"\\1","g",chaine)  # enlève les espaces commençant ou terminant la chaîne
    # ^^ le gensub ne marche pas (substitue même si pas premier caractère) donc application d'une solution alternative
    chaine=trim(chaine)
    if (index(chaine,"(")==1) {
        if (index(substr(chaine,length(chaine)-1),")")==1) {
            chaine=substr(chaine,2,length(chaine)-3)
        }
    }
    return chaine
}
