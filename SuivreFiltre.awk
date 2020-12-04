# SuivreFiltre.awk
# CREATION  11:39 30/09/2020 Met en forme l'argument fourni de manière à le restituer sous forme de couple "type de donnéee;valeur"
#  Le type de donnée est déduit du format de l'argument fourni
# MODIF     21:44 21/10/2020 permet de suivre l'arrivée d'un numéro de série, est considéré comme tel tout ce qui n'est pas reconnu comme dossier, colis ou apt

BEGIN {
    IGNORECASE=1
    OFS=";"
}

{ # MAIN
    switch ($1) {
        case /^[E|I]S[0-9]{9}$/ :
        {
            Donnee="Livraison"
            Valeur=$1
            break
        }
        case /^[A-Z]{2}[0-9]{9}[A-Z]{2}$/ :
         {
            Donnee="Colis"
            Valeur=$1
            break
        }
        case /^[0-9][A-Z][0-9]{11}$/ :
         {
            Donnee="Colis"
            Valeur=$1
            break
        }
        case /^[0-9]{10}$/ :
         {
            Donnee="Dossier"
            Valeur=$1
            break
        }
        default :
        {
            Donnee="NumSerie"
            Valeur=$1
        }
    }
    if (Valeur) { # entrée valide
        print Donnee OFS toupper(Valeur)
    } else { # entrée invalide, le numéro de la ligne d'entrée est rendu en tant que code erreur
        print "donnée invalide @" Donnee " ligne " NR
        exit NR
    }
}