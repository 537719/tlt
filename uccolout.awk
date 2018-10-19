# uccolout.awk
# 15/10/2018 - 11:06:06 ventile les uc colissimo sorties par I&S selon qu'elles soient concernent un incident ou une demande
BEGIN {
    FS=";"
    OFS=FS
    
    print "priorite" OFS "origine" OFS "dossier"
}

$6 ~ /^CLP1/ {
    print $2 OFS $1 OFS $3

    switch ($2) { # "priorité"
        case /P2/ : 
        {
           incident++
           break
        }
        case /P[3|4]/ : 
        {
             switch ($3) { # "provenance"
                case /SWAP/ : 
                {
                   incident++
                   break
                }
                case /DEPL/ : 
                {
                   demande++
                   break
                }
                default :
                {
                    autre++
                }
            }
           break
        }
        default :
        {
             switch ($3) { # "provenance"
                case /SWAP/ : 
                {
                   incident++
                   break
                }
                case /DEPL/ : 
                {
                   demande++
                   break
                }
                default :
                {
                    autre++
                }
            }
        }
    }
}
END {
    print "uc COLI sorties"
    print "sur incident : "incident 
    print "sur demande : "demande 
    print "bizarreries : "autre
}
