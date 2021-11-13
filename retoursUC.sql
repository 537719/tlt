-- retour UC de coignŠres et pau
select reference,libelle from entrees where reference like "CHR10%" and tagis in (select tagis from entrees where reference = "UC" and dateentree like "12/04/2021%");
-- retours UC Nantes
select reference,libelle from entrees where reference like "CHR10%" and tagis in (select tagis from entrees where reference = "UC" and dateentree like "20/04/2021%");
