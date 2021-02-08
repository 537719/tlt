# wordcolor.awk
# CREATION  15:00 19/12/2020 cacule une couleur en fonction du texte fourni en entrée
# critères :
#   après avoir converti le texte en majuscules
#   première caractère converti de [0-Z] en [#01-#FE] donne la valeur du rouge
#   caractère du milieu converti de [0-Z] en [#01-#FE] donne la valeur du vert
#   dernière  caractère converti de [0-Z] en [#01-#FE] donne la valeur du bleu
#   règle particulière : caractère < "0" => #00
#   règle particulière : caractère > "Z" => #FF

BEGIN {
    charset="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    fistchar=substr(charset,1,1)
    lastchar=substr(charset,length(charset),1)
    # print fistchar,lastchar
}
{ # MAIN
    $0=toupper($0)
    debut=substr($0,1,1)
    milieu=substr($0,length($0)/2,1)
    fin=substr($0,length($0),1)
    
    rouge=index(charset,debut)
    vert=index(charset,milieu)
    bleu=index(charset,fin)
    print rouge, vert, bleu

    rouge=rouge*254/36
    vert=vert*254/36
    bleu=bleu*254/36
    print rouge, vert, bleu
    
    rouge=int(rouge +1.5)
    vert=int(vert +1.5)
    bleu=int(bleu +1.5)
    print rouge, vert, bleu
    
    if (debut   < fistchar) {rouge=0}
    if (debut   > lastchar) {rouge=255}
    if (milieu  < fistchar) {vert=0}
    if (milieu  > lastchar) {vert=255}
    if (fin     < fistchar) {bleu=0}
    if (fin     > lastchar) {bleu=255}

    printf("%x\r\n", 65536 * rouge +256 * vert + bleu,$0)
        

}

