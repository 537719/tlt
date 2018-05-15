#typesortieinclude.awk
# Détermination du type de sortie d'après le fichier d'export du matériel expédié par I&S
# Le type de sortie prenant au final l'une des valeurs suivantes :
# DEL : mise en Destruction
# RMA : Envoi en réparation
# DEM : Sortie sur demande
# INC : Sortie sur incident

# Selon les critères suivants :
# en règle générale:
#   la priorité P2 signifie INC et les priorités P3 et P3 signfient DEM
#   la provenance SWAP signifie INC et la provenance DEPLOIEMENT signifie DEM
# en pratique c'est plus compliqué :
#   Il arrive que les champs Priorité et Provenance ne soient pas en cohérence
#   Ces champs peuvent être vides
#   Certains matériels apparaissent en incident alors qu'ils n'y sont pas éligibles
#   Il faut distinguer les envois en maintenance de ceux en destruction
#   Certains des envois en maintenance ou en destruction sont affectés d'un code priorité ou provenance pouvant être pris pour du INC ou du DEM
#   Il y a des fautes de frappe dans la valeur du champ provenance

# LIMITATIONS :
#   La validation du résultat n'a pu être faite que sur les données correspondant à un numéro GLPI valide
#   Cette validation ne peut concerner que le contrôle des valeurs DEM et INC (pas pertinent pour les RMA et DEL)
#   Certaines discordances entre la valeur GLPI et le résultat de ce script sont logiques :
#       RECONFIFURATIONS (suite à un incident, mais traités en DEMANDE selon les critères du contrat)
#       Pannes sur matériel exclu du périmètre du swap (matériel bureautique, etc)



# Selon le format de fichier suivant (séparé par point virgule)
# 1 GLPI
# 2 Priorit▒
# 3 Provenance
# 4 DateCr▒ation
# 5 CentreCout
# 6 Reference
# 7 Description
# 8 Date BL
# 9 D▒pot
# 10 sDepot
# 11 Num Serie
# 12 Nom Client L
# 13 Adr1 L
# 14 Adr2 L
# 15 Adr3 L
# 16 CP L
# 17 Dep
# 18 Ville L
# 19 Tagis
# 20 Societe L
# 21 NumeroOfl
# 22  Pays de destination

# CREATION 02/05/2018 - 10:10:53 en tant que script autonome
# VALIDATION 07/05/2018 - 16:09:53 Validation par croisement avec les données issues de GLPI du résultat produit sur un échantillon de donnée regroupant tout 2017 et le début 2018, voir #LIMITATIONS
# MODIF 09/05/2018 - 10:51:00 transformation du script autonome en module à inclure (ie rien d'actif dans les sections BEGIN, MAIN et END)

function typesortie(dossier, priorite, provenance, reference, codepostal,   localvar,exitvar)
{
    exitvar="N/A"
    switch(dossier provenance) {
        case /PAL|DESTR/ :
        {
           exitvar="DEL"
           break
        }
        
        case /^PR/ : # PROD, Préparation - à placer avant le test de RMA afin d'éviter que PREPARATION soit pris pour REPARATION
        {
            exitvar="DEM"
            break
        }
        
        case /NAV|RMA|RETOUR|REPAR/ :
        {
           exitvar="RMA"
           break
            # rajouter le cas des renvois vers lvi/spc/athesi et ayant un numéro de dossier
        }
        
        case /^1[0-9]{9}|^[I|R]M[0-9]{5}/ : # dans le cas où on a un numéro de dossier valide - attention on peut sortir de ce case sans avoir de "return" élucidé
        {
            localvar=codepostal reference
            switch (localvar) {
                case /94043CHR34/ : #LVI
                {
                   exitvar="RMA"
                   break
                }
                case /91019CLP34/ : #SPC
                {
                   exitvar="RMA"
                   break
                }
                case /94360CHR63/ : #ATHESI
                {
                   exitvar="RMA"
                   break
                }
            }
            if (provenance ~ /^.E/) { # Reconditionnement, Preparation, Deploiement, Demande, etc...
                exitvar="DEM"
                break
            }
            switch(priorite) { # il n'y a pour l'instant qu'un seul case dans ce switch. Je sais c'est con et inutile mais ça donne la possibilité d'en rajouter plus tard
                case  /P2/ :
                { # vérification des cas de swap autorisés
                    switch (reference) {
                        case /^C..10/ : #UC fixes CHR et COL (et encore, pas toutes mais on ne peut pas savoir)
                        {
                           exitvar="INC"
                           break
                        }
                        case /^CHR47/ : #carte wifi intégrée à une UC
                        {
                           exitvar="INC"
                           break
                        }
                        case /^C..3[2|4]/ : # imprimantes CHR et COL laser nb et thermiques
                        {
                           exitvar="INC"
                           break
                        }
                        case /^CHR41N.0BQ/ : # module éthernet accompagnant les imprimantes PC43d (thermiques chrono)
                        {
                           exitvar="INC"
                           break
                        }
                        case /^CHR6[3|4]..1A/ : # PSM chrono ou socle de PSM
                        {
                           exitvar="INC"
                           break
                        }
                        case /^CHR54..1E7/ : # alim socle de PSM
                        {
                           exitvar="INC"
                           break
                        }
                    }
                }
            }
        }
        
        case /S.*W.*P/ : # SWAP éventuellement mal orthographié, attention matche éventuellement avec switch + lettre P 
        {
            if (priorite !~ /P[3-5]/) { # accepte seulement les cas vide et P2 (P1 n'existe pas)
                exitvar="INC"
                break
            }
        }
        
       default : # attention car le case sur la vérif de numéro de dossier valide permet une sortie autrement que par un return
        {
           exitvar="DEM" # tous les autres cas que ceux qui ont été déterminés précédemment sont considérés comme étant des demandes
        }
    }
    return exitvar
}
BEGIN {
# Dé-commenter les lignes suivantes dans le cas où ce module doit être testé en stand-alone plutût qu'être utilisé en @INCLUDE
    # FS=";"
    # OFS=";"
    # IGNORECASE = 1
    
    # print "Ce module n'est pas censé être invoqué directement mais appelé par d'autres scripts au moyen d'une instruction #INCLUDE"
    # exit 1
    # print "!dossier" OFS "virgule" OFS "priorite" OFS "provenance" OFS "Reference" OFS "codepos" OFS "typesortie" OFS "index" OFS "typedossier" OFS "anomalie" OFS "erreur"

}
{ #MAIN
    # print $1 OFS "," OFS $2 OFS $3 OFS $6 OFS $16 OFS typesortie($1,$2,$3,$6,$16)
}
END { # ATTENTION
    # régler dans le programme appelant la problématique de plusieurs articles revenant avec un code de type de sortie différent
    # une première approche est faite dans ce module en considérent que certains accessoires sont autant éligibles au swap que des produits principaux
    # --> uc + carte wifi, psm + dock + alim par exemple
}
