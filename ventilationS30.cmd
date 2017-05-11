@echo off
goto :debut
Ventilation du détail de facturation mensuel S30 par BU et par tranches de temps passé
voir détails dans le fichier VentilationS30.txt

A partir d'un fichier "tableaux [nom_du_mois] TELINTRANS.csv" produit à partir des données fournies par S30,
alimentation d'une base SQLite
Recherche de la BU
Produit un résultat du genre suivant :
CHRONOPOST;21;2H;2310
CHRONOPOST;2;3H;270
CHRONOPOST;3;1/2 J;570
CHRONOPOST;2;1 JOURNEE;540
CHRONOPOST;4;30MN;200
CHRONOPOST;6;1H;450
COLISSIMO;10;2H;1100
COLISSIMO;6;3H;810
COLISSIMO;6;1 JOURNEE;1620
COLISSIMO;4;3HNO+2H;1580
COLISSIMO;2;30MN;100
COLISSIMO;9;1H;675

Prérequis :
- Chemin d'accès à SQLite
- Utilitaires GNUWIN32 : tail
- ligne de commande MySQL et connecion à la base GLPI
- script creeGLPIsql.cmd
- script filtreTEE.cmd

MODIF 15:58 jeudi 11 mai 2017 ajout d'une page d'aide
:debut
REM affichage de la page d'aide si le script est invoqué avec un argument
if @%1@ NEQ @@ goto aide

REM définition du chemin d'accès à SQLite et de la base associée
set SQLite="C:\Users\admin\Path\sqlite\sqlite-tools-win32-x86-3150100\sqlite-tools-win32-x86-3150100\sqlite3.exe" S30.DB
set ALEA=%RANDOM%
REM ^^ pour un nom de fichier temporaire

REM Détermination du fichie CSV à traiter (plus récent des "tableau*.csv" )
if not exist tableau*.csv goto :errfich
dir /od /b tableau*.csv |tail -1 >%temp%\%ALEA%.tmp
set /p inputfile=<%temp%\%ALEA%.tmp

REM création du script SQLite de génération de la liste des dossiers GLPI concernés
@echo .separator ; >temp.sql
@echo DROP TABLE S30_factu ; >>temp.sql
@echo .import "%inputfile%" S30_factu >>temp.sql
@echo .output numglpi.txt >>temp.sql
@echo SELECT DISTINCT REF_PARTENAIRE from S30_factu ORDER BY REF_PARTENAIRE ; >>temp.sql

REM purge des variables et fichiers temporaires
del %temp%\%ALEA%.tmp
set inputfile=
set ALEA=
REM impératif de le faire avant que l'une de ces variables soit réutilisée par un script fils

REM génération de la liste des dossiers GLPI concernés
%SQLite% < temp.sql

rem génération de la requête d'interrogation des BU asssociées aux dossiers GLPI concernés
call creeGLPIsql.cmd

del tee.txt 2>nul
REM destruction de toute trace éventuelle d'un fichier résultat précédent

REM Exécuter dans la ligne de commande MySQL le script généré à l'étape précédente (commande "source nom_de_source.sql")
REM vérification de la présence du fichier résultat tee.txt attendu avant de continuer
:notee
if not exist tee.txt (uecho -n . && goto :notee)
REM tant que le fichier résultat n'est pas présent, on boucle

grep " rows in set (" tee.txt
if errorlevel 1 (uecho -n + && goto :notee)
REM on boucle tant que le fichier résultat ne contient pas de signal de requête terminée

type tee.txt |filtretee.cmd >tee.csv

REM création du script SQLite de ventilation de la facturation S30 par durée et bu
@echo .separator ; >temp.sql
@echo DROP TABLE GLPIxBU ; >>temp.sqL
@echo .import tee.csv GLPIxBU >>temp.sqL
@echo .output ventilationS30.csv >>temp.sql
@echo SELECT completename, count(id),TEMPS_PASSE, count(id) * PRIX_CLIENT from S30_201704, GLPIxBU where S30_201704.REF_PARTENAIRE = id GROUP BY completename, TEMPS_PASSE ORDER BY completename,PRIX_CLIENT; >>temp.sqL

REM ventilation de la facturation S30 par durée et bu
%SQLite% < temp.sql

@echo Ventilation de la facturation S30 dans le fichier ventilationS30.csv
type ventilationS30.csv

goto :eof
:errfich
msg /w %username% Fichier tableau*.csv absent
goto :eof
:aide
Affichage d'un texte explicatif dans le cas où un argument est spécifié
msg /w %username% < ventilationS30.txt

:eof
