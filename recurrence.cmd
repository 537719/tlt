@echo off
goto :debut
Extraction des �l�ments de calcul de r�currence parmi les stats mensuelles

Entr�e : fichier description.txt
1� colonne = num�ro de dossier
2� colonne = entit� concern�e
colonne quelconque = descriptif de tous les incidents du mois, avec la particularit� que le contenu de cette cellule s'�tend sur plusieurs lignes
ATTENTION
(filtrer en n'en retenant que les incidents de l'entit� racine vis�e)
Le fichier d'entr�e doit �tre cr�� par un copier-coller d'un filtre ne retenant que les incidents de l'entit� racine vis�e vers une feuille vierge sauv�e en tant que texte tabul� et non � partir du fichier complet filtr� "enregistr� sous" texte, sinon il contiendrait des enregistrements non hors scope.

Sortie : fichier recurrence.txt
Liste des noms de poste concern�s, tri�e de mani�re non unique

Le taux de r�currence consistera alors � d�nombrer combien de fois apparait chaque poste non unique
:debut
cat description.txt |tr -d \n  |tr -d \r |ssed -e "s/\(141[0-9][0-9][0-9][0-9][0-9][0-9][0-9]\tEntit\)/\n\1/g" >recurrence.txt
REM Remise en une seule ligne du flot de texte de la description de chaque dossier
REM 1�) suppression des cr et lf 2�) remise d'un CRLF � chaque changement de dossier
REM la d�tection se fait sur la reconnaissance du d�but de dossier (num�ro tabulation Entit�)

ssed -n "s/1[4-9][0|1][0-9][0-9][0-9][0-9][0-9][0-9][0-9].*\([P|p][B|M|b|m][P|p]0[0-9][0-9][0-9][0-9]\).*/\1/p" recurrence.txt |usort -f -o recurrence.txt
REM Reconnaissance de ce qui est un num�ro de poste et �limination du reste

REM Calcul de la r�currence :
cat recurrence.txt |wc -l >%temp%\inters.tmp
uniq -i recurrence.txt |wc -l >%temp%\uniques.tmp
set /P nbinter=<%temp%\inters.tmp
set /P nbuniqu=<%temp%\uniques.tmp
set /A recurr=%nbinter%-%nbuniqu%
echo %nbinter% interventions dont %recurr% r�currences
del %temp%\inters.tmp
del %temp%\uniques.tmp
set nbinter=
set nbuniqu=
set recurr=