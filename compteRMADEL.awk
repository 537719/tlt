#compteRMADEL.awk
# compte le nombre d'envois et mises en destruction dans un export des expéditions I&S
@ include "typesortieinclude.awk" BEGIN
{
rma = 0 del = 0 FS = ";" OFS = ";"}

{
#MAIN
  if (typesortie (1, $2, $3, $6, $16) ~ /RMA /)
    {
#  RMA
    rma++}
  if (typesortie (1, $2, $3, $6, $16) ~ /DEL /)
    {
#  destruction
    del++}
}

END
{
  mois = gensub (/.*([0 - 9]
		     {
		     4}
		 )([0 - 9]
		   {
		   2}
		 ).* /, "\\1/\\2", "1", FILENAME) print mois OFS rma OFS del}
