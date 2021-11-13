CREATE VIEW IF NOT EXISTS  v_Stock_NonOK AS
-- CREATION 08:51 31/08/2021 Liste des quantit‚s de chaque article en stock qui n'est pas dans l'‚tat OK
    SELECT count(*) AS Nb, Etat,Nom_projet AS Stock,ref AS Reference,Designation
    FROM stock 
    WHERE etat NOT LIKE "OK" -- Il y a eu des cas de Ok avec des minuscules donc on pr‚fŠre le LIKE … l'‚galit‚
    AND length(ref) = 10 and cast(substr(ref,4,1) as integer) != 0 -- afin d'‚viter les articles g‚n‚riques et les r‚f … usage interne I&S 
    GROUP BY nom_projet, etat,ref
;

CREATE TABLE IF NOT EXISTS t_Stock_NonOK(
-- CREATION 09:08 31/08/2021 Liste des motifs pour lesquels des articles en stocks ne sont pas OK
    Stock       TEXT NOT NULL,
    Reference   TEXT NOT NULL,
    Designation TEXT, -- donn‚e inutilis‚e ici mais colonne utile pour permettre l'import depuis v2_Stock_NonOK_Motif
    Nb          INTEGER, -- donn‚e inutilis‚e ici mais colonne utile pour permettre l'import depuis v2_Stock_NonOK_Motif
    Etat        TEXT NOT NULL,
    Motif       TEXT DEFAULT NULL,
    Suivi       TEXT DEFAULT NULL,
    PRIMARY KEY(Stock,Reference,Etat),
    CHECK(
        length(Reference) = 10
    AND
        cast(substr(Reference,4,1) as integer) > 0
    )
)
;

.print purge des ‚l‚ments revenus … un statut NORMAL
-- SELECT * FROM t_Stock_NonOK WHERE 
    -- Etat||Stock||Reference NOT IN (
        -- SELECT Etat||Stock||Reference FROM v_Stock_NonOK
    -- )
-- ;
DELETE FROM t_Stock_NonOK WHERE 
    Etat||Stock||Reference NOT IN (
        SELECT Etat||Stock||Reference FROM v_Stock_NonOK
    )
;

.print peuplement de la table des motifs de non ok en stock sans ‚craser les infos des articles qui y sont d‚j…
INSERT INTO t_Stock_NonOK(Stock,Reference,Etat) SELECT Stock,Reference,Etat FROM v_stock_nonok WHERE Stock||Reference||Etat NOT IN (
    SELECT Stock||Reference||Etat FROM t_stock_nonok
);

CREATE VIEW IF NOT EXISTS v2_Stock_NonOK_SansMotif AS
    SELECT Stock,Etat,Nb,Reference,Designation FROM v_Stock_NonOK
    WHERE Etat||Stock||Reference  IN (
        SELECT Etat||Stock||Reference 
        FROM t_Stock_NonOK 
        WHERE MOTIF IS NULL
    )
;

.print Actualiser le motif de chaque ligne puis enregistrer au mˆme format
.mode list
.separator ;
.header on
.once "Stock_NonOK_SansMotif.csv"
SELECT Stock,Etat,Nb,Reference,Designation,"" AS Motif FROM v2_Stock_NonOK_SansMotif;
.system "Stock_NonOK_SansMotif.csv"
DROP TABLE IF EXISTS t_Stock_NonOK_ImportMotif;
.import Stock_NonOK_SansMotif.csv t_Stock_NonOK_ImportMotif

.print report des motifs depuis la table temporaire vers la table officielle
UPDATE t_stock_nonok
  SET motif = maj.nouveaumotif
  FROM (SELECT t_stock_nonok_importmotif.motif AS nouveaumotif,stock,reference,etat FROM t_stock_nonok_importmotif
   ) AS maj
 WHERE t_stock_nonok.stock = maj.stock
   AND t_stock_nonok.reference = maj.reference
   AND t_stock_nonok.etat = maj.etat
;

-- select * from t_Stock_NonOK order by stock, reference, etat ;

CREATE VIEW IF NOT EXISTS v2_Stock_NonOK_Motif AS
    SELECT  v_Stock_NonOK.Stock,v_Stock_NonOK.Reference,v_Stock_NonOK.Designation, printf("%3d",v_Stock_NonOK.Nb) AS Nb, v_Stock_NonOK.Etat,
            t_Stock_NonOK.Motif,t_Stock_NonOK.Suivi
    FROM t_Stock_NonOK,v_Stock_NonOK
    WHERE   Motif >""
    AND t_Stock_NonOK.stock=v_Stock_NonOK.stock
    AND t_Stock_NonOK.reference=v_Stock_NonOK.REFERENCE
    and t_Stock_NonOK.etat=v_Stock_NonOK.etat
    ORDER BY v_Stock_NonOK.Stock,v_Stock_NonOK.Reference,v_Stock_NonOK.Etat
;
-- bon jusqu'ici 16:40 03/09/2021
.print Actualiser le motif et le suivi de chaque ligne puis enregistrer au mˆme format
.mode list
.separator ;
.header on
.once "Stock_NonOK_Suivi.csv"
--  le fichier csv produit servira d'une part … mettre … jour la bdd de suivi du mat‚riel NonOK et d'autre part … l'affichage web
SELECT * FROM v2_Stock_NonOK_Motif;
.system "Stock_NonOK_Suivi.csv"
DROP TABLE IF EXISTS t_Stock_NonOK_ImportSuivi;
.import Stock_NonOK_Suivi.csv t_Stock_NonOK_ImportSuivi
.print mise … jour des motifs et du suivi dans la table du stock NonOK
-- le truc important c'est le "update from"
UPDATE t_stock_nonok
  SET 
    motif = maj.nouveaumotif,
    suivi = maj.nouveausuivi
  FROM (SELECT 
    t_Stock_NonOK_ImportSuivi.motif AS nouveaumotif,
    t_Stock_NonOK_ImportSuivi.suivi AS nouveausuivi,
    stock,reference,etat FROM t_Stock_NonOK_ImportSuivi
   ) AS maj
 WHERE t_stock_nonok.stock = maj.stock
   AND t_stock_nonok.reference = maj.reference
   AND t_stock_nonok.etat = maj.etat
;

CREATE VIEW IF NOT EXISTS v2_Stock_NonOK AS
SELECT t_stock_nonok.Stock,t_stock_nonok.Reference,v_stock_nonok.Designation,v_stock_nonok.Nb,t_stock_nonok.Etat,t_stock_nonok.Motif,t_stock_nonok.Suivi
FROM t_stock_nonok,v_stock_nonok
 WHERE t_stock_nonok.stock = v_stock_nonok.stock
   AND t_stock_nonok.reference = v_stock_nonok.reference
   AND t_stock_nonok.etat = v_stock_nonok.etat
;

.print production du r‚sultat final
.mode list
.separator ;
.header on
.once ../work/Stock_NonOK.csv
SELECT * from v2_Stock_NonOK;
