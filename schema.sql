CREATE TABLE SORTIES(
  "GLPI" TEXT,
  "Priorite" TEXT,
  "Provenance" TEXT,
  "DateCreation" TEXT,
  "CentreCout" TEXT,
  "Reference" TEXT,
  "Description" TEXT,
  "Date BL" TEXT,
  "BU" TEXT,
  "sDepot" TEXT,
  "NumSerie" TEXT,
  "NomClient" TEXT,
  "Adr1" TEXT,
  "Adr2" TEXT,
  "Adr3" TEXT,
  "CP" TEXT,
  "Dep" TEXT,
  "Ville" TEXT,
  "Tagis" TEXT,
  "Societe" TEXT,
  "NumeroOfl" TEXT,
  " Pays" TEXT
);
CREATE TABLE suivi_attente(
  "TagIs" TEXT,
  "Motif" TEXT,
  "Suivi" TEXT,
  "date_vu" TEXT
);
CREATE TABLE histostock(
Projet TEXT,
Reference TEXT,
Designation TEXT,
OkDispo INT,
OkReserve INT,
SAV INT,
Maintenance INT,
Destruction INT,
Alivrer INT
, dateimport text
CHECK (OkDispo=OkDispo+1-1)
);
CREATE TABLE ENTREES(
  "Projet" TEXT,
  "Reference" TEXT,
  "Numero_Serie" TEXT,
  "DateEntree" TEXT,
  "APT" TEXT,
  "RefAppro" TEXT,
  "BonTransport" TEXT,
  "Libelle" TEXT,
  "TagIS" TEXT,
  "NumTag" TEXT
  CHECK(
        length(TagIs)=12
    AND
        substr(tagis,1,2)="TE"
    )
);
CREATE TABLE Tarif(
    Cat                         TEXT NOT NULL,
    Libelle                     TEXT NOT NULL,
    Designation                 TEXT NOT NULL,
    Commentaire                 TEXT NOT NULL,
    ReceptionUnitaire           NUM  NOT NULL,
    Swap                        NUM  NOT NULL,
    StockageUnitaireParSemaine  NUM  NOT NULL,
    Expedition                  NUM  NOT NULL,
    Transfert                   NUM  NOT NULL,
    SortieManuelle              NUM  NOT NULL
        CHECK(ReceptionUnitaire LIKE "%,%")
);
CREATE TABLE familles(
CodeFamille int not null,
CodeType text not null,
LibFamille text not null,
LibType text not null,
Proposition text
check(codefamille>0
AND codefamille<=9
AND length(codetype)=1
)
);
CREATE TABLE AuditADB(
    NUMERO_ADB TEXT NOT NULL,
    DATE_AUDIT TEXT NOT NULL,
    TYPE_MATERIEL TEXT NOT NULL,
    SYSTEM_MANUFACTURER TEXT NOT NULL,
    SYSTEM_MODEL TEXT NOT NULL,
    SYSTEM_SERIAL TEXT NOT NULL,
    CPU_MODEL TEXT NOT NULL,
    DISK_CAPACITY TEXT NOT NULL,
    MEMORY_CAPACITY TEXT NOT NULL,
    OPTICAL_DRIVE_TYPE TEXT NOT NULL,
    OS TEXT NOT NULL,
    VALEUR_REPRISE INT NOT NULL,
    GRADE TEXT NOT NULL,
    COMMMENTAIRES TEXT NOT NULL,
    NUMERO_PALETTE TEXT NOT NULL,
    FA TEXT NOT NULL,
    CLIENT TEXT NOT NULL
    
    CHECK(
        DATE_AUDIT LIKE "__/__/____ __:__"
    AND GRADE BETWEEN "A" AND "Z"
    AND LENGTH(GRADE)=1
    )
);
CREATE TABLE SFPproduits(
    CodeStat    TEXT NOT NULL,
    Reference   TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS "sfpSorties"(
    CodeStat    TEXT NOT NULL,
    DateStat    TEXT NOT NULL,
    INC         INTEGER NOT NULL DEFAULT 0,
    DEM         INTEGER NOT NULL DEFAULT 0,
    RMA         INTEGER NOT NULL DEFAULT 0,
    DEL         INTEGER NOT NULL DEFAULT 0,
    DIV         INTEGER NOT NULL DEFAULT 0
);
CREATE TABLE ISIResultats(
    Jour TEXT NOT NULL,
    Code TEXT NOT NULL,
    Nombre INTEGER NOT NULL DEFAULT 0
    CHECK( Code LIKE "ISI-%")
);
CREATE TABLE IncProdIS(
  "ID" TEXT,
  "Titre" TEXT,
  "Entité" TEXT,
  "Statut" TEXT,
  "Contact / Bénéficiaire - Contact / Bénéficiaire" TEXT,
  "Catégorie" TEXT,
  "Priorité" TEXT,
  "Dernière modification" TEXT,
  "Appelant / Demandeur - Appelant / Demandeur" TEXT,
  "Contact / Bénéficiaire - Emplacement" TEXT,
  "Plugins - Contrat" TEXT,
  "Description" TEXT,
  "Tâches - Description" TEXT,
  "Type" TEXT,
  "Tâches - Date" TEXT,
  "" TEXT
);
CREATE TABLE codeserreur(
    code text,
    sujet text,
    description text
    CHECK(substr(code,1,4)="ISI-")
    -- le check est là pour éviter d'insérer la ligne de titre comme faisant partie des données
, abrege text);
CREATE TABLE Resultats(
    Jour TEXT NOT NULL,
    Code TEXT NOT NULL,
    Nombre INTEGER NOT NULL DEFAULT 0
    CHECK( Code LIKE "ISI-%")
);
CREATE TABLE matosreseau(
  "dossier" TEXT,
  "tagis" TEXT,
  "sn" TEXT,
  "modèle" TEXT,
  "Projet" TEXT,
  "CdP" TEXT
);
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
    AND (length(valeur) between 10 AND 13)
    )
);
CREATE TABLE sqliteshow(
Donnee text not null primary key,
valeur text
);
CREATE TABLE ProjetsDeploiements (
    CodeProjet  TEXT NOT NULL PRIMARY KEY,
    NomProjet   TEXT NOT NULL DEFAULT ""
);
CREATE TABLE DEPLPMLXCOL (
    CodeColissimo  TEXT NOT NULL PRIMARY KEY,
    SITE TEXT NOT NULL,
    ADR1 TEXT NOT NULL,
    ADR2 TEXT NOT NULL,
    ADR3 TEXT NOT NULL,
    CPV TEXT NOT NULL,
    NOM TEXT NOT NULL,
    migration TEXT NOT NULL
    CHECK(
        CAST(CodeColissimo AS INTEGER) BETWEEN 1 AND 999999
    AND
        CPV LIKE "_____ %"
    )
, NoChange INTEGER);
CREATE TABLE SuiviDeploiements (
-- indispensable pour pouvoir ne pas sélectionner les déploiements auxquel un dossier est déjà affecté
-- /!\ Attention, nécessité d'un trigger donc on inserre sur la vue et non sur la table
    CodeSite    TEXT  NOT NULL,
    CodeProjet  TEXT NOT NULL,
    Dossier     INTEGER NOT NULL DEFAULT 0
);
CREATE TABLE sfpStats(
-- archivage des stats
    DateStat    TEXT NOT NULL,
    Incident    INTEGER NOT NULL DEFAULT 0,
    Demande     INTEGER NOT NULL DEFAULT 0,
    RMA         INTEGER NOT NULL DEFAULT 0,
    DEL         INTEGER NOT NULL DEFAULT 0,
    undef       INTEGER NOT NULL DEFAULT 0,
    CodeStat    TEXT NOT NULL,
    OkDispo     INTEGER NOT NULL DEFAULT 0,
    OkReserve   INTEGER NOT NULL DEFAULT 0,
    SAV         INTEGER NOT NULL DEFAULT 0,
    Maintenance INTEGER NOT NULL DEFAULT 0,
    Destruction INTEGER NOT NULL DEFAULT 0,
    Alivrer     INTEGER NOT NULL DEFAULT 0,
    CodeStatBis TEXT NOT NULL,              -- Ce champ fait doublon car l'ancien système de stat était construit ainsi
    Seuil       INTEGER NOT NULL DEFAULT 0, -- bien qu'il soit déjà dans sfpListe le seuil est archivé ici car il peut changer au cours de la vie du produit
    LibStat     TEXT NOT NULL   -- Pareil pour le libellé du produit
    CHECK(      DateStat LIKE "____-__-__"
          AND   CodeStat=CodeStatBis -- Autant utiliser le doublon pour vérification de la cohérence des données
        )
);
CREATE TABLE cataloguesrefchrsansmmvt(
    fichier text,
    Ref text,
    refgen text,
    refalt text,
    magdest text,
    famille test,
    designation text,
    cat text,
    kg text,
    partenaire text,
    projet text,
    active text
    check(active in ("Oui","Non"))
);
CREATE TABLE p_Sorties(
-- table pivot des sorties : le contenu de cette table sera ensuite transposé dans une autre
    CodeStat    TEXT NOT NULL,
    DateStat    TEXT NOT NULL,
    ItemStat    TEXT NOT NULL DEFAULT "IND",
    Valeur      INTEGER NOT NULL DEFAULT 0
    CHECK       (
            ItemStat    IN  ("INC","DEM","RMA","DEL","ATL","IND","DIV")
        AND DateStat    LIKE "____-__-__"
    )
);
CREATE TABLE v_gsorties(
  "GLPI" TEXT,
  "Priorit�" TEXT,
  "Provenance" TEXT,
  "DateCr�ation" TEXT,
  "CentreCout" TEXT,
  "Reference" TEXT,
  "Description" TEXT,
  "Date BL" TEXT,
  "D�pot" TEXT,
  "sDepot" TEXT,
  "Num Serie" TEXT,
  "Nom Client L" TEXT,
  "Adr1 L" TEXT,
  "Adr2 L" TEXT,
  "Adr3 L" TEXT,
  "CP L" TEXT,
  "Dep" TEXT,
  "Ville L" TEXT,
  "Tagis" TEXT,
  "Societe L" TEXT,
  "NumeroOfl" TEXT,
  " Pays de destination" TEXT
);
CREATE TABLE g_SORTIES(
-- 12:57 20/10/2020 utilisation de la feature "generated columns"
-- /!\ L'import .csv ne marche pas en direct sur la table parce que :
--     le csv comporte moins de champs que la table ET on ne peut pas écrire sur les champs générés
-- sqlite> .import is_out_dernier.csv g_sorties
-- Error: table g_sorties has 23 columns but 25 values were supplied
-- Une généralisation de l'usage des champs calculés pourrait permettre de se passer de la vue v_sorties par exemple
  "GLPI" TEXT,
  "Priorite" TEXT,
  "Provenance" TEXT,
  "DateCreation" TEXT,
  "CentreCout" TEXT,
  "Reference" TEXT,
  "Description" TEXT,
  "Date BL" TEXT,
  "BU" TEXT,
  "sDepot" TEXT,
  "NumSerie" TEXT,
  "NomClient" TEXT,
  "Adr1" TEXT,
  "Adr2" TEXT,
  "Adr3" TEXT,
  "CP" TEXT,
  "Dep" TEXT,
  "Ville" TEXT,
  "Tagis" TEXT,
  "Societe" TEXT,
  "NumeroOfl" TEXT,
  "Pays" TEXT,
  "Vide" TEXT default "", -- # bug de sqlite, colonne morte obligatoire entre les champs importés via csv et les champs calculés
  DateBL GENERATED ALWAYS     AS (        substr("Date BL",7,4) || "-" || substr("Date BL",4,2) || "-" || substr("Date BL",1,2))     STORED,
  DateEntree GENERATED ALWAYS AS ("20" || substr(tagis,3,2)     || "-" || substr(tagis,5,2)     || "-" || substr(tagis,7,2))     STORED
);
CREATE TABLE IF NOT EXISTS 'posts_data'(id INTEGER PRIMARY KEY, block BLOB);
CREATE TABLE IF NOT EXISTS 'posts_idx'(segid, term, pgno, PRIMARY KEY(segid, term)) WITHOUT ROWID;
CREATE TABLE IF NOT EXISTS 'posts_content'(id INTEGER PRIMARY KEY, c0, c1);
CREATE TABLE IF NOT EXISTS 'posts_docsize'(id INTEGER PRIMARY KEY, sz BLOB);
CREATE TABLE IF NOT EXISTS 'posts_config'(k PRIMARY KEY, v) WITHOUT ROWID;
CREATE TABLE SuiviChgt(
  "Titre" TEXT,
  "Entite" TEXT,
  "ID" INTEGER,
  "Statut" TEXT,
  "Urgence" TEXT,
  "Contact" TEXT,
  "Responsable" TEXT,
  "NbDocuments" TEXT,
  "Description" TEXT,
  "Ouverture" TEXT,
  "Cloture" TEXT,
  "Attribution" TEXT,
  "Modification" TEXT
  CHECK(
    id +1 -1 = id -- vérifie que l'id est de type numérique afin d'exclure la ligne d'en-tête
  )
);
CREATE TABLE cablesprojets(
    Annee   integer,
    QtIn    integer,
    E_In    NUMBER,
    QStock INTEGER,
    E_Stockage NUMERIC,
    QtOut   integer,
    E_Out   NUMBER,
    Q10Out INTEGER
    check(annee between 2016 AND 2020)
);
CREATE TABLE test1(
  "Qte" TEXT,
  "Nom projet" TEXT,
  "Ref" TEXT,
  "Lib" TEXT,
  "Designation" TEXT,
  "Etat" TEXT,
  "Statut" TEXT,
  "Num�ro de s�rie" TEXT,
  "TagIs" TEXT,
  "DateEntree" TEXT,
  "" TEXT
);
CREATE TABLE Stock(
  "Qte" INT NOT NULL DEFAULT 1,
  "Nom_projet" TEXT NOT NULL,
  "Ref" TEXT NOT NULL,
  "Lib" TEXT NOT NULL,
  "Designation" TEXT NOT NULL,
  "Etat" TEXT NOT NULL,
  "Statut" TEXT NOT NULL,
  "Numero_de_serie" TEXT NOT NULL,
  "TagIs" TEXT NOT NULL PRIMARY KEY,
  "DateEntree" TEXT NOT NULL,
  "vide" TEXT NOT NULL
  CHECK(
        Qte=1
    AND
        Lib="Lib"
    AND
        Vide=""
    AND (
            TagIS LIKE "TE__________"
        OR  TagIS LIKE "SN____________"
        )
    )
);
CREATE TABLE EtatCorrect(
-- table des états de stock ne demandant pas de suivi
Etat TEXT NOT NULL PRIMARY KEY
);
CREATE TABLE SuiviStock(
    DateStock TEXT NOT NULL PRIMARY KEY,
    nbOK    INTEGER DEFAULT 0,
    nbADA   INTEGER DEFAULT 0,
    nbAudit INTEGER DEFAULT 0,
    nbHS    INTEGER DEFAULT 0,
    nbDiv   INTEGER DEFAULT 0,
    nbNeuf  INTEGER DEFAULT 0
    CHECK(DateStock LIKE "____-__-__")
);
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
);
CREATE TABLE CatArchive(
-- archive des mouvements de catalogue
-- afin de détecter/dater les ajouts ou suppression de références, par exemple

  "Nom_projet" TEXT NOT NULL,
  "Ref" TEXT NOT NULL,
  "Cat" TEXT NOT NULL,
  "Active" TEXT NOT NULL,
  "DateExport" TEXT NOT NULL,
  PRIMARY KEY(DateExport,Nom_Projet,Ref)
  CHECK(
        DateExport LIKE "____-__-__"
    AND length(Cat)=1
    AND Active in ("Oui","Non")
  )
);
CREATE TABLE Catalogue(
    Ref TEXT NOT NULL,
    ReferenceGen TEXT NOT NULL DEFAULT "",
    ReferenceAlt TEXT NOT NULL DEFAULT "",
    MagasinDest TEXT NOT NULL DEFAULT "",
    Famille TEXT NOT NULL DEFAULT "",
    Designation TEXT NOT NULL,
    Categorie TEXT NOT NULL,
    Kg NUM NOT NULL DEFAULT 0,
    Partenaire TEXT NOT NULL DEFAULT "TELINTRANS",
    Projet TEXT NOT NULL,
    Active TEXT NOT NULL DEFAULT "Oui",
    Vide TEXT NOT NULL DEFAULT ""
        CHECK(
                Active IN ("Oui","Non")
            AND Vide=""
        )
);
CREATE TABLE StatProduits(
	BU TEXT NOT NULL
	,
	CodeFamille TEXT NOT NULL,
	CodeStock TEXT NOT NULL,
	NomProduit TEXT NOT NULL
);
CREATE TABLE CodesVentileNR(
  "Famille" TEXT NOT NULL,
  "Stock" TEXT NOT NULL,
  "Nomproduit" TEXT NOT NULL,
  PRIMARY KEY(Famille, Stock)
);
CREATE TABLE ClassesDurees(
	Classe INTEGER NOT NULL PRIMARY KEY,
	LibClasse TEXT NOT NULL UNIQUE
);
CREATE TABLE stockold(
  "Qte" TEXT,
  "Nom projet" TEXT,
  "Ref" TEXT,
  "Lib" TEXT,
  "Designation" TEXT,
  "Etat" TEXT,
  "Statut" TEXT,
  "Num�ro de s�rie" TEXT,
  "TagIs" TEXT,
  "DateEntree" TEXT,
  "" TEXT
);
CREATE TABLE comparestock(
qte integer,
nomprojet text,
ref text,
datestock text
);
CREATE TABLE SFPliste(
    CodeStat    TEXT NOT NULL PRIMARY KEY,
    LibStat     TEXT NOT NULL,
    Seuil       INTEGER NOT NULL DEFAULT 0,
    ACTIVE TEXT DEFAULT "Oui"
);
CREATE TABLE stockbug(
  "Qte" TEXT,
  "Nom projet" TEXT,
  "Ref" TEXT,
  "Lib" TEXT,
  "Etat" TEXT,
  "Statut" TEXT,
  "Numéro de série" TEXT,
  "" TEXT
);
CREATE TABLE StockBackup(
-- 16:22 01/02/2021 sauvegarde mise à jour à chaque suppression dans stock
  "Qte" INT NOT NULL DEFAULT 1,
  "Nom_projet" TEXT NOT NULL,
  "Ref" TEXT NOT NULL,
  "Lib" TEXT NOT NULL,
  "Designation" TEXT NOT NULL,
  "Etat" TEXT NOT NULL,
  "Statut" TEXT NOT NULL,
  "Numero_de_serie" TEXT NOT NULL,
  "TagIs" TEXT NOT NULL PRIMARY KEY,
  "DateEntree" TEXT NOT NULL,
  "Vide" TEXT NOT NULL DEFAULT "",
  "LastUpdate" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
  CHECK(
        Qte=1
    AND
        Lib="Lib"
    -- AND
        -- Vide=""
    AND (
            TagIS LIKE "TE__________"
        OR  TagIS LIKE "SN____________"
        )
    )
);
CREATE UNIQUE INDEX Stag on SORTIES(tagis);
CREATE UNIQUE INDEX k_SoTag ON SORTIES(tagis);
CREATE UNIQUE INDEX k_histostock on histostock(dateimport,reference,projet);
CREATE UNIQUE INDEX k_entrees on entrees(tagis,dateentree,reference);
CREATE INDEX k_datebl_sorties on sorties("Date BL");
CREATE INDEX k_RG_Sorties ON SORTIES(Reference, GLPI);
CREATE INDEX k_SN_Entrees_CI ON ENTREES(Numero_Serie COLLATE NOCASE);
CREATE UNIQUE INDEX K_Tarif on tarif(cat);
CREATE UNIQUE INDEX k_famille on familles(codefamille,codetype);
CREATE INDEX K_SoPriPro on SORTIES(PRIORITE,PROVENANCE);
CREATE UNIQUE INDEX K_SFPP on sfpproduits(reference);
CREATE UNIQUE INDEX k_ISIr on Resultats(Jour,Code);
CREATE UNIQUE INDEX k_SurvS ON SuiviMVT(Donnee,Valeur);
CREATE UNIQUE INDEX K_SD on SuiviDeploiements(CodeSite,CodeProjet);
CREATE UNIQUE INDEX k_sfpStats ON sfpStats(DateStat,CodeStat);
CREATE INDEX k_SuiviMVT_date ON SuiviMVT(DateVu DESC);
CREATE INDEX k_SORTIES_glpi ON SORTIES(GLPI);
CREATE INDEX k_SuiviMVT_Donnee_Datevu ON SuiviMVT(Donnee, DateVu);
CREATE INDEX k_SFPproduits_CodeStat ON SFPproduits(CodeStat);
CREATE UNIQUE INDEX k_Psorties ON p_Sorties(CodeStat,DateStat,ItemStat);
CREATE UNIQUE INDEX kg_sorties on g_sorties(tagis);
CREATE UNIQUE INDEX k_cpa on cablesprojets(annee);
CREATE INDEX kS_OFL ON SORTIES(NumeroOfl);
CREATE INDEX k_SA_Etat on StockArchive(Etat);
CREATE INDEX k_ES ON StockArchive(Etat, Statut);
CREATE INDEX k_CatPR ON Catalogue(Projet,Ref);
CREATE INDEX k_SA_RP ON StockArchive(Ref, Nom_projet);
CREATE INDEX k_C_CPR ON Catalogue(Categorie, Projet, Ref);
CREATE VIEW v_statsortie as
  SELECT tagis, "PCA" as Usage FROM sorties
  WHERE GLPI IN (2003200324,2003200325,2003200326,2003200327,2003200328,2003200347,2003200389,2003200459)
UNION
  SELECT tagis,"MAGNETIK" AS Usage   FROM sorties 
  WHERE ADR1 LIKE "%3 BOULEVARD ROMAIN ROLLAND%"
  AND GLPI NOT IN (2003200324,2003200325,2003200326,2003200327,2003200328,2003200347,2003200389,2003200459)
UNION
  SELECT tagis,"CHRONOSHIP" AS Usage   FROM sorties 
  WHERE sdepot="CHRONOPOST SHIPPING" 
  AND ADR1 NOT LIKE "%3 BOULEVARD ROMAIN ROLLAND%"
UNION
  SELECT tagis,"EXPEDITOR" AS Usage FROM sorties 
  WHERE sdepot="COLIPOSTE SHIPPING" 
  AND ADR1 NOT LIKE "%3 BOULEVARD ROMAIN ROLLAND%"
UNION
  SELECT tagis,"COLISSIMO" AS Usage FROM sorties 
  WHERE sdepot LIKE "COLIPOSTE%" 
  AND sdepot <> "COLIPOSTE SHIPPING" 
  AND ADR1 NOT LIKE "%3 BOULEVARD ROMAIN ROLLAND%"
UNION
  SELECT tagis,"ALTURING" AS Usage FROM sorties 
  WHERE sdepot="TELINTRANS" 
  AND ADR1 NOT LIKE "%3 BOULEVARD ROMAIN ROLLAND%"
UNION
  SELECT tagis,"CHR METIER" AS Usage FROM sorties 
  WHERE sdepot LIKE "CHRONOPOST%" 
  AND sdepot <> "CHRONOPOST SHIPPING" 
  AND ADR1 NOT LIKE "%3 BOULEVARD ROMAIN ROLLAND%"
/* v_statsortie(Tagis,Usage) */;
CREATE VIEW v_adresses as
SELECT
        glpi               AS DernierDossier ,
        datebl             AS DernierBL      ,
        printf("%02d",dep) AS Dpt            ,
        trim(societe)      AS NomSite        ,
        nomclient                            ,
        adr1                                 ,
        adr2                                 ,
        adr3                                 ,
        CP AS CodePostal                     ,
        ville                                ,
        " pays" AS Pays
FROM
        sorties,
        v_sorties
WHERE
        sorties.tagis =v_sorties.tagis
AND     societe       > "!"
AND     nomclient     > "!"
AND     sdepot NOT LIKE "%ship%"
AND     pays   NOT LIKE "FR%"
GROUP BY
        nomsite,
        cp

UNION

SELECT
        glpi               AS DernierDossier ,
        datebl             AS DernierBL      ,
        printf("%02d",dep) AS Dpt            ,
        trim(societe)      AS NomSite        ,
        nomclient                            ,
        adr1                                 ,
        adr2                                 ,
        adr3                                 ,
        printf("%05d",CP) AS CodePostal      ,
        ville                                ,
        " pays" AS Pays
FROM
        sorties,
        v_sorties
WHERE
        sorties.tagis =v_sorties.tagis
AND     societe       > "!"
AND     nomclient     > "!"
AND     sdepot NOT LIKE "%ship%"
AND     pays       LIKE "FR%"
GROUP BY
        nomsite,
        cp
ORDER BY
        cp ASC,
        datebl DESC
/* v_adresses(DernierDossier,DernierBL,Dpt,NomSite,NomClient,Adr1,Adr2,Adr3,CodePostal,Ville,Pays) */;
CREATE VIEW v_lastliv as
WITH storage as (SELECT max(datebl) as datemax FROM v_sorties) SELECT glpi,count(sorties.tagis) as Nb,"date bl",societe,nomclient,cp,ville,reference,description FROM sorties,v_sorties,storage WHERE sorties.tagis=v_sorties.tagis AND datebl = datemax GROUP BY glpi,reference
/* v_lastliv(GLPI,Nb,"Date BL",Societe,NomClient,CP,Ville,Reference,Description) */;
CREATE VIEW v_OFLX AS
WITH Storage AS (
    SELECT NoOFL,Date_Creation,Date_Expedition,Date_souhaitee,Date_Notification,  Heure_Notification
    FROM "OFLX"
    WHERE Date_Creation <> ""
UNION ALL
    SELECT NoOFL,DateCreation,Date_Expedition,Date_souhaitee,Date_Notification,Heure_Notification
    FROM "OFLX",Sorties
    WHERE Date_Creation = ""
    AND "OFLX".NOOFL=Sorties.NumeroOfl
)

SELECT NoOFL,
    substr(Date_Creation,7,4) || "-" || substr(Date_Creation,4,2)  || "-" || substr(Date_Creation,1,2) AS Date_Creation, 
    substr(Date_Expedition,7,4) || "-" || substr(Date_Expedition,4,2)  || "-" || substr(Date_Expedition,1,2) AS Date_Expedition, 
    substr(Date_souhaitee,7,4) || "-" || substr(Date_souhaitee,4,2)  || "-" || substr(Date_souhaitee,1,2) AS Date_souhaitee, 
    substr(Date_Creation,7,4) || "-" || substr(Date_Creation,4,2)  || "-" || substr(Date_Creation,1,2)  AS DateHeure_Notification
    -- substr(Date_Notification,7,4) || "-" || substr(Date_Notification,4,2)  || "-" || substr(Date_Notification,1,2) || " " || Heure_Notification AS DateHeure_Notification
    FROM Storage
    -- WHERE DateHeure_Notification = "-- "
    WHERE Date_Notification = ""
UNION ALL
SELECT NoOFL,
    substr(Date_Creation,7,4) || "-" || substr(Date_Creation,4,2)  || "-" || substr(Date_Creation,1,2) AS Date_Creation, 
    substr(Date_Expedition,7,4) || "-" || substr(Date_Expedition,4,2)  || "-" || substr(Date_Expedition,1,2) AS Date_Expedition, 
    substr(Date_souhaitee,7,4) || "-" || substr(Date_souhaitee,4,2)  || "-" || substr(Date_souhaitee,1,2) AS Date_souhaitee, 
    -- substr(Date_Creation,7,4) || "-" || substr(Date_Creation,4,2)  || "-" || substr(Date_Creation,1,2)  AS DateHeure_Notification
    substr(Date_Notification,7,4) || "-" || substr(Date_Notification,4,2)  || "-" || substr(Date_Notification,1,2) || " " || Heure_Notification AS DateHeure_Notification
    FROM Storage
    WHERE DateHeure_Notification <> "-- "
    
ORDER BY  NoOfl ASC
;
CREATE VIEW v_ref_sortie as SELECT
substr(reference,1,3) as BU,
substr(reference,4,1) as SurFamille,
substr(reference,5,1) as SousFamille,
substr(reference,6,1) as Etat,
substr(reference,7,1) as Stock,
substr(reference,8)   as produit
,
substr(reference,4,2) as Famille,
TagIS
FROM sorties
;
CREATE VIEW v_ref_stock as SELECT
substr(ref,1,3) as BU,
substr(ref,4,1) as SurFamille,
substr(ref,5,1) as SousFamille,
substr(ref,6,1) as Etat,
substr(ref,7,1) as Stock,
substr(ref,8)   as Produit,
substr(ref,4,2) as Famille,
Tagis
FROM stock
/* v_ref_stock(BU,SurFamille,SousFamille,Etat,Stock,Produit,Famille,TagIs) */;
CREATE VIEW v_LastLivMagnetik AS
WITH storage                as
     (
            SELECT
                   max(datebl) as datemax
            FROM
                   v_sorties
                 , sorties
            WHERE
                   adr1            LIKE "%3 BOULEVARD ROMAIN ROLLAND%"
                   AND v_sorties.tagis=sorties.tagis
     )
SELECT
         glpi
       , count(sorties.tagis) as nb
       , datebl
       , nomclient
       , reference
       , description
       , Numeros_de_colis
       , "https://glpi.alturing.eu/front/ticket.form.php?id="
                  || glpi as "Lien"
FROM
         sorties
       , storage
       , v_sorties
       , "OFLX"
WHERE
         sorties.tagis=v_sorties.tagis
         AND datebl   > date(datemax,"-3 days")
         AND adr1  LIKE "%3 BOULEVARD ROMAIN ROLLAND%"
         AND sorties.NumeroOFL = "OFLX".NoOFL
GROUP BY
         reference
       , glpi
order by
         datebl desc
       , glpi
;

CREATE VIEW v_sn_entrees as
SELECT tagis,numero_serie as SN FROM entrees WHERE numero_serie not LIKE "S________" OR (numero_serie LIKE "S________" AND libelle not LIKE "%lenovo%" AND libelle not LIKE "%generique%")
union
SELECT tagis,substr(numero_serie,2,8) as SN FROM entrees WHERE numero_serie LIKE "S________" AND (libelle LIKE "%lenovo%" or libelle LIKE "%generique%")
/* v_sn_entrees(TagIS,SN) */;
CREATE VIEW v_sn_stock as
SELECT tagis,numero_de_serie as SN FROM stock WHERE numero_de_serie not LIKE "S________" OR (numero_de_serie LIKE "S________" AND Designation not LIKE "%lenovo%" AND Designation not LIKE "%generique%")
union
SELECT tagis,substr(numero_de_serie,2,8) as SN FROM stock WHERE numero_de_serie LIKE "S________" AND (Designation LIKE "%lenovo%" or Designation LIKE "%generique%")
/* v_sn_stock(TagIs,SN) */;
CREATE VIEW v_PM_sorties as SELECT count(sorties.tagis) as NB,strftime("%Y-%m",datebl) as mois,produit,description FROM sorties,v_sorties WHERE sorties.tagis=v_sorties.tagis GROUP BY mois,produit order by mois,produit
/* v_PM_sorties(NB,mois,Produit,Description) */;
CREATE VIEW v_Retour_UC_Windows2mois AS
SELECT
         sn
       , entrees.tagis
       , entrees.reference
       , libelle
       , v_entrees.dateentree
FROM
         entrees
       , v_entrees
       , v_sn_entrees
WHERE
         entrees.tagis=v_sn_entrees.tagis
     AND entrees.tagis=v_entrees.tagis
     AND entrees.tagis IN
         (
                SELECT DISTINCT
                       entrees.tagis
                FROM
                       entrees
                WHERE
                       entrees.tagis > "TE"
                                     || substr(strftime("%Y%m%d",date("now", "-2 month")),3)
                   AND numero_serie > " "
         )
         AND
         (
                  entrees.reference IN ("UC","PORTABLE")
               or entrees.reference LIKE "___10R%"
               or entrees.reference LIKE "___11R%"
         )
GROUP BY
         entrees.tagis
HAVING
         entrees.libelle   NOT LIKE "%FREEDOS%"
     AND entrees.reference NOT LIKE "%STT"
ORDER BY
         entrees.tagis
/* v_Retour_UC_Windows2mois(SN,TagIS,Reference,Libelle,DateEntree) */;
CREATE VIEW v_1er_sn_entree as
WITH storage as (
  SELECT distinct v_entrees.dateentree,sn
    FROM entrees,v_sn_entrees,v_entrees
    WHERE entrees.tagis=v_entrees.tagis
    AND entrees.tagis=v_sn_entrees.tagis
    AND v_sn_entrees.sn in (
      SELECT sn  FROM stock,v_stock,v_sn_stock
        WHERE stock.tagis=v_stock.tagis 
        AND surfamille in ("1","3","4","6") AND sousfamille <> "9"
        AND length(stock.numero_de_serie)>3
        AND stock.tagis=v_sn_stock.tagis
    )
)
-- SELECT dateentree,sn
SELECT min(dateentree) as Date1eEntree,sn
  FROM storage
 GROUP BY sn
  order by sn 
-- limit 10
/* v_1er_sn_entree(Date1eEntree,sn) */;
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
/* v_1ere_entree(RefAppro,DateEntree,SN,TagIS,Reference,Libelle,APT,Projet) */;
CREATE VIEW V_TARIF AS
SELECT Cat, REPLACE(ReceptionUnitaire,",",".") as ReceptionUnitaire, REPLACE(Swap,",",".") AS Swap, REPLACE(StockageUnitaireParSemaine,",",".") AS StockageUnitaireParSemaine, REPLACE(Expedition,",",".") AS Expedition, REPLACE(Transfert,",",".") AS Transfert, REPLACE(SortieManuelle,",",".") AS SortieManuelle FROM TARIF
/* V_TARIF(Cat,ReceptionUnitaire,Swap,StockageUnitaireParSemaine,Expedition,Transfert,SortieManuelle) */;
CREATE VIEW v_familles as SELECT codefamille || codetype as famille,codefamille as surfamille,codetype as sousfamille,libfamille as nom,
case
when proposition > "" then proposition 
else libtype 
end prenom
FROM familles
order by surfamille,sousfamille
/* v_familles(famille,surfamille,sousfamille,nom,prenom) */;
CREATE VIEW v_TEexport as
-- re-création de l'export quotidien envoyé par l'automate
WITH storage as (SELECT max(dateimport) as maxdate FROM histostock) SELECT Projet, Reference, Designation, OkDispo, OkReserve, SAV, Maintenance, Destruction, Alivrer, dateimport FROM histostock,storage WHERE dateimport=maxdate
/* v_TEexport(Projet,Reference,Designation,OkDispo,OkReserve,SAV,Maintenance,Destruction,Alivrer,dateimport) */;
CREATE VIEW v_dernierimport AS
-- rappel de la dernière date d'import des données
SELECT max(dateimport) as maxdate FROM histostock
/* v_dernierimport(maxdate) */;
CREATE VIEW v_sqliteshow as SELECT donnee,valeur FROM sqliteshow
/* v_sqliteshow(Donnee,valeur) */;
CREATE TRIGGER T_show
   INSTEAD OF INSERT ON v_sqliteshow
-- WHEN new.donnee = old.donnee 
BEGIN
   -- set 
   REPLACE into sqliteshow(valeur,donnee) values(new.valeur,new.donnee)
   -- WHERE donnee=new.donnee
   ;
END;
CREATE VIEW v_TransposeStatsSorties AS
-- Transposition de la table pivot
-- trouvé sur https://stackoverflow.com/questions/3611542/sql-columns-for-different-categories
SELECT     CodeStat,
    max(case when     ItemStat="INC" then     Valeur END) as INC,
    max(case when     ItemStat="DEM" then     Valeur END) as DEM,
    max(case when     ItemStat="RMA" then     Valeur END) as RMA,
    max(case when     ItemStat="DEL" then     Valeur END) as DEL,
    max(case when     ItemStat="ATL" then     Valeur END) as ATL,
    max(case when     ItemStat="IND" then     Valeur END) as IND,
    DateStat
FROM p_Sorties
GROUP BY CodeStat
/* v_TransposeStatsSorties(CodeStat,INC,DEM,RMA,DEL,ATL,IND,DateStat) */;
CREATE VIEW v_SuiviDeploiements as 
-- Nécessité d'un trigger avec clause instead pour inserrer, donc on le fera sur cette vue
SELECT CodeSite,CodeProjet,Dossier FROM SuiviDeploiements
/* v_SuiviDeploiements(CodeSite,CodeProjet,Dossier) */;
CREATE TRIGGER Ti_SuiviDeploiements
-- sans ça, l'INSERT échoue et arrête le script
-- résultat de ce trigger, on ajoute uniquement les lignes qui n'existent pas encore sans toucher aux autres
INSTEAD OF INSERT ON v_SuiviDeploiements
WHEN NOT EXISTS (SELECT * FROM suivideploiements WHERE suivideploiements.codesite=new.codesite AND suivideploiements.codeprojet=new.codeprojet)
BEGIN
    INSERT into suivideploiements(codesite,CodeProjet) SELECT CodeColissimo,"PMCOLLX" FROM deplpmlxcol WHERE CodeColissimo=new.codesite 
    ;
END;
CREATE VIEW v_ProchaineDate AS
SELECT min(date(migration,"-7 days")) AS ProchaineDate,CodeColissimo,site FROM deplpmlxcol,suivideploiements
WHERE codesite=CodeColissimo AND CodeProjet="PMCOLLX" AND dossier=0
/* v_ProchaineDate(ProchaineDate,CodeColissimo,SITE) */;
CREATE TRIGGER Tu_SuiviDeploiements
-- sans ça, l'INSERT échoue et arrête le script
-- résultat de ce trigger, on ajoute uniquement les lignes qui n'existent pas encore sans toucher aux autres
INSTEAD OF INSERT ON v_SuiviDeploiements
WHEN EXISTS (SELECT * FROM suivideploiements WHERE suivideploiements.codesite=new.codesite AND suivideploiements.codeprojet=new.codeprojet)
BEGIN
    UPDATE suivideploiements set dossier=new.dossier WHERE codesite=new.codesite  AND CodeProjet="PMCOLLX"
    ;
END;
CREATE VIEW v_CreationDossierAbregee AS
SELECT 
    strftime("%d/%m/%Y",date(migration,"-7 days")) as Creation
    ,SITE
    ,CodeColissimo
    ,CASE 
        WHEN strftime("%w",migration) <= "2" THEN strftime("%d/%m/%Y",date("migration","-4 days"))
        ELSE strftime("%d/%m/%Y",date("migration","-1 day"))
    END Envoi
, site
    , NOM
    ,ADR1
    ,ADR2
    -- ,ADR3
    ,CPV

FROM deplpmlxcol,suivideploiements 
WHERE codesite=CodeColissimo AND CodeProjet="PMCOLLX" AND dossier=0

GROUP BY CodeColissimo
having creation <= "Dossier à créer le " || date("now")
order by migration asc
/* v_CreationDossierAbregee(Creation,SITE,CodeColissimo,Envoi,"SITE:1",NOM,ADR1,ADR2,CPV) */;
CREATE VIEW V_StatIS AS
SELECT
    Datestat,INC AS Incident,DEM AS Demande,RMA,DEL as Destruction,ATL + IND AS undef,sfpProduits.CodeStat,
    sum(OkDispo) AS OkDispo,sum(OkReserve) AS OkReserve,sum(SAV) AS SAV,sum(Maintenance) AS Maintenance,sum(Destruction) AS Destruction,sum(Alivrer) AS Alivrer,
    SFPliste.CodeStat,Seuil,LibStat
FROM v_TransposeStatsSorties,v_TEexport,SFPliste,sfpProduits
WHERE
        DateStat=DateImport
        AND SFPliste.CodeStat=sfpProduits.CodeStat
    AND v_TransposeStatsSorties.CodeStat=SFPliste.CodeStat
    AND v_TEexport.Reference LIKE sfpproduits.reference
GROUP BY sfpproduits.codestat
/* V_StatIS(DateStat,Incident,Demande,RMA,Destruction,undef,CodeStat,OkDispo,OkReserve,SAV,Maintenance,"Destruction:1",Alivrer,"CodeStat:1",Seuil,LibStat) */;
CREATE VIEW V_ValCatalogue AS

-- CREATE VIEW V_Catalogue AS
SELECT
    Ref AS Reference,

    -- SUBSTR(Ref,1,3) AS BU,
    -- SUBSTR(Ref,4,1) AS SurFamille,
    -- SUBSTR(Ref,5,1) AS SousFamille,
    -- SUBSTR(Ref,6,1) AS Etat,
    -- SUBSTR(Ref,7,1) AS Stock,
    -- SUBSTR(Ref,8)   AS Produit,
    SUBSTR(Ref,4,2) AS Famille,

    Categorie,
    CAST(REPLACE(Kg,",",".")          AS NUMERIC) AS Kg,
    -- Active,
    -- Projet
    -- ,
    CAST(REPLACE(ReceptionUnitaire,",",".")          AS NUMERIC) AS Cout_Reception,
    CAST(REPLACE(Swap,",",".")                       AS NUMERIC) AS Cout_Swap,
    CAST(REPLACE(StockageUnitaireParSemaine,",",".") AS NUMERIC) AS Cout_StockHebdo,
    CAST(REPLACE(Expedition,",",".")                 AS NUMERIC) AS Cout_Expedition,
    CAST(REPLACE(Transfert,",",".")                  AS NUMERIC) AS Cout_Transfert,
    CAST(REPLACE(SortieManuelle,",",".")             AS NUMERIC) AS Cout_SortieManuelle
    
FROM    Catalogue
    ,
        Tarif
WHERE   Catalogue.Categorie=Tarif.Cat

-- ORDER BY
    -- Projet,Ref
/* V_ValCatalogue(Reference,Famille,Categorie,Kg,Cout_Reception,Cout_Swap,Cout_StockHebdo,Cout_Expedition,Cout_Transfert,Cout_SortieManuelle) */;
CREATE VIEW V_Catalogue AS
SELECT
    Ref AS Reference,

    SUBSTR(Ref,1,3) AS BU,
    SUBSTR(Ref,4,1) AS SurFamille,
    SUBSTR(Ref,5,1) AS SousFamille,
    SUBSTR(Ref,6,1) AS Etat,
    SUBSTR(Ref,7,1) AS Stock,
    SUBSTR(Ref,8)   AS Produit,
    SUBSTR(Ref,4,2) AS Famille,

    Categorie,
    Active,
    CAST(REPLACE(Kg,",",".")          AS NUMERIC) AS Kg,
    Projet,
    Designation
    -- ,
    -- CAST(REPLACE(ReceptionUnitaire,",",".")          AS NUMERIC) AS Cout_Reception,
    -- CAST(REPLACE(Swap,",",".")                       AS NUMERIC) AS Cout_Swap,
    -- CAST(REPLACE(StockageUnitaireParSemaine,",",".") AS NUMERIC) AS Cout_StockHebdo,
    -- CAST(REPLACE(Expedition,",",".")                 AS NUMERIC) AS Cout_Expedition,
    -- CAST(REPLACE(Transfert,",",".")                  AS NUMERIC) AS Cout_Transfert,
    -- CAST(REPLACE(SortieManuelle,",",".")             AS NUMERIC) AS Cout_SortieManuelle
    
FROM    Catalogue
    -- ,
        -- Tarif
-- WHERE   Catalogue.Categorie=Tarif.Cat

ORDER BY
    Projet,Ref
/* V_Catalogue(Reference,BU,SurFamille,SousFamille,Etat,Stock,Produit,Famille,Categorie,Active,Kg,Projet,Designation) */;
CREATE VIEW v_cataloguesrefchrsansmmvt as
SELECT
    substr(fichier,14,4) || "-" || substr(fichier,18,2) || "-" || substr(fichier,20,2) as apparition,
    ref,
    projet
    FROM cataloguesrefchrsansmmvt
    GROUP BY apparition,ref,projet
/* v_cataloguesrefchrsansmmvt(apparition,Ref,projet) */;
CREATE VIEW vv_SuiviMvt_1mois AS
    SELECT  * 
    FROM    v_SuiviMvt
    WHERE   DateMvt >= DATE("now","-1 month") 
    OR      DateMvt="N/A"
    ORDER BY DateMvt DESC,DateSurv DESC
/* vv_SuiviMvt_1mois(Qte,Donnee,Valeur,DateMvt,DateSurv,Reference,Designation,NumSerie,Stock,Transport,Societe,TagIS,Motif) */;
CREATE VIEW vv_SuiviMvt_1jour AS
    WITH STORAGE AS ( -- Détermination de la date à partir de laquelle on recherche les mouvements
        -- Le SELECT CASE en commentaire produit les données du dernier jour ouvrable écoulé compte tenu du fait que les données sont disponibles à 19h
        -- SELECT CASE
            -- WHEN (strftime("%w",date("now")) >="1" AND strftime("%w",date("now")) <"6" AND strftime("%H",datetime("now","localtime") >= "19")) THEN date("now")           -- lundi à vendredi après 19h => jour même
            -- WHEN (strftime("%w",date("now")) >="2" AND strftime("%w",date("now")) <"6" AND strftime("%H",datetime("now","localtime") <  "19")) THEN date("now","-1 day")  -- mardi à vendredi avant 19h => la veille
            -- WHEN (strftime("%w",date("now")) = "1" AND strftime("%H",datetime("now","localtime") <  "19")) THEN date("now","-3 days")      -- lundi avant 19h => 3 jours avant
            -- ELSE date("now","-" || (strftime("%w",date("now"))/6)-2 || "days")      --  samedi ou dimanche quelle que soit l'heure => vendredi précédent
        -- END querydate
        
        -- Le SELECT ci-dessous produit les donnés les plus récentes que l'on a
        SELECT max(datevu) AS querydate FROM suivimvt
        -- La préférence entre les deux, outre la simplicité, tient au fait que le cas le plus compliqué ne donne rien s'il n'y a rien ce jour précis alors que le plus simple donne toujiurs quelque chose*
    )
    SELECT  Valeur,printf("%3d",Qte) AS Qté,Substr(Reference,1,10) AS Référence,substr(Designation,1,40) AS Désignation,substr(Stock,instr(stock," ")+1) AS Stock,
        CASE
            WHEN Donnee="Dossier" THEN Transport
            ELSE Societe
        END Information
    ,
    Motif
    FROM    v_SuiviMvt,storage
    WHERE   DateMvt >= QueryDate AND DateMvt LIKE "____-__-__"
    ORDER BY DateMvt DESC,DateSurv DESC
/* vv_SuiviMvt_1jour(Valeur,"Qté","Référence","Désignation",Stock,Information,Motif) */;
CREATE VIEW V_DossierValide AS
-- Vérifie si la valeur du champ GLPI dans un enregistrement de déstockage correspond à un numéro de dossier valide ou pas
-- -- C'est une information essentielle pour déterminer le type de sortie, utilisée en aval par la vue vv_Sorties
-- En profite pour produire également les informations utiles à vv_Sorties sans avoir à réinterroger la base SORTIES soit :
-- -- Informations sur le destinataires (servent à trancher pour déterminer certains types de sortie)
-- -- Eclatement de la référence en chacun de ses composants et Conversion de la date de sortie au format standard
-- -- Informations de suivi et croisement tels que tagis et numero d'ofl
-- S'appuie sur la table SORTIES uniquement
-- Historique
-- -- 10:46 24/09/2020 Ecriture dans la forme actuelle
-- -- 11:11 24/09/2020 privilégie l'information d'appartenance plutôt que la référence pour déterminer la BU afin de l'afficher correctement dans le cas des références génériques
-- -- -- sans cela IMPRIMANTE donnait IMP au lieu de la bonne BU
-- -- 19:25 15/10/2020 rajout du numéro de série

SELECT
    CASE
        WHEN glpi LIKE "IM_______" THEN substr(glpi,3,7) -- Ancien incident SM7
        WHEN glpi LIKE "RM______-___" THEN substr(glpi,3,6) || substr(glpi,10,3) -- Ancienne demande SM7
        WHEN glpi LIKE "RM_____-___" THEN substr(glpi,3,6) || substr(glpi,10,3) -- Ancienne demande SM7 avec oubli du zéro initial
        -- WHEN length(glpi)<9 THEN 0  -- Référence numérique qui ne peut pas être un numéro de dossier -- activer cette clause invalide les dossiers mal saisis
        ELSE CAST(substr(glpi,1,10) as integer)
    END Dossier
    -- permet de considérer comme valides les cas où le numéro de dossier est complété par une mention textuelle

,   glpi,priorite,provenance,reference,societe,cp,ville,tagis,numeroofl,numserie

,   CASE
        WHEN "Date BL"="" THEN date(substr(datecreation,7,4) || "-" || substr(datecreation,4,2) || "-" || substr(datecreation,1,2))
        ELSE date(substr("Date BL",7,4) || "-" || substr("Date BL",4,2) || "-" || substr("Date BL",1,2))
        -- Si la date d'expéditon est absente, on remplace par celle de création (cas rare mais présent dans des enregistrements anciens
    END DateBL
    -- Eclatement de la référence en chacun de ses composants
,   CASE -- Détermination de la BU
        WHEN BU LIKE "CHR%" THEN "CHR"
        WHEN BU LIKE "COL%" THEN "CLP"
        WHEN BU LIKE "TEL%" THEN "ALT"
        ELSE substr(reference,1,3)
    END BU
-- ,       substr(reference,1,3) AS BU
,       substr(reference,4,1) AS "SurFamille"
,       substr(reference,5,1) AS "Sousfamille"
,       substr(reference,4,2) AS "Famille"
,       substr(reference,6,1) AS "Etat"
,       substr(reference,7,1) AS "Stock"
,       substr(reference,8,3) AS "Produit"
FROM sorties
/* V_DossierValide(Dossier,GLPI,Priorite,Provenance,Reference,Societe,CP,Ville,Tagis,NumeroOfl,NumSerie,DateBL,BU,SurFamille,Sousfamille,Famille,Etat,Stock,Produit) */;
CREATE VIEW vv_Sorties AS
-- Synthèse des informations significatives sur les infos de stock :
-- -- Eclatement de la référence en chacun de ses composants
-- -- Conversion de la date de sortie au format standard
-- -- Calcul du type de sortie parmi les possibilités suivantes :
-- -- -- INC Incident
-- -- -- DEM Demande
-- -- -- RMA Envoi en maintenance
-- -- -- DEL Mise en destruction
-- -- -- ATL Traitement atelier
-- -- -- IND Cause indéterminée (ne devrait jamais se produire)
-- S'appuie sur :
-- -- Table SORTIES
-- -- Vue   V_DossierValide
-- Historique
-- -- 10:46 24/09/2020 Ecriture dans la forme actuelle
-- -- 19:28 15/10/2020 Rajout du numéro de série

SELECT glpi, datebl
,   CASE -- Détermination du type de sortie
        -- cas indépendants de la manière dont est formé le numéro de dossier
        WHEN Provenance NOT LIKE "%DE%TR%" AND Provenance LIKE "_E%"   THEN "DEM" -- Demande à faible priorite
        WHEN Provenance     LIKE "%DE%TR%" OR  Provenance LIKE "%P_L%" THEN "DEL" -- Mise en destruction, matche aussi bien "DEsTRuction" que "DETRuire"
        WHEN glpi       NOT LIKE "%DE%TR%" AND glpi       LIKE "_E%"   THEN "DEM" -- Demande à faible priorite
        WHEN glpi           LIKE "%DE%TR%" OR  glpi       LIKE "%P_L%" THEN "DEL" -- Mise en destruction

        -- cas historique des anciens dossiers SM7
        WHEN glpi LIKE "IM_______"    THEN "INC"
        WHEN glpi LIKE "RM%-___" THEN "DEM"

        -- cas où l'on a un dossier valide
        WHEN Dossier > 0 AND Priorite="P2" AND (Provenance     IN ("SWAP","") OR  Provenance =  Dossier) THEN "INC" -- swap normal
        WHEN Dossier > 0 AND Priorite="P2" AND (Provenance NOT IN ("SWAP","") AND Provenance <> Dossier) THEN "DEM" -- demande à haute priorite

        WHEN Dossier > 0 AND Provenance="" AND CP     IN ("94043","77600","91019","94360","69750") THEN "RMA" -- Envoi vers un des mainteneurs habituels
        WHEN Dossier > 0 AND Priorite="P5" AND CP     IN ("94043","77600","91019","94360","69750") THEN "RMA" -- Envoi vers un des mainteneurs habituels
        WHEN Dossier > 0 AND Provenance LIKE "%NAV%"  THEN "RMA" -- Envoi vers un des mainteneurs habituels

        WHEN Dossier > 0 AND Priorite IN ("P3","P4") AND Provenance =  "SWAP" THEN "INC" -- Incident mal référencé
        WHEN Dossier > 0 AND Priorite IN ("P3","P4") AND Provenance <> "SWAP" THEN "DEM" -- Demande normale

        WHEN Dossier > 0 AND Priorite="" AND Provenance LIKE "%S%W%P" THEN "INC" -- Incident mal référencé
        WHEN Dossier > 0 AND Priorite="" AND CP="92390" THEN "ATL" -- Reste chez I&S pour un traitement en atelier

        WHEN Dossier > 0 AND Priorite="" AND Provenance="" THEN "DEM"

        WHEN Dossier = 0 AND CP="92390" THEN "ATL" -- Reste chez I&S pour un traitement en atelier
        WHEN Dossier = 0 AND Provenance LIKE "MMO %" AND glpi = Provenance THEN "ATL" -- Transfert à l'ancien atelier Telintrans de Tours
        WHEN Dossier = 0 AND Provenance LIKE "%DISPO%" THEN "ATL" -- Reste chez I&S pour un traitement en atelier
        WHEN Dossier = 0 AND Societe LIKE "%INTEG%" THEN "ATL" -- Reste chez I&S pour un traitement en atelier
        WHEN Dossier = 0 AND Provenance LIKE "%PROJ%" THEN "DEM" -- Traîtement particulier pour un projet
        WHEN Dossier = 0 AND CP="79140" AND Priorite NOT IN ("P2","P3","P4") THEN "DEL" -- Envoi en destruction
        WHEN Dossier = 0 AND CP     IN ("94043","77600","91019","94360","69750") THEN "RMA" -- Envoi vers un des mainteneurs habituels
        WHEN Dossier = 0 AND CP NOT IN ("94043","77600","91019","94360","69750") AND Provenance LIKE "%RMA%" THEN "RMA" -- Envoi vers un autre mainteneur
        WHEN Dossier = 0 AND Provenance LIKE "%DEM%" THEN "DEM"   -- Demande zarbi
        WHEN Dossier = 0 AND Reference LIKE "%DIVERS%" THEN "DEM"   -- Demande zarbi
        WHEN Dossier = 0 AND (glpi LIKE "Dossier%" OR GLPI LIKE "%MAIL%") THEN "DEM"   -- Demande zarbi
        WHEN Provenance LIKE "Dossier%" OR Provenance LIKE "%MA%" THEN "DEM"   -- Demande zarbi


        ELSE "IND"  -- Pour INDéterminé
    END TypeSortie
,   famille,reference,bu,surfamille,sousfamille,etat,stock,produit
,   tagis,numeroofl,numserie
,   cp,ville,societe
FROM V_DossierValide
/* vv_Sorties(GLPI,DateBL,TypeSortie,Famille,Reference,BU,SurFamille,Sousfamille,Etat,Stock,Produit,Tagis,NumeroOfl,NumSerie,CP,Ville,Societe) */;
CREATE VIEW vg_sorties as SELECT * FROM g_sorties
-- Contournement du problème d'import via un trigger instead of insert sur une table homologue à la vue
/* vg_sorties(GLPI,Priorite,Provenance,DateCreation,CentreCout,Reference,Description,"Date BL",BU,sDepot,NumSerie,NomClient,Adr1,Adr2,Adr3,CP,Dep,Ville,Tagis,Societe,NumeroOfl,Pays,Vide,DateBL,DateEntree) */
/* vg_sorties(GLPI,Priorite,Provenance,DateCreation,CentreCout,Reference,Description,"Date BL",BU,sDepot,NumSerie,NomClient,Adr1,Adr2,Adr3,CP,Dep,Ville,Tagis,Societe,NumeroOfl,Pays,Vide,DateBL,DateEntree) */;
CREATE TRIGGER tg_sorties
INSTEAD OF INSERT ON vg_sorties
-- l'utilisation de ce trigger procure toujours l'affichage d'erreurs parce qu'on importe moins de champs que ce qu'il y a dans la vue mais c'est justement corrigé par le trigger
-- is_out_dernier.csv:1362: expected 25 columns but found 22 - filling the rest WITH NULL
-- le champ "vide" est affecté de sa valeur par défaut (ici : "") et les champs générés sont affectés de leur valeur calculée
BEGIN
    INSERT OR REPLACE INTO g_sorties(
  "GLPI",
  "Priorite",
  "Provenance",
  "DateCreation",
  "CentreCout",
  "Reference",
  "Description",
  "Date BL",
  "BU",
  "sDepot",
  "NumSerie",
  "NomClient",
  "Adr1",
  "Adr2",
  "Adr3",
  "CP",
  "Dep",
  "Ville",
  "Tagis",
  "Societe",
  "NumeroOfl",
  "Pays"
)
values (
  new."GLPI",
  new."Priorite",
  new."Provenance",
  new."DateCreation",
  new."CentreCout",
  new."Reference",
  new."Description",
  new."Date BL",
  new."BU",
  new."sDepot",
  new."NumSerie",
  new."NomClient",
  new."Adr1",
  new."Adr2",
  new."Adr3",
  new."CP",
  new."Dep",
  new."Ville",
  new."Tagis",
  new."Societe",
  new."NumeroOfl",
  new."Pays"
);
END;
CREATE VIRTUAL TABLE posts 
USING FTS5(title, body)
/* posts(title,body) */;
CREATE VIEW v_CreationDossier AS
-- CREATE VIEW v_CreationDossier AS
SELECT 
    "Dossier à créer le " || date(migration,"-7 days") as Creation
    -- ,"Entité                : Entité racine > LA POSTE > BSCC Colissimo"
    ,"Client                : ACP > " || SITE
    ,"Catégorie             : Demande de matériel > Matériel réseau et serveur > Demande d'installation serveur agence"
    ,"Attribué à            : I&S_DEPART"
    ,"Appelant / Demandeur  : COUGOULAT PATRICE"
    ,"Contact               : " || NOM
    ,"Titre                 : DEPLOIEMENT Postes Maîtres Colissimo Linux de " || SITE
    ,"Description           :"
    ,"Depuis le stock COLIPOSTE FIL DE L'EAU préparer"
    ,"2 CLPMETL POSTE MAITRE COLISSIMO LINUX"
    ,"selon la nouvelle procédure [SOP_PRC_COL Production de poste maitre.docx] disponible sur le serveur I&S (WIGNV1) dans Coliposte\Poste Maitre Linux\ "
    ,"CODE Colissimo : " || CodeColissimo
    ,"Nom des postes : PM-" || CodeColissimo || "-1 et PM-" || CodeColissimo || "-2"
    ,"En cas de problème avec les fichiers de configuration notifier le dossier à N2_SYSTEME"
    ,""
    ,"/!\ Attention le poste doit être sur site au plus tard en début de matinée du " || CASE 
        WHEN strftime("%w",migration) <= "2" THEN strftime("%d/%m/%Y",date("migration","-4 days"))
        ELSE strftime("%d/%m/%Y",date("migration","-1 day"))
    END Envoi
    ,"Coordonnées d'expédition :"
    ,"COLISSIMO " || SITE as site
    ,"attn : " || trim(NOM)
    ,ADR1
    ,ADR2
    -- ,ADR3
    ,CPV
    ,"",""

FROM deplpmlxcol,suivideploiements 
WHERE codesite=CodeColissimo AND CodeProjet="PMCOLLX" AND dossier=0

GROUP BY CodeColissimo
having creation <= "Dossier à créer le " || date("now")
order by migration asc
/* v_CreationDossier(Creation,"""Client                : ACP > "" || SITE","""Catégorie             : Demande de matériel > Matériel réseau et serveur > Demande d'installation serveur agence""","""Attribué à            : I&S_DEPART""","""Appelant / Demandeur  : COUGOULAT PATRICE""","""Contact               : "" || NOM","""Titre                 : DEPLOIEMENT Postes Maîtres Colissimo Linux de "" || SITE","""Description           :""","""Depuis le stock COLIPOSTE FIL DE L'EAU préparer""","""2 CLPMETL POSTE MAITRE COLISSIMO LINUX""","""selon la nouvelle procédure [SOP_PRC_COL Production de poste maitre.docx] disponible sur le serveur I&S (WIGNV1) dans Coliposte\Poste Maitre Linux\ ""","""CODE Colissimo : "" || CodeColissimo","""Nom des postes : PM-"" || CodeColissimo || ""-1 et PM-"" || CodeColissimo || ""-2""","""En cas de problème avec les fichiers de configuration notifier le dossier à N2_SYSTEME""","""""",Envoi,"""Coordonnées d'expédition :""",site,"""attn : "" || trim(NOM)",ADR1,ADR2,CPV,""""":1",""""":2") */;
CREATE VIEW V_audit AS
SELECT 
Tagis,Reference,
SUBSTR(Reference,1,3) AS BU
,
SUBSTR(Reference,4,2) AS Famille,
SUBSTR(Reference,6,1) AS Etat,
SUBSTR(Reference,7,1) AS Stock,
SUBSTR(Reference,8,3) AS Produit
,
SUBSTR(Dateentree,7,4) || "-" || SUBSTR(Dateentree,4,2) || "-" || SUBSTR(Dateentree,1,2) || SUBSTR(Dateentree,11,9) AS DateTimeEntree
FROM Entrees
/* V_audit(TagIS,Reference,BU,Famille,Etat,Stock,Produit,DateTimeEntree) */;
CREATE VIEW vv_Entrees AS
SELECT
TagIS,Reference,DateEntree,
CASE
WHEN BU IN ("CHR","CLP","ALT") THEN ""
ELSE Reference
END RefProvisoire,
CASE
WHEN BU IN ("CHR","CLP","ALT") THEN Reference
ELSE ""
END RefDefinitive,
CASE
WHEN BU IN ("CHR","CLP","ALT") THEN ""
ELSE DateEntree
END DateReception,
CASE
WHEN BU IN ("CHR","CLP","ALT") THEN DateEntree
ELSE ""
END DateAudit
FROM v_entrees
/* vv_Entrees(TagIS,Reference,DateEntree,RefProvisoire,RefDefinitive,DateReception,DateAudit) */;
CREATE VIEW vvv_Entrees AS
SELECT
TagIS,Reference,DateEntree,
MAX(Refprovisoire) AS Refprovisoire,
MAX(RefDefinitive) AS RefDefinitive,
MAX(DateReception) AS DateReception,
MAX(DateAudit)   AS DateAudit
FROM vv_Entrees
GROUP BY TagIS
/* vvv_Entrees(TagIS,Reference,DateEntree,Refprovisoire,RefDefinitive,DateReception,DateAudit) */;
CREATE VIEW vv_Suivi_Sorties_1mois AS
    SELECT               GLPI
                       , DateBL 
                       , Societe
                       , Qte
                       , Reference
                       , Designation
                       , NumSerie
                       , Transport
                       , TagIS
                       , NumeroOFL 

    FROM     v_Suivi_Sorties
    WHERE    Datebl >= DATE("now","-1 month") 
    ORDER BY Datebl DESC,GLPI DESC
/* vv_Suivi_Sorties_1mois(GLPI,DateBL,Societe,Qte,Reference,Designation,NumSerie,Transport,TagIS,NumeroOFL) */;
CREATE VIEW v_CumulCoutStockage AS
-- 17:08 14/12/2020 classe les articles selon ce qu'ils ont côuté depuis leur entrée en stock
SELECT DISTINCT
    length(
            (
                strftime("%s",date("now")) -- conversion en secondes linux pour pouvoir manipuler les chiffres
                    - -- différence en secondes
                strftime("%s",date("20" || substr(tagis,3,2) || "-" || substr(tagis,5,2) || "-" || substr(tagis,7,2)))
                -- conversion du tagis en date
                -- préféré au champ "DateEntree" qui contient la date de dernier mouvement de l'article alors que le tag se réfère à la date d'entrée initiale
            )/3600/24 -- donne le nombre de jours
          )                     AS Classe, -- nombre de caractères d'un nombre = log décimal => classifié selon cette valeur
    nom_projet                  AS Stock,
    printf("%4d",count(tagis))  AS Qte,
    stock.ref                   AS Reference,
    stock.designation           AS Designation,
-- StockageUnitaireParSemaine as CoutSem, -- affiché pour tests et vérifications seulement
    date(
        avg(
                strftime("%s",date("20" || substr(tagis,3,2) || "-" || substr(tagis,5,2) || "-" || substr(tagis,7,2)))
           ) -- date moyenne d'entrée en stock
     ,"unixepoch" -- conversion du format de secondes linux vers aaaa-mm-jj
        )                       AS Entree,
    printf("%4d",cast(
        avg( -- nombre moyen de semaines de présence en stock
            round( -- convertit le réen en entier
                    (
                        strftime("%s",date("now"))
                        -
                        strftime("%s",date("20" || substr(tagis,3,2) || "-" || substr(tagis,5,2) || "-" || substr(tagis,7,2)))
                    )/3600/24/7.0 -- divisé par 7 pour avoir le nb de semaines, avec un point décimal pour avoir un résultat à virgule
               ,0)  -- arrondi à un nombre entier de semaines
            ) -- la moyenne doit être calculée sur des entiers, mais ne donne pas un entier
            as integer
        )
    )                           AS NbSem , -- nombre moyen de semaines de présence en stock
    printf("%8.2f E",   round(sum(replace(StockageUnitaireParSemaine,",",".")
                    *
                        round((
                            strftime("%s",date("now"))
                        -
                            strftime("%s",date("20" || substr(tagis,3,2) || "-" || substr(tagis,5,2) || "-" || substr(tagis,7,2)))
                              )/3600/24/7.0 ,0
                             )
                         ),2
                     )
         )                      AS Cout     -- NbSem * StockageUnitaireParSemaine arrondi au plus proche
FROM  stock,catalogue,tarif
WHERE stock.nom_projet=catalogue.projet
  AND stock.ref=catalogue.ref   -- chaque couple (stock,reference) appartient à une catégorie
  AND categorie=cat             -- chaque catégorie est affectée à un coût de stockage
-- AND nom_projet LIKE "%HUB%"  -- pour vérifications
-- AND stock.ref="CLP92NP012"   -- pour vérifications
GROUP BY nom_projet,stock.ref
ORDER BY
-- classe desc,
     Cout desc
    ,NbSem desc
-- limit 8
/* v_CumulCoutStockage(Classe,Stock,Qte,Reference,Designation,Entree,NbSem,Cout) */;
CREATE VIEW vv_CoutStockage_Detail AS 
SELECT
    length(JoursStock)      AS Classe,
    count(TagIS)            AS Qte,
    Stock,Reference,Designation,
    cast(round(JoursStock/7.0,0) as integer) AS NbSem,
    round(round(JoursStock/7.0,0) * CoutHebdo,2) AS CoutCumul,
    date(strftime("%s",date("now")) - avg(JoursStock) * 3600 * 24 , "unixepoch") as EntreeMoyenne
    
FROM v_DureeStockage
-- WHERE reference ="CHR22RSZYQ"
GROUP BY    stock,reference,nbsem
order by    stock,reference,nbsem desc
-- limit 10
/* vv_CoutStockage_Detail(Classe,Qte,Stock,Reference,Designation,NbSem,CoutCumul,EntreeMoyenne) */;
CREATE VIEW v_Stat_EtatStock AS
SELECT     DateStock,
    sum(case when     Code="OK"     then     QTetat ELSE 0 END) as qOK,
    sum(case when     Code="ADA"    then     QTetat ELSE 0 END) as qADA,
    sum(case when     Code="Audit"  then     QTetat ELSE 0 END) as qAudit,
    sum(case when     Code="HS"     then     QTetat ELSE 0 END) as qHS,
    sum(case when     Code="Neuf"   then     QTetat ELSE 0 END) as qNeuf,
    sum(case when     Code="Divers" then     QTetat ELSE 0 END) as qDiv
FROM v_p_Stock
-- WHERE DATESTOCK LIKE  "2020-12-1%"
GROUP BY DateStock
/* v_Stat_EtatStock(DateStock,qOK,qADA,qAudit,qHS,qNeuf,qDiv) */;
CREATE VIEW vv_Stat_EtatStock AS
SELECT DateStock,qADA,qAudit,qHS,qDiv,qNeuf,qOK, (qOK+0.0)/(qADA+qAudit+qHS+qDiv+qNeuf+qOK) as RatioOK
FROM v_Stat_EtatStock
/* vv_Stat_EtatStock(DateStock,qADA,qAudit,qHS,qDiv,qNeuf,qOK,RatioOK) */;
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
/* vvv_Stat_EtatStock(DateStock,ADA,Audit,HS,Divers,Neuf,OK,RatioOK) */;
CREATE VIEW v_SynchroTables AS
-- 21:16 16/12/2020 compare les dates de dernière mises à jour des tables horodatées
-- 12:15 19/12/2020 prend en compte la date de dernière archive de stock
-- 23:54 19/12/2020 prend en compte la date de dernière archive de catalogue
WITH
a as (
SELECT max(datebl) AS LastBL FROM v_sorties
)
,
b as (
SELECT max(Date_Expedition) AS LastExped FROM v_oflx
)
    ,
c as (
SELECT date(max(DateEntree)) AS LastRecep FROM v_entrees
)
    ,
d as (
SELECT max(InDate) AS LastStock FROM v_stock
)
    ,
e as (
SELECT max(DateImport) AS LastTEexport FROM HistoStock
)
    ,
f as (
SELECT max(DateExport) AS LastStockArchive FROM StockArchive
)
    ,
g as (
SELECT max(DateExport) AS LastCatArchive FROM CatArchive
)
    SELECT
        LastBL ||
        CASE
            WHEN LastBL = max(LastBL, LastExped,LastRecep,LastStock,LastTEexport,LastStockArchive,LastCatArchive) THEN " OK"
            ELSE " KO"
        END Sorties,
        LastRecep ||
        CASE
            WHEN LastRecep = max(LastBL, LastExped,LastRecep,LastStock,LastTEexport,LastStockArchive,LastCatArchive) THEN " OK"
            ELSE " KO"
        END Entrees,
        LastStock ||
        CASE
            WHEN LastStock = max(LastBL, LastExped,LastRecep,LastStock,LastTEexport,LastStockArchive,LastCatArchive) THEN " OK"
            ELSE " KO"
        END Stock,
        LastStockArchive ||
        CASE
            WHEN LastStockArchive = max(LastBL, LastExped,LastRecep,LastStock,LastTEexport,LastStockArchive,LastCatArchive) THEN " OK"
            ELSE " KO"
        END StockArchive,
        LastCatArchive ||
        CASE
            WHEN LastCatArchive = max(LastBL, LastExped,LastRecep,LastStock,LastTEexport,LastStockArchive,LastCatArchive) THEN " OK"
            ELSE " KO"
        END CatArchive,
        LastTEexport ||
        CASE
            WHEN LastTEexport = max(LastBL, LastExped,LastRecep,LastStock,LastTEexport,LastStockArchive,LastCatArchive) THEN " OK"
            ELSE " KO"
        END TEexport,
        LastExped ||
        CASE
            WHEN LastExped = max(LastBL, LastExped,LastRecep,LastStock,LastTEexport,LastStockArchive,LastCatArchive) THEN " OK"
            ELSE " KO"
        END OFLX
    FROM a,b,c,d,e,f,g;
CREATE VIEW v_NouvRef AS
WITH storage as (SELECT max(dateexport) as datemaj FROM catarchive) SELECT projet,ref,designation,categorie,kg FROM catalogue WHERE ref not in (SELECT ref FROM catarchive,storage WHERE dateexport < datemaj)
/* v_NouvRef(Projet,Ref,Designation,Categorie,Kg) */;
CREATE TRIGGER T_kg_catalogue
    AFTER INSERT ON catalogue
WHEN new.kg LIKE "%,%"
BEGIN
   UPDATE catalogue
   SET kg=REPLACE(NEW.Kg,",",".")
   WHERE kg LIKE "_,_"
   ;
END;
CREATE VIEW vv_SemStockage as SELECT *, printf("%4d",round(joursstock/7.0,0)) as SemStock FROM v_dureestockage
/* vv_SemStockage(Stock,TagIs,Reference,Designation,CoutHebdo,JoursStock,SemStock) */;
CREATE VIEW vvv_CoutStockageUnitaire AS SELECT *,couthebdo* semstock as coutstockage FROM vv_SemStockage
/* vvv_CoutStockageUnitaire(Stock,TagIs,Reference,Designation,CoutHebdo,JoursStock,SemStock,coutstockage) */;
CREATE VIEW vvvv_DureeStockageProduit AS 
-- 18:40 25/12/2020 réécriture identée et ajout de l'abréviation des noms de stock
SELECT 
    REPLACE(REPLACE(stock,"POST",""),"IE ","I ") AS Stock,
    count(tagis) as nb,reference,
    designation,couthebdo, 
    printf("%4d",round(avg(joursstock),0)) as joursmoy, 
    round(avg(joursstock)/7,0) as semmoy 
FROM vvv_CoutStockageUnitaire 
GROUP BY stock,reference
/* vvvv_DureeStockageProduit(Stock,nb,Reference,Designation,CoutHebdo,joursmoy,semmoy) */;
CREATE VIEW vvvvv_CoutStockageProduit AS
-- 18:46 25/12/2020 suppression de l'abbréviation du nom de stock qui a maintenant lieu dans vvvv_DureeStockageProduit
SELECT
    CASE
        WHEN joursmoy+0 <1 THEN printf("%3d",0)
        ELSE printf("%3d",length(trim(joursmoy)))
    END Classe,
    printf("%5d",nb) as Qte,
    Stock,
    Reference,Designation,
    -- CoutHebdo  as CoutHedoUnit,
    printf("%4d",semmoy) AS NbSem,
    date(strftime("%s",date("now")) - joursmoy*3600*24,"unixepoch") as EntreeMoy,

        printf("%9.2f E",round(couthebdo *  semmoy * nb ,2)) AS CoutCumul
FROM vvvv_DureeStockageProduit
ORDER BY CoutCumul desc,NbSem desc,Stock,reference
/* vvvvv_CoutStockageProduit(Classe,Qte,Stock,Reference,Designation,NbSem,EntreeMoy,CoutCumul) */;
CREATE VIEW v_DureeStockage AS
SELECT
--  18:26 25/12/2020 Suppression de l'abréviation de "post" désormais reportée vers vvv_CoutStockageUnitaire
    -- REPLACE(nom_projet,"POST","")
    nom_projet AS Stock,
    TagIS,
    stock.ref                   AS Reference,
    stock.designation           AS Designation,
    replace(StockageUnitaireParSemaine,",",".") AS CoutHebdo,
    (           strftime("%s",date("now")) -- conversion en secondes linux pour pouvoir manipuler les chiffres
                    - -- différence en secondes
                strftime("%s",date("20" || substr(tagis,3,2) || "-" || substr(tagis,5,2) || "-" || substr(tagis,7,2)))
                -- conversion du tagis en date
                -- préféré au champ "DateEntree" qui contient la date de dernier mouvement de l'article alors que le tag se réfère à la date d'entrée initiale
            )/3600/24 -- donne le nombre de jours
    AS JoursStock
FROM  stock,catalogue,tarif
WHERE stock.nom_projet=catalogue.projet
  AND stock.ref=catalogue.ref   -- chaque couple (stock,reference) appartient à une catégorie
  AND categorie=cat             -- chaque catégorie est affectée à un coût de stockage
GROUP BY Tagis
ORDER BY
    Stock,Reference,Tagis
/* v_DureeStockage(Stock,TagIs,Reference,Designation,CoutHebdo,JoursStock) */;
CREATE VIEW v_stockVSsorties AS
-- CREATION 21:31 25/12/2020    Pour chaque produit présent en stock, nombre d'unités sortis durant l'année écoulée (ou null si aucun)
-- Utilisé par V_Autonomie_Jours
WITH storage as (
    SELECT reference , sdepot ,count(v_sorties.tagis) as QSorties 
    FROM v_sorties,sorties
    WHERE datebl > date("now","-1 year") AND v_sorties.tagis=sorties.tagis GROUP BY sdepot,reference 
)
SELECT ref , nom_projet ,count(tagis) as Qstock,Qsorties 
FROM stock
LEFT JOIN storage 
ON (ref = reference) AND sdepot=nom_projet 
-- WHERE ref LIKE "CHR10_F%"  -- clause pour tests seulement
GROUP BY nom_projet, ref
/* v_stockVSsorties(Ref,Nom_projet,Qstock,QSorties) */;
CREATE VIEW V_Autonomie_Jours AS
-- CREATION 21:07 25/12/2020 Calcule l'autonomie des stocks de la manière suivante :
-- --       Si le produit est sorti durant l'année écoulée, combien de fois la quantité sortie est contenue dans la qté présente en stock, divisée par le nombre de jours dans une année
-- --       Si le produit n'est pas sorti durant l'année écoulée, nombre de jours depuis lesquels ce produit est en stock
-- Utilisé par V_Autonomie_Date
-- MODIF    21:25 25/12/2020 rajoute un tri par durée d'autonomie décroissante
SELECT
    Nom_Projet AS Stock,
    Ref as Reference,
    Qstock,
    CASE
        WHEN QSorties IS NULL THEN 0
        ELSE QSorties
    END Sorties_1_an,
    CASE
        WHEN QSorties IS NULL THEN JoursStock
        ELSE cast(QStock as float)/cast(Qsorties as float)*365.25
    END Autonomie

FROM  v_stockVSsorties,v_DureeStockage
WHERE v_stockVSsorties.Nom_Projet=v_DureeStockage.Stock
  AND v_stockVSsorties.Ref=v_DureeStockage.Reference
GROUP BY Stock,Reference
ORDER BY Autonomie DESC
/* V_Autonomie_Jours(Stock,Reference,Qstock,Sorties_1_an,Autonomie) */;
CREATE VIEW v_Autonomie_Date AS
-- CREATION 21:26 25/12/2020 Calcule l'autonomie des stocks de la manière suivante :
-- --       Si le produit est sorti durant l'année écoulée, date à laquelle le stock serait épuisé s'il était consommé au même rythme sans répappro
-- --       Si le produit n'est pas sorti durant l'année écoulée, date projetée dans l'avenir correspondant à une durée de stockage égale à ce qu'il a enregistré jusqu'à maintenant
SELECT
    date(strftime("%s",date("now"))+Autonomie*3600*24,"unixepoch") AS Fin_Autonomie,
    CASE
        WHEN Autonomie = 0 THEN 0
        ELSE length(printf("%d",round(Autonomie+0.5,0)))
    END Classe,
    REPLACE(REPLACE(Stock,"POST",""),"IE ","I ") AS Stock,
    Reference,
    Designation,
    Qstock,
    Sorties_1_an

FROM V_Autonomie_Jours, Catalogue
WHERE V_Autonomie_Jours.Stock=Catalogue.Projet AND V_Autonomie_Jours.Reference=Catalogue.Ref
ORDER BY Fin_Autonomie DESC
/* v_Autonomie_Date(Fin_Autonomie,Classe,Stock,Reference,Designation,Qstock,Sorties_1_an) */;
CREATE VIEW v_Sorties AS
-- MODIF    16:25 29/12/2020    Modification par rapport à l'ancienne formulation qui double la vitesse d'exécution
SELECT
    "TagIS"
,    date(substr(DateCreation,7,4) || "-" || substr(DateCreation,4,2) || "-" ||  substr(DateCreation,1,2))  AS DateCreation
,    CASE
        WHEN "Date BL" = "" THEN date(substr(DateCreation,7,4) || "-" || substr(DateCreation,4,2) || "-" ||  substr(DateCreation,1,2),"+1 day")
        ELSE date(substr("Date BL",7,4) || "-" || substr("Date BL",4,2) || "-" ||  substr("Date BL",1,2))
    END DateBL
,       substr(reference,1,3) AS BU
,       substr(reference,4,1) AS "SurFamille"
,       substr(reference,5,1) AS "Sousfamille"
,       substr(reference,4,2) AS "Famille"
,       substr(reference,6,1) AS "Etat"
,       substr(reference,7,1) AS "Stock"
,       substr(reference,8,3) AS "Produit"
    FROM Sorties
/* v_Sorties(Tagis,DateCreation,DateBL,BU,SurFamille,Sousfamille,Famille,Etat,Stock,Produit) */;
CREATE VIEW v_VentileNR AS
-- CREATION 10:47 06/01/2021    Reproduit, en plus simple et plus souple, l'ancienne stat sous gawk de ventilation neuf/reconditionné des produits déstockés
-- MODIF    08:51 07/01/2021    Rajoute la mention de la BU, ce qui veut dire qu'il faut filtrer dessus et ne pas l'afficher lors de l'exploitation pour être compatible avec l'ancienne stat
-- BUG      16:06 08/01/2021    Correction de l'oubli de la mention du nom de la BU
SELECT Annee,Produit,sum(neuf) AS Neuf,sum(recond) AS Recond,BU
FROM v_P_VentileNR GROUP BY  Annee, BU,Produit ORDER BY Annee,Produit
/* v_VentileNR(Annee,Produit,Neuf,Recond,BU) */;
CREATE VIEW vv_typesortie AS
SELECT *,
    CASE
        -- cas indépendants de la manière dont est formé le numéro de dossier
        WHEN Provenance NOT LIKE "%DE%TR%" AND Provenance LIKE "_E%"   THEN "DEM" -- Demande à faible priorite
        WHEN Provenance     LIKE "%DE%TR%" OR  Provenance LIKE "%P_L%" THEN "DEL" -- Mise en destruction, matche aussi bien "DEsTRuction" que "DETRuire"
        WHEN glpi       NOT LIKE "%DE%TR%" AND glpi       LIKE "_E%"   THEN "DEM" -- Demande à faible priorite
        WHEN glpi           LIKE "%DE%TR%" OR  glpi       LIKE "%P_L%" THEN "DEL" -- Mise en destruction

        -- cas historique des anciens dossiers SM7
        WHEN glpi LIKE "IM_______"    THEN "INC"
        WHEN glpi LIKE "RM%-___" THEN "DEM"

        -- cas où l'on a un numéro de dossier valide
        WHEN Dossier > 0 AND Priorite="P2" AND (Provenance     IN ("SWAP","") OR  Provenance =  Dossier) THEN "INC" -- swap normal
        WHEN Dossier > 0 AND Priorite="P2" AND (Provenance NOT IN ("SWAP","") AND Provenance <> Dossier) THEN "DEM" -- demande à haute priorite

        WHEN Dossier > 0 AND Provenance="" AND CP     IN ("94043","77600","91019","94360","69750") THEN "RMA" -- Envoi vers un des mainteneurs habituels
        WHEN Dossier > 0 AND Priorite="P5" AND CP     IN ("94043","77600","91019","94360","69750") THEN "RMA" -- Envoi vers un des mainteneurs habituels
        WHEN Dossier > 0 AND Provenance LIKE "%NAV%"  THEN "RMA" -- Envoi vers un des mainteneurs habituels

        WHEN Dossier > 0 AND Priorite IN ("P3","P4") AND Provenance =  "SWAP" THEN "INC" -- Incident mal référencé
        WHEN Dossier > 0 AND Priorite IN ("P3","P4") AND Provenance <> "SWAP" THEN "DEM" -- Demande normale

        WHEN Dossier > 0 AND Priorite="" AND Provenance LIKE "%S%W%P" THEN "INC" -- Incident mal référencé
        WHEN Dossier > 0 AND Priorite="" AND CP="92390" THEN "ATL" -- Reste chez I&S pour un traitement en atelier

        WHEN Dossier > 0 AND Priorite="" AND Provenance="" THEN "DEM"

        WHEN Dossier = 0 AND CP="92390" THEN "ATL" -- Reste chez I&S pour un traitement en atelier
        WHEN Dossier = 0 AND Provenance LIKE "MMO %" AND glpi = Provenance THEN "ATL" -- Transfert à l'ancien atelier Telintrans de Tours
        WHEN Dossier = 0 AND Provenance LIKE "%DISPO%" THEN "ATL" -- Reste chez I&S pour un traitement en atelier
        WHEN Dossier = 0 AND Societe LIKE "%INTEG%" THEN "ATL" -- Reste chez I&S pour un traitement en atelier
        WHEN Dossier = 0 AND Provenance LIKE "%PROJ%" THEN "DEM" -- Traîtement particulier pour un projet
        WHEN Dossier = 0 AND CP="79140" AND Priorite NOT IN ("P2","P3","P4") THEN "DEL" -- Envoi en destruction
        WHEN Dossier = 0 AND CP     IN ("94043","77600","91019","94360","69750") THEN "RMA" -- Envoi vers un des mainteneurs habituels
        WHEN Dossier = 0 AND CP NOT IN ("94043","77600","91019","94360","69750") AND Provenance LIKE "%RMA%" THEN "RMA" -- Envoi vers un autre mainteneur
        WHEN Dossier = 0 AND Provenance LIKE "%DEM%" THEN "DEM"   -- Demande zarbi
        WHEN Dossier = 0 AND Reference LIKE "%DIVERS%" THEN "DEM"   -- Demande zarbi
        WHEN Dossier = 0 AND (glpi LIKE "Dossier%" OR GLPI LIKE "%MAIL%") THEN "DEM"   -- Demande zarbi
        WHEN Provenance LIKE "Dossier%" OR Provenance LIKE "%MA%" THEN "DEM"   -- Demande zarbi


        ELSE "IND"  -- Pour INDéterminé
    END TypeSortie

FROM V_DossierValide
/* vv_typesortie(Dossier,GLPI,Priorite,Provenance,Reference,Societe,CP,Ville,Tagis,NumeroOfl,NumSerie,DateBL,BU,SurFamille,Sousfamille,Famille,Etat,Stock,Produit,TypeSortie) */;
CREATE VIEW v_P_VentileNR AS
-- CREATION 10:47 06/01/2021    vue pivot de la stat VentileNR
-- MODIF    08:48 07/01/2021    rajoute la mention de la BU afin d'être homogène avec l'ancienne version de la stat, sous gawk, qui ne ciblait que CHR
-- BUG      15:28 08/01/2021    Remplace la table statproduits et un test d'égalité (appel à des couples précis de BU/Famille/stock) par la table CodesVentileNR (tests génériques sur des LIKE)
-- BUG      16:06 08/01/2021    Correction de l'oubli de la mention du nom de la BU
-- MODIF    11:00 09/01/2021    Travaille sur la vue des types de sorties afin de ne produire que les sorties "utiles" c'est à dire uniquement incidents et demandes, hors rma, destruction et traitement en atelier
WITH storage AS (
    SELECT strftime("%Y",datebl) AS Annee, BU,
    count(*) AS Qte,nomproduit,etat
    -- ,produit
    -- ,nomproduit
    FROM vv_typesortie,CodesVentileNR
    WHERE 
    -- "datebl" > strftime("%Y",date("now"))  AND -- année en cours pour debug seulement
    vv_typesortie.famille LIKE CodesVentileNR.famille AND
    vv_typesortie.stock LIKE CodesVentileNR.stock AND
    typesortie in ("INC","DEM")
    
    GROUP BY Annee,BU,nomproduit,Etat
    -- ,produit
)
SELECT
    Annee,BU,
    NomProduit as Produit,
    CASE
        WHEN Etat = "N" THEN SUM(Qte)
        ELSE 0
    END Neuf,
    CASE
        WHEN Etat = "R" THEN SUM(Qte)
        ELSE 0
    END Recond
FROM storage
GROUP BY Annee,BU,Produit,Etat
/* v_P_VentileNR(Annee,BU,Produit,Neuf,Recond) */;
CREATE VIEW v_Sorties_Secondes AS
SELECT
    strftime("%Y",DateBL) AS Annee,
    CASE
       WHEN TagIS LIKE "TE__________" THEN
            strftime("%s","20" || substr(tagis,3,2) || "-" || substr(tagis,5,2) || "-" || substr(tagis,7,2)) 
       WHEN TagIS LIKE "SN____________" THEN
            substr(tagis,3,4) || "-" || substr(tagis,7,2) || "-" || substr(tagis,9,2)
        ELSE TagIS
    END sEntree,
    strftime("%s",DateBL) AS sBL,
    Tagis,Etat,Famille,Produit FROM v_sorties
    -- WHERE TagIS NOT LIKE "TE%"
    -- WHERE Produit="012"
-- LIMIT 4
/* v_Sorties_Secondes(Annee,sEntree,sBL,Tagis,Etat,Famille,Produit) */;
CREATE VIEW vv_Sorties_Jours AS
-- SELECT Annee,(sBL-sEntree)/(3600*24) AS NbJour,tagis,etat,famille,produit 
SELECT Annee,(sBL-sEntree)/3600/24.0 AS NbJour,tagis,etat,famille,produit 
FROM v_sorties_secondes
/* vv_Sorties_Jours(Annee,NbJour,Tagis,Etat,Famille,Produit) */;
CREATE VIEW vvv_Sorties_Secondes AS
SELECT
    strftime("%Y",DateBL) AS Annee,
    BU,
    CASE
       WHEN TagIS LIKE "TE__________" THEN
            strftime("%s","20" || substr(tagis,3,2) || "-" || substr(tagis,5,2) || "-" || substr(tagis,7,2)) 
       WHEN TagIS LIKE "SN____________" THEN
            substr(tagis,3,4) || "-" || substr(tagis,7,2) || "-" || substr(tagis,9,2)
        ELSE TagIS
    END sEntree,
    strftime("%s",DateBL) AS sBL,
    Tagis,Etat,Famille,Produit
FROM vv_typesortie
WHERE TypeSortie IN ("INC","DEM")
/* vvv_Sorties_Secondes(Annee,BU,sEntree,sBL,Tagis,Etat,Famille,Produit) */;
CREATE VIEW vvvv_Sorties_Jours AS
SELECT Annee,BU,(sBL-sEntree)/3600/24 AS NbJour
FROM vvv_sorties_secondes
/* vvvv_Sorties_Jours(Annee,BU,NbJour) */;
CREATE VIEW vvvvv_VieStock AS
-- Reproduit sous SQLite et la bdd standart l'ancienne stat générée en ligne de commande via gawk et sqlite sans bdd
-- Attention le mode de calcul n'est pas exactement le même donc les totaux sont légèrement différents
WITH storage AS (
SELECT 
    Annee,
    -- BU,
    CASE
        WHEN NbJour <2  THEN 0
        WHEN NbJour >99999 THEN 5
        ELSE length(NbJour)
    END Classe
FROM vvvv_sorties_Jours 
)
SELECT 
    -- Annee,
    -- BU,
    storage.Classe,LibClasse,count(*) AS Nb,Annee
FROM storage,ClassesDurees
WHERE storage.Classe=ClassesDurees.Classe
    -- AND Annee=(SELECT max(annee) FROM storage)
GROUP BY Annee,
-- Bu,
storage.Classe
-- HAVING Annee=(SELECT max(annee) FROM storage) -- Enormément plus lent que la même chose dans la clause WHERE
/* vvvvv_VieStock(Classe,LibClasse,Nb,Annee) */;
CREATE VIEW v_NbJourStock AS
SELECT BU, (strftime("%s",date("now")) - strftime("%s",InDate))/3600/24 as NbJour,TagIS FROM v_Stock
-- limit 10
/* v_NbJourStock(BU,NbJour,TagIs) */;
CREATE VIEW vv_AgeStock AS
WITH storage AS (
SELECT
    -- BU,
    CASE
        WHEN NbJour <2  THEN 0
        WHEN NbJour >99999 THEN 5
        ELSE length(NbJour)
    END Classe
FROM v_NbJourStock
)
SELECT
    -- BU,
    storage.Classe,LibClasse,count(*) AS Nb --,Annee
FROM storage,ClassesDurees
WHERE storage.Classe=ClassesDurees.Classe
    -- AND Annee=(SELECT max(annee) FROM storage)
GROUP BY 
-- Annee,
-- Bu,
storage.Classe
-- HAVING Annee=(SELECT max(annee) FROM storage) -- Enormément plus lent que la même chose dans la clause WHERE
/* vv_AgeStock(Classe,LibClasse,Nb) */;
CREATE VIEW v_sfpStats AS
WITH storage AS (
    SELECT date(max(dateimport),"start of month","-1 year","-1 month") AS mindate,date(max(dateimport),"start of month","-1 day") AS maxdate,max(dateimport) AS lastdate FROM histostock
)
SELECT  DateStat,Incident,Demande,RMA,DEL,undef,sfpstats.CodeStat,OkDispo,OkReserve,SAV,Maintenance,Destruction,Alivrer,CodeStatBis,sfpstats.Seuil,sfpstats.LibStat 
FROM    sfpstats,storage,sfpliste
WHERE   sfpstats.codestat IN (SELECT codestat FROM sfpstats GROUP BY codestat)
    AND sfpstats.codestat=sfpliste.codestat
    AND sfpliste.active="Oui"
    AND (
        datestat=lastdate 
    OR  datestat BETWEEN storage.mindate AND storage.maxdate
        )
ORDER BY sfpstats.codestat ASC, datestat ASC
/* v_sfpStats(DateStat,Incident,Demande,RMA,DEL,undef,CodeStat,OkDispo,OkReserve,SAV,Maintenance,Destruction,Alivrer,CodeStatBis,Seuil,LibStat) */;
CREATE VIEW vvv_P_Volumetrie_TypeSortie AS
-- 09:43 14/01/2021 vue pivot donnant au jour je jour combien il y a eu de sorties de chaque type
SELECT datebl,typesortie,count(*) as Nb 
FROM vv_typesortie 
-- WHERE datebl > date("now","-1 month") 
GROUP BY datebl,typesortie 
ORDER BY datebl,typesortie
/* vvv_P_Volumetrie_TypeSortie(DateBL,TypeSortie,Nb) */;
CREATE VIEW vvvv_Volumetrie_TypeSortie AS
SELECT DateBL,
    CASE
        WHEN TypeSortie="INC" THEN Nb
        ELSE 0
    END Incidents,
    CASE
        WHEN TypeSortie="DEM" THEN Nb
        ELSE 0
    END Demandes,
    CASE
        WHEN TypeSortie="RMA" THEN Nb
        ELSE 0
    END "Envois en réparation",
    CASE
        WHEN TypeSortie="ATL" THEN Nb
        ELSE 0
    END "Traitement Atelier",
    CASE
        WHEN TypeSortie="DEL" THEN Nb
        ELSE 0
    END "Mises en destruction",
    CASE
        WHEN TypeSortie="IND" THEN Nb
        ELSE 0
    END "Indéterminé"
FROM vvv_P_Volumetrie_TypeSortie
/* vvvv_Volumetrie_TypeSortie(DateBL,Incidents,Demandes,"Envois en réparation","Traitement Atelier","Mises en destruction","Indéterminé") */;
CREATE VIEW vv_SortiesDossiers AS
-- 15:38 14/01/2021 Nombre quotidien de dossiers GLPI ayant donné lieu à une expédition
WITH storage AS (
    SELECT datebl,glpi FROM v_dossiervalide
    WHERE datebl>=date("now","-1 month") 
    AND dossier>0
    GROUP BY datebl,glpi
)
SELECT Datebl,count(*) AS NbDossiers 
FROM storage 
GROUP BY DateBL
/* vv_SortiesDossiers(datebl,NbDossiers) */;
CREATE VIEW vv_SortiesProduits AS
-- 15:39 14/01/2021 Nombre quotidien de produits déstockés, y compris hors glpi,y compris destruction et autres
SELECT datebl,count(*) AS NbProduits 
FROM v_sorties
WHERE datebl>=date("now","-1 month") 
GROUP BY datebl
/* vv_SortiesProduits(DateBL,NbProduits) */;
CREATE VIEW vv_Receptions AS
-- 15:44 14/01/2021 Nombre quotitien de produits réceptionnés, tous types de motif de réception confondus, hors reconditionnements et préparation de matériel
SELECT substr(dateentree,1,10) AS JourEntree,count(*) as Nb
FROM v_entrees 
WHERE TypeEntree NOT IN ("REC","PRP")
GROUP BY jourEntree
/* vv_Receptions(JourEntree,Nb) */;
CREATE VIEW vv_Audit AS
-- 15:44 14/01/2021 Nombre quotitien de produits audités
SELECT substr(dateentree,1,10) AS JourEntree,count(*) as Nb
FROM v_entrees 
WHERE TypeEntree  IN ("REC") -- le type "PRP" (Préparation) ne correspond pas au critère de "reconditionnements"
GROUP BY jourEntree
/* vv_Audit(JourEntree,Nb) */;
CREATE VIEW vvv_receptions_1sem AS
WITH storage as (
    SELECT jourEntree as dateentree FROM vv_receptions WHERE dateentree > date("now","-13 month")
)
SELECT dateentree, sum(nb)/7.0 as NbEntrees 
FROM storage,vv_receptions 
WHERE 
    jourentree between date(dateentree,"-7 days") AND dateentree
GROUP BY dateentree
/* vvv_receptions_1sem(dateentree,NbEntrees) */;
CREATE VIEW vv_SortiesDossiers_1sem AS
WITH storage as (
    SELECT datebl as joursortie FROM v_dossiervalide WHERE joursortie > date("now","-13 month") GROUP BY joursortie
)
SELECT joursortie, count(*)/7.0 as NbSorties
FROM storage,v_dossiervalide 
WHERE 
    dossier > 0 AND
    joursortie between date(datebl,"-7 days") AND datebl
    -- AND dossier > 0
GROUP BY joursortie
/* vv_SortiesDossiers_1sem(joursortie,NbSorties) */;
CREATE VIEW vv_SortiesProduits_1sem AS
WITH storage as (
    SELECT datebl as joursortie FROM v_sorties WHERE joursortie > date("now","-13 month") GROUP BY joursortie
)
SELECT joursortie,count(*)/7.0 AS NbProduits 
FROM storage,v_sorties
WHERE joursortie between date(datebl,"-7 days") AND datebl
GROUP BY joursortie
/* vv_SortiesProduits_1sem(joursortie,NbProduits) */;
CREATE VIEW vvv_audit_1sem AS
WITH storage as (
    SELECT jourEntree as dateentree FROM vv_audit WHERE dateentree > date("now","-13 month")
)
SELECT dateentree, sum(nb)/7.0 as NbAudit
FROM storage,vv_Audit 
WHERE 
    jourentree between date(dateentree,"-7 days") AND dateentree
GROUP BY dateentree
/* vvv_audit_1sem(dateentree,NbAudit) */;
CREATE VIEW v_p_Stock AS
-- 11:47 27/01/2021 pivot donnant l'historique quotidien du nombre d'article dans chacun des états référencés
WITH storage AS (
    SELECT
    -- 11:37 27/01/2021 Catégorise l'historique de l'état en stock selon une nomenclature fixe
        DateExport,
        CASE
            WHEN Etat LIKE "%altu%"         THEN "ADA"      -- Attente Décision Alturing
            WHEN Etat LIKE "%attente"       THEN "Audit"    -- vieux matériel reconditionné et non encore audité
            WHEN Etat LIKE "%paration"      THEN "HS"       -- Réparation
            WHEN Etat LIKE "%maintenance%"  THEN "HS"       -- Maintenance
            WHEN Etat LIKE "%panne%"        THEN "HS"       -- En panne
            WHEN Etat LIKE "%SAV%"          THEN "HS"       -- SAV
            WHEN Etat LIKE "%serv%"         THEN "HS"       -- Réservé (pour quelque raison que ce soit, il n'est ni ok ni en attente de décision)
            WHEN Etat LIKE "%neuf%"         THEN "NEUF"     -- Neuf à traiter
            WHEN Etat LIKE "%OK%"           THEN "OK"       -- OK
            ELSE "DIVERS"                                   -- Sans etat ou destruction ou autre
        END Code
    FROM StockArchive

)
SELECT DateExport AS DateStock,Code,count(*) AS QTetat FROM storage GROUP BY DateExport,Code
/* v_p_Stock(DateStock,Code,QTetat) */;
CREATE VIEW v3_statstock AS
-- 18:56 29/01/2021 pour chaque donnée enregistrée depuis un an modulo début du mois, sort le nombre d'articles dans chacun des statuts monitorés
WITH storage AS (
    -- détermine la valeur maximale qui sera représentée en abscisse et en fait le coeff multiplicateur pour représenter la valeur 100% sur la même échelle
    SELECT
        max(
                max(qADA),
                max(qAudit),
                max(qHS),
                max(qDiv),
                max(qNeuf)
        ) AS Coeff
    FROM vv_Stat_EtatStock
    WHERE datestock >= date("now","-1 year","start of month","-1 day","start of month")
)
SELECT
    DateStock,
    qADA    AS "Attente Décision Alturing",
    qAudit  AS "Attente Audit",
    qHS     AS "Non fonctionnel",
    -- qDiv    AS "Divers",
    -- qNeuf   AS "Neuf à traiter",
    CASE -- ajuste le ratio de manière à le rendre compatible avec l'échelle
        WHEN cast(substr(coeff,2) AS integer) = 0 THEN substr(coeff,1,1) || substr("000000",1,length(coeff)-1) * RatioOK
        ELSE (substr(coeff,1,1)+1)  || substr("000000",1,length(coeff)-1) * RatioOK
    END "Taux de disponibilité",
    CASE -- trace une ligne 100% pour comparaison
        WHEN cast(substr(coeff,2) AS integer) = 0 THEN substr(coeff,1,1) || substr("000000",1,length(coeff)-1)
        ELSE (substr(coeff,1,1)+1)  || substr("000000",1,length(coeff)-1)
    END "100%"
FROM vv_Stat_EtatStock,storage
WHERE DateStock >= date("now","-1 year","start of month","-1 day","start of month")
/* v3_statstock(DateStock,"Attente Décision Alturing","Attente Audit","Non fonctionnel","Taux de disponibilité","100%") */;
CREATE TRIGGER Ti_Stock
-- 13:49 01/02/2021 sauvegarde du stock avant destruction
BEFORE DELETE ON STOCK
    WHEN NOT EXISTS (SELECT * FROM StockBackup WHERE old.TagIs=StockBackup.TagIS)
BEGIN
    INSERT INTO StockBackup(Qte,Nom_projet,Ref,Lib,Designation,Etat,Statut,Numero_de_serie,TagIs,DateEntree,vide)
    VALUES (
        old.Qte,old.Nom_projet,old.Ref,old.Lib,old.Designation,old.Etat,old.Statut,old.Numero_de_serie,old.TagIs,old.DateEntree,old.vide
    );
END;
CREATE TRIGGER Tu_Stock
-- 13:49 01/02/2021 sauvegarde du stock avant destruction
BEFORE DELETE ON STOCK
    WHEN EXISTS (SELECT * FROM StockBackup WHERE old.TagIS=StockBackup.TagIs)
BEGIN
    UPDATE StockBackup set
        Qte=old.Qte,
        Nom_projet=old.Nom_projet,
        Ref=old.Ref,
        Lib=old.Lib,
        Designation=old.Designation,
        Etat=old.Etat,
        Statut=old.Statut,
        Numero_de_serie=old.Numero_de_serie,
        TagIs=old.TagIs,
        DateEntree=old.DateEntree,
        vide=old.vide,
        LastUpdate=CURRENT_TIMESTAMP
    WHERE StockBackup.TagIs=old.TagIS
    ;
END;
CREATE VIEW v_STOCK AS
    WITH storage as (
            --  détermine la plus récente des dates d'entrée en stock afin de calculer le nombre de semaines depuis lequel chaque produit est en stock
            SELECT  "20" ||
            substr(max(TagIs),3,2)
            -- tagis est un meilleur indicateur de date que DateEntree car basé sur le premier mouvement de l'article concerné alors que DateEntree est basé sur le dernier
            -- on fait l'impasse sur les quelques et éventuels tags commençant par SN
                || "-" ||
            substr(max(TagIs),5,2)
                || "-" ||
            substr(max(TagIs),7,2)
            as DateMax
            FROM stock
--            WHERE dateentree -- sous entendu "existe" : afin d'exclure la dernière ligne du fichier, qui ne comporte que le nombre total d'articles
--       ^^   inutile car filtré par le check constraint sur la table stock
    )
    SELECT
        (strftime("%s",datetime(DateMax)) - strftime("%s",date("20" || substr(TagIs,3,2) || "-" || substr(TagIs,5,2) || "-" || substr(TagIs,7,2))))/604800+1 AS NbSem, -- nombre de secondes unix divisé par le nombre de secondes par semaine
        -- StockageUnitaireParSemaine as CoutHebdo,

        date("20" || substr(TagIs,3,2) || "-" || substr(TagIs,5,2) || "-" || substr(TagIs,7,2)) as InDate,
        "20" || substr(TagIs,3,2) as InAnnee,
         substr(TagIs,5,2) as InMois,
         substr(TagIs,7,2) as InJour,
         substr(Nom_projet,1,3) as BU, -- préférer nom_projet plutôt que le début de la référence afin de ne pas être perturbé par les articles génériques n'ayant pas une référence normalisée tels que les baies ou switches
         substr(stock.ref,4,1) as SurFamille, substr(stock.ref,5,1) as Sousfamille, substr(stock.ref,4,2) as Famille,
         substr(stock.ref,6,1) as Etat, substr(stock.ref,7,1) as Stock,
         substr(stock.ref,8,3) as Produit,

        tagis,
        ref,nom_projet

        FROM
             storage
            ,stock
        -- WHERE
            -- tagis LIKE "TE__________"
        -- OR
            -- tagis LIKE "SN__________"
--       ^^   inutile car filtré par le check constraint sur la table stock
        -- group
            -- by tagis -- une même référence pouvant apparaître plusieurs fois dans le catalogue, on s'assure ainsi de ne la voir ressortir qu'une seule fois
        -- ^^ inutile depuis qu'on sort la référence et le projet
order by nbsem desc
        -- limit 10
/* v_STOCK(NbSem,InDate,InAnnee,InMois,InJour,BU,SurFamille,Sousfamille,Famille,Etat,Stock,Produit,TagIs,Ref,Nom_projet) */;
CREATE VIEW v_Stock_Sidetable AS
-- CREATION 07:41 02/02/2021 remplace la table Stock_Sidetable alimentée par l'import du résultat d'une requête exportée précedemment en csv
-- BUG      08:41 02/02/2021 remplace la virgule par un point dans les données numériques
SELECT
    NbSem,
    replace(StockageUnitaireParSemaine,",",".") AS CoutHebdo,
    InDate,InAnnee,InMois,InJour,BU,SurFamille,Sousfamille,v_stock.Famille,Etat,Stock,Produit,TagIs
FROM v_stock,catalogue,tarif
WHERE
    v_stock.ref=catalogue.ref -- lien stock vers catalogue afin d'obtenir la catégorie de tarification
AND v_stock.nom_projet=catalogue.projet
AND
    catalogue.categorie=tarif.cat -- lien catalogue vers tarif afin d'obtenir le coût de stockage hebdo pour la catégorie
-- AND dateentree LIKE "%2018%"
-- limit 10
/* v_Stock_Sidetable(NbSem,CoutHebdo,InDate,InAnnee,InMois,InJour,BU,SurFamille,Sousfamille,Famille,Etat,Stock,Produit,TagIs) */;
CREATE VIEW v2_SA_Mois AS
-- CREATION 15:37 02/02/2021 rajoute la durée de stockage et le coût de stockage hebdomadaire
SELECT
    v_SA_Mois.Ref,TagIs,Indate,DateExport,Mois,BU,SurFamille,SousFamille,Etat,Stock,Produit,
    Nom_projet,
    -- cat,
    CAST((((strftime("%s",DateExport) - strftime("%s","Indate")) / 3600/24/7)+ 0.5) AS INTEGER) AS NbSem,
    replace(StockageUnitaireParSemaine,",",".") AS CoutHebdo
    -- StockageUnitaireParSemaine AS CoutHebdo
FROM v_SA_Mois,Catalogue,Tarif
WHERE 
    -- v_SA_Mois.ref="IMPRIMANTE" AND
    v_SA_Mois.ref=Catalogue.ref
AND v_SA_Mois.Nom_Projet=Catalogue.Projet
AND Catalogue.Categorie=Tarif.Cat
-- LIMIT 10
/* v2_SA_Mois(Ref,TagIs,Indate,DateExport,Mois,BU,SurFamille,SousFamille,Etat,Stock,Produit,Nom_projet,NbSem,CoutHebdo) */;
CREATE VIEW v_SA_Mois AS
-- CREATION 10:05 02/02/2021 produit une trace de la présence en stock par article et par mois sur tout l'historique du stock
-- BUG      16:50 02/02/2021 La sélection de date max était faite sur la date d'entrée (donc inutile car unique) au lieu de la date des données
SELECT ref,
    TagIS,
        CASE
            WHEN TagIS LIKE "TE%" AND length(TagIS)=12 THEN "20" || substr(tagis,3,2) || "-" || substr(tagis,5,2) || "-" || substr(tagis,7,2)
            ELSE substr(tagis,3,4) || "-" || substr(tagis,7,2) || "-" || substr(tagis,9,2)
        END Indate, 
    max(DateExport) AS DateExport,
    strftime("%Y-%m",DateExport) as Mois,
    substr(ref,1,3) AS BU,
    substr(ref,4,1) AS SurFamille,
    substr(ref,5,1) AS SousFamille,
    substr(ref,6,1) AS Etat,
    substr(ref,7,1) AS Stock,
    substr(ref,8,3) AS Produit,
    Nom_Projet    
FROM StockArchive 
-- WHERE Mois LIKE "2021%"
GROUP BY Mois,TagIS 
-- GROUP BY Tagis,Mois
-- LIMIT 10
/* v_SA_Mois(Ref,TagIs,Indate,DateExport,Mois,BU,SurFamille,SousFamille,Etat,Stock,Produit,Nom_projet) */;
CREATE VIEW v_p_CoutStockage AS
SELECT 
    Mois,
    DateExport,
    count(*) AS Qte,
    BU,
    CASE
        WHEN Nom_Projet LIKE "%SHIP%" THEN "Shipping"
        WHEN surFamille NOT BETWEEN "1" AND "9" THEN "Générique"
        ELSE LibFamille 
    END Famille,
    sum(couthebdo) AS CoutHebdo,
    sum(couthebdo*nbsem) AS CoutCumul
FROM v2_SA_Mois,Familles
WHERE 
        surFamille=familles.CodeFamille 
    AND
        sousFamille=familles.CodeType 
    -- AND surfamille="2"
    -- AND BU="CHR"
    -- AND Mois LIKE "2020%"
    GROUP BY Mois, Bu, Famille
    ORDER BY Mois, Bu, Famille
-- limit 20
/* v_p_CoutStockage(Mois,DateExport,Qte,BU,Famille,CoutHebdo,CoutCumul) */;
CREATE VIEW v3_Stat_CoutStock AS
SELECT     
        Mois,
        max(DateExport) as DateStock,
        BU,

    sum(case when ( Famille LIKE "%riph%ique"       OR  
                    Famille LIKE "%Divers%"         OR  
                    Famille LIKE "%Accessoire%")    then    CoutHebdo ELSE 0 END) as Divers,
    sum(case when   Famille LIKE "%cran%"           then    CoutHebdo ELSE 0 END) as Ecrans,
    sum(case when   Famille LIKE "R_seau%"          then    CoutHebdo ELSE 0 END) as Reseau,
    sum(case when   Famille LIKE "%Ship%"           then    CoutHebdo ELSE 0 END) as Shipping,
    sum(case when   Famille LIKE "%pri%t%%"         then    CoutHebdo ELSE 0 END) as Imprimantes,
    sum(case when   Famille LIKE "%PC%"             then    CoutHebdo ELSE 0 END) as PC,
    sum(case when   Famille LIKE "%C_ble%"          then    CoutHebdo ELSE 0 END) as Cables
FROM v_p_CoutStockage
GROUP BY Mois,BU
/* v3_Stat_CoutStock(Mois,DateStock,BU,Divers,Ecrans,Reseau,Shipping,Imprimantes,PC,Cables) */;
CREATE VIEW v4_Stat_CoutStock_13mois AS
SELECT  
        DateStock,
        printf("%7.2f",Divers) AS Divers, 
        printf("%7.2f",Ecrans) AS Ecrans, 
        printf("%7.2f",Reseau) AS Reseau, 
        printf("%7.2f",Shipping) AS Shipping, 
        printf("%7.2f",Imprimantes) AS Imprimantes, 
        printf("%7.2f",PC) AS PC, 
        printf("%7.2f",Cables) AS Cables,
        BU
FROM v3_Stat_CoutStock 
WHERE "Mois" || "-01" >= date("now","-13 month","start of month")
/* v4_Stat_CoutStock_13mois(DateStock,Divers,Ecrans,Reseau,Shipping,Imprimantes,PC,Cables,BU) */;
CREATE VIEW v_SA_Semaine AS
SELECT StockArchive.ref,
    TagIS,
    CASE
        WHEN TagIS LIKE "TE%" AND length(TagIS)=12 THEN "20" || substr(tagis,3,2) || "-" || substr(tagis,5,2) || "-" || substr(tagis,7,2)
        ELSE substr(tagis,3,4) || "-" || substr(tagis,7,2) || "-" || substr(tagis,9,2)
    END Indate, 
    max(DateExport) AS DateExport,
    -- strftime("%Y-%m",DateExport) as Mois,
    -- cast (julianday(date("now")) - julianday(DateExport) as integer) as Jours,
    cast((julianday(date("now")) - julianday(DateExport))/7.0 + 0.5 as integer) as Semaines,
    replace(StockageUnitaireParSemaine,",",".") AS CoutHebdo,
    substr(StockArchive.ref,1,3) AS BU,
    substr(StockArchive.ref,4,1) AS SurFamille,
    substr(StockArchive.ref,5,1) AS SousFamille,
    substr(StockArchive.ref,6,1) AS Etat,
    substr(StockArchive.ref,7,1) AS Stock,
    substr(StockArchive.ref,8,3) AS Produit,
    Nom_Projet    
FROM StockArchive,Catalogue,Tarif
-- WHERE Mois LIKE "2021%"
-- WHERE Produit="18R"
WHERE 
    StockArchive.ref=Catalogue.ref
AND StockArchive.Nom_Projet=Catalogue.Projet
AND Catalogue.Categorie=Tarif.Cat
GROUP BY Semaines,TagIS 
-- LIMIT 30
/* v_SA_Semaine(Ref,TagIs,Indate,DateExport,Semaines,CoutHebdo,BU,SurFamille,SousFamille,Etat,Stock,Produit,Nom_projet) */;
CREATE VIEW v2_p_CoutStockage AS
SELECT 
    Semaines,
    DateExport,
    count(*) AS Qte,
    BU,
    CASE
        WHEN Nom_Projet LIKE "%SHIP%" THEN "Shipping"
        WHEN surFamille NOT BETWEEN "1" AND "9" THEN "Générique"
        ELSE LibFamille 
    END Famille,
    sum(couthebdo) AS CoutHebdo,
    sum(couthebdo*Semaines) AS CoutCumul
FROM v_SA_Semaine,Familles
WHERE 
        surFamille=familles.CodeFamille 
    AND
        sousFamille=familles.CodeType 
    -- AND surfamille="2"
    -- AND BU="CHR"
    -- AND Mois LIKE "2020%"
    GROUP BY Semaines, Bu, Famille
    ORDER BY Semaines DESC, Bu, Famille
-- limit 30
/* v2_p_CoutStockage(Semaines,DateExport,Qte,BU,Famille,CoutHebdo,CoutCumul) */;
CREATE VIEW v3_Stat_CoutStock_Semaine AS
SELECT     
        Semaines,
        max(DateExport) as DateStock,
        BU,

    sum(case when ( Famille LIKE "%riph%ique"       OR  
                    Famille LIKE "%Divers%"         OR  
                    Famille LIKE "%Accessoire%")    then    CoutHebdo ELSE 0 END) as Divers,
    sum(case when   Famille LIKE "%cran%"           then    CoutHebdo ELSE 0 END) as Ecrans,
    sum(case when   Famille LIKE "R_seau%"          then    CoutHebdo ELSE 0 END) as Reseau,
    sum(case when   Famille LIKE "%Ship%"           then    CoutHebdo ELSE 0 END) as Shipping,
    sum(case when   Famille LIKE "%pri%t%%"         then    CoutHebdo ELSE 0 END) as Imprimantes,
    sum(case when   Famille LIKE "%PC%"             then    CoutHebdo ELSE 0 END) as PC,
    sum(case when   Famille LIKE "%C_ble%"          then    CoutHebdo ELSE 0 END) as Cables
FROM v2_p_CoutStockage
GROUP BY Semaines,BU
-- limit 30
/* v3_Stat_CoutStock_Semaine(Semaines,DateStock,BU,Divers,Ecrans,Reseau,Shipping,Imprimantes,PC,Cables) */;
CREATE VIEW v4_Stat_CoutStock_57semaines AS
SELECT  
        DateStock,
        printf("%7.2f",Divers) AS Divers, 
        printf("%7.2f",Ecrans) AS Ecrans, 
        printf("%7.2f",Reseau) AS Reseau, 
        printf("%7.2f",Shipping) AS Shipping, 
        printf("%7.2f",Imprimantes) AS Imprimantes, 
        printf("%7.2f",PC) AS PC, 
        printf("%7.2f",Cables) AS Cables,
        BU
FROM v3_Stat_CoutStock_Semaine 
WHERE Semaines <= 57
/* v4_Stat_CoutStock_57semaines(DateStock,Divers,Ecrans,Reseau,Shipping,Imprimantes,PC,Cables,BU) */;
CREATE VIEW v3_TypeEntree AS
SELECT
    JourEntree,
    sum(case WHEN   TypeEntree = "PRJ"  THEN    Qte ELSE 0 END) AS Projets,
    sum(case WHEN   TypeEntree = "RMA"  THEN    Qte ELSE 0 END) AS RMA,
    sum(case WHEN   TypeEntree = "PRP"  THEN    Qte ELSE 0 END) AS Preparations,
    sum(case WHEN   TypeEntree = "REC"  THEN    Qte ELSE 0 END) AS Reconditionnements,
    sum(case WHEN   TypeEntree = "RET"  THEN    Qte ELSE 0 END) AS Retours,
    sum(case WHEN   TypeEntree = "LIV"  THEN    Qte ELSE 0 END) AS Livraisons,
    sum(case WHEN   TypeEntree = "IND"  THEN    Qte ELSE 0 END) AS Autres
FROM v2_p_TypeEntree
GROUP BY JourEntree
/* v3_TypeEntree(JourEntree,Projets,RMA,Preparations,Reconditionnements,Retours,Livraisons,Autres) */;
CREATE VIEW v2_p_TypeEntree AS
SELECT
    date(DateEntree) AS JourEntree,
    TypeEntree,
    count(*) AS Qte
FROM v_Entrees
-- WHERE JourEntree = "2021%"
GROUP BY
    JourEntree,
    TypeEntree
-- LIMIT 30
/* v2_p_TypeEntree(JourEntree,TypeEntree,Qte) */;
CREATE VIEW v4_TypeEntree_3mois AS
WITH storage AS (
    SELECT date(max(DateEntree),"-3 months") AS MaxDate FROM v_Entrees
    -- cette formulation est d'une exécution plus longue qu'une référence à la date du jour dans le WHERE principal mais a l'avantage de fonctionnner même s'il n'y a pas de données récentes
)
SELECT
    JourEntree,
    Autres,
    Projets,
    RMA,
    Preparations,
    Reconditionnements,
    Retours,
    Livraisons
FROM v3_TypeEntree,storage
WHERE JourEntree >= MaxDate
/* v4_TypeEntree_3mois(JourEntree,Autres,Projets,RMA,Preparations,Reconditionnements,Retours,Livraisons) */;
CREATE INDEX k_BonTransport ON ENTREES(BonTransport COLLATE NOCASE);
CREATE VIEW v_Dernier_Retour_UC AS
SELECT 
numero_colis 
FROM v_entrees 
WHERE 
    date(dateentree)=(SELECT date(max(dateentree)) FROM v_entrees) 
AND typeentree="RET" 
AND numero_colis LIKE "X__________FR"
AND reference LIKE "UC%" 
order by dateentree asc
/* v_Dernier_Retour_UC(Numero_Colis) */;
CREATE VIEW v_Suivi_Dernier_Retour_UC AS
WITH storage AS (
    SELECT numero_colis 
    FROM v_Dernier_Retour_UC 
    ) 
SELECT 
    "http://suivi.chronopost.fr/servletAuguste?Hrequete=recherche&TAlisteNumeroLT=" 
    || group_concat(numero_colis,",") || 
    "&RBresultats=ecran&TFNumeroLTPartiel=&StypeCalcul=commun&StypeRecherche=tous" 
    AS LienAuguste
FROM storage
/* v_Suivi_Dernier_Retour_UC(LienAuguste) */;
CREATE TABLE DEPLPMLXCOL2(
    Coderegate INTEGER NOT NULL,
    CodeColissimo INTEGER PRIMARY KEY,
    Region,
    Site,
    Adresse,
    CPV,
    Responsable,
    Migration,
    VLAN,
    PST,
    PM1,
    IP_PM1,
    PM2,
    IP_PM2,
    Anciens_PM,
    ETAT_Site,
    Projet_Déploiement,
    Changement,
    KS,
    EIP,
    GLPI,
    NoColis,
    InterTech,
    Systeme,
    Supervision,
    Contact_Systeme,
    InstalApplis
    CHECK (
        cast(Coderegate AS INTEGER) > 0
    AND cast(CodeColissimo AS INTEGER) > 0
    AND julianday(migration) > CURRENT_DATE
    )
);
CREATE TABLE Priorisations(
-- 11:46 05/03/2021 liste des dossiers ayant demandé une priorisation
-- sous ensemble des mouvements suivis (beaucoup de suivis ne sont pas priorisés)
    GLPI INTEGER PRIMARY KEY
);
CREATE VIEW v_Entrees AS
-- CREATION 15:25 14/01/2021 réécriture de la vue avec détermination du type d'éntreee et mention de champs utiles qui évitent de croiser avec la table de base
-- BUG      19:44 15/01/2021 le réemploi du nom de champs présents dans la table entrees créee un doublon en cas d'usage couplé avec la table "entrees" => utilisation d'autres noms
-- MODIF    19:02 09/02/2021 Considère qu'une refappro commençant par "APPRO" concerne une livraison (précédemment en INDéterminé)
-- MODIF    17:10 10/02/2021 Considère qu'une refappro commençant par "APPRO" concerne une réception pour un " (précédemment en LIVraison)
-- MODIF    17:29 10/02/2021 affinage des clauses et de leur ordre afin de mieux coller à la réalité
-- BUG      09:56 08/03/2021 certaines entrées étaient 2 fois en tant que "RET" : 1 fois à la réception et 1 fois à la destruction. La distinction se fait sur l'horotadate (dateheure en réception, date sans heure pour le 2nd mvt)
-- BUG      09:56 08/03/2021 La BU était prise dans le début de la référence plutôt que dans le nom de stock ce qui occasionnait des anomalies pour les produits génériques
SELECT
    TagIS,
    Reference,
    substr(dateentree,7,4) || "-" || substr(dateentree,4,2) || "-" || substr(dateentree,1,2) || substr(dateentree,11) as DateEntree,
    -- substr(Reference,1,3) AS BU,
    substr(Projet,1,3) as BU, -- préférer Projet plutôt que le début de la référence afin de ne pas être perturbé par les articles génériques n'ayant pas une référence normalisée tels que les baies ou switches
    substr(Reference,4,1) AS Surfamille,
    substr(Reference,5,1) AS Sousfamille,
    substr(Reference,4,2) AS Famille,
    substr(Reference,6,1) AS Etat,
    substr(Reference,7,1) AS Stock,
    CASE
        WHEN substr(Reference,1,3) IN ("CHR","CLP","TLT") AND LENGTH(Reference)=10 THEN SUBSTR(Reference,8,3)
        ELSE "GEN"
    END Produit,
    Projet AS Nom_du_Stock,
    Libelle AS Designation,
    Refappro AS Ref_Appro,
    BonTransport as Numero_Colis,
    APT AS NoAppro,
    CASE
        WHEN APT < "!" AND cast(substr(refappro,1,INSTR(refappro,"-")) as integer) > 0 THEN "PRP" -- préparation matériel neuf
        WHEN APT < "!" AND INSTR(refappro," - ") > 0 AND length(Reference) = 10 AND SUBSTR(Reference,1,3) IN ("CHR","CLP","ALT") THEN "PRP" -- préparation matériel neuf
        WHEN refappro LIKE "APPRO%" AND refappro not LIKE "%rique%" THEN "PRJ" -- approvisionnement en matériel non référencé (usuellement pour des projets spécifiques)
        WHEN RefAppro LIKE "%PROJET%"  THEN "PRJ"
        WHEN refappro  LIKE "%SPC%"     THEN "RMA"
        WHEN refappro  LIKE "%Athesi%"  THEN "RMA"
        WHEN Reference LIKE "%DESTRUCTION%"  THEN "DEL" -- produit détecté dès son retour comme devant être détruit
        WHEN Reference LIKE "%ATHESI%"  THEN "RMA"
        WHEN SUBSTR(Reference,1,3) IN ("CHR","CLP","ALT") AND SUBSTR(Reference,6,1)="R" AND LENGTH(Reference)=10 AND APT > "" THEN "RMA" -- référence d'un produit reconditionné + APT = retour RMA
        WHEN SUBSTR(Reference,1,3) IN ("CHR","CLP","ALT") AND SUBSTR(Reference,6,1)="R" AND LENGTH(Reference)=10 AND APT = "" THEN "REC" -- référence d'un produit reconditionné sans APT = reconditionné
        WHEN RefAppro LIKE "%RMA%" THEN "RMA"
        WHEN RefAppro LIKE "%Retour%" THEN "RET" -- retours
        WHEN RefAppro LIKE "%g_n_riq%" THEN "RET" -- retours
        WHEN cast(substr(refappro,1,INSTR(refappro,"-")) as integer) > 0 THEN "LIV" -- réception de livraison avec numéro de commande valide
        WHEN INSTR(refappro," - ") > 0 AND length(Reference) = 10 AND SUBSTR(Reference,1,3) IN ("CHR","CLP","ALT") THEN "LIV" -- réception de livraison sur commande non numérotée
        WHEN cast(substr(refappro,length(refappro)-10) as integer) BETWEEN 2000000000 AND 2999999999 THEN "RET" -- retour de matériel client
        WHEN RefAppro LIKE "%Dossier%" THEN "RET" -- retour de matériel client
        WHEN length(RefAppro)=13 AND cast(substr(refappro,3,9) AS INTEGER) > 0 THEN "RET" -- numéro de colis retour dans la zone de refappro
        WHEN RefAppro LIKE "DEMANDE%"  THEN "PRJ"
        WHEN APT < "!" THEN "REC" -- audit de matériel reconditionné
        WHEN Libelle LIKE "%GENERIQUE%" THEN "RET"
        ELSE "IND" -- indéterminé, correspond la plupart du temps à des livraisons spéciales
    END TypeEntree
    -- ,
    -- ,substr(refappro,length(refappro)-10) as fin
FROM Entrees
-- WHERE DateEntree LIKE "%12/2020%"
-- AND Reference LIKE "CHR34RS%"
-- WHERE TAGIS LIKE "TE150729008_"
-- GROUP BY refappro ,apt
-- having Reference NOT LIKE "C_________"
ORDER BY
    DateEntree  DESC,
    TagIS   DESC
/* v_Entrees(TagIS,Reference,DateEntree,BU,Surfamille,Sousfamille,Famille,Etat,Stock,Produit,Nom_du_Stock,Designation,Ref_Appro,Numero_Colis,NoAppro,TypeEntree) */;
CREATE VIEW v_Dernier_Retour_Sensible AS
-- CREATION 14:03 12/03/2021 Comme v_Dernier_Retour_UC mais traite aussi les serveurs
SELECT
numero_colis
FROM v_entrees
WHERE
    date(dateentree)=(SELECT date(max(dateentree)) FROM v_entrees)
AND typeentree="RET"
AND numero_colis LIKE "X__________FR"
AND substr(reference,1,2) IN ("UC","SE")
order by dateentree asc
/* v_Dernier_Retour_Sensible(Numero_Colis) */;
CREATE VIEW v_Suivi_Dernier_Retour_Sensible AS
-- CREATION 14:03 12/03/2021 Comme v_Suivi_Dernier_Retour_UC mais traite aussi les serveurs
WITH storage AS (
    SELECT numero_colis
    FROM v_Dernier_Retour_Sensible
    )
SELECT
    "http://suivi.chronopost.fr/servletAuguste?Hrequete=recherche&TAlisteNumeroLT="
    || group_concat(numero_colis,",") ||
    "&RBresultats=ecran&TFNumeroLTPartiel=&StypeCalcul=commun&StypeRecherche=tous"
    AS LienAuguste
FROM storage
/* v_Suivi_Dernier_Retour_Sensible(LienAuguste) */;
CREATE VIEW v2_SortiesProduits AS
-- CREATION 11:07 15/03/2021 donne pour chaque jour
-- -- nombre de sorties du jour
-- -- nombre de sorties cumulées sur un mois
-- -- sur les 13 derniers mois
-- remplace vv_SortiesProduits_1sem
WITH storage as (
    SELECT datebl,count(*) as sortiesjour FROM v_dossiervalide WHERE datebl > date("now","-13 month") group  by datebl
)
SELECT storage.datebl as Sortie,SortiesJour AS Jour,
    (
        SELECT count(*) FROM v_dossiervalide WHERE v_dossiervalide.datebl between date(storage.datebl,"-7 days") AND storage.datebl
    ) AS Semaine,
    (
        SELECT count(*) FROM v_dossiervalide WHERE v_dossiervalide.datebl between date(storage.datebl,"-1 month") AND storage.datebl
    ) AS Mois
FROM storage
GROUP BY storage.datebl
/* v2_SortiesProduits(Sortie,Jour,Semaine,Mois) */;
CREATE VIEW v3_SortiesDossiers AS
-- CREATION 15:04 15/03/2021 donne pour chaque jour le nombre de dossiers de sorties d'incidents et de demandes traités ce jour 
-- -- le nombre de dossiers de sortie cumulées sur une semaine et un mois sont calculés dans une autre vue qui s'appuie sur celle-ci
    WITH storage AS (
        SELECT datebl,count(*) AS sortiesjour FROM vv_Sorties WHERE typesortie in ("DEM","INC") AND datebl > date("now","-1 month") GROUP BY glpi
    )
    SELECT storage.datebl AS Dossiers,sum(SortiesJour) AS Jour
    FROM storage
    GROUP BY storage.datebl
/* v3_SortiesDossiers(Dossiers,Jour) */;
CREATE VIEW v3_RecapDossiers AS
-- CREATION 14:26 17/03/2021 Donne le nombre d'articles et les infos constantes sur chaque dossier produit
SELECT     DateBl,count(*) AS NbArticles,TypeSortie,GLPI,Dossier,BU,Stock,Societe,CP,Ville
FROM       vv_typesortie 
-- WHERE      dossier>0
-- activer le WHERE si l'on veut exclure les dossiers de rma, destruction et autres
GROUP BY   DateBl,GLPI 
-- limit 10
/* v3_RecapDossiers(DateBL,NbArticles,TypeSortie,GLPI,Dossier,BU,Stock,Societe,CP,Ville) */;
CREATE VIEW v3_Receptions AS
-- CREATION 11:19 15/03/2021 donne pour chaque jour
-- -- nombre de produits traités en réception ce jour (tout compris, y compris audit)
-- -- nombre de réceptions cumulées sur une semaine et un mois
-- -- sur les 13 derniers mois
-- remplace vvv_receptions_1sem
WITH storage as (
    SELECT date(DateEntree) as Entree,count(*) as EntreesJour FROM v_Entrees WHERE DateEntree > date("now","-13 month") group  by Entree
)
SELECT storage.Entree as Entrees,EntreesJour AS Jour,
    (
        SELECT count(*) FROM v_Entrees WHERE v_Entrees.DateEntree between date(storage.Entree,"-7 days") AND storage.Entree
    ) AS Semaine,
    (
        SELECT count(*) FROM v_Entrees WHERE v_Entrees.DateEntree between date(storage.Entree,"-1 month") AND storage.Entree
    ) AS Mois
FROM storage
GROUP BY storage.Entree
/* v3_Receptions(Entrees,Jour,Semaine,Mois) */;
CREATE VIEW v3_Audit AS
-- CREATION 11:51 15/03/2021 donne pour chaque jour
-- -- nombre de produits audités ce jour (entrées de type "reconditionnement")
-- -- nombre de réceptions cumulées sur une semaine et un mois
-- -- sur les 13 derniers mois
-- remplace vvv_receptions_1sem
WITH storage as (
    SELECT date(DateEntree) as Entree,count(*) as EntreesJour FROM v_Entrees WHERE DateEntree > date("now","-13 month") AND TypeEntree = "REC" group  by Entree
)
SELECT storage.Entree as Audits,EntreesJour AS Jour,
    (
        SELECT count(*) FROM v_Entrees WHERE v_Entrees.DateEntree between date(storage.Entree,"-7 days") AND storage.Entree AND TypeEntree = "REC" 
    ) AS Semaine,
    (
        SELECT count(*) FROM v_Entrees WHERE v_Entrees.DateEntree between date(storage.Entree,"-1 month") AND storage.Entree AND TypeEntree = "REC" 
    ) AS Mois
FROM storage
GROUP BY storage.Entree
/* v3_Audit(Audits,Jour,Semaine,Mois) */;
CREATE VIEW v4_SortiesDossiers AS
-- CREATION 14:37 17/03/2021 
-- -- nombre de dossiers de production traités par jour (uniquement glpi, hors rma, destruction et autres)
-- -- nombre de dossiers cumulées sur une semaine et sur mois
-- -- sur les 13 derniers mois
WITH storage AS (
    SELECT datebl,count(*) AS DossiersJour FROM v3_RecapDossiers WHERE DateBl > date("now","-13 month") AND Dossier > 0 GROUP BY datebl
)
SELECT storage.datebl AS Ordis,DossiersJour AS Jour,
    (
        SELECT count(*) FROM v3_RecapDossiers WHERE v3_RecapDossiers.datebl between date(storage.datebl,"-7 days") AND storage.datebl AND Dossier > 0
    ) AS Semaine,
    (
        SELECT count(*) FROM v3_RecapDossiers WHERE v3_RecapDossiers.datebl between date(storage.datebl,"-1 month") AND storage.datebl AND Dossier > 0
    ) AS Mois
FROM storage
GROUP BY storage.datebl
-- limit 1
/* v4_SortiesDossiers(Ordis,Jour,Semaine,Mois) */;
CREATE TABLE NOMS(
         Masculin TEXT NOT NULL,
         Feminin TEXT  NOT NULL PRIMARY KEY
CHECK (Masculin > "A")
, NoOrdre INTEGER, MasculinPluriel TEXT, FemininPluriel TEXT);
CREATE TABLE VERBES(
	verbe TEXT NOT NULL PRIMARY KEY
);
CREATE VIEW v_1verbe AS
WITH storage AS (
    SELECT verbe FROM verbes WHERE rowid=(
        SELECT abs(random() % count(*)) FROM verbes
    )
)
SELECT verbe,
    CASE
        WHEN verbe LIKE "%er" THEN 1
        WHEN verbe LIKE "%ir" THEN 2
    END Groupe
FROM storage
/* v_1verbe(verbe,Groupe) */;
CREATE VIEW v_1nom AS
WITH storage AS (
    SELECT 
        CASE
            WHEN (SELECT (abs(random()) % 2) = 0) THEN "Masculin"
            ELSE "Féminin"
        END Genre,
        CASE
            WHEN (SELECT (abs(random()) % 2) = 0) THEN "Singulier"
            ELSE "Pluriel"
        END Nombre,
        CASE
            WHEN (SELECT (abs(random()) % 2) = 0) THEN "Défini"
            ELSE "Indéfini"
        END Pronom
)
SELECT
    CASE
        WHEN Nombre ="Singulier" AND Pronom = "Défini"   AND Genre = "Masculin" THEN "le "
        WHEN Nombre ="Singulier" AND Pronom = "Défini"   AND Genre = "Féminin"  THEN "la "
        WHEN Nombre ="Singulier" AND Pronom = "Indéfini" AND Genre = "Masculin" THEN "un "
        WHEN Nombre ="Singulier" AND Pronom = "Indéfini" AND Genre = "Féminin"  THEN "une "
        WHEN Nombre ="Pluriel"   AND Pronom = "Défini"                          THEN "les "
        WHEN Nombre ="Pluriel"   AND Pronom = "Indéfini"                        THEN "des "
    END Article,
    CASE
        WHEN Genre = "Masculin" THEN (
            SELECT
                Masculin FROM Noms WHERE rowid=(
                SELECT abs(random() % (count(*)-1))+1 FROM Noms
            )
        )
        ELSE (
            SELECT
                Feminin FROM Noms WHERE rowid=(
                SELECT abs(random() % (count(*)-1))+1 FROM Noms
            )
        )
    END Nom,
    CASE
        WHEN Nombre ="Pluriel" THEN "s"
        ELSE ""
    END Pluriel
FROM storage
/* v_1nom(Article,Nom,Pluriel) */;
CREATE VIEW v2_1nom  AS
WITH storage AS (
    SELECT Article AS A1, Nom AS N1, Pluriel AS P1 FROM v_1nom
)
SELECT
    CASE
        WHEN A1 IN ("Le ","La ") AND substr(N1,1,1) IN ("a","e","é","i","o","u","y","h") THEN "l'" || N1 || " " 
        ELSE A1 || N1 || P1 || " "
    END GroupeNominal,
    N1,
    substr(N1,1,1) as Initiale
FROM storage
/* v2_1nom(GroupeNominal,N1,Initiale) */;
CREATE VIEW v_SuiviSorties_1mois AS SELECT 1
/* v_SuiviSorties_1mois("1") */;
CREATE VIEW v_Noms AS
SELECT
    CASE
        WHEN substr(Masculin,1,1) IN ("a","e","é","h","i","o","u","y") THEN "l'"
        ELSE "le "
    END ArticleMasculin,
    Masculin AS NomMasculin,
    CASE
        WHEN substr(Feminin,1,1) IN ("a","e","é","h","i","o","u","y") THEN "l'"
        ELSE "la "
    END ArticleFeminin,
    Feminin AS NomFeminin,
    NoOrdre,
    MasculinPluriel,
    FemininPluriel    
FROM Noms
/* v_Noms(ArticleMasculin,NomMasculin,ArticleFeminin,NomFeminin,NoOrdre,MasculinPluriel,FemininPluriel) */;
CREATE VIEW v2_GroupeNominal AS
WITH s1 AS (
    SELECT 
        CASE
            WHEN (SELECT (abs(random()) % 2) = 0) THEN "Masculin"
            ELSE "Féminin"
        END Genre,
        CASE
            WHEN (SELECT (abs(random()) % 2) = 0) THEN "Singulier"
            ELSE "Pluriel"
        END Nombre,
        CASE
            WHEN (SELECT (abs(random()) % 2) = 0) THEN "Défini"
            ELSE "Indéfini"
        END Pronom
),
s2 AS (
            SELECT
                ArticleMasculin,NomMasculin,ArticleFeminin,NomFeminin,MasculinPluriel,FemininPluriel FROM v_Noms WHERE NoOrdre=(
                SELECT abs(random() % (count(*)-1))+1 FROM Noms
            )
)
SELECT  
    genre,nombre,pronom,NomMasculin,NomFeminin,
CASE
    WHEN Nombre="Singulier" AND Genre = "Masculin" AND Pronom = "Indéfini" THEN "un "  || NomMasculin || " "
    WHEN Nombre="Singulier" AND Genre = "Féminin"  AND Pronom = "Indéfini" THEN "une " || NomFeminin || " "
    WHEN Nombre="Pluriel" AND Genre = "Masculin"  AND Pronom = "Défini" THEN "les " || MasculinPluriel || " "
    WHEN Nombre="Pluriel" AND Genre = "Féminin"  AND Pronom = "Défini" THEN "les " || FemininPluriel || " "
    WHEN Nombre="Pluriel" AND Genre = "Masculin"  AND Pronom = "Indéfini" THEN "des " || MasculinPluriel || " "
    WHEN Nombre="Pluriel" AND Genre = "Féminin"  AND Pronom = "Indéfini" THEN "des " || FemininPluriel || " "
    WHEN Nombre="Singulier" AND Genre = "Masculin" AND Pronom = "Défini" THEN ArticleMasculin || NomMasculin || " "
    ELSE ArticleFeminin || NomFeminin || " "
END GroupeNominal
FROM s1,s2
/* v2_GroupeNominal(Genre,Nombre,Pronom,NomMasculin,NomFeminin,GroupeNominal) */;
CREATE VIEW v3_SujetVerbe AS
SELECT
    GroupeNominal AS Sujet,
    CASE
        WHEN nombre="Pluriel" THEN (
            SELECT
                substr(verbe,1,length(verbe)-2) ||
                replace(REPLACE(substr(verbe,length(verbe)-1,2),"er","ent") ,"ir","issent")
                FROM Verbes WHERE rowid=(
                SELECT abs(random() % (count(*)-1))+1 FROM Verbes 
            )
        )
        ELSE (
            SELECT
                substr(verbe,1,length(verbe)-2)
                ||
                replace(substr(verbe,length(verbe)-1,1),"i","it")
                FROM Verbes WHERE rowid=(
                SELECT abs(random() % (count(*)-1))+1 FROM Verbes
            )
        )
    END Verbe
FROM v2_GroupeNominal
/* v3_SujetVerbe(Sujet,Verbe) */;
CREATE VIEW v4_1phrase AS
SELECT Sujet || verbe || " " || (
    SELECT GroupeNominal FROM v2_GroupeNominal
) AS Phrase
FROM v3_SujetVerbe
/* v4_1phrase(Phrase) */;
CREATE VIEW v2_SortiesOrdis AS
-- CREATION 14:06 17/03/2021 d'après v2_SortiesProduits donne pour chaque jour
-- -- nombre de production d'ordis du jour (fixes, portables, etc ET SERVEURS)
-- -- nombre de sorties cumulées sur un mois
-- -- sur les 13 derniers mois
-- BUG      13:19 23/03/2021 mauvais placement de la clause restreignant au seul type de produits monitoré

WITH storage AS (
    SELECT datebl,count(*) AS sortiesjour FROM v_dossiervalide WHERE datebl > date("now","-13 months") AND (Surfamille="1" or famille="48") GROUP BY datebl
)
SELECT storage.datebl AS Ordis,SortiesJour AS Jour,
    (
        SELECT count(*) FROM v_dossiervalide WHERE v_dossiervalide.datebl between date(storage.datebl,"-7 days") AND storage.datebl AND (Surfamille="1" or famille="48") 
    ) AS Semaine,
    (
        SELECT count(*) FROM v_dossiervalide WHERE v_dossiervalide.datebl between date(storage.datebl,"-1 month") AND storage.datebl AND (Surfamille="1" or famille="48")
    ) AS Mois
FROM storage
GROUP BY storage.datebl
/* v2_SortiesOrdis(Ordis,Jour,Semaine,Mois) */;
CREATE VIEW v_EnAttente AS
-- MODIF    15:03 29/03/2021 considère tout le matériel shipping comme une catégorie à part entière, afin de le distinguer des imprimantes "métier"
SELECT
    DateExport,
    -- Nom_projet,
    CASE
        WHEN Nom_projet LIKE "%SHIPPING%" THEN "SHIPPING"
        ELSE Ref
    END RefGen,
    printf("%5d",count(*)) AS Qte
FROM StockArchive
WHERE
--    substr(ref,1,3) NOT IN ("CHR","CLP","TLT") AND
-- En pratique cette clause ^^ est inutile
    (Etat LIKE "%Attente%" AND Etat NOT LIKE "%cision%")
-- AND DateExport = "2021-03-25" -- pour debug seulement
--
GROUP BY
    DateExport,RefGen
/* v_EnAttente(DateExport,RefGen,Qte) */;
CREATE VIEW v2_p_EnAttente AS
-- MODIF 15:04 29/03/2021 modification du libellé de la référence pour s'adapter au changement opéré dans la vue v_EnAttente
SELECT
    DateExport AS DateStock,
    CASE
        WHEN RefGen < "!" THEN "DIVERS"
        WHEN instr(RefGen ," ") = 0 THEN RefGen
        ELSE substr(RefGen,1,instr(RefGen ," ")-1)
    END Reference,
    sum(Qte) AS Qte
FROM v_EnAttente
-- WHERE DateStock < date("now","-3 days") -- pour debug seulement
GROUP BY
    DateStock,Reference
/* v2_p_EnAttente(DateStock,Reference,Qte) */;
CREATE VIEW v3_EnAttente AS
-- MODIF 15:06 29/03/2021 Ajout d'une catégorie "Shipping" afin de différencier les imprimantes shipping des autres²
SELECT
DateStock,
    sum(case when   Reference LIKE "%cran%"           then    Qte ELSE 0 END) as Ecrans,
    sum(case when   Reference LIKE "%pri%t%%"         then    Qte ELSE 0 END) as Imprimantes,
    sum(case when   Reference LIKE "%port%"           then    Qte ELSE 0 END) as Portables,
    sum(case when   Reference LIKE "%PSM%"            then    Qte ELSE 0 END) as PSM,
    sum(case when   Reference LIKE "%SERV%"           then    Qte ELSE 0 END) as Serveurs,
    sum(case when   Reference LIKE "%Stat%"           then    Qte ELSE 0 END) as Stations,
    sum(case when   Reference LIKE "%Swit%"           then    Qte ELSE 0 END) as Reseau,
    sum(case when   Reference LIKE "%UC%"             then    Qte ELSE 0 END) as UC,
    sum(case when   Reference LIKE "%SHIP%"           then    Qte ELSE 0 END) as Shipping,
    sum(case when ( Reference LIKE "%AI%E%"       OR -- Astuce : concerne aussi bien "BAIE" que "CAISSEGRISE"
                    Reference LIKE "%Divers%"    )    then    Qte ELSE 0 END) as Divers
FROM v2_p_EnAttente
GROUP BY DateStock
/* v3_EnAttente(DateStock,Ecrans,Imprimantes,Portables,PSM,Serveurs,Stations,Reseau,UC,Shipping,Divers) */;
CREATE VIEW v4_EnAttente_3mois AS
-- MODIF 15:06 29/03/2021 Ajout d'une catégorie "Shipping" afin de différencier les imprimantes shipping des autres
-- MODIF 15:10 29/03/2021 Inversion de l'ordre d'affichage des PSM et UC afin de rendre ces dernières plus lisibles sur le graphique généré
SELECT
    DateStock,
    Ecrans,
    Imprimantes,
    Portables,
    UC,
    Serveurs,
    Stations,
    Reseau,
    PSM,
    Shipping,
    Divers
FROM v3_EnAttente
WHERE DateStock >= date("now","-3 months")
/* v4_EnAttente_3mois(DateStock,Ecrans,Imprimantes,Portables,UC,Serveurs,Stations,Reseau,PSM,Shipping,Divers) */;
CREATE VIEW v_1moisLivMagnetik AS
-- le résultat de cette vue doit être exploité par des scripts initialemet prévus pour la gestion des projets d'où les noms de champs non intuitifs
-- MODIF    16:16 06/04/2021 suppression des [CROCHETS] encadrant les numéros de colis
WITH storage                as
     (
            SELECT
                   max(datebl) as datemax
            FROM
                   v_sorties
                 , sorties
            WHERE
                   adr1            LIKE "%3 BOULEVARD ROMAIN ROLLAND%"
                   AND v_sorties.tagis=sorties.tagis
     )
SELECT
         glpi as GLPI
       , datebl as env
       , "OFLX".societe as proj
       , replace(replace(Numeros_de_colis,"[",""),"]","") as lieu
       , count(sorties.tagis) as qte
       , reference as ref
       , description as lib
       , nom_client as dem

FROM
         sorties
       , storage
       , v_sorties
       , "OFLX"
WHERE
         sorties.tagis=v_sorties.tagis
         AND datebl   > date(datemax,"-1 month")
         AND adr1  LIKE "%3 BOULEVARD ROMAIN ROLLAND%"
         AND sorties.NumeroOFL = "OFLX".NoOFL
GROUP BY
         reference
       , glpi
order by
         datebl desc
       , glpi
       , reference
;
CREATE TABLE OFLX(
      "RefClient" TEXT,
      "Projet" TEXT,
      "Type" TEXT,
      "NoOFL" TEXT NOT NULL,
      "Priorite" TEXT,
      "Date_Creation" TEXT,
      "Date_Expedition" TEXT,
      "Societe" TEXT,
      "Nom_Client" TEXT,
      "Adresse" TEXT,
      "Code_Postal" TEXT,
      "Destination" TEXT,
      "Date_souhaitee" TEXT,
      "Date_Notification" TEXT,
      "Heure_Notification" TEXT,
      "Numeros_de_colis" TEXT,
      "Colis_Retour" TEXT,
      "vide" TEXT
      check (
            instr(Date_Expedition,"/")=3
        AND instr(Date_souhaitee,"/")=3
        AND vide=""
      )
);
CREATE TABLE RetoursRecus(NumColis TEXT PRIMARY KEY CHECK(length(NumColis=13) AND NumColis LIKE "X__________FR"));
CREATE INDEX k_TR_OFLX ON OFLX(Type, Colis_Retour);
CREATE VIEW v_Retours_NonRecus_NoObj AS
-- CREATION 14:56 09/04/2021 Liste numéros de colis des swaps revenus mais non enregsitrés dans les produits réceptionnés
-- USAGE    importer la liste des colis attendus dans Auguste, en extraire la liste des colis déjà distribués et l'importer dans la table RetoursRecus puis lancer la vue "detail"
WITH storage AS (
    SELECT substr(Colis_retour,2,13) AS Retour FROM oflx,v_oflx
    WHERE type="SWAP"
    AND colis_retour > ""
    AND oflx.noofl=v_oflx.noofl AND v_oflx.date_expedition BETWEEN date("now","-3 month") AND date("now","-7 days")
    AND Retour NOT IN (SELECT numero_colis FROM v_entrees WHERE dateentree > v_oflx.Date_Expedition)
    AND Retour NOT IN (SELECT numcolis FROM RetoursRecus)
    GROUP BY Retour
)
SELECT
    '"C:\Program Files\Google\Chrome\Application\chrome.exe" ' || '"'
    ||  "http://suivi.chronopost.fr/servletAuguste?Hrequete=recherche&TAlisteNumeroLT="
    || group_concat(Retour,",") ||
    "&RBresultats=fichier&TFNumeroLTPartiel=&StypeCalcul=commun&StypeRecherche=distribues" || '"'
    AS LienAuguste
FROM storage;
CREATE VIEW v_Retours_NonRecus_Detail AS
-- CREATION 14:56 09/04/2021 Liste des swaps non revenus
-- USAGE    importer dans RetoursRecus la liste Auguste des colis revenus mais absents de la liste des produits revenus via v_Retours_NonRecus_NoObj
--          puis exécuter cette vue pour obtenir la liste des dossiers de swap dont on n'a pas eu le retour de matériel
SELECT refclient AS GLPI,Projet AS Stock,substr(Colis_retour,2,13) AS Retour,v_oflx.Date_Expedition,Societe FROM oflx,v_oflx
WHERE type="SWAP"
AND colis_retour > ""
AND oflx.noofl=v_oflx.noofl AND v_oflx.date_expedition BETWEEN date("now","-3 month") AND date("now","-7 days")
AND Retour NOT IN (SELECT numero_colis FROM v_entrees WHERE dateentree > v_oflx.Date_Expedition)
AND Retour NOT IN (SELECT numcolis FROM RetoursRecus)
GROUP BY Retour;
CREATE INDEX K_OFLX_RefCli ON OFLX(RefClient);
CREATE VIEW v_SuiviMvt AS
-- 11:26 28/09/2020 Listage des mouvements I&S à suivre qui viennent d'être détectés comme étant effectués.
-- Doit être exécuté aussitôt après l'exécution du script SuiviMvt.sql
-- 15:36 29/09/2020 MODIF : Supprime les crochets et virgules dans les numéros des colis expédiés (pas besoin de le faire dans les colis reçus)
-- 14:06 01/10/2020 Rajoute la date de début de surveillance, affiche les mouvements surveillés mais pas encore vus et les mouvements vus depuis moins d'un mois (au lieu de juste la journée précédemment)
WITH storage AS
     (
               SELECT -- sorties
                         Donnee
                       , Valeur
                       , DateBL AS DateMvt
                       , DateSurv
                       , Reference
                       , Description AS Designation
                       , NumSerie
                       , sDepot AS Stock
                       -- , NumeroOFL aucune utilité
                       , REPLACE(REPLACE(REPLACE(numeros_de_colis,"[",""),"]",""),","," ") AS Transport
                       , sorties.Societe  AS Societe
                       , SORTIES.TagIS
                       , Motif
               FROM
                         SORTIES
                       , SuiviMvt
                       , v_SORTIES
                         LEFT JOIN
                                   "OFLX"
                                   ON
                                             "OFLX".refclient = Valeur
               WHERE
                             DateVu    >=DATE("now","-1 month")
                         AND Donnee="Dossier"
                         AND Valeur=glpi
                         AND SORTIES.TagIS=v_SORTIES.TagIS
               -- GROUP BY -- la présence de cette clause perturbe l'affichage des quantités en sortie
                         -- Valeur
                       -- , Reference
               -- ORDER BY Valeur
               -- ;
               UNION
               SELECT -- -- -- dossiers (reste quelques cas de doublons)
                      -- count(Entrees.TagIS) AS Nb,
                       Donnee
                    , Valeur
                    , DATE(v_Entrees.DateEntree) AS DateVu
                    , DateSurv
                    , Entrees.Reference
                    , Libelle
                    , Numero_Serie
                    , Projet
                    -- , APT doublon avec la colonne "valeur" si on cherche sur APT, inutile sinon
                    , BonTransport
                    , RefAppro
                    , Entrees.TagIS AS TagIS
                    , Motif
               FROM
                      SuiviMvt
                    , Entrees
                    , v_Entrees
               WHERE

                          DateVu    >=DATE("now","-1 month")
                      AND Donnee                ="Dossier"
                      AND v_Entrees.DateEntree >= datesurv
                      AND Entrees.TagIS         =v_Entrees.TagIS
                      AND RefAppro           LIKE "%"
                             || Valeur
                             || "%"
               -- GROUP BY Valeur,Numero_Serie
               -- ;
               UNION
               SELECT -- -- -- APT
                      -- count(Entrees.TagIS) AS Nb,
                      Donnee
                    , Valeur
                    , date(v_Entrees.DateEntree) AS DateVu
                    , DateSurv
                    , Entrees.Reference
                    , Libelle
                    , Numero_Serie
                    , Projet
                    -- , APT doublon avec la colonne "valeur" si on cherche sur APT, inutile sinon
                    , BonTransport
                    , RefAppro
                    , Entrees.TagIS AS TagIS
                    , Motif
               FROM
                      SuiviMvt
                    , Entrees
                    , v_Entrees
               WHERE
                          DateVu    >=DATE("now","-1 month")
                      AND Donnee                ="Livraison"
                      AND v_Entrees.DateEntree >= datesurv
                      AND Entrees.TagIS         =v_Entrees.TagIS
                      AND APT                LIKE "%"
                             || Valeur
                             || "%"
               -- GROUP BY Valeur
               -- ;
               UNION
               SELECT -- -- Colis
                        -- count(v_Entrees.TagIS) AS Nb,
                        Donnee
                      , Valeur
                      , date(v_Entrees.DateEntree) AS DateVu
                      , DateSurv
                      , Entrees.Reference
                      , Libelle
                      , Numero_Serie
                      , Projet
                      -- , APT doublon avec la colonne "valeur" si on cherche sur APT, inutile sinon
                      , BonTransport
                      , RefAppro
                      , Entrees.TagIS AS TagIS
                      , Motif
               FROM
                        SuiviMvt
                      , Entrees
                      , v_Entrees
               WHERE
                            DateVu    >=DATE("now","-1 month")
                        AND Donnee                ="Colis"
                        AND v_Entrees.DateEntree >= datesurv
                        AND Entrees.TagIS         =v_Entrees.TagIS
                        AND BonTransport       LIKE "%"
                                 || Valeur
                                 || "%"
               GROUP BY
                        Entrees.TagIS
                        -- GROUP BY Valeur
                        -- ;
               UNION
               SELECT
                         Donnee
                       , Valeur
                       , "N/A"  AS DateVu
                       , DateSurv
                       , ""     AS Reference
                       , ""     AS Designation
                       , ""     AS NumSerie
                       , ""     AS Stock
                       , ""     AS Transport
                       , ""     AS Societe
                       , ""     AS TagIS
                       , Motif
               FROM SuiviMvt
               WHERE DateVu=""
     )
SELECT DISTINCT
         (COUNT(TagIS) * (DateMvt >"")) AS Qte -- nombre de lignes concernées par le mouvement
       , *
FROM
         storage
         -- WHERE Donnee="Dossier"
GROUP BY
         Valeur
       , Reference  -- une ligne par dossier/colis/apt et référence d'article différente
/* v_SuiviMvt(Qte,Donnee,Valeur,DateMvt,DateSurv,Reference,Designation,NumSerie,Stock,Transport,Societe,TagIS,Motif) */;
CREATE INDEX k_OFLX_RefClient ON OFLX(RefClient);
CREATE VIEW v_Suivi_Sorties AS
-- d'après v_SuiviMvt du 09:40 02/10/2020
-- Liste des déstockages I&S des 30 derniers jours effectués sur dossier GLPI, avec affichage des numéros de colis
WITH storage AS
     (
               SELECT -- sorties
                         GLPI
                       , DateBL
                       , Reference
                       , Description AS Designation
                       , NumSerie
                       , sDepot AS Stock
                       , NumeroOFL
                       , REPLACE(REPLACE(REPLACE(numeros_de_colis,"[",""),"]",""),","," ") AS Transport
                       , sorties.Societe  AS Societe
                       , SORTIES.TagIS
               FROM
                         SORTIES
                       , v_SORTIES
                         LEFT JOIN
                                   oflx
                                   ON
                                             oflx.refclient = GLPI
               WHERE
                             length(CAST(GLPI AS INTEGER))=10
                         AND SORTIES.TagIS=v_SORTIES.TagIS
                         -- AND datebl > date("now","-2 day") -- uniquement pour debug
     )
SELECT DISTINCT
         COUNT(TagIS)  AS Qte -- nombre de lignes concernées par le mouvement
       , *
FROM
         storage
GROUP BY
         GLPI
       , Reference  -- une ligne par dossier et référence d'article différente
/* v_Suivi_Sorties(Qte,GLPI,DateBL,Reference,Designation,NumSerie,Stock,NumeroOFL,Transport,Societe,TagIS) */;
