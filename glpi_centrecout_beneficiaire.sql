-- Extraction des centres de coût et bénéficiaire des 13 dossiers GLPI ayant fait l'objet d'un déstockage d'UC ou portable immobilisé par Chronopost
-- entre le 02/07/2018 et le 12/07/2018
-- généré par le script genSQLccbGLPI.awk le 17/07/2018 par traitement du fichier ..\Data\is_out_201807.csv

tee C:/Users/UTILIS~1/AppData/Local/Temp/output.csv ;
SELECT       glpi_groups_tickets.tickets_id AS 'NoDossier',
             glpi_plugin_shipping_clients.num_contract AS 'Centre_de_Cout', 
             glpi_users.firstname AS 'Prenom', 
             glpi_users.realname AS 'Nom'
    FROM     glpi_groups_tickets,  glpi_plugin_shipping_clients, glpi_tickets_users,  glpi_users
    WHERE    glpi_tickets_users.type=1
    AND      glpi_groups_tickets.type=1
    AND      glpi_plugin_shipping_clients.groups_id=glpi_groups_tickets.groups_id
    AND      glpi_users.id=glpi_tickets_users.users_id
    AND      glpi_groups_tickets.tickets_id=glpi_tickets_users.tickets_id
    AND
             glpi_tickets_users.tickets_id IN (
               1807090113,
               1807110151,
               1806280138,
               1806280152,
               1806280245,
               1806280281,
               1806280436,
               1806280571,
               1806290199,
               1807030197,
               1807030363,
               1807040419,
               1807050727,
               0
    )
    AND
             glpi_groups_tickets.tickets_id IN (
               1807090113,
               1807110151,
               1806280138,
               1806280152,
               1806280245,
               1806280281,
               1806280436,
               1806280571,
               1806290199,
               1807030197,
               1807030363,
               1807040419,
               1807050727,
               0
    )
    GROUP BY glpi_groups_tickets.tickets_id
    LIMIT 13
;
notee