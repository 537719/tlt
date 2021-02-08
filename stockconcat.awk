# stockconcat.awk
# CREATION  10:35 17/12/2020 concatène et réajuste tous les exports de stock en un seul fichier
# NOTA      Les exports de stock doivent être en pagecode UTF8 au préalable, les convertir si nécessaire par for %I in (is_stock_2*.csv) do convertcp 1252 65001 /i %I /o utf8\%I
# MODIF     11:32 18/12/2020 supprime les champs inutiles à l'analyse des stocks, soient $1 (qté) et $4 (designation), le champ mort "Lib" ayant déjà été supprimé dès le début

BEGIN {
    FS=";"
    OFS=";"
    pattern="\\1-\\2-\\3" 
}
BEGINFILE {
    datefich=gensub(/.*_([0-9]{4})([0-9]{2})([0-9]{2})-.*/ ,pattern,1,FILENAME)
}

FNR != 1 {
    gsub(/Lib;/,"",$0)
    print $2,$3,$5,$6,$7,$8,$9, datefich
}
