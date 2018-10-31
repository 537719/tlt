-- liveGLPIprojectsdetails.sql
-- CREE     27/09/2018 - 17:03:28
-- d'après liveGLPIprojects.sql 20/09/2018 - 10:40:32
-- interroge la base GLPI pour en extraire les numéro/titre/description des dossiers glpi de projets en cours qui sont passés par I&S
-- MODIF    30/10/2018 - 10:35:06 explication de la requête
-- à invoquer depuis une ligne de commande MySQL connectée à la base GLPI

USE glpi

tee c:/users/Utilisateur/Documents/TLT/I&S/work/projetsencoursdetails.txt
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
