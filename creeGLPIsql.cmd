::creeGLPIsql.cmd
:: 15:49 mardi 9 mai 2017
:: crée une requête GLPI à partir d'une liste de numéros de dossiers
:: entrée : le plus récent des fichiers *glpi*.txt du répertoire courant, contenant une liste de numéros de dossiers GLPI (un par ligne)
:: sortie : requête MySQL mettant le nom de l'entité concernée en face de chaque dossier, à exécuter via HeidiSQL par exemple
::
:: prérequis :
:: utilitaires GnuWin32 : tail, sed (ici dans sa version ssed), gclip
:: présence d'un fichier texte nommé *glpi*.txt contenant les numéros de dossiers glpi concernés
::
:: MODIF
:: 09:25 mercredi 10 mai 2017 ajout d'un contrôle de présence du fichier de numéros glpi

:debut
set ALEA=%RANDOM%
REM ^^ pour un nom de fichier temporaire
if not exist *glpi*.txt goto :errfich
dir /od /b *glpi*.txt |tail -1 >%temp%\%alea%.tmp
set /p inputfile=<%temp%\%alea%.tmp

@echo -- GLPIxBU.sql généré le %date% %time% par %0 appliqué à %inputfile% >GLPIxBU.sql
@echo tee %cd%\tee.txt >>GLPIxBU.sql
@echo SELECT glpi_tickets.id, glpi_entities.completename from glpi_tickets,glpi_entities WHERE (glpi_tickets.entities_id = glpi_entities.id) AND glpi_tickets.id IN ( >>GLPIxBU.sql
REM ^^ écriture de l'en-tête de la requête sql

ssed -n "s/\([0-9].*[0-9]\)/'\1',/p" %inputfile% >>GLPIxBU.sql
REM ^^ écriture de la partie variable de la requête sql

@echo '0');   >>GLPIxBU.sql
REM ^^ terminaison de la requête sql
@echo notee   >>GLPIxBU.sql

REM purge des variables et fichiers temporaires
del %temp%\%ALEA%.tmp
set inputfile=
set ALEA=

@echo source C:\Users\admin\Documents\TLT\S30\GLPIxBU.sql |gclip
@echo Coller le contenu du presse-papier "source C:\Users\admin\Documents\TLT\S30\GLPIxBU.sql" dans la ligne de commande MySQL
MSG /w %username% Coller le contenu du presse-papier dans la ligne de commande MySQL "source C:\Users\admin\Documents\TLT\S30\GLPIxBU.sql"

goto :eof
:errfich
msg /w %username% Fichier *glpi*.txt absent
goto :eof
:eof
@echo fin de la création du code sql