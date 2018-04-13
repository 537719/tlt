#IShtmlInclude.awk
#module à inclure regroupant les fonctions communes a la génération de pages html
#à destination de la famille de script gen*.awk (genHTMLindex.awk         genHTMLlink.awk          genressourcesindex.awk)

# CREATION 03/04/2018 - 16:41:43 en tant que nouvelle branche htmlinclude divergeant de la branche statsis

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

function makehead(titre,description,generateur,nuage,sujet,url,mailto) # génère le code du header de la page html de titre, description et générateur requis
{
	print "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 3.2 Final//EN\">"
	print "<html lang=\"fr-FR\" >"
	print "\t<head>"
	print "\t\t<meta charset=\"UTF-8\"/>"
	print "\t\t<title>" titre "</title>"
	print "\t\t<meta name=\"Content-Type\" content=\"UTF-8\">"
	print "\t\t<meta name=\"Content-Language\" content=\"fr\">"
	print "\t\t<meta name=\"Description\" content=\"" description "\">"
	print "\t\t<meta name=\"Keywords\" content=\"" nuage "\">"
	print "\t\t<meta name=\"Subject\" content=\"" sujet "\">"
	print "\t\t<meta name=\"Copyright\" content=\"Alturing\">"
	print "\t\t<meta name=\"Author\" content=\"Gilles Métais\">"
	print "\t\t<meta name=\"Publisher\" content=\"Gilles Métais\">"
	print "\t\t<meta name=\"Identifier-Url\" content=\"" url "\">"
	print "\t\t<meta name=\"Reply-To\" content=\"" mailto "\">"
	print "\t\t<meta name=\"Rating\" content=\"restricted\">"
	print "\t\t<meta name=\"Distribution\" content=\"iu\">"
	print "\t\t<meta name=\"generator\" content=\"" generateur "\" />"
	print "\t\t<meta name=\"date\" content=\"" strftime("%d/%m/%Y %T",systime()) "\" />"
	print "\t\t<meta name=\"Expires\" content=\"" strftime("%d/%m/%Y",systime()+604800) "\" />"
	print "\t\t<meta name=\"Geography\" content=\"94250 Gentilly, France\">"
	print "\t</head>"
	print "\t<body>"
}

function inittableau(ttitre,theader,tfooter,tcolgroupstring,thoptions)
{ # titre du tableau, contenu du thead et tfoot, groupement de colonnes, options supplémentaires dans le titre du tableau
    print "\t\t<table border=\"0px\" cellspacing=\"0px\" cellpadding=\"0px\" " thoptions "> " #" commentaire servant juste à placer une double quote de manière à ce que la coloration syntaxique retombe sur ses pieds
    print "\t\t\t<caption>" ttitre "</caption>"
    if (colgroupstring ~ /^<col/)
    {
        print "\t\t\t<colgroup>"
        print "\t\t\t\t" tcolgroupstring
        print "\t\t\t</colgroup>"
    }
    print "\t\t\t<thead>"
    print "\t\t\t\t<tr>"
    print "\t\t\t\t\t" theader
    print "\t\t\t\t</tr>"
    print "\t\t\t</thead>"
    print "\t\t\t<tfoot>"
    print "\t\t\t\t<tr>"
    print "\t\t\t\t" tfooter
    print "\t\t\t\t</tr>"
    print "\t\t\t</tfoot>"
    print "\t\t\t<tbody>"
}

function htmllink(url,texte,cible)
{
    switch (cible) {
        case /^\_blank$|^_parent$|^_self$|^_top$/ :
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


