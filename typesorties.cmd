@echo off
goto :debut
11/05/2018  15:31               451 typesorties.cmd

OBJET : Traite un flot d'export des produits expédiés par I&S pour en extraire les données suivantes :
    NumDossier GLPI
    "famille" de produit
    Type de sortie (incident/demande/rma/destruction)
    an;mois;jour de création du dossier
    an;mois;jour d'expédition du matériel
    numéro de tag I&S
    
BUT : intégration de ces données dans la base SQLite de traitement des données I&S

PREREQUIS : Utilitaires GNU Linux (inclus dans GIT) : cat, awk (ici dans sa version gawk) et sort (ici renommé Usort)
ATTENTION : utiliser des / au lieu de \ dans le chemin d'accès fourni à cat
:debut
cat %1|gawk -i typesortieinclude.awk -i ISsuiviInclude.awk -F; -v sepdate="/" "$8 !~/./ {$8=$4};{split($4,datecrea,sepdate);split($8,datebl,sepdate);print $1 FS selectfamille($6,$11) FS typesortie($1,$2,$3,$6,$16) FS datecrea[3] FS datecrea[2] FS datecrea[1] FS datebl[3] FS datebl[2] FS datebl[1]FS $19}"|sed -e "s/Tagis$/!Tagis/" -e "s/DIVERS/divers/" -e "s/SERIALISE/serialise/"|usort -t; -k 10 -u -o ../work/typesorties.csv
@echo le résultat est dans
dir ..\work\typesorties.csv