:: extrait d'un export csv de la stat d'autonomie
:: les dossiers d'incidents COL concernant la CEMI
:: cemi.cmd
:: 24/03/2016 12:06:07,84
:: entree : fichier glpi.txt = glpi.csv ‚pur‚ de ses sauts de lignes parasites
:: sortie : liste des num‚ros de dossiers
gawk -F\0 "{if ($0~/CEMI/) if ($2~/COLI/) if ($33~/cident/) print $1}" %1
