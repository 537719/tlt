INSERT INTO Corrections(
  "BU",
  "Identifiant",
  "Nom",
  "Adresse",
  "CP",
  "Ville",
  "Periode",
  "Type",
  "Libelle",
  "Poste_Comptable",
  "Depot",
  "Trg",
  "Centre_Cout",
  "Periode2",
  "Rattachement",
  "Code_Activite",
  "Code_Tr",
  "Libelle3",
  "Id_Site",
  "Id_Localisation",
  "Id_Activite",
  "Id_Chantier"
)
SELECT Referentiel."BU",
 Referentiel."Identifiant",
 Referentiel."Nom",
 Referentiel."Adresse",
 Referentiel."CP",
 Referentiel."Ville",
 Referentiel."Periode",
 Referentiel."Type",
 Referentiel."Libelle",
 Referentiel."Poste_Comptable",
 Referentiel."Depot",
 Referentiel."Trg",
 Referentiel."Centre_Cout",
 Referentiel."Periode2",
 Referentiel."Rattachement",
 Referentiel."Code_Activite",
 Referentiel."Code_Tr",
 Referentiel."Libelle3",
 Referentiel."Id_Site",
 Referentiel."Id_Localisation",
 Referentiel."Id_Activite",
 Referentiel."Id_Chantier"
from Referentiel,Sites
WHERE Referentiel.Code_Activite=sites.Code_Activite
-- AND Referentiel.Id_Chantier=sites.Id_Chantier
AND (
 referentiel.Code_Activite in ("MLH07")
)
;

Select 
    Referentiel.Code_Activite,Referentiel.Type,Referentiel.Nom,Referentiel.Adresse,Referentiel.CP,Referentiel.Ville
, strftime("%n%n",0)
,
    Sites.Code_Activite,Sites.Type,Sites.Nom,Sites.Adresse,Sites.CP,Sites.Ville
, strftime("%n%n",0)

    from Referentiel,sites
 WHERE Referentiel.Code_Activite=sites.Code_Activite
AND Referentiel.Id_Chantier=sites.Id_Chantier
AND (
 referentiel.CP in (22190,15199,"",75017,26800)
)
;

select
Code_Activite,Type,Nom,Adresse,CP,Ville
from corrections
;

with storage as (
select substr(code_activite,1,3) as trig,printf("%02d",count(adresse)) as nb,max(substr(code_activite,4,2)) as delocs from import where type="DEL" group by trig order by trg asc,code_activite desc
)
select * from storage
where nb <> delocs
 ;

drop table import;
.log log.txt
.separator ,
CREATE TABLE Import(
  "BU" TEXT,
  "Identifiant" TEXT,
  "Nom" TEXT,
  "Adresse" TEXT,
  "CP" TEXT,
  "Ville" TEXT,
  "Periode" TEXT,
  "Type" TEXT,
  "Libelle" TEXT,
  "Poste_Comptable" TEXT,
  "Depot" INT,
  "Trg" TEXT,
  "Centre_Cout" INT,
  "Periode2" TEXT,
  "Rattachement" TEXT,
  "Code_Activite" TEXT,
  "Code_Tr" TEXT,
  "Libelle3" TEXT,
  "Id_Site" INT,
  "Id_Localisation" INT,
  "Id_Activite" INT,
  "Id_Chantier" INT
  
  CHECK (
            LENGTH(TRG)<4
  AND   LENGTH("Poste_Comptable")<7
  AND   LENGTH("Code_Activite")<6
  AND   LENGTH(CP)<8
  AND   (
            "Depot"+"Centre_Cout"+"Id_Site"+"Id_Localisation"+"Id_Activite"+"Id_Chantier" ="Depot"+"Centre_Cout"+"Id_Site"+"Id_Localisation"+"Id_Activite"+"Id_Chantier" +0
            )
        )
)
;
CREATE UNIQUE INDEX k_Import on Import( Id_Localisation,Depot,Id_Activite,Id_Chantier);
.import EX6E6E~1.CSV Import
.log off


-- candidats à l'unicité
id chantier toujours -1 si site administratif
Code ActivitÃ©	Code Tr. et trg souvent vides
Id Site	Id Localisation	Id ActivitÃ© souvent en doublons


