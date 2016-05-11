@echo off
goto :debut
20/07/2015  17:22             2 488 ESIS.cmd
# ESIS = Entrées Sorties I&S
DESCRIPTION
Concatène les exports d'expédition et réception chez I&S en un seul fichier d'entrées-sorties 
EN SE LIMITANT aux seuls articles dotés d'un numéro de série
#prerequis : utilitaires GNUWIN32
	gawk (version 4.1 minimum)
	sort (ici renommé en usort)
	head
#entree : fichiers d'export de l'extranet I&S (un pour l'export des expéditions, l'autre pour l'export des réceptions)
#sortie : concaténation des deux fichiers d'entrée, en respectant les champs
#MODIF 01/02/2016 12:08 : rajout d'une précision dans la description
#BUG 16:37 mercredi 11 mai 2016 correction d'une erreur de contrôle sur le type de fichier, si l'un au moins des deux fichiers est de mauvais type
#BUG 16:42 mercredi 11 mai 2016 suite à màj de la version de gawk, une erreur se produisant dans le traitement des dates => refonte complète des monolignes awk
#BUG 16:43 mercredi 11 mai 2016 produisait des résultats erronés si le fichier "réception" était spécifié avant le fichier "expéditions"
#MODIF 17:31 mercredi 11 mai 2016 affiche correctement les accents en cas de popup de message d'erreur

:debut
REM Contrôle d'existence des noms de fichiers
@echo  Contrôle d'existence des noms de fichiers
set file1=%1
set file2=%2
if "%file2%" EQU "" (msg /w %username% "Fournir deux fichiers CSV en parametre"&&goto :eof)
if not exist %file1% (
msg /w %username% "fichier %file1% manquant"
goto :eof
)
if not exist %file2% (
msg /w %username% "fichier %file2% manquant"
goto :eof
)
REM Contrôle de cohérence de date : rejet si plus d'une heure d'écart entre les deux fichiers
@echo  Contrôle de cohérence de date : rejet si plus d'une heure d'écart entre les deux fichiers
for %%I in (%file1%) do @echo %%~tI|gawk -F" |/" -v ODS="/" -v seconds=":00" "{print $3 ODS $2 ODS $1 OFS $4 seconds}" >%temp%\date1.txt
for %%I in (%file2%) do @echo %%~tI|gawk -F" |/" -v ODS="/" -v seconds=":00" "{print $3 ODS $2 ODS $1 OFS $4 seconds}" >%temp%\date2.txt
set /P date1=<%temp%\date1.txt
set /P date2=<%temp%\date2.txt
udate -d "%date1%" +%%s >%temp%\date1.txt
udate -d "%date2%" +%%s >%temp%\date2.txt
rem doubler le "%" pour utilisation dans un batch ^^

set /P date1=<%temp%\date1.txt
set /P date2=<%temp%\date2.txt
set /A deltadate=%date1%-%date2%
if %deltadate% gtr 3600 (msg /w %username% "Ecart de date trop grand entre les deux fichiers"&&goto :eof)
if %deltadate% lss -3600 (msg /w %username% "Ecart de date trop grand entre les deux fichiers"&&goto :eof)

REM Contrôle de cohérence de type : un fichier d'entrées ET un fichier de sorties
@echo  Contrôle de cohérence de type : un fichier d'entrées ET un fichier de sorties
set type1=undef
set type2=undef
head -1 %file1%|gawk -F; "{print NF}" >%temp%\NF1.txt
head -1 %file2%|gawk -F; "{print NF}" >%temp%\NF2.txt
set /p NF1=<%temp%\NF1.txt
set /p NF2=<%temp%\NF2.txt
if %NF1% EQU 18 set type1=sortie
if %NF2% EQU 18 set type2=sortie
if %NF1% EQU 8 set type1=entree
if %NF2% EQU 8 set type2=entree
if %NF1% EQU %NF2% (msg /w %username% "Les deux fichiers sont de type %type2%"&&goto :eof)
if %type1% EQU undef (msg /w %username% "Le fichier %file1% est de type inconnu"&&goto :eof)
if %type2% EQU undef (msg /w %username% "Le fichier %file2% est de type inconnu"&&goto :eof)

:libre
REM Répète le traitement tant que le fichier sortie n'est pas libre
set message=
REM ^^ ^purge l'éventuel message d'erreur

REM Prise en compte des sorties dans le fichier de résultat
@Echo Traitement du fichier des expéditions
set fichier=NUL
if %type1% EQU sortie set fichier=%file1%
if %type2% EQU sortie set fichier=%file2%
REM élimination de la ligne d'en-tête
REM mise de la date au format aaaa-mm-jj (afin de pouvoir trier dessus)
REM Ajout d'une heure fictive à la date de sortie pour cohérence avec la date d'entrée
REM Ajout du tag indiquant le sens du mouvement
REM élimination du matériel sans numéro de série
REM Sortie au même format que fichier des réceptions de matériel
REM gawk -F";" -v OFS=";" -v sens="Sortie" -v titre="" -v repl="\\3/\\2/\\1 23:59:59" "{gsub(/.*;Num.*Serie;.*/,titre,$0);bl=gensub(/([0-9][0-9])\/([0-9][0-9])\/([0-9][0-9][0-9][0-9])/,repl,1,$8);if ($11 ~ /./) {print sens OFS $10 OFS $6 OFS $11 OFS bl OFS OFS $1 OFS OFS $7}}" %fichier% >outfile.csv
REM ^^ ancienne formulation, obsolète
gawk -F; "BEGIN { OFS=FS } { gsub(/.*;Num.*Serie;.*/,\"\",$0) ; if ($11 ~ /./) {split($8,tabdate,\"/\");print \"Sortie\" OFS $10 OFS $6 OFS $11 OFS strftime(\"%%F %%H:%%M:%%S\",mktime(tabdate[3] \" \" tabdate[2] \" \" tabdate[1] \" 23 59 59\")) OFS OFS $1 OFS OFS $7}}"  %fichier% >outfile.csv
REM ATTENTION ^^ à bien doubler les % pour exécution à l'intérieur d'un batch

REM Prise en compte des entrées dans le fichier de résultat
@Echo Traitement du fichier des réceptions
REM if %fichier% EQU %file1% set fichier=%file2%
REM if %fichier% EQU %file2% set fichier=%file1%
if %type1% EQU entree set fichier=%file1%
if %type2% EQU entree set fichier=%file2%
REM Modification de la ligne d'en-tête de manière à ce qu'elle soit triée en premier
REM mise de la date au format aaaa-mm-jj (afin de pouvoir trier dessus)
REM Ajout du tag indiquant le sens du mouvement
REM élimination du matériel sans numéro de série
REM gawk -F";" -v OFS=";" -v sens="Entree" -v titre=";#Num Serie;" -v repl="\\3/\\2/\\1" "{gsub(/;Num.*Serie;/,titre,$0);$0=gensub(/([0-9][0-9])\/([0-9][0-9])\/([0-9][0-9][0-9][0-9])/,repl,1,$0) ;if ($3 ~ /./) print sens OFS $0}" %fichier% >>outfile.csv
REM ^^ ancienne formulation, obsolète
gawk -F; "BEGIN { OFS=FS } { gsub(/;Num.*Serie;/,\";#Num Serie;\",$0) ; split($4,tabdate,/\/| |:/) ; if ($3 ~ /./) print \"Entree\" OFS $1 OFS $2 OFS $3 OFS strftime(\"%%F %%H:%%M:%%S\",mktime(tabdate[3] \" \" tabdate[2] \" \" tabdate[1] \" \" tabdate[4] \" \" tabdate[5] \" \" tabdate[6])) OFS $5 OFS $6 OFS $7 OFS $8}" %fichier%  >>outfile.csv
REM ATTENTION ^^ à bien doubler les % pour exécution à l'intérieur d'un batch

REM tri des résultats par numéro de série / date du mouvement
@Echo tri des résultats par numéro de série / date du mouvement
REM usort -o outfile.csv -t ; -k 4,5 outfile.csv
ssed "s/1970-01-01 00:59:59/Date/" outfile.csv | usort -o outfile.csv -t ; -k 4,5
REM ^^ l'en-tête de la colonne de date n'étant justement pas une date, son traitement en tant que date aboutit à un résultat erroné corrigé ici ^^

del %temp%\errlog.txt 2>nul
outfile.csv 2>%temp%\errlog.txt
if exist %temp%\errlog.txt for %%I in (%temp%\errlog.txt) do (if %%~zI GTR 0 (set /p message=<errlog.txt&&msg /W %username% %message%&&goto libre))
REM Contrôle ^^ si une ancienne version du fichier est utilisée, boucle tant qu'elle n'est pas libérée

REM Epuration après traitement
@Echo Epuration après traitement
REM goto :eof
del %temp%\errlog.txt 2>nul
del %temp%\date1.txt
del %temp%\date2.txt
del %temp%\NF1.txt
del %temp%\NF2.txt
set file1=
set file2=
set fichier=
set date1=
set date2=
set deltadate=
set NF1=
set NF2=
set type1=
set type2=
