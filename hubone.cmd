:: extrait d'un export csv de la stat d'autonomie
:: les dossiers d'incidents COL concernant HubOne
:: 13:52 jeudi 24 mars 2016
:: d'après cemi.cmd 24/03/2016 12:06:07,84
:: entree : fichier glpi.txt = glpi.csv ‚pur‚ de ses sauts de lignes parasites
:: sortie : liste des num‚ros de dossiers
gawk -F\0 "BEGIN {IGNORECASE=1}{if ($0~/HUB[ |_]?ONE/) if ($2~/COLI/) if ($33~/ncident/) print $1}" %1
