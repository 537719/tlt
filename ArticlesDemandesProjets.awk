#ArticlesDemandesProjets.awk
# CREE  16/10/2018 - 14:04:16 isole quantité,référence et désignation dans un flot de texte contenant de tout, y compris des lignes d'articles
# BUG   02/11/2018 - 11:37:32 laissait parfoit passer un espace en début de champ
# MODIF 02/11/2018 - 11:37:32 déport dans le module StringAdvFunctions.awk des fontions avancées de traitement de chaine de caractères

# USAGE : Destiné à être invoqué depuis le script ArticlesDemandesProjets.cmd

@include "StringAdvFunctions.awk"

BEGIN {
    FS=" "
    OFS=";"
    if (dossier !~ /[0-9]{10}/) { # invocation sans numéro de dossier dans le cas où l'on veut juste créer l'en-tête
        print dossier OFS "Qte" OFS "Reference" OFS "Designation" # en-têtes de champ
        exit
    }
}
/CHR[0-9][0-Z][N|R][F|P][0-Z]{3}/ { #référence brute

# next # inhibition temporaire pour ne pas parasiter le débuggage de la partie # refbundle

    vu=match($0,/[^0-9]*([0-9]*).* *(CHR[0-9][0-Z][N|R][F|P][0-Z]{3}) *(.*)/,tablo)
    # pour toute ligne commençant éventuellemen par autre chose qu'un nombre (exemple : 'Qté')
    # et contenant peut-être un nombre (quantité) 
    # puis éventuellement autre chose qu'un nombre (exemple : 'X' ou '*')
    # puis au moins un espace
    # et contenant une référence brute
    # puis au moins un espace
    # le reste est pris comme désignation
    
    if (tablo[1]+1==1) {tablo[1]=1} # corrige les lignes pour lesquelles aucune quantité n'est spécifiée, en assumant dans ce cas que c'est l'unité

    print dossier OFS tablo[1] OFS tablo[2] OFS epurechaine(tablo[3])
    nblgn[dossier]++ # test de présence de refbrute pour le dit dossier
    
    next # important, sinon la ref brute est aussi interpretée comme une refbundle
}
/CHR[0-Z]{3,5}/ && !/CHRON/ { #refbundle
    if (nglgn[dossier]==0) {    #si on a des références brutes demandées pour on dossier, il y  tout lieu de considérer qu'elles sont le détail du bundle donc on l'ignore
        vu=match($0,/[^0-9]*([0-9]*).* *(CHR[0-Z]{3,5}) *(.*)/,tablo)
 
        if (tablo[1]+1==1) {tablo[1]=1} # corrige les lignes pour lesquelles aucune quantité n'est spécifiée, en assumant dans ce cas que c'est l'unité
        if (tablo[3]) {tablo[3]=epurechaine(tablo[3])}
 
        cle=dossier OFS tablo[2]
        if (tablo[1]>qte[cle]) {qte[cle]=tablo[1]}
        if (length(tablo[3])>length(lib[cle])) {lib[cle]=tablo[3]}
    }
}
# /BUNDLE/ {print dossier OFS $0} 
# on pourrait en théorie appliquer un traitement inspiré de celui du cas "bundle"
# car une refbundle (mal écrite car contenant un espace) se trouve souvent sur la meme ligne
# mais le matériel est aussi détaillé dans les autres lignes du dossier (pour tous les  échantillons vus en tout cas)
# donc ce traitement est inutile

END {
    for (i in qte) {
        split(i,champ,";")
        dossier=champ[1]
        ref=champ[2]
        if (nglgn[dossier]==0) {    #si on a des références brutes demandées pour on dossier, il y  tout lieu de considérer qu'elles sont le détail du bundle donc on l'ignore
            print dossier OFS qte[i] OFS ref OFS lib[i]
        }
    }
}