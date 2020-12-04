CREATE VIEW IF NOT EXISTS v_SuiviMVT AS
-- 11:26 28/09/2020 Listage des mouvements I&S à suivre qui viennent d'être détectés comme étant effectués.
-- Doit être exécuté aussitôt après l'exécution du script SuiviMVT.sql
WITH storage AS
     (
               SELECT -- sorties
                         Donnee
                       , Valeur
                       ,"Date BL" AS DateMVT
                       , Reference
                       , Description AS Designation
                       , NumSerie
                       , sDepot AS Stock
                       , NumeroOFL
                       , numeros_de_colis AS Transport
                       , sorties.Societe  AS Societe
                       , TagIS
                       , Motif
               FROM
                         SORTIES
                       , SuiviMVT
                         LEFT JOIN
                                   OFLX
                                   ON
                                             OFLX.refclient = Valeur
               WHERE
                         DateVu    =DATE("now")
                         AND Donnee="Dossier"
                         AND Valeur=glpi
               GROUP BY
                         Valeur
                       , Reference
               -- ORDER BY Valeur
               -- ;
               UNION
               SELECT -- -- -- dossiers (reste quelques cas de doublons)
                      -- count(Entrees.TagIS) AS Nb,
                       Donnee
                    , Valeur
                    , DATE(v_Entrees.DateEntree) AS DateVu
                    , Entrees.Reference
                    , Libelle
                    , Numero_Serie
                    , Projet
                    , APT
                    , BonTransport
                    , RefAppro
                    , Entrees.TagIS AS TagIS
                    , Motif
               FROM
                      SuiviMVT
                    , Entrees
                    , v_Entrees
               WHERE
                      DateVu                    =date("now")
                      AND Donnee                ="Dossier"
                      AND v_Entrees.DateEntree >= datesurv
                      AND Entrees.TagIS         =v_Entrees.TagIS
                      AND RefAppro           like "%"
                             || Valeur
                             || "%"
               -- GROUP BY Valeur,Numero_Serie
               -- ;
               UNION
               SELECT -- -- -- APT
                      -- count(Entrees.TagIS) AS Nb,
                       Donnee
                    , Valeur
                    , date(v_Entrees.DateEntree) AS DateVu
                    , Entrees.Reference
                    , Libelle
                    , Numero_Serie
                    , Projet
                    , APT
                    , BonTransport
                    , RefAppro
                    , Entrees.TagIS AS TagIS
                    , Motif
               FROM
                      SuiviMVT
                    , Entrees
                    , v_Entrees
               WHERE
                      DateVu                    =date("now")
                      AND Donnee                ="Livraison"
                      AND v_Entrees.DateEntree >= datesurv
                      AND Entrees.TagIS         =v_Entrees.TagIS
                      AND APT                like "%"
                             || Valeur
                             || "%"
               -- GROUP BY Valeur
               -- ;
               UNION
               SELECT -- -- Colis
                        -- count(v_Entrees.TagIS) AS Nb,
                         Donnee
                      , Valeur
                      , date(v_Entrees.DateEntree) AS DateVu
                      , Entrees.Reference
                      , Libelle
                      , Numero_Serie
                      , Projet
                      , APT
                      , BonTransport
                      , RefAppro
                      , Entrees.TagIS AS TagIS
                      , Motif
               FROM
                        SuiviMVT
                      , Entrees
                      , v_Entrees
               WHERE
                        DateVu                    =date("now")
                        AND Donnee                ="Colis"
                        AND v_Entrees.DateEntree >= datesurv
                        AND Entrees.TagIS         =v_Entrees.TagIS
                        AND BonTransport       like "%"
                                 || Valeur
                                 || "%"
               GROUP BY
                        Entrees.TagIS
                        -- GROUP BY Valeur
                        -- ;
                        -- UNION
     )
SELECT DISTINCT
         COUNT(TagIS) AS Nb -- nombre de lignes concernées par le mouvement
       , *
FROM
         storage
         -- WHERE Donnee="Dossier"
GROUP BY
         Valeur
       , Reference  -- une ligne par dossier/colis/apt et référence d'article différente
;