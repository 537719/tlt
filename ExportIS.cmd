@echo off
goto :debut
ExportIS.cmd
Gilles M‚tais 19/01/2018 - 14:48:52
R‚cupŠre un fichier d'export I&S, le classe et le renomme en fonction des dates et selon qu'il s'agisse d'un fichier des produits exp‚di‚s ou re‡us

CONTEXTE :
Les fichiers d'exports I&S s'appellent toujours export*.csv et sont r‚cup‚r‚s par d‚faut dans le r‚pertoire "T‚l‚hargements" de l'utilisateur
Ce sont des fichiers d‚limit‚s par point-virgule, comportant un nombre de champs bien d‚finis et en particulier un champ "date" … un emplacement connu.

PREREQUIS
AWK (ici dans sa version GNU Gawk 4, issu de la distrib de GIT)
:debut
if not exist %userprofile%\downloads\export*.csv goto :raf

REM Boucle de scan des fichiers d'export
for %%I in (%userprofile%\downloads\export*.csv) do (
gawk -F; "NR==1 {if (NF==22) 
)

goto :eof
:raf
@echo Aucun fichier d'export trouv‚ dans le dossier de t‚l‚chargement
goto :eof
