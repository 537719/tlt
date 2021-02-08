#filtre034.awk
BEGIN {
    FS=";"
    OFS=FS
    glob="g"
    doubleq="''"
    un="\\1" 
}   
{ #MAIN
    for (i=1;i<=NF;i++) {
        $i=gensub(/\042(.)/,doubleq un,glob,$i)
    }
    print 
}