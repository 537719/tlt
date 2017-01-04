@echo off
goto :debut
Extraction des éléments de calcul de récurrence parmi les stats mensuelles

Entrée : fichier description.txt
1° colonne = numéro de dossier
2° colonne = entité concernée
colonne quelconque = descriptif de tous les incidents du mois, avec la particularité que le contenu de cette cellule s'étend sur plusieurs lignes
ATTENTION
(filtrer en n'en retenant que les incidents de l'entité racine visée)
Le fichier d'entrée doit être créé par un copier-coller d'un filtre ne retenant que les incidents de l'entité racine visée vers une feuille vierge sauvée en tant que texte tabulé et non à partir du fichier complet filtré "enregistré sous" texte, sinon il contiendrait des enregistrements non hors scope.

Sortie : fichier recurrence.txt
Liste des noms de poste concernés, triée de manière non unique

Le taux de récurrence consistera alors à dénombrer combien de fois apparait chaque poste non unique
:debut
cat description.txt |tr -d \n  |tr -d \r |ssed -e "s/\(141[0-9][0-9][0-9][0-9][0-9][0-9][0-9]\tEntit\)/\n\1/g" >recurrence.txt
REM Remise en une seule ligne du flot de texte de la description de chaque dossier
REM 1°) suppression des cr et lf 2°) remise d'un CRLF à chaque changement de dossier
REM la détection se fait sur la reconnaissance du début de dossier (numéro tabulation Entité)

ssed -n "s/1[4-9][0|1][0-9][0-9][0-9][0-9][0-9][0-9][0-9].*\([P|p][B|M|b|m][P|p]0[0-9][0-9][0-9][0-9]\).*/\1/p" recurrence.txt |usort -f -o recurrence.txt
REM Reconnaissance de ce qui est un numéro de poste et élimination du reste

REM Calcul de la récurrence :
cat recurrence.txt |wc -l >%temp%\inters.tmp
uniq -i recurrence.txt |wc -l >%temp%\uniques.tmp
set /P nbinter=<%temp%\inters.tmp
set /P nbuniqu=<%temp%\uniques.tmp
set /A recurr=%nbinter%-%nbuniqu%
echo %nbinter% interventions dont %recurr% récurrences
del %temp%\inters.tmp
del %temp%\uniques.tmp
set nbinter=
set nbuniqu=
set recurr=