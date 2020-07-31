# testcmdline.awk

BEGIN {
    print "valeur=" a
    for (i in ARGV) {
        print i " argv" ARGV[i]
    }
    print FILENAME
    print strftime("%Y-%m-%d",systime())
        print strftime("%Y-%m-%d",systime()+3600*24*8)
}
END {
    nomfich=gensub(/.*\\(.*)\..*$/,"\\1","g",FILENAME)
    print nomfich
}