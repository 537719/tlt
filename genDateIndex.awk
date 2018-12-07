# genDateIndex.awk
# 05/04/2018 - 17:26:10
# génère une page d'index html
# selon les règles suivantes :
#   une ligne en entrée => un lien vers le dossier de nom correspondant à la ligne
#   ne produit de sortie que pour les lignes ayant un format date (aaaa-mm-jj pour l'instant)
#   trie la sortie par ordre de date décroissante (donc le plus récent en haut)
# MODIF 26/10/2018 - 16:02:31 rajout d'un lien vers la page de suivi des projets
# BUG   03/12/2018 - 11:39:31 corrige la valeur erronée du generator dans l'invocation de la fonction makehead
# MODIF 03/12/2018 - 11:39:31 rajoute le lien vers la visu du stock alturing dans le bas de page

@include "IShtmlInclude.awk"
BEGIN {
    delete tablo
}

/[0-9]{4}-[0-9]{2}-[0-9]{2}/ { # s'assure de ne sélectionner que les lignes contenant une date au format aaaa-mm-jj
    tablo[NR]=gensub(/.*([0-9]{4}-[0-9]{2}-[0-9]{2}).*/,"\\1","1",$0) # ne garde que la date au format aaaa-mm-jj parmi la ligne du flot d'entrée
}

END {
    makehead("Index principal","Liste des Statistiques I&S par famille de produit","genDateIndex.awk","statistiques,flux,sorties,stock,i&s,liste,dates","Liste des Statistiques I&S par famille de produit","http://quipo.alt","gilles.metais@alturing.eu")
    
    PROCINFO["sorted_in"] = "@val_type_desc"
    # choisit l'ordre dans lequel les indices seront scannés, voir https://www.gnu.org/software/gawk/manual/gawk.html#Controlling-Scanning
    # for (i in tablo) print tablo[i] 
    print "\t\t<h1 align=\"center\">"
    print "\t\t\tListe des Statistiques I&S par famille de produit"
    print "\t\t</h1>"
    print "\t\t<div align=\"center\">"
    print "\t\t\t<a href=\" webresources/aide.html\">Aide</a><hr/>"
    for (i in tablo) {
        split(tablo[i],aaaammjj,"-")
        print "\t\t\t<a href=\"" tablo[i]"/index.html\">État au  " aaaammjj[3] "/" aaaammjj[2] "/" aaaammjj[1] "</a><br/>"
    }
    print "\t\t</div>"
    print "\t\t<hr/>"
    print "\t\t<div align=\"center\">"
    print "\t\t\t" htmllink("../snxcc/index.html","Imputations")
    print "\t\t\t" htmllink("../projets/index.html","Projets")
    print "\t\t\t" htmllink("../stockalt/index.html","&copy;Alturing")
    print "\t\t</div>"
 }