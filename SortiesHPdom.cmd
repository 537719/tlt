REM @echo off
goto :debut
SortiesHPdom.cmd
d'après EtatStock.cmd du 08:53 19/11/2020 
CREATION    15:03 19/11/2020    Produit la liste des PC HP expédiés dans les DOM à la demande de LQN pour les contrats de maintenance

:debut
pushd ..\date
md ..\StatsIS\quipo\%~n0 2>nul

REM ATTENTION il faut que les % soient doublés pour un appel depuis un batch
sqlite3 sandbox.db ".separator ;" ".header on" "select '20' || substr(sorties.tagis,3,2) || '-' || substr(sorties.tagis,5,2) || '-' || substr(sorties.tagis,7,2) as DateEntree, sorties.numserie, sorties.reference,sorties.description as Designation,sorties.cp,sorties.societe as Destinataire from sorties where sorties.reference like 'CHR1_N%%' and description like '%%HP%%' and DateEntree > date('now', '-3 year') and sorties.cp like '97___' order by DateEntree desc;" |gawk -f ..\bin\csv2xml.awk > ..\StatsIS\quipo\%~n0\fichier.xml
@echo %date%>..\StatsIS\quipo\%~n0\date.txt
