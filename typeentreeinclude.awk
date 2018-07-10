# typeentreeinclude.awk
# détermine si l'entrée en stock considérée concerne une livraison, un retour de RMA, un retour client ou une sortie d'audit
# d'après un fichier d'export des produits réceptionnés par I&S selon la structure suivante :
# 1 Projet 
# 2 Reference
# 3 Numero Serie
# 4 DateEntree
# 5 APT
# 6 RefAppro
# 7 BonTransport 
# 8 Libell▒
# 9 TagIS
# 10 NumTag 


# règle (farfelue) de ventilation des données dans les champs
# 1 Projet  =>  Stock de destination
# 2 Reference   =>  soit "vraie" référence, soit référence générique
# 3 Numero Serie
# 4 DateEntree  => jj/mm/aaaa hh:mm:ss (mais parfois il n'y a pas d'heure)
# 5 APT         => si commence par ES c'est une livraison, si commence par IS ou vide c'est un retour, si vide le numéro d'apt est dans le champ BonTransport et c'est un IS
# 6 RefAppro    => Si APT commence par ES, contient le numéro de commande ; si BonTransport commence par IS
#               => si contient " - " et APT vide, contient le numéro de commande
#               => sinon, contient  soit un numéro de bon de transport (1 chiffre 1 majuscule suivi de 11 chiffres) ou 2 lettres 9 chiffres 2 lettres)
#               =>                  soit la mention "retour" et/ou "generique" en maj ou min et éventuellement avec des fautes de frappe
#               =>                  soit un numéro non idenfitié dans le cas d'un PSM (numéro de RMA ?)
# 7 BonTransport => soit un numéro de colis, soit la mention "retour", soit le numéro du bon de livraison, soit la valeur qui aurait du être dans le champ APT (ou sa répétition)
# 8 Libell▒     => Désignation de l'article
# 9 TagIS       => si répété, il s'agit d'une préparation (ou audit) de matériel après qu'il ait été auparavant réceptionné. attention, la référence a pu changer
# 10 NumTag     => si non vide, mac:address


# Règle de répartition :
# *LIV   APT commence par ES et matériel neuf
# *LIV   RefAppro contient " - "
# *LIV   RefAppro contient 000*[0-9]{4}
# AUDIT TagIS déjà vu ET référence valide => pas traité dans ce module, l'autre condition étant suffisante
# *AUDIT APT vide
# *CLI   présence d'un numéro de colis
# *CLI   présence d'un numéro de dossier GLPI
# *RMA   Reference de éligible au RMA ET "non LIV" ET ne contient pas de numéro GLPI
# *RMA   présence de la mention RMA ou ATHESI ou SPC ou LVI
# DEL   possibilité de mettre en évidence les retours pour destruction (par exemple certaines entrées ayant une date mais pas d'heure et pas prise en compte par les autres cas) => non pertinent
# CLI   autre cas

# CREATION  26/06/2018 - 14:10:13 en tant que module à inclure
# MODIF     09/07/2018 - 11:19:48 affinage des règles de répartition

function refvalide(ref)
{
    # renvoie 1 si la référence est valide, zéro sinon
    return ref ~ /^[C|T][H|L][R|P|T][0-9][0-Z][N|R][F|P|S][0-Z]{3}$/
}

function refrma(ref)
{
    # renvoie 1 si la référence est éligible au RMA, zéro sinon
    switch(ref) {
        case /^C[H|L][R|P]34R[F|S][0-Z]{3}$/ : # Imprimante thermique reconditionnée appartenant à chronopost ou colissimo
        {
            return 1
        }
        
        case /^CHR63R[F|P]1AD$/ : # PSM M3 Chrono reconditionné
        {
            return 1
        }
        
        default : # tout le reste
        {
            return 0
        }
    }
}

function lignerma()
{
    return $0 ~ /SPC|RMA/ # pas de mention de LVI ou ATHESI car ils peuvent aussi envoyer du neuf
}

function typeentree(ref, apt, refappro, tagis,datein,      localvar)
{   # attention l'ordre des tests est important
    if (apt !~ /./) return "AUDIT"                  # absence de tout numéro de réception donc ré-entrée en stock après audit de matériel déjà reçu auparavant sous un numéro
    if ($0 ~ / +1[0-9]{9}[ |;]+/) return "CLI"  # présence d'un numéro de dossier GLPI donc retour client - Attention au test de la présence des séparateurs de mot sinon confusion possible avec un numéro de tag
    if (refrma(ref))    return "RMA"                # référence éligible au RMA (donc pas de livraison de neuf) et pas de référence à un dossier GLPI
    if (lignerma())     return "RMA"                # mention explicite au RMA dans la ligne
    if (apt ~ /^ES[0-9]{9}$/) return "LIV"          # présence d'un numéro d'appro et pas de retour RMA donc réception de matériel neuf (il peut y avoir des ES pour des retours RMA d'où l'importance de l'ordre des tests)
    if (refappro ~ / - /) return "LIV"              # présence d'un séparateur de numéro de commande donc réception de matériel neuf
    if (refappro ~ /000*[0-9]{4}/) return "LIV"     # présence d'un numéro de commande donc réception de matériel neuf
    if ($0 ~ /[A-Z]{2}[0-9]{9}[A-Z]{2}/) return "CLI"   # présence d'un numéro de colis chronopost donc retour client (pourrait être un retour RMA de Athesi d'où l'importance de l'ordre des tests)
    if ($0 ~ /[0-9][A-Z][0-9]{11}/) return "CLI"    # présence d'un numéro de colis colissimo donc retour client
    if ($0 ~ /GEN|RIQUE/)   return "CLI"            # matériel générique = retour client, improtant de le placer en dernier afin de ne pas interférer avec la notion de GENération (pour les serveurs en particulier)
    
    # A partir d'ici on n'a que des cas "chelous" qui en première instance ressortaient en DEF
    if (refappro ~ /RETOUR|CLIENT|DESTR|ROLL|PAL/) return "CLI" # retour, client, destruction, roll, palette
    if (refappro ~ /^1[0-9]{9}$/) return "CLI"      # uniquement un numéro glpi
    
    switch (ref) {
        case /ATHESI/ :
        {
            return "RMA"
        }
        
        case /^[A-Z]{3}[0-9][0-Z]N[FPS][0-Z]{3}$/ :
        {
            return "LIV"
        }
        
        case /^[A-Z]{3}[0-9][0-Z]R[FPS][0-Z]{3}$/ :
        {
            return "CLI"
        }
        
        default :
        {
            if (datein !~ / /)  return "CLI"            # s'il y a une date et pas d'heure et que le type n'a pas été déterminé avant, il s'agit d'un retour client - inhibé car concerne aussi des retours athesi   
            return "DEF"                                    # retour par défaut en cas d'échec à tous les tests précédents, temporaire afin de déterminer une typologie
        }
    }
    
    # on renonce au comptage du nombre d'apparitions du tagis concerné afin de déterminer s'il s'agit ou non d'un audit, car le test sur l'absence du numéro d'apt est censé suffire
}

BEGIN {
    FS=";"
    OFS=";"
    IGNORECASE=1 # pour éviter les erreurs de saisie en minuscule
    # print "Ce module n'est pas censé être invoqué directement mais appelé par d'autres scripts au moyen d'une instruction #INCLUDE"
}

NR == 1 {
    print "TYPE" OFS $0
}
NR >1 { # MAIN
    # print "Ce module n'est pas censé être invoqué directement mais appelé par d'autres scripts au moyen d'une instruction #INCLUDE"
    # exit 1
    # print "!dossier" OFS "virgule" OFS "priorite" OFS "provenance" OFS "Reference" OFS "codepos" OFS "typesortie" OFS "index" OFS "typedossier" OFS "anomalie" OFS "erreur"

    # correction des désignations contenant des ; par erreur

    for (i=9;i<=NF;i++) {
        if ($i !~ /^TE[0-9]{10}$/) {
            $8 = $8 " " $ i
        } else {
            tagis=$i
            mac=$(i+1)
        }
        $i=""
    }
    $9=tagis
    $10=mac
    NF=10
    
    print typeentree($2,$5,$6,$4) OFS $0
    # print $1
}