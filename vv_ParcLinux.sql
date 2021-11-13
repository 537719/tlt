CREATE VIEW vv_ParcLinux AS
-- CREATION 21:50 12/11/2021 Liste des UC Linux (hors d‚loc) sorties et pas revenues au stock
WITH 
storageA AS (
-- liste des s/n des uc linux sorties coupl‚es … leur tagis le plus r‚cent
    SELECT max(tagis) AS TagIS, numserie 
    FROM Sorties
    WHERE
        -- UC pr‚format‚es Linux
        reference LIKE "CHR10__1FQ"
    OR
        (
            reference LIKE "CHR10%" -- UC
        AND substr(reference,8,3) != "1F4" -- On exclut les UC D‚loc
        AND description LIKE "%FREEDOS%" -- Les "non freedos" sont des UC windows
    )
    GROUP BY numserie -- parmi toutes les occurences de chaque num‚ro de s‚rie on ne garde que le plus grand tagis c'est … dire le plus r‚cent
)
,
storageB AS (
-- liste des s/n d'uc linux revenus au stock coupl‚s … leur tagis le plus r‚cent
    SELECT max(tagis) AS TagIS,numero_serie 
    FROM Entrees
    WHERE numero_serie IN (
        SELECT numserie FROM storageA
    ) -- on ne s'int‚resse qu'aux UC linux sorties
    GROUP BY numero_serie  -- parmi toutes les occurences de chaque num‚ro de s‚rie on ne garde que le plus grand tagis c'est … dire le plus r‚cent
)
,
storageC AS (
    -- -- uc linux sorties et jamais rentr‚es
    SELECT storageA.tagis,storageA.numserie 
    FROM storageA 
    WHERE numserie NOT IN (
        SELECT numero_serie FROM storageB
    )
    UNION
    -- -- uc linux sorties aprŠs leur dernier retour
    SELECT storageA.tagis,storageA.numserie 
    FROM storageA,storageB 
    WHERE   numserie        = numero_serie 
    AND     storageA.tagis >= storageB.tagis
   -- tagis sup‚rieur ou ‚gal et pas sup‚rieur strict pour conserver les UC sorties le jour o— elles sont audit‚es, donc jour de sortie = jour d'entr‚e
)
SELECT 
    lower(Sorties.NumSerie) AS "Num‚ro S‚rie",description AS D‚signation,societe AS Site,CP AS "Code Postal",Ville,GLPI AS "Dossier GLPI",
    substr("date bl",7,4) || "-" || substr("date bl",4,2) || "-" || substr("date bl",1,2) AS "Date Exp‚dition"
FROM Sorties , storageC
WHERE storageC.tagIS=sorties.tagis
ORDER BY CP,Societe,sorties.NumSerie
;


