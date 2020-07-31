@echo off
goto :debut
NobjRetourChroShip.cmd
CREATION 05/12/2019 - 11:23 : extrait les num‚ros de chronopost de mat‚riel chronoship arriv‚ chez I&S quelque soit le champ dans lequel l'info a ‚t‚ saisie
:debut
sed -n "/^CHRO.*SHIP/ s/.*\([A-Z][A-Z][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]FR\).*/\1/p" is_in_201912.csv |usort -u 
