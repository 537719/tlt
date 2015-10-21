@echo off
goto :debut
30/01/2015  13:56               345 IS2CLPparc34.cmd
Convertit un export I&S en liste des expéditions d'imprimantes Expeditor au même format qu'Econocom

prérequis :
- utilitaire AWK (ici dans sa version GNUwin32 gAWK)
- fichier d'export d'I&S

variables clefs :
La sélection se fait sur la référence du produit envoyé. Les imprimantes Expeditor ont toutes une référence en CLP34xSxxx

Evolution possible :
Rajouter un en-tête avec les noms des champs
Date Demande	N°STATION	Nom Client	Adresse 1	Adresse 2	CP	Ville	Pays	Type	Marque	Modèle	n°série	N°INTER	STOCK	ETAT	Code Cmd	Expédié ou intervention le	Code Elite	Appartient à	Tot	Etat	Etat 2	Garantie																			


:debut
@echo on
set source=%~dp0
pushd %source%
@echo Date Demande;N°STATION;Nom Client;Adresse 1;Adresse 2;CP;Ville;Pays;Type;Marque;Modèle;n°série;N°INTER;STOCK;ETAT;Code Cmd;Expédié ou intervention le;Code Elite;Appartient à;Tot;Etat;Etat 2;Garantie;>"clp34_%~n1%~x1"
gawk -F; -v OFS=";" -v space=" " -v sep="/" "{if ($1 !~ /[A-z]/) if ($3 ~ /^CLP34/) print substr($1,5,2) sep substr($1,3,2) sep substr($1,1,2) OFS OFS $9 OFS $10 OFS $11 OFS $12 SPACE $13 OFS $15 OFS $14 OFS $4 OFS OFS $3 OFS $8 OFS $1 OFS $7 OFS substr($3,6,1) OFS OFS $5 OFS OFS $6 OFS OFS OFS }" %1 >>"clp34_%~n1%~x1"
popd
