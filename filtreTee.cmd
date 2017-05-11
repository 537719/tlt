:: 11/05/2017  10:37               237 filtreTee.cmd
:: Transforme en CSV les sorties texte s‚par‚ par | produites par MySql
:: 
:: pr‚requis : utilitaire GnuWin32 sed (ici dans sa version ssed)
:: MODIF 14:38 jeudi 11 mai 2017 rajoute un echo off sans quoi la ligne d'exécution fait partie de la sortie
:: MODIF 14:39 jeudi 11 mai 2017 supprime les espaces en fin de champ et de ligne
@echo off
ssed -n -e "s/  *| /;/g" -e "s/Entit.*> //"  -e "s/^. //" -e "s/  *.$//p" %1
