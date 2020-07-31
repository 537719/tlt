@echo off
::GitProxy.cmd
::Gilles M‚tais 19/01/2018 - 14:31:21
::configure git de maniŠre … pouvoir passer au travers du proxy d'entreprise
:: … ex‚cuter une fois pour toute … l'installation de git
:: modif 17:26 09/02/2020 modification du proxy d'entreprise
REM git config --global http.proxy http://proxy.alt:3128 :: obsolète début 2020
git config --global http.proxy http://proxy.pac.alt:3128
@echo les sources peuvent maintenant ˆtre r‚cup‚r‚es en tapant la commande
@echo "md xxx&&git clone <url> [nomdedossierdestinataire]"
