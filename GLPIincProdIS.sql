-- GLPIincProdIS.sql
-- CREE     29/11/2018 - 17:52:48 extrait de GLPI les données relatives aux incidents de productions détectés par I&S
--

tee c:/users/Utilisateur/Documents/TLT/I&S/work/GLPIincProdIS.txt
-- redigige la sortie vers le fichier attendu
-- la sortie sera à filtrer par le script outsql.awx pour être transformée en csv

SELECT  tickets_id,date,content
FROM    glpi_tickettasks -- on cherche un commentaire placé dans les taches
WHERE   
    content LIKE "%ISI-%" -- structure de type "code d'incident de production"
AND 
    users_id IN ( -- on cherche un commentaire émis par un membre des groupes I&S - on ne prend pas en compte les saisie accidentelles de texte similaire aux codes recherchés par quelqu'un qui ne fait pas partie des personnes habilitées à les renseigner
        SELECT  id
        FROM    glpi_users
        WHERE   id IN (
            SELECT  users_id
            FROM    glpi_groups_users
            WHERE   groups_id in ( -- les opérateurs habilités font partie des groupes suivants
            28,29,30,111922
            )
            GROUP BY users_id -- pas besoin d'avoir plusieurs fois l'id de chaque personne
        )
    )
;

notee
-- libere le fichier de sortie