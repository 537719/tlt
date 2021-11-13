-- backlogsuivi.sql
-- CREATION 10:32 27/05/2021 extrait depuis la liste des dossiers clos ceux qui auraient du faire l'objet d'un suivi et les rajoute … la table des mouvements suivis
-- BUG      14:32 15/06/2021 d‚sactivation/r‚activation du mode "change" et remplacement d'un output par un once afin que le code sql g‚n‚r‚ ne soit pas pollu‚ par les messages informatifs
.open "../../stats/glpi.db"
.changes off
.mode insert SuiviMvt
.once ../work/backlogsuivi.sql
SELECT char(32) as "","Dossier",glpi.ID,v_glpi.douverture,
    TRG || " " || glpi.Titre
    -- || " " || v_glpi.TypeSite || " " || replace(v_glpi.nomsite,"&amp;","&")
    -- glpi.redacteur,
    -- v_glpi.TypeSite AS TypeSite,
    -- replace(v_glpi.nomsite,"&amp;","&") AS NomSite 
from glpi,v_GLPI,Trigrammes
WHERE glpi.typedossier="Demande"
    AND glpi.id=v_GLPI.id
    and v_glpi.douverture > date("now","-1 month")
    AND v_glpi.Historique LIKE "%DEPART%"
    and glpi.Redacteur IN (SELECT Nom FROM TRIGRAMMES)
    and trigrammes.nom=glpi.redacteur
;
.changes on
.open "../data/sandbox.db"
.print .read "../work/backlogsuivi.sql"
.read "../work/backlogsuivi.sql"