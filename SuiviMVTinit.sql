-- Surveillance dossiers clés
drop table SuiviMVT;
CREATE TABLE SuiviMVT(
    DateVu tTEXT NOT NULL DEFAULT "",
    Donnee TEXT NOT NULL DEFAULT "Dossier",
    Valeur TEXT NOT NULL DEFAULT "",
    DateSurv TEXT NOT NULL DEFAULT "",
    Motif   TEXT NOT NULL DEFAULT ""
    CHECK (
        (datevu LIKE "____-__-__" or datevu="")
    AND
            (datesurv LIKE "____-__-__")
    AND
        (date(datevu) >= date(datesurv) OR datevu="")
    AND (Donnee IN ("Dossier","Livraison","Colis")        )
    AND (length(valeur) between 10 and 13)
    )
);
CREATE UNIQUE INDEX k_SurvS ON SuiviMVT(Donnee,Valeur);

delete from SuiviMVT;
-- jeu d'essai
INSERT INTO SuiviMVT (Donnee,Valeur,Datesurv,motif) VALUES
("Dossier","1234567890","2020-09-25","dossier bidon, n'existe pas"),
("Dossier","2009220489","2020-09-23","test de sortie de PMC Linux"),
("Dossier","2009240763","2020-09-24","test de sortie de PMC Linux"),
("Dossier","2008310162","2020-09-11","Envoi de câbles réseau à Angers"),
("Dossier","2009020546","2020-09-03","Envoi de câbles USB-C à Angers"),
("Dossier","2005170043","2020-05-20","PC du chef d'agences d'Albi"),
("Dossier","2005050725","2020-05-06","PMCTRIG supplétif St Etienne"),
("Dossier","2004230576","2020-05-05","portables pour CSV"),
("Dossier","2003130584","2020-03-16","postes wifi pour Chilly"),
("Dossier","2003130561 ","2020-03-13","postes BIO pour covid"),
("Dossier","2002170576 ","2020-02-17","UC Dell pour fifi"),
("Colis","8R42265487561","2020-08-30","test de réception de colis colissimo"),
("Colis","EE166913726FR","2020-08-31","test de réception de colis SP9"),
("Colis","XU848265304FR","2020-09-20","test de réception de colis chrono stantard"),
("Livraison","ES020090012","2020-09-01","test de réception de RMA LVI"),
("Livraison","ES020090005","2020-09-01","test de réception de commande de câbles"),
("Livraison","ES020070021","2020-08-01","test de réception de commande d'écrans neufs"),
("Dossier","2009170785","2020-09-20","test de réception de dossier"),
("Dossier","2003120662","2020-09-01","test de réception de dossier"),
("Livraison","ES020090016","2020-09-24","Bundle LYM"),
("Livraison","ES020090015","2020-09-23","Nouveaux postes maîtres Linux pour COLI"),
("Livraison","ES020070020","2020-07-27","Imprimantes C11"),
("Livraison","ES020070006","2020-07-10","Imprimantes COLPV"),
("Livraison","IS020090002","2020-09-02","Retour AG CHR Rennes")
;
select * from SuiviMVT;


-- mise à jour 
-- -- surveille entrées
-- -- -- dossiers
with storage as (
select date("now") as datevu,"Dossier" as donnee,valeur,datesurv from SuiviMVT,entrees,v_entrees where datevu="" and donnee="Dossier" and v_entrees.dateentree >= datesurv and entrees.tagis=v_entrees.tagis and refappro like "%" || valeur || "%" group by valeur
)
REPLACE into SuiviMVT(datevu,donnee,valeur,datesurv) select * from storage
;
-- -- -- APT
with storage as (
select date("now") as datevu,"Livraison" as donnee,valeur,datesurv from SuiviMVT,entrees,v_entrees where datevu="" and donnee="Livraison" and v_entrees.dateentree >= datesurv and entrees.tagis=v_entrees.tagis and APT like "%" || valeur || "%" group by valeur
)
REPLACE into SuiviMVT(datevu,donnee,valeur,datesurv) select * from storage
;
-- -- -- Colis
with storage as (
select date("now") as datevu,"Colis" as donnee,valeur,datesurv from SuiviMVT,entrees,v_entrees where datevu="" and donnee="Colis" and v_entrees.dateentree >= datesurv and entrees.tagis=v_entrees.tagis and BonTransport like "%" || valeur || "%" group by valeur
)
REPLACE into SuiviMVT(datevu,donnee,valeur,datesurv) select * from storage
;
-- -- surveille sortie
UPDATE SuiviMVT
SET datevu = DATE("now") 
WHERE datevu="" AND Donnee="Dossier" AND Valeur in (SELECT GLPI from vv_sorties,SuiviMVT where glpi=valeur and datebl >= datesurv  )
;

-- listage des cas concernés
-- -- en entrée

with storage as (
select -- -- -- dossiers (reste quelques cas de doublons)
-- count(entrees.tagis) as Nb, 
donnee,valeur,date(v_entrees.dateentree) as datevu,entrees.reference,libelle,numero_serie,projet,apt,bontransport,refappro,entrees.tagis as tagis from SuiviMVT,entrees,v_entrees where datevu=date("now") and donnee="Dossier" and v_entrees.dateentree >= datesurv and entrees.tagis=v_entrees.tagis and refappro like "%" || valeur || "%" 
-- group by valeur,numero_serie
-- ;
UNION
select -- -- -- APT
-- count(entrees.tagis) as Nb, 
donnee,valeur,date(v_entrees.dateentree) as datevu,entrees.reference,libelle,numero_serie,projet,apt,bontransport,refappro,entrees.tagis as tagis from SuiviMVT,entrees,v_entrees where datevu=date("now") and donnee="Livraison" and v_entrees.dateentree >= datesurv and entrees.tagis=v_entrees.tagis and APT like "%" || valeur || "%" 
-- group by valeur
-- ;
UNION
select -- -- Colis
-- count(v_entrees.tagis) as Nb, 
donnee,valeur,date(v_entrees.dateentree) as datevu,entrees.reference,libelle,numero_serie,projet,apt,bontransport,refappro,entrees.tagis as tagis from SuiviMVT,entrees,v_entrees where datevu=date("now") and donnee="Colis" and v_entrees.dateentree >= datesurv and entrees.tagis=v_entrees.tagis and BonTransport like "%" || valeur || "%" 
group by entrees.tagis
-- group by valeur
-- ;
)
select distinct count(tagis) as nb,* from storage 
-- where donnee="Dossier" 
group by valeur,reference;

-- -- -- en sortie
SELECT  count(tagis) as nb,donnee,valeur,"Date BL",Reference, Description,numserie,sDepot,NomClient, CP, Ville,Societe,tagis
FROM SORTIES,SuiviMVT
where datevu=date("now") and donnee="Dossier" and valeur=glpi
group by glpi,reference
order by GLPI;
-- -- -- affichage des numéros de colis des dossiers sortis concernés
SELECT Valeur,"Numeros_de_colis" FROM OFLX,SuiviMVT
where datevu=date("now") and Valeur=refclient
order by Valeur
;


---- abandonné
CREATE TRIGGER T_tg
AFTER UPDATE ON tmp_gen
WHEN old.datevu="" AND new.datevu LIKE "____-__-__"
BEGIN
UPDATE tmp_gen set datevu=date(new.datevu,"+1 day");
END;
drop TRIGGER T_tg;

--in progress

-- listage des cas concernés
-- -- en entrée

with storage as (
SELECT -- sorties
Donnee,Valeur,"Date BL" as DateMVT,Reference, description as Designation,NumSerie,sDepot as Stock, NumeroOFL,numeros_de_colis as Transport, sorties.Societe as Societe,TagIS
FROM SORTIES,SuiviMVT
left join oflx on
oflx.refclient = valeur
where datevu=date("now") and donnee="Dossier" and valeur=glpi
group by valeur,reference
-- order by valeur
-- ;
UNION
select -- -- -- dossiers (reste quelques cas de doublons)
-- count(entrees.tagis) as Nb, 
donnee,valeur,date(v_entrees.dateentree) as datevu,entrees.reference,libelle,numero_serie,projet,apt,bontransport,refappro,entrees.tagis as tagis from SuiviMVT,entrees,v_entrees where datevu=date("now") and donnee="Dossier" and v_entrees.dateentree >= datesurv and entrees.tagis=v_entrees.tagis and refappro like "%" || valeur || "%" 
-- group by valeur,numero_serie
-- ;
UNION
select -- -- -- APT
-- count(entrees.tagis) as Nb, 
donnee,valeur,date(v_entrees.dateentree) as datevu,entrees.reference,libelle,numero_serie,projet,apt,bontransport,refappro,entrees.tagis as tagis from SuiviMVT,entrees,v_entrees where datevu=date("now") and donnee="Livraison" and v_entrees.dateentree >= datesurv and entrees.tagis=v_entrees.tagis and APT like "%" || valeur || "%" 
-- group by valeur
-- ;
UNION
select -- -- Colis
-- count(v_entrees.tagis) as Nb, 
donnee,valeur,date(v_entrees.dateentree) as datevu,entrees.reference,libelle,numero_serie,projet,apt,bontransport,refappro,entrees.tagis as tagis from SuiviMVT,entrees,v_entrees where datevu=date("now") and donnee="Colis" and v_entrees.dateentree >= datesurv and entrees.tagis=v_entrees.tagis and BonTransport like "%" || valeur || "%" 
group by entrees.tagis
-- group by valeur
-- ;
-- UNION

)
select distinct count(tagis) as nb,* from storage 
-- where donnee="Dossier" 
group by valeur,reference
;


