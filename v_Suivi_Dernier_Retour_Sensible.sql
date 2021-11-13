CREATE VIEW v_Suivi_Dernier_Retour_Sensible AS
-- CREATION 14:03 12/03/2021 Comme v_Suivi_Dernier_Retour_UC mais traite aussi les serveurs
WITH storage AS (
    select numero_colis
    from v_Dernier_Retour_Sensible
    )
SELECT
    "http://suivi.chronopost.fr/servletAuguste?Hrequete=recherche&TAlisteNumeroLT="
    || group_concat(numero_colis,",") ||
    "&RBresultats=ecran&TFNumeroLTPartiel=&StypeCalcul=commun&StypeRecherche=tous"
    AS LienAuguste
FROM storage
/* v_Suivi_Dernier_Retour_Sensible(LienAuguste) */;
