#IShtmlInclude.awk
#module à inclure regroupant les fonctions communes a la génération de pages html
#à destination de la famille de script gen*.awk (genHTMLindex.awk         genHTMLlink.awk          genressourcesindex.awk)

# CREATION  03/04/2018 - 16:41:43 en tant que nouvelle branche htmlinclude divergeant de la branche statsis
# MODIF     21:03 12/10/2020 Rajout d'un paramètre facultatif de redirection de sortie pour les routines qui en font une
# MODIF     21:08 12/10/2020 changement de la géographie de localisation
# BUG	21:29 05/02/2021 le passage de gawk 4 à gawk 5 impose de remplacer \: par : dans les regexp


function classifinfo(c,     i,x,ligne) # affiche une ligne (typiquement en bas de page) correspondant au niveau de classification de l'information
{   # le paramètre (c) correspond au niveau de confidentialité selon la nomenclature suivante
    # [ ] C0 (Public)
    # [ ] C1 (Interne)
    # [ ] C2 (Restreint)
    # [ ] C3 (Confidentiel)
    # [ ] C4 (Secret)
    # avec une X entre les crochets correspondant au niveau
    # et l'image Cx.png présente dans le dossier de webresources

    c=rangeinfo(c)
    
    for (i=0;i<=4;i++) x[i]="[ ] C" i " "
    x[c]="[x] C" c " "
    for (i=0;i<=4;i++) x[i]=x[i] labelinfo(i)
    
    ligne=""
    for (i=0;i<=4;i++) ligne=ligne x[i]
    return ligne
}

function labelinfo(niveau) # renvoie le texte correspondant au niveau de confidentialité
{
    switch (niveau) {
        case /0/ :
        {
            return "(Public)"
        }

        case /1/ :
        {
            return "(Interne)"
        }

        case /2/ :
        {
            return "(Restreint)"
        }

        case /3/ :
        {
            return "(Confidentiel)"
        }

        case /4/ :
        {
            return "(Secret)"
        }
        
        default :
        {
            return "(Interne)"
        }
    }
}

function rangeinfo(niveau) # vérifie que le niveau d'info passé en paramètre est bien dans le range prévue, attribue le niveau par défaut sinon
{   #difficulté  : le niveau par défaut est 1 mais il existe aussi un niveau zéro donc "paramètre vide"  ou non numérique doit rendre 1 et non 0
    # ajout cosmétique : tout nombre non entier est arrondi à l'entier le plus proche
    # interprétation : tout niveau supérieur au niveau maximum est ramené au niveau maximum au lieu d'être ramené au niveau par défaut
    if (niveau !~ /^[0-9]/) niveau=1
    niveau=int(niveau+0.5) # arrondi les valeurs numérique snon entières à l'entier le plus proche
    if (niveau>4) niveau=4
    return niveau
}

function makehead(titre,description,generateur,nuage,sujet,url,mailto           ,printto) # génère le code du header de la page html de titre, description et générateur requis
{
    if (printto=="") {printto="-"}
    
	print "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 3.2 Final//EN\">" >printto
	print "<html lang=\"fr-FR\" >">>printto
	print tabu(1) "<head>">>printto
	print tabu(2) "<meta charset=\"UTF-8\"/>">>printto
	print tabu(2) "<title>" titre "</title>">>printto
	print tabu(2) "<meta name=\"Content-Type\" content=\"UTF-8\">">>printto
	print tabu(2) "<meta name=\"Content-Language\" content=\"fr\">">>printto
	print tabu(2) "<meta name=\"Description\" content=\"" description "\">">>printto
	print tabu(2) "<meta name=\"Keywords\" content=\"" nuage "\">">>printto
	print tabu(2) "<meta name=\"Subject\" content=\"" sujet "\">">>printto
	print tabu(2) "<meta name=\"Copyright\" content=\"Alturing\">">>printto
	print tabu(2) "<meta name=\"Author\" content=\"Gilles Métais\">">>printto
	print tabu(2) "<meta name=\"Publisher\" content=\"Gilles Métais\">">>printto
	print tabu(2) "<meta name=\"Identifier-Url\" content=\"" url "\">">>printto
	print tabu(2) "<meta name=\"Reply-To\" content=\"" mailto "\">">>printto
	print tabu(2) "<meta name=\"Rating\" content=\"restricted\">">>printto
	print tabu(2) "<meta name=\"Distribution\" content=\"iu\">">>printto
	print tabu(2) "<meta name=\"generator\" content=\"" generateur "\" />">>printto
	print tabu(2) "<meta name=\"date\" content=\"" strftime("%d/%m/%Y %T",systime()) "\" />">>printto
	print tabu(2) "<meta name=\"Expires\" content=\"" strftime("%d/%m/%Y",systime()+604800) "\" />">>printto
	print tabu(2) "<meta name=\"Geography\" content=\"75014 Paris, France\">">>printto
	print "\t</head>">>printto
	print "\t<body>">>printto
}

function inittableau(ttitre,theader,tfooter,tcolgroupstring,thoptions           ,printto)
{ # titre du tableau, contenu du thead et tfoot, groupement de colonnes, options supplémentaires dans le titre du tableau
    if (printto=="") {printto="-"}
    
    print tabu(2) "<table border=\"0px\" cellspacing=\"0px\" cellpadding=\"0px\" " thoptions "> " >>printto #" commentaire servant juste à placer une double quote de manière à ce que la coloration syntaxique retombe sur ses pieds
    print tabu(3) "<caption>" ttitre "</caption>">>printto
    if (colgroupstring ~ /^<col/)
    {
        print tabu(3) "<colgroup>">>printto
        print tabu(4) tcolgroupstring>>printto
        print tabu(3) "</colgroup>">>printto
    }
    print tabu(3) "<thead>">>printto
    print tabu(4) "<tr>">>printto
    print tabu(5) "" theader>>printto
    print tabu(4) "</tr>">>printto
    print tabu(3) "</thead>">>printto
    print tabu(3) "<tfoot>">>printto
    print tabu(4) "<tr>">>printto
    print tabu(4) tfooter>>printto
    print tabu(4) "</tr>">>printto
    print tabu(3) "</tfoot>">>printto
    print tabu(3) "<tbody>">>printto
}

function htmllink(url,texte,cible)
{
    switch (cible) {
        case /^_blank$|^_parent$|^_self$|^_top$/ :
        {
            cible=" target=\"" cible "\""
            break
        }
        default :
        {
            cible=""
        }
    }
    return "<a href=\"" url "\"" cible " title=\"" texte "\">" texte "</a>"
    #" commentaire servant juste à placer une double quote de manière à ce que la coloration syntaxique retombe sur ses pieds
}

function tabu(n,    localstring,i) # retourne une chaîne constituée de n tabulations
{
    for (i=1;i<=n;i++) localstring=localstring "\t"
    return localstring
}

BEGIN {
    # print "Ce module n'est pas censé être invoqué directement mais appelé par d'autres scripts au moyen d'une instruction #INCLUDE"
    # {
        # makehead("Page d'aide","Aide à l'utilisation des Statistiques I&S par famille de produit","IShtmlInclude.awk","statistiques,flux,sorties,stock,i&s","Aide à l'utilisation des Statistiques I&S par famille de produit","http://quipo.alt","gilles.metais@alturing.eu")
# }
    # exit 1
    # system("ls -l")
}
{ #MAIN
    # print classifinfo($1)
    # system($0)
    # print htmllink($1,$2,$3)
}


