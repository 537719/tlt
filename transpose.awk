# transpose.awk
# CREATION  14:57 jeudi 30 janvier 2020 transpose de lgnes en colonnes le fichier d'historique des stats de coût de stockage
# MODIF         17:56 vendredi 31 janvier 2020 produit au maximum 13 lignes en sortie afin d'avoir un historique sur 13 mois glissants
# MODIF     16:41 mardi 4 février 2020 rajout de "ISI" en tant que pseudo-BU afin de pouvoir générer les stats d'incident de production I&S qui utilisent le même format de fichier mais avec la valeur ISI là ou l'on a la BU

# Entrée :
# Stockd du;BU;Qte;Famille;CoutHebdo;CoutCumul
# 2018-11-30;CHR;12266;Cablage;711.344730250931;40136.9190042659
# 2018-11-30;CHR;4725;Divers / Accessoires;419.586194103028;16928.3283522568
# 2018-11-30;CHR;386;Ecran;92.5429628820004;4789.83404539202
# 2018-11-30;CHR;208;Imprimante;86.6143847110001;2540.66004658201
# 2018-11-30;CHR;1332;PC;372.086139233997;21621.281835072
# 2018-11-30;CHR;1314;Reseau;85.5858122249992;5269.677459079
# 2018-11-30;CHR;76;Serveur;36.571470362;2700.345942948
# 2018-11-30;CHR;739;Shipping;66.9101294179995;4884.421990263
# 2018-12-10;CHR;12229;Cablage;709.239436830931;40798.5631480608
# 2018-12-10;CHR;4696;Divers / Accessoires;413.041213074028;17056.709452041
# 2018-12-10;CHR;375;Ecran;90.6858179000004;4886.96272772101
# 2018-12-10;CHR;202;Imprimante;83.8858101640001;2634.73158266701
# 2018-12-10;CHR;1314;PC;367.457562517997;21857.0678186389
# 2018-12-10;CHR;1303;Reseau;85.0000972679992;5338.82039530103
# 2018-12-10;CHR;76;Serveur;36.571470362;2739.831702354
# 2018-12-10;CHR;777;Shipping;79.5672867239999;4894.06062572202

# Sortie souhaitée
# Date;CHR Cablage;CHR Divers / Accessoires;CHR Ecran;CHR Imprimante;CHR PC;CHR Reseau;CHR Serveur;CHR Shipping
#30/11/2018;711.344730250931;419.586194103028;92.5429628820004;86.6143847110001;372.086139233997;85.5858122249992;36.571470362;66.9101294179995
#10/12/2018;709.239436830931;413.041213074028;90.6858179000004;83.8858101640001;367.457562517997;85.0000972679992;36.571470362;79.5672867239999

# C'est à dire qu'on ne conserve que l'on met sur une seule ligne par date toutes les valeurs de couthebdo pour chaque couple bu+famille

BEGIN {
    FS=";"
    OFS=FS
}

$2 !~ /CHR|COL|TEL|ISI/ { sub(/.*/,"CHR",$2)} # toute BU n'apparaissant pas en Chrono, Coli, Telintrans est attribuée à Chronopost (cas de Chronofood, libellé en tant que Food)
 NR>1 { # main
    jour=$1
    BU = $2
    famille=$4
    couthebdo=$5
    
    
    BUfamille= BU " " famille
    aBUfamille[BUfamille]=BUfamille
    aDate[jour]=jour
    # print BUfamille
    tablo[jour BUfamille] = tablo[jour BUfamille] + couthebdo
    
}

END {
    asort(aBUfamille)
    printf "Date" OFS
    for (i in aBUfamille) {
        # if (aBUfamille[i] ~ /CHR/) {
            printf  aBUfamille[i] OFS
        # }
    }
    printf "Total\r\n"
    # for (i in aBUfamille) {
        # print i OFS  aBUfamille[i]
    # }
    imax=asort(aDate)
    imin=imax-13
    if (imin<1) imin=1
    # print imin,imax
    for (j=imin;j<=imax;j++) {
        totaljour=0
        printf aDate[j] OFS
        for (i in aBUfamille) {
            # if (aBUfamille[i] ~ /CHR/) {
                printf  "%d%s",tablo[aDate[j] aBUfamille[i]]+0.5 , OFS
                totaljour=totaljour+tablo[aDate[j] aBUfamille[i]]
            # }
        }
        printf "%d%s",totaljour +0.5 , "\r\n"
    }
}