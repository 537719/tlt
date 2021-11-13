# typagechamps.awk
# CREATION  18:53 27/10/2021 D‚termine le type le plus adapt‚ … chaque champ d'un fichier csv
BEGIN {
    IGNORECASE=1
    FS=";"
    OFS=","
    
    libtype[9]="NoColis"
    libtype[8]="NoDossier"
    libtype[7]="date"
    libtype[6]="heure"
    libtype[5]="dateheure"
    libtype[4]="entier"
    libtype[3]="flottant"
    libtype[2]="pourcent"
    libtype[1]="texte"
    libtype[0]="vide"
    
    generator=""
    for (i in PROCINFO["argv"]) { generator=generator PROCINFO["argv"][i]" "} # r‚cupŠre toute la ligne de commande contrairement … ARGV[]
}
NR==1 { # traitement de la ligne d'en-tˆte
    split(FILENAME,splitname,".") # s‚pare nom et extension du fichier d'entr‚e
    
    
    
    if ($1 !~ /[^0-9][A-z]+$/) if ($1 !~ /[0-9]{4}/) { # 1ø champ ne commence pas par un chiffre puis ne contient que des lettres ET 1ø champ n'est pas une ann‚e
        print "ERREUR : Manque l'intitul‚ des champs " NR "@" $1 "@"
        exit 1
    }

    nbchamps=NF # d‚termine le nombre de champs du fichier
    for (i=1;i<=NF;i++) {    # sauvegarde les noms des champs avec accents et espaces, pour affichage
        accent[i]=$i
    }
    gsub(/ /,"_") # remplace tous les espaces par des _
    gsub(/.\251/,"e") # 251 = conversion en octal de 169 en d‚cimal, code ascii du ‚ - le . avant le \251 est l…ÿ parce que ce caractŠre est cod‚ sur 2 digits
    for (i=1;i<=NF;i++) {    # d‚termine les noms des champs, sans accents ni espaces, pour traitement des donn‚es
        entete[i]=$i
        if ($i !~ /./) { # cas particulier des champs dont l'en-tˆte est vide
            entete[i] = "champ_" i
        }
    }

    for (i=1;i<=NF;i++) { # constitution de la liste des noms de champs
        nom[i]=$i
    }
}

NR > 1 { #MAIN - D‚termine le type de chaque champ
    # print $0
    for (i=1;i<=NF;i++) {
        # suppression des espaces en d‚but et fin de donn‚e
        gsub(/^ */,"",$i)
        gsub(/ *$/,"",$i)
        
        # d‚termination du type de donn‚e
        if ($i) switch($i) {
            case /[A-Z]{2}[0-9]{9}[A-Z]{2}/ :
            # pas de calage sur les d‚but et fin de champ car il peut y avoir plusieurs NoColis … l'int‚rieur
            {   #NoColis
                type[i,9]++
                break
            }
            case /^[0-9]{10}$/ :
            {   #NoDossier
                type[i,8]++
                break
            }
            # case /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/ :
            # {   #date
                # type[i,7]++
                # break
            # }
            case /^[0-9]*[-|\/][0-9]*[-|\/][0-9]*$/ :
            {   #date
                type[i,7]++
                break
            }
            case /^[0-9]{2}:[0-9]{2}:[0-9]{2}$/ :
            {   #heure
                type[i,6]++
                break
            }
            case /^[0-9]*[-|\/][0-9]*[-|\/][0-9] +[0-9]{2}:[0-9]{2}:[0-9]{2}$/ :
            {   #dateheure
                type[i,5]++
                break
            }
            case /^[0-9]{4}-[0-9]{2}-[0-9]{2} +[0-9]{2}:[0-9]{2}:[0-9]{2}$/ :
            {   #dateheure
                type[i,5]++
                break
            }
            case /^[0-9]+$/ :
            {   #int
                type[i,4]++
                break
            }
            case /^[0-9| ]+[,|\.][0-9| ]+$/ :
            {   #float
                type[i,3]++
                break
            }
            case /^[0-9| |,|\.]+%$/ :
            {   # %
                type[i,2]++
                break
            }
            default :
            {   # txt
                type[i,1]++
            }
        } else {
            # vide
            type[i,0]++
        }
        # print "ligne " NR,"champ " i,$i
        # for (j=0;j<=9;j++){
            # if (type[i,j] >0) {
                # print type[i,j],libtype[j]
            # }
        # }
    } 
    # print ""
}
END {
    for (i=1;i<=NF;i++) {
    # for (i=1;i<=3;i++) {
        # print "champ " i , entete[i]  
        meilleurtype[i]=0
        for (j in libtype) {
            # print "champ "  i , entete[i]  ", type " j ,libtype[j] " = " type[i,j]+0 " meilleur type = " meilleurtype[i] " avec " type[i,meilleurtype[i]] " valeurs"
            qualite_type[i,j]=100*type[i,j] / ((NR-1)-type[i,0])
            if (type[i,j] > type[i,meilleurtype[i]])      meilleurtype[i]=j
            # if (type[i,j]>0)                print type[i,j] " lignes de type " j,libtype[j] " soit " qualite_type[i,j] "% des non vides"
        }
        if (meilleurtype[i] == 8 && qualite_type[i,j] < 95) meilleurtype[i] = 4 # on ne considŠre comme ‚tant de type "NoDossier" que les champs qui en contiennent plus de 95%
        if (meilleurtype[i] >= 5 && meilleurtype[i] <= 7) meilleurtype[i]=1 # les horodatages sont trait‚s comme des textes
        print "le meilleur type pour le champ " i " " entete[i] " est " meilleurtype[i], libtype[meilleurtype[i]]
    }
}