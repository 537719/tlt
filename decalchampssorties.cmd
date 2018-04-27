:: 06/03/2018  15:03               467 decalchampssorties.cmd
:: corrige les ; placés à tort dans les données des exports des produits expédiés par I&S
:: deux cas :
::  soit plusieurs ; dans le champ "désignation" $7
::  soit un ; dans le champ "num série" $11
gawk -F; "BEGIN {OFS=FS} NF==22 {print} ;NF==25 {print $1 OFS $2 OFS $3 OFS $4 OFS $5 OFS $6 OFS $7 $8 $9 $10 OFS $11 OFS $12 OFS $13 OFS $14 OFS $15 OFS $16 OFS $17 OFS $18 OFS $19 OFS $20 OFS $21 OFS $22 OFS $23 OFS $24 OFS $25} NF==23 {print $1 OFS $2 OFS $3 OFS $4 OFS $5 OFS $6 OFS $7 OFS $8 OFS $9 OFS $10 OFS $11 $12 OFS $13 OFS $14 OFS $15 OFS $16 OFS $17 OFS $18 OFS $19 OFS $20 OFS $21 OFS $22 OFS $23 OFS $24 OFS $25}" %1 >"%~p1%~n1x22%~x1"
