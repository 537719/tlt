#ISsuiviInclude.awk
#module à inclure regroupant les fonctions communes aux stats de suivi I&S
#à destination de la famille de script ISsuiviXXX.awk

# CREATION 12/02/2018 - 16:06:19 en tant que nouvelle branche statsinclude divergeant de la branche statsis
# MODIF 15/02/2018  14:43 rajoute l'index de départ comme premier paramètre de la fonction "affiche"
# MODIF 16/02/2018 - 15:28:17 COLPORT et WIFICISCO ne sont plus monitorés
# MODIF 16/02/2018 - 15:31:00 rajoute les uc "deloc" prémasterisées au pool CHRUC
# MODIF 27/03/2018 - 10:28:03 remplace la famille des uc hp rp 5700/5800 (chrrp) par la famille des uc xp (CHRXP), identique sauf qu'elle inclut aussi les Lenovo compatibles W7 (donc XP), plus difficile à calculer
# MODIF 04/04/2018 - 17:20:43 ajoute un avertissement indiquant que ce script doit être utilisé comme #inclide et interdisant de l'utiliser en stand-alone
# BUG   09/05/2018 - 15:47:1 - il y a besoin d'avoir le numéro de série en 2nd paramètre pour pouvoir déterminer la famille "sérialisé"
# MODIF 09/05/2018 - 15:49:25 - Ajout de la réf -19N à la famille "FINGERPRINT"
# MODIF 23/11/2018 - 15:12:54 - Ajout des imprimantes MS826DE au périmètre des imprimantes C11

function initfamilles() # initialise un tableau avec le nom des familles de produits suivies
{
    familles[1]="COLPV"
    familles[2]="COLGV"
    familles[3]="COLMET"
    familles[4]="PFMA"
    familles[5]="COLUC"
    # familles[6]="COLPORT"
    # familles[7]="WIFICISCO"
    familles[06]="C11"
    familles[07]="CHROMEBOOK"
    # familles[8]="CHRRP"
    familles[8]="CHRXP"
    familles[9]="CHRUC"
    familles[10]="CHRPORT"
    familles[11]="SERVEURS"
    familles[12]="PSMM3"
    familles[13]="UCSHIP"
    familles[14]="ZPL"
    familles[15]="FINGERPRINT"
    familles[18]="SERIALISE"
    familles[19]="DIVERS"
}

function zerofamilles() # initialise à zéro la matrice famille x statut afin de ne pas avoir de "cases vides" à la sortie
{
    # la matrice [types] est censée être créée de façon externe, parce qu'elle diffère selon le script appelant
    for (i in familles) for (j in types) nbsorties[familles[i] types[j]]=0 # afin de ne pas avoir de "cases vides" à la sortie
}

function erreurnf(n) # produit un message d'erreur si le fichier traité n'a pas le nombre de champs souhaité
{
            print "Ce fichier n'est pas du type requis car il contient " n " champs."
}

function selectfamille(entree,sn)    # détermination de la famille de produits, la référence du produit et l'éventuel numéro de série étant passés en paramètres
{
    switch (entree) { # corriger les expressions régulières en fonction des critères précis
        case /CHR34[N|R]S19[M|N]|CHR34RS18R|CHR34NS18R|CHR34RSZXT|CHR34NS0TK|CHR34RS0IT|CHR34RSZXS|CHR34NS0IT|CHR34RSZXZ|CHR34RSZY1|CHR34NS0LN|CHR34NS0KR|CHR34NS15B|CHR34RSZXV/ :
        {
            sortie="FINGERPRINT"
            break
        }
        
        case /CHR34[N|R].18[P|Q]/ : # pc43d ZPL
        {
            sortie="ZPL"
            break
        }
        case /CLP34[N|R]S0CN|CLP34[N|R]S1A[4|H|N|P]|CLP34RS0E1|CLP34[N|R]S1B1/ :  # Colissimp PV
        {
            sortie="COLPV"
            break
        }
        
        # case /CHR10[N|R][F|P]0[DT|VK]|CHR10[N|R][F|I|P]18[3|M]|CHR10[N|R][F|P]164|CHR10RFZX6|CHR10RIKFX/ : # UC CHR RP remplacé par UC CHR XP depuis le 27/03/2018
        # {
            # sortie="CHRRP"
            # break
        # }
        case /CHR10[N|R][F|P]1A[4|S]|CHR10[N|R][F|I|P]18[3|M]|CHR10[N|R][F|P]0[DT|VK]|CHR10[N|R][F|P]164|CHR10RFZX6|CHR10RIKFX/ : # UC CHR XP - remplace UC CHR RP depuis le 27/03/2018 = idem plus références -1A4 et -1AS
        #IMPORTANT 28/03/2018 - 16:16:23 il faut que cette section soit placée avant celle des CHRUC de manière à sortir avant en cas de détection de -1A4 ou -1AS
        {
            sortie="CHRXP"
            break
        }
        
        case /CHR10.[^S]1[A-Z]/ : # inclut toutes les UC Lenovo M78/M79 y compris les poses développeurs (M73 i7 et m700) ainsi que les uc dell, et hors shipping
        #MODIF 12/02/2018 - 16:35:15 prise en compte des nouveaux modèles d'uc HP -1ER et -1F4 ainsi que les éventuels ultérieurs 
        #VERIF 16/02/2018 - voir si possible d'extraire facilement les uc non compatibles w8/10 (ie -1AS et -1A4)
        #IMPORTANT 28/03/2018 - 16:16:23 il faut que cette section soit placée après celle des CHRXP de manière à sortir avant en cas de détection de -1A4 ou -1AS
        {
            if (entree ~ /1A[4|S]$/) {
                # normalement on ne passe jamais par ici, si le test CHRUC a bien été fait auparavant
                sortie="CHRXP"
                break
            }
            sortie="CHRUC"
            break
        }
        case /^CHR10.[^S]STT/ : # rajoute les uc "deloc" prémasterisées au pool CHRUC
        #MODIF 16/02/2018 - 15:31:00 rajoute les uc "deloc" prémasterisées au pool CHRUC
        {
            sortie="CHRUC"
            break
        }
        
        case /CHR10.S/ : # UC Chronoship
        {
            sortie="UCSHIP"
            break
        }
        
        case /^CLP10/ : # UC Coli
        {
            sortie="COLUC"
            break
        }
        
        # COLPORT n'est plus monitoré depuis début 2018
        # case /CLP11[N|R][F|P]189|CLP11[N|R]F18K|CLP11[N|R][F|P]1[8|9]T|CLP11[N|R][F|P]19[0|R|S]|CLP11[N|R][F|P]1D./ : 
        # {
            # sortie="COLPORT"
            # break
        # }
        
        case /CLP34[N|R][F|P|S]1A[I|M|O]|CLP34[N|R]S194/ : 
        {
            sortie="COLGV"
            break
        }
        
        case /CLP34[N|R][F|P]194|CLP34[N|R][F|P]1BD/ :
        {
            sortie="PFMA"
            break
        }
        
        case /CLP34[N|R][F|S|P]0E2|CLP34[N|R][F|P|S]15P|CLP34[N|R][F|P]1BC|CLP34[N|R][F|P]13K/ :
        {
            sortie="COLMET"
            break
        }
        
        # WIFICISCO n'est plus monitoré depuis début 2018
        # case /CHR47[N|R][F|P]0T7/ :
        # {
            # sortie="WIFICISCO"
            # break
        # }
        
        case /CHR11[N|R][F|P]1../ : # Portables CHR
        {
            sortie="CHRPORT"
            break
        }
        
        case /^CHR48/ :
        {
            sortie="SERVEURS"
            break
        }
        
        case /^CHR12/ :
        {
            sortie="CHROMEBOOK"
            break
        }
        
        case /^CHR32[N|R][F|P]1[A2|G3]$/ : # MODIF 23/11/2018 - 15:12:54 - Ajout des imprimantes MS826DE au périmètre des imprimantes C11
        {
            sortie="C11"
            break
        }
        case /CHR63[N|R][P|F]1AD/ :
        {
            sortie="PSMM3"
            break
        }

        default :
        {
            if (sn ~ /./) {
                sortie="SERIALISE"
            } else {
                sortie="DIVERS"
            }
        }
    }
    return sortie
}

function affiche(indexmin,indexmax,tablo1,tablo2,tablo3)
{
    ligne= "!" FILENAME
    for (j=indexmin;j<=indexmax;j++) ligne= ligne OFS tablo1[j]
    print ligne
    for (i in tablo2) {
        ligne= tablo2[i]
        for (j=indexmin;j<=indexmax;j++) ligne=ligne OFS tablo3[tablo2[i] tablo1[j]]
        print ligne
    }
}

BEGIN {
    # print "Ce module n'est pas censé être invoqué directement mais appelé par d'autres scripts au moyen d'une instruction #INCLUDE"
    # exit 1
}