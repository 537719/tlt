@echo off
goto :debut
ArticlesDemandesProjets.cmd
CREE    16/10/2018 - 13:53:38 - Donne la liste des quantité de chaque article requises par chacun des dossiers projets en cours
MODIF   24/10/2018 - 17:26:54 - Initialise le fichier résultant avec des en-têtes de champ

PREREQUIS :
    liveGLPIprojects.csv fichier des dossiers de projets en cours (issue de glpi via liveGLPIprojects.sql)
    BDD Sqlite contenant la liste des en-têtes de projets (dont numéro de dossier et description)
    
PRINCIPE DE FONCTIONNEMENT :
    filtre la description de chaque dossier de manière à en isoler ce qui ressemble à une référence et suppose que la qté est avant et la désignation après

:debut
REM for /F %I in (liveGLPIprojects.csv) do sqlite3 projets.db "select content from dossiers where id=%I;"  |sed -n "s/\(.*\) \(CHR[0-9][0-Z][N|R][F|P][0-Z][0-Z][0-Z]\) \(.*\)/%I;\1;\2;\3/p"
REM Explication :
::  pour chacun des dossiers mentionnés dans le fichier fourni en argument de la boucle for
::  extraire de la bdd la valeur du champ multilignes contenant, entre autres, les qtés et articles demandés
::  filtrer le flot multiligne de manière à y repérer ce qui ressemble à une référence
::  ventiler les données valides en qté, référence, désignation, précédées du numéro de dossier issu de la boucle for

REM Amélioration à faire :
::  remplacer le filtre SED par un traitement oar gawk de manière à
::      ne garder que la valeur numérique de ce qui précède la référence (1 par défaut)
::      prendre en compte aussi bien les références brutes que les refbundles
::      un traitement ultérieur remplacera les refbundles par les références brutes de ce qui compose les dits bundles
@echo GLPI;qte;reference;designation> ArticlesDemandesProjets.csv
:: Attention, pas d'espace avant la redirection sinon il est rajouté au texte redirigé et perturbe le nommage des champs dans la base sqlite générée à partir du fichier csv

for /F %%I in (liveGLPIprojects.csv) do sqlite3 projets.db "select content from dossiers where id=%%I;"  |gawk -f .\ArticlesDemandesProjets.awk -v dossier=%%I >> ArticlesDemandesProjets.csv

