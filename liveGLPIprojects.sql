-- liveGLPIprojects.sql
-- 20/09/2018 - 10:40:32
-- interroge la base GLPI pour en extraire les numéros de dossiers des demandes émis par les chefs de projets et non encore clos

-- à invoquer depuis une ligne de commande MySQL connectée à la base GLPI
tee c:/users/Utilisateur/Documents/TLT/I&S/work/suiviprojets.txt
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
