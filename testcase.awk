{
	switch ($0) {
		case /^[0-9]/ : 
		{
			print "num "
			break
		}
		case /^[a-z]/ :
		{
			print "min "
			break
		}
		case /^[A-Z]/ :
		{
			print "maj "
			break
		}
		default :
			print "autre "
	}
}
