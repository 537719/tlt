#VillesDemandesProjets.awk
# d'après ArticlesDemandesProjets.awk du 16/10/2018 - 14:04:16
# CREE 29/10/2018 - 14:20:50 isole code postal et ville dans un flot de texte contenant de tout, y compris l'adresse d'expédition souhaitée
# MODIF 02/11/2018 - 11:37:32 déport dans le module StringAdvFunctions.awk des fontions avancées de traitement de chaine de caractères

# USAGE : Destiné à être invoqué depuis le script VillesDemandesProjets.cmd

@include "StringAdvFunctions.awk"

BEGIN {
    FS=" "
    OFS=";"
    if (dossier !~ /[0-9]{10}/) { # invocation sans numéro de dossier dans le cas où l'on veut juste créer l'en-tête
        print dossier OFS "CodePostal" OFS "Ville" # en-têtes de champ
        exit
    }
}
/^[0-9]{4}0 [A-Z| |-|']+/ || / [0-9]{4}0 [A-Z| |-|']+/ { #commence par un code postal ou contient un code postal et contient du texte ensuite
# définition du code postal = 5 chiffres (ni plus ni moins) se terminant par un zéro
# on perd les cédex mais on évite les adresses kilométriques ou les numéros de quai
# de toutes façons on ne doit livrer en cédex

# next # inhibition temporaire pour ne pas parasiter le débuggage de la partie # refbundle
    if (nblgn[dossier]==0) { # si on a déjà une ville pour ce dossier, on n'en cherche pas une autre
        vu=match($0,/([0-9]{4}0) ([A-Z]*.*)/,tablo)
        # pour toute ligne passant l'IR
        # et contenant un code postal (5 chiffres dont le dernier est un zéro)
        # suivi d'un unique espace
        # puis au moins un espace
        # puis le genre de caractères autorisés dans on nom de ville
        # la première parenthèse donne le code postal
        # la 2° la ville
        
        print dossier OFS tablo[1] OFS toupper(epurechaine(tablo[2]))
        nblgn[dossier]++ # test de présence de refbrute pour le dit dossier
    }    
    next # important, sinon la ref brute est aussi interpretée comme une refbundle
}
 donc ce traitement est inutile

END {
}