@echo off
goto :debut
VillesDemandesProjets.cmd
d'après 24/10/2018 - 17:26:54 ArticlesDemandesProjets.cmd
CREE    29/10/2018 - 16:17:23 - Donne, si trouvé, le code postal et la ville de de chacun des dossiers projets en cours

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
::  filtrer le flot multiligne de manière à y repérer ce qui ressemble à un couple code postal + ville
::  ventiler les données valides code postal, ville, précédées du numéro de dossier issu de la boucle for


@echo GLPI;CodePostal;Ville> VillesDemandesProjets.csv
:: Attention, pas d'espace avant la redirection sinon il est rajouté au texte redirigé et perturbe le nommage des champs dans la base sqlite générée à partir du fichier csv

for /F %%I in (liveGLPIprojects.csv) do sqlite3 projets.db "select content from dossiers where id=%%I;"  |gawk -f .\VillesDemandesProjets.awk -v dossier=%%I >> VillesDemandesProjets.csv

