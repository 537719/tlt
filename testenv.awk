#testenv.awk
#test de récupération des variables d'environnement
#afin d'en extraire le nom du répertoire courant
{
    disque=ENVIRON["HOMEDRIVE"]
    print "HOMEDRIVE " ENVIRON["HOMEDRIVE"]
    print "!C: " ENVIRON["!C:"]
    print "toto @" ENVIRON["toto"] "@"
    print "ISdir " ENVIRON["ISdir"]
    
    disque="!" disque
    chemin=ENVIRON[disque]
    print "chemin " chemin
    # for (i in ENVIRON) {print i OFS ENVIRON[i]}
}