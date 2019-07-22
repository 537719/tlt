-- GLPIincProdISbu.sql
-- d'après GLPIincProdIS.sql du 29/11/2018 - 17:52:48 extrait de GLPI les données relatives aux incidents de productions détectés par I&S
-- Créé  14:24 29/01/2019    rajoute la mention de la BU concernée

-- tee c:/users/Utilisateur/Documents/TLT/I&S/work/GLPIincProdIS.txt
-- redigige la sortie vers le fichier attendu
-- la sortie sera à filtrer par le script outsql.awx pour être transformée en csv

SELECT
       glpi_tickettasks.tickets_id
     , glpi_tickettasks.date
     , glpi_tickettasks.content
     , glpi_tickets.entities_id
     , glpi_entities.name
FROM
       glpi_tickettasks
     , glpi_tickets,glpi_entities -- on cherche un commentaire placé dans les taches
WHERE
                glpi_tickettasks.date       > "2018-11-01"
       AND   glpi_tickettasks.date       < "2019-03-01"
       AND   glpi_tickettasks.content   LIKE "%ISI-%" -- structure de type "code d'incident de production"
       AND glpi_tickettasks.users_id IN
       ( -- on cherche un commentaire émis par un membre des groupes I&S - on ne prend pas en compte les saisie accidentelles de texte similaire aux codes recherchés par quelqu'un qui ne fait pas partie des personnes habilitées à les renseigner
              SELECT
                     id
              FROM
                     glpi_users
              WHERE
                     id IN
                     (
                              SELECT
                                       users_id
                              FROM
                                       glpi_groups_users
                              WHERE
                                       groups_id in ( -- les opérateurs habilités font partie des groupes suivants
                                                     28, 29, 30, 111922 )
                              GROUP BY
                                       users_id -- pas besoin d'avoir plusieurs fois l'id de chaque personne
                     )
       )
       AND glpi_tickettasks.tickets_id=glpi_tickets.id
       -- Lien de la tâche vers le dossier, qui contient le code de la BU
       AND glpi_entities.id           =glpi_tickets.entities_id
       -- lien du code de la BU vers son libellé
--       AND glpi_entities.name LIKE "%Ship%"
        -- restriction à un type de BU particulier
-- 
;

-- notee
-- libere le fichier de sortie