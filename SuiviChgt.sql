-- SuiviChgt.sql
-- 26/10/2020  11:33 transformation de l'export csv glpi de l'état des changements en cours de manière à remettre sur une seule ligne les champs qui contiennent des caractères LF
--                   et standardisation des noms de champs afin de les rendre compatibles avec le script csv2xml

CREATE TABLE IF NOT EXISTS SuiviChgt( -- simplifie et raccourcit les noms des champs, supprime les accents, espaces et caractères spéciaux
  "Titre" TEXT,
  "Entite" TEXT,
  "ID" INTEGER,
  "Statut" TEXT,
  "Urgence" TEXT,
  "Contact" TEXT,
  "Responsable" TEXT,
  "Docs" TEXT,
  "Description" TEXT,
  "Ouverture" TEXT,
  "Cloture" TEXT,
  "Attribution" TEXT,
  "Modification" TEXT
  CHECK(
    id +1 -1 = id -- vérifie que l'id est de type numérique afin d'exclure la ligne d'en-tête
  )
);
delete from suivichgt;



.cd ../work

.separator ;
.import suivichgt.xls.csv suivichgt
    UPDATE SuiviChgt set Contact=replace(Contact,char(10),", ");
    UPDATE SuiviChgt set Description=replace(Description,char(10),"</br>");
    UPDATE SuiviChgt set Responsable=replace(Responsable,char(10),", ");

.mode list
.header on
.separator ;
.once suivichgt.csv
select * from suivichgt;
.output