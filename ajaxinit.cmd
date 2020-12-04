@echo off
goto :debut
ajaxinit.cmd
CREATION    08:44 24/10/2020 rassemble les ‚l‚ments de base pour pr‚senter en tant que page web le contenu du fichier csv fourni en paramŠtre
/!\ Attention, encodage en OEM863:French afin d'afficher correctement les accents
PREREQUIS   
    convertcp.exe pour rendre lisibles les caractŠres accentu‚s pr‚sents dans le fichier de donn‚es xml
    gawk.exe        gnu awk, dans une version sup‚rieure … 4
    scripts gawk de transformation du csv fourni en paramŠtre :
    23/10/2020  21:16              6326 csv2html.awk    cr‚ation de la page d'index
    11/02/2020  15:34              4095 csv2xml.awk     cr‚ation des feuilles de style
    23/10/2020  21:21             12499 csv2xsl.awk     cr‚ation du fichier de donn‚es

ENTREE      un fichier texte s‚par‚ par point virgule fourni en argument sur la ligne de commande
SORTIE      un dossier prˆt … ˆtre t‚l‚charg‚ sur le repository et contenant une page h“te, 
            un fichier de donn‚es XML et l'ensemble des feuilles de style XSL qui permettent de l'int‚grer … la page h“te
            un template de page d'aide au mˆme format
PAS FOURNI  feuille de style, images et code javascript d'int‚gration du xml, cens‚s ˆtre d‚j… pr‚sents sur le site d'h‚bergement

:debut
for %%I in (%1) do set basename=%%~nI
for %%I in (%1) do set extension=%%~xI
for %%I in (%1) do set datefile=%%~tI
if not @%extension%@==@.csv@ goto erreurext

if exist %basename% goto :existe
del %temp%\erreur.txt 2>nul
md %basename% 2>%temp%\erreur.txt
if exist %basename%\nul goto :ok
dir %basename% |find "%basename%"
@echo %basename% est un fichier
goto :fin
:existe
if exist %basename%\nul goto :dossier
dir %basename% |find "%basename%"
@echo un fichier %basename% existe d‚j…
@echo faire [ctrl+c] pour arrˆter ici
@echo ou bien, pour poursuivre et le supprimer
del %basename%
pause
goto :debut
:dossier
dir /ad |find "%basename%"
dir /d %basename%
@echo un dossier %basename% existe d‚j…
@echo faire [ctrl+c] pour arrˆter ici
@echo ou bien, pour poursuivre et le supprimer
pause
rd /s /q %basename%
goto :debut
:ok
@echo Dossier %basename% cr‚‚ 
@echo Les donn‚es seront mises dans le dossier
dir /ad |find "%basename%"

@echo %datefile%>%basename%\date.txt
gawk -f ..\bin\csv2html.awk %1 > %basename%\index.html
gawk -v outputdir="%basename%" -f ..\bin\newcsv2xsl.awk %1
gawk -v outputdir="%basename%" -f ..\bin\csv2aide.awk %1
gawk -f ..\bin\csv2xml.awk %1 > fichier.xml
convertcp 65001 28591 /i fichier.xml /o %basename%\fichier.xml
dir %basename%

:fin
goto :eof
:erreurext
@echo fournir en argument le nom d'un fichier .csv
goto :eof
