:: extrait d'un export csv de la stat d'autonomie
:: les dossiers d'incidents COL concernant LVI
:: LVI.CMD
:: 13:53 jeudi 24 mars 2016
:: d'après cemi.cmd 24/03/2016 12:06:07,84
:: entree : fichier glpi.txt = glpi.csv ‚pur‚ de ses sauts de lignes parasites
:: sortie : liste des num‚ros de dossiers
gawk -F\0 "{if ($0~/\WLVI|LVI\W/) if ($2~/COLI/) if ($33~/cident/) print $1}" %1
