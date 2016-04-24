:: structurecsv.cmd
:: 02:41 samedi 23 avril 2016
:: donne la structure d'un fichier .csv d'après sa ligne d'en-tête
:: #PREREQUIS : awk (ici dans sa version GNU gawk)
@echo off
gawk -F; "{if (NR==1) for (i=1;i<=NF;i++) print i OFS $i}" %1
goto :eof
# Exemple
Pour un fichier .csv dont les premières lignes sont :
Projet;Reference;Numero Serie;DateEntree;APT;Libell▒;BonTransport;RefAppro
CHRONOPOST FIL DE L'EAU;CHR10NF1C3;2N32H92;01/04/2016 11:55:37;;00000908 - DELLSA;IS016030427;UC DELL OPTIPLEX CHR 3020SFF
CHRONOPOST FIL DE L'EAU;CHR12NF1CR;NXG55EF001549004907600;01/04/2016 15:11:56;;00001068 - LAFI;IS016030426;CHROMEBOOK ACER C738T C3YL
CHRONOPOST FIL DE L'EAU;CHR11NF1C4;JMQXF72;01/04/2016 16:59:25;;00000908 - DELLSA;IS016040002;PORTABLE DELL LATITUDE CHR E7450

Le résultat produit sera :
1 Projet
2 Reference
3 Numero Serie
4 DateEntree
5 APT
6 Libell▒
7 BonTransport
8 RefAppro

Ce qui permet de savoir quel $champ référencer dans awk