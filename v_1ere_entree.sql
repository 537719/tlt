CREATE VIEW v_1ere_entree AS
SELECT
       refappro
     , v_entrees.dateentree
     , v_sn_entrees.sn
     , entrees.tagis
     , entrees.reference
     , libelle
     , apt
     , projet
FROM
         entrees
     , v_entrees
     , v_1er_sn_entree
     , v_sn_entrees
WHERE
       entrees.tagis=v_entrees.tagis
   AND surfamille in ("1","3","4","6")
   AND sousfamille         <> "9"
   AND entrees.tagis        =v_sn_entrees.tagis
   AND v_sn_entrees.sn      = v_1er_sn_entree.sn
   AND v_entrees.dateentree = v_1er_sn_entree.Date1eEntree
;