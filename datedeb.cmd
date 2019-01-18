:: datedeb.cmd
:: Créé 14/12/2018 - 16:31:53   donne la date de début de mois correspondant au flot de dates jj/mm/aaaa passé en argument
gawk -F/ -v format="%F" 'NF==3 {datedeb=mktime($3 " " $2 " 01 00 00 00");$2=$2+1;if ($2^>12) {$2="01";$3=$3+1};datefin=mktime($3 " " $2 " 01 00 00 00");print strftime(format,datedeb) , strftime(format,datefin),$1,$2,$3}'