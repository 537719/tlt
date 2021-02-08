select etats_stock.etat,count(tagis)
    from etats_stock
    left join stock on stock.etat
    group by stock.etat
;

with storage as(
    select etat as lib from etats_stock
)
select count(tagis), etat from stock
where etat=lib
group by etat
;


with storage as (
    select rowid as recnum,etat as etatref from etats_stock
)
select 
-- recnum,
etatref, 
    case
        when ( select count(*) from stock where stock.etat = etatref) then  (select count(tagis) from stock where stock.etat = etatref)
        else 0
    end nometat
from storage
group by etatref
;



CREATE TABLE StockArchive(
  "Nom_projet" TEXT NOT NULL,
  "Ref" TEXT NOT NULL,
  "Etat" TEXT NOT NULL,
  "Statut" TEXT NOT NULL,
  "Numero_de_serie" TEXT NOT NULL,
  "TagIs" TEXT NOT NULL,
  "DateEntree" TEXT NOT NULL,
  "DateExport" TEXT NOT NULL,
  PRIMARY KEY(DateExport,TagIS)
  CHECK(
        DateExport LIKE "____-__-__"
    AND (
            TagIS LIKE "TE__________"
        OR  TagIS LIKE "SN____________"
        )
    )
)
;

with storage as (
    select rowid as recnum,etat as nometat from etats_stock
)
select 
-- recnum,
    case
        when ( select count(*) from StockArchive where StockArchive.etat = nometat) then  (select count(tagis) from StockArchive where StockArchive.etat = nometat)
        else 0
    end NBetat,
    nometat

from storage
ORDER BY NBetat
-- group by nometat
;

CREATE TABLE P_Stock(
-- table pivot pour la stat de suivi d'état des stocks
    DateStock   TEXT NOT NULL,
    Etat    TEXT NOT NULL DEFAULT "",
    QTetat      INTEGER DEFAULT 0,
    PRIMARY KEY(DateStock,Etat)
    CHECK (DateStock LIKE "____-__-__")
)
;

CREATE TABLE SuiviStock(
    DateStock TEXT NOT NULL PRIMARY KEY,
    nbOK    INTEGER DEFAULT 0,
    nbADA   INTEGER DEFAULT 0,
    nbAudit INTEGER DEFAULT 0,
    nbHS    INTEGER DEFAULT 0,
    nbDiv   INTEGER DEFAULT 0,
    nbNeuf  INTEGER DEFAULT 0
    CHECK(DateStock LIKE "____-__-__")
)
;
    
INSERT OR REPLACE INTO p_Stock(DateStock,Etat,QTetat) select dateexport,etat,count() from stockarchive group by dateexport,etat;

CREATE VIEW v_P_stock AS
-- regroupe les différents états en codes utiles pour les stats
    select DateStock,Code,QTetat from p_Stock,Etats_Stock where p_Stock.etat=Etats_Stock.etat
;

CREATE VIEW v_Stat_EtatStock AS
select     DateStock,
    sum(case when     Code="OK"     then     QTetat ELSE 0 END) as qOK,
    sum(case when     Code="ADA"    then     QTetat ELSE 0 END) as qADA,
    sum(case when     Code="Audit"  then     QTetat ELSE 0 END) as qAudit,
    sum(case when     Code="HS"     then     QTetat ELSE 0 END) as qHS,
    sum(case when     Code="Neuf"   then     QTetat ELSE 0 END) as qNeuf,
    sum(case when     Code="Divers" then     QTetat ELSE 0 END) as qDiv
from v_p_Stock
-- WHERE DATESTOCK LIKE  "2020-12-1%"
group by DateStock
;
CREATE VIEW vv_Stat_EtatStock AS
SELECT DateStock,qADA,qAudit,qHS,qDiv,qNeuf,qOK, (qOK+0.0)/(qADA+qAudit+qHS+qDiv+qNeuf+qOK) as RatioOK
FROM v_Stat_EtatStock
;

CREATE VIEW vvv_Stat_EtatStock AS
SELECT DateStock,
    printf("%4d",qADA)      AS ADA,
    printf("%3d",qAudit)    AS Audit,
    printf("%4d",qHS)       AS HS,
    printf("%4d",qDiv)      AS Divers,
    printf("%4d",qNeuf)     AS Neuf,
    printf("%6d",qOK)       AS OK, 
printf("%6.2f %",round(100*(RatioOK),2)) as RatioOK
FROM vv_Stat_EtatStock
;

.output ../work/ada.csv
select datestock,qa as "Attente Décision Alturing"
from vv_Stat_EtatStock
where datestock >= date("now","-1 year","start of month","-1 day","start of month")
;

.output ../work/audit.csv
select datestock,qAudit as "Matériel à auditer"
from vv_Stat_EtatStock
where datestock >= date("now","-1 year","start of month","-1 day","start of month")
;

.output ../work/hs.csv
select datestock,qHS as "Matériel à réparer"
from vv_Stat_EtatStock
where datestock >= date("now","-1 year","start of month","-1 day","start of month")
;

.output ../work/ratiook.csv
select datestock,RatioOK as "Taux de matériel OK"
from vv_Stat_EtatStock
where datestock >= date("now","-1 year","start of month","-1 day","start of month")
;
.output
