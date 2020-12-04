-- cablesprojets.sql
-- 14:56 27/10/2020 mise en rapport des coûts de mise en stock et de déstockage des câbles pour les projets
-- 12:22 mercredi 28 octobre 2020 rajout du nombre de câbles qui auraient été déstockés si on les avait sortis par pochettes de 10 par le passé


drop table if exists cablesprojets
;

CREATE TABLE cablesprojets
             (
                          Annee      integer
                        , QtIn       integer
                        , E_In       NUMBER
                        , QStock     INTEGER
                        , E_Stockage NUMERIC
                        , QtOut      integer
                        , E_Out      NUMBER
                        , Q10Out     INTEGER check(annee between 2016 and 2020)
             )
;

CREATE UNIQUE INDEX k_cpa
on
                    cablesprojets
                    (
                                        annee
                    )
;

-- with storage as (select strftime("%Y",datebl) as Annee,cast(round((count(tagis)+9)/10,0)*10 as integer) as Q10,Expedition from vv_sorties,catalogue,tarif where datebl > "2015-12-31" AND reference like "CHR73NP%" and ref=reference and projet like "%infra%" and categorie=cat group by annee,reference,GLPI)
with storage as
     (
              select
                       strftime("%Y",datebl)                            as Annee
                     , count(tagis)                                     as Out
                     , cast(round((count(tagis)+9)/10,0)*10 as integer) as Q10
                     , Expedition
              from
                       vv_sorties
                     , catalogue
                     , tarif
              where
                       datebl           > "2015-12-31"
                       AND reference like "CHR73NP%"
                       and ref          =reference
                       and projet    like "%infra%"
                       and categorie    =cat
              group by
                       annee
                     , reference
                     , GLPI
     )
insert
       or replace
into
       cablesprojets
       (annee
            , QtOut
            , Q10Out
            , E_Out
       )
select
         annee
       , sum(Out)                                      as Out
       , sum(Q10)                                      as Q10
       , round(sum(Out)*replace(expedition,",","."),2) as Sortie
from
         storage
group by
         annee
;

insert
       or replace
into
       cablesprojets
       (annee
            , QtIn
            , E_In
            , QtOut
            , E_Out
            , Q10Out
       )
select
         strftime("%Y",dateentree)                         as An
       , count(tagis)                                      as QtIn
       , replace(ReceptionUnitaire,",",".") * count(tagis) as E_In
       , QtOut
       , E_Out
       , Q10Out
from
         v_entrees
       , catalogue
       , tarif
       , cablesprojets
where
         ref        like "CHR73NP%"
         and ref       =reference
         and projet like "%infra%"
         and categorie =cat
         and annee     =an
group by
         Annee
having
         Annee > "2015"
;

with storage as
     (
              select
                       strftime("%Y",dateimport)                   as Annee
                     , avg(okdispo)                                as qte
                     , replace(StockageUnitaireParSemaine,",",".")    Couthebdo
              from
                       histostock
                     , catalogue
                     , tarif
              where
                       reference like "CHR73NP%"
                       and ref      =reference
                       and categorie=cat
              group by
                       annee
                     , reference
     )
insert
       or replace
into
       cablesprojets
       (annee
            , QtIn
            , E_In
            , QStock
            , E_Stockage
            , QtOut
            , E_Out
            , Q10Out
       )
select
         storage.Annee
       , QtIn
       , E_In
       , printf("%5d",cast(round(sum(qte),0) as integer))       as QStock
       , printf("%8.2f E",round(sum(qte*couthebdo*365.25/7),2)) as E_Stockage
       , QtOut
       , E_Out
       , Q10Out
from
         storage
       , cablesprojets
where
         storage.annee=cablesprojets.annee
group by
         storage.annee
;

select
       printf("%5d",annee)          as Annee
     , printf("%4d",QtIn)           as QtIn
     , printf("%7.2f E",E_In)       as E_In
     , printf("%6d",QStock)         as QStock
     , printf("%9.2f E",E_Stockage) as E_Stockage
     , printf("%4d",QtOut)          as QtOut
     , printf("%7.2f E",E_Out)      as E_Out
     , printf("%5d",Q10Out)         as Q10Out
from
       cablesprojets
where
       annee > 2017
union
select
       "Moyenne"
     , cast(avg(qtin) as integer)
     , printf("%7.2f E",avg(e_in))
     , printf("%6d",cast(avg(QStock) as integer))
     , printf("%9.2f E",avg(E_Stockage))
     , cast(avg(qtout) as integer)
     , printf("%7.2f E",avg(e_out))
     , printf("%5d",cast(avg(Q10Out) as integer))
from
       cablesprojets
where
       annee > 2017
;
