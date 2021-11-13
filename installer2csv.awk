# installer2csv.awk
# CREATION  15:33 05/07/2021 Convertit en csv les donn‚es obtenues depuis une extraction de l'installer
# Donn‚es obtenues par 
#   curl --proxy proxypar.chronopost.fr:3128 "https://installer.chronopost.fr/installer/tools/integrity.php?class=vmware/Agence/PROD/ALL&nbperline=1" 
#   avec    --proxy : url et port du proxypar
#           &nbperline=1 nombre de colonnes par ligne fix‚ … 1 (et guillemets obligatoires … cause du & dans l'url)
# Utilisation ‚volu‚e :
#   for /f "delims=@" %I in ('curl --proxy proxypar.chronopost.fr:3128 "https://installer.chronopost.fr/installer/tools/integrity.php?class=vmware/Agence/PROD/ALL&nbperline=1" ^|gawk -f ..\bin\installer2csv.awk') do (curl --proxy proxypar.chronopost.fr:3128  https://installer.chronopost.fr/installer/vmware/Agence/PROD/ALL/uploads/integrity/%I.tlt.integrity.txt > %I.txt) 
# ^^ un curl produit un tableau html pars‚ par ce pr‚sent script et dont le r‚sultat sert … retrouver les fichiers individuels des serveurs en erreur
# ^^ il faudra ensuite parser chacun des fichiers textes obtenus de maniŠre … mettre en rapport nom, site et num‚ro de s‚rie

BEGIN {
    point="."
}
$0 ~ td { # MAIN
    
    delete tablo
    if (split($0,tablo,"<br/>",seps) > 8) { # un enregistrement normal a 8 champs, une anomalie en a un de plus
        j=split(tablo[1],partie,point) # le point est un discriminant pratique pour naviguer dans l'adresse
        split(partie[7],hostname,">") # cette partie contient le hostname … interroger, pr‚c‚d‚ d'un >
        print hostname[2]
    }
}
# En sortie on produit la liste des hostnames en anomalie, dont on va pouvoir interroger le fichier d'int‚grit‚