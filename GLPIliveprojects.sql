-- GLPIliveprojects.sql
-- CREE     31/10/2018 - 15:35:59 Combine en une seule requête l'extraction de toutes les données requise au suivi du matériel expédié sur les projets en cours
--          à savoir : liste des numéros de dossier concernés, liste des numéros de dossier/titre/description, liste des numéros de dossiers/demandeurs
--          d'après 21/09/2018  13:06               901 liveGLPIprojects.sql
--                  30/10/2018  11:30              1718 liveGLPIprojectsdetails.sql
--                  31/10/2018  15:24              3771 genSQLddrGLPI.awk

USE glpi

-- POINT 1 : Liste des numeros de dossiers des projets Chronopost en cours
SELECT "POINT 1 : Liste des numeros de dossiers des projets Chronopost en cours";
tee c:/users/Utilisateur/Documents/TLT/I&S/work/GLPIliveprojectsNumbers.txt
-- redigige la sortie vers le fichier attendu

SELECT tickets_id AS GLPI FROM glpi_plugin_timelineticket_assigngroups
WHERE groups_id = 29
AND tickets_id IN (
	SELECT id FROM glpi_tickets WHERE
	`status` != 6
	AND `type` = 2
	AND
	 users_id_recipient IN (
	    SELECT users_id FROM glpi_groups_users WHERE groups_id = 51744
	)
)
GROUP BY tickets_id
ORDER BY tickets_id
;
notee
-- annule la redirection de sortie
-- la sortie sera délimitée par des caractères semi-graphiqnes
-- le script outsql.awk a été créé pour les filtrer

SELECT "POINT 2 : liste des numeros de dossier+titre+description";
-- POINT 2 : liste des numeros de dossier+titre+description
tee c:/users/Utilisateur/Documents/TLT/I&S/work/GLPIliveprojectsDetails.txt
-- redigige la sortie vers le fichier attendu

SELECT id,name,content FROM glpi_tickets
WHERE id IN (   -- id = numéro de dossier
	SELECT tickets_id AS GLPI FROM glpi_plugin_timelineticket_assigngroups
	WHERE groups_id = 29    -- glpi_plugin_timelineticket_assigngroups.groups_id = 29 => Dossier passé par le groupe d'affectation d'I&S
	AND tickets_id IN (
		SELECT id FROM glpi_tickets WHERE   -- numéros des dossiers non clos et créés par un chef de projet
		`status` != 6   -- glpi_tickets.`status` != 6 => non clos. Attention aux quotes inverses, obligatoires car le nom du champ est un mot réservé
		AND `type` = 2  -- glpi_tickets.type` = 2 => Demande. Attention aux quotes inverses, obligatoires car le nom du champ est un mot réservé
		AND
		users_id_recipient IN ( -- appelant/demandeur appartient au groupe des chefs de projets
			SELECT users_id FROM glpi_groups_users WHERE groups_id = 51744  -- produit les ID utilisateurs des membres du groupe des chefs de projets
		)
	)
	GROUP BY tickets_id
	ORDER BY tickets_id
)
;

notee
-- annule la redirection de sortie
-- la sortie sera délimitée par des caractères semi-graphiqnes
-- le script outsql.awk a été créé pour les filtrer


SELECT "POINT 3 : liste des numeros de dossiers+demandeurs";
-- POINT 3 : liste des numeros de dossiers+demandeurs
-- redirection de la sortie
tee C:/Users/Utilisateur/Documents/TLT/I&S/work/GLPIliveprojectsDemandeurs.txt
SELECT       glpi_groups_tickets.tickets_id AS 'NoDossier',
             CONCAT(glpi_users.realname,' ',glpi_users.firstname) AS 'Demandeur'
    FROM     glpi_groups_tickets,  glpi_tickets_users,  glpi_users
    WHERE    glpi_tickets_users.type=3 -- 3 = demandeur
    AND      glpi_groups_tickets.type=1
    AND      glpi_users.id=glpi_tickets_users.users_id
    AND      glpi_groups_tickets.tickets_id=glpi_tickets_users.tickets_id
    AND
             glpi_tickets_users.tickets_id IN (
SELECT tickets_id AS GLPI FROM glpi_plugin_timelineticket_assigngroups
WHERE groups_id = 29
AND tickets_id IN (
	SELECT id FROM glpi_tickets WHERE
	`status` != 6
	AND `type` = 2
	AND
	 users_id_recipient IN (
	    SELECT users_id FROM glpi_groups_users WHERE groups_id = 51744
	)
)
GROUP BY tickets_id
ORDER BY tickets_id
    )
    GROUP BY glpi_groups_tickets.tickets_id
    LIMIT 68
;
notee

SELECT "POINT 4 : Validation de fin";
tee C:/Users/Utilisateur/Documents/TLT/I&S/work/GLPIliveprojectsFini.txt
-- POINT 4 : Validation de fin"*
SELECT "Tous les fichiers GLPIliveprojects* OK"; 
-- Le fait d'avoir 4 fichiers en sortie valide la fin du traitement
notee
