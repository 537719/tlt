-- numéro de dossier + centre coût + bénéficiaire
select glpi_groups_tickets.tickets_id, glpi_plugin_shipping_clients.num_contract,glpi_users.firstname, glpi_users.realname
	from		glpi_groups_tickets,  glpi_plugin_shipping_clients, glpi_tickets_users,  glpi_users
	where		glpi_tickets_users.type=1 
    AND         glpi_groups_tickets.type=1 
	AND 
				glpi_tickets_users.tickets_id IN (
1712200469,
1712200473,
1712200486,
1712210312,
1712210342,
1712270140,
1712280141,
1801020143,
1801030128,
1801040042,
1801040171,
1801040339,
1801040351,
1801040447,
1801050126,
1801050213,
1801050435,
1801080620,
1801080711,
1801090174,
1801090175,
1801090230,
1801090316,
1801090581,
1801100230,
1801100236,
1801100406,
1801100549,
1801100643,
1801110206,
1801120172,
1801120203,
1801120473,
1801150281,
1801150396,
1801150441,
1801150596,
1801160385,
1801160519,
1801170350,
1801170378,
1801170396,
1801170457,
1801180092,
1801180355,
1801180402,
1801220109,
1801220210,
1801220400,
1801220635,
1801230128,
1801230149,
1801230152,
1801230274,
1801240393,
1801240630,
1801260289,
1801260353,
1801260534,
1801290180,
1801290397,
1801290406,
1801300121,
1801300136,
1801300335,
1801300450,
1801300604,
1801310282,
1801310478,
1801310639,
1801310668,
1802010112,
1802010142,
1802010161,
1802020052,
1802020275,
1802020564,
1802050202,
1802050205,
1802050229,
1802050242,
1802050418,
1802050419,
1802050598,
1802060228,
1802060463,
1802060593,
1802070344,
1802070347,
1802070383,
1802070458,
1802070678,
1802080117,
1802080131,
1802080147,
1802090073,
1802090204,
1802090213,
1802090392,
1802090446,
1802120241,
1802120446,
1802130192,
1802140292,
1802140407,
1802140408,
1802140471,
1802160183,
1802160402,
1802190129,
1802190226,
1802190261,
1802190358,
1802200170,
1802200574,
1802210314,
1802210359,
1802210481,
1802220112,
1802220281,
1802220463,
1802220507,
1802230192,
1802230430,
1802230445,
1802230529,
1802260078,
1802260103,
1802260211,
1802090021,
1802270051,
1802270301,
1802270524,
1803020192,
1803020225,
1803020298,
1803050207,
1803050272,
1803050316,
1803050498,
1803050516,
1803060257,
1803060353,
1803060354,
1803060555,
1803060631,
1803060633,
1803070333,
1803070600,
1803080422,
1803080435,
1803080444,
1803080462,
1803080468,
1803090108,
1803090456,
1803100005,
1803120447,
1803120454,
1803120458,
1803120464,
1803120467,
1803120748,
1803130226,
1803140350,
1803140379,
1803140500,
1803140501,
1803140565,
1803150135,
1803150150,
1803150231,
1803150293,
1803150540,
1803150544,
1803150551,
1803160013,
1803160114,
1803160216,
1803160421,
1803160422,
1803190177,
1803190181,
1803190190,
1803190279,
1803190418,
1803190498,
1803200024,
1803200324,
1803200326,
1803200477,
1803200615,
1803210139,
1803210514,
1803220297,
1803220440,
1803230257,
1803230426,
1803230468,
1803260220,
1803260257,
1803260357,
1803270299,
1803270331,
1803270339,
1803270366,
1803280355,
1803280607,
1803270154,
0
				)
	AND 
				glpi_groups_tickets.tickets_id IN (
1712200469,
1712200473,
1712200486,
1712210312,
1712210342,
1712270140,
1712280141,
1801020143,
1801030128,
1801040042,
1801040171,
1801040339,
1801040351,
1801040447,
1801050126,
1801050213,
1801050435,
1801080620,
1801080711,
1801090174,
1801090175,
1801090230,
1801090316,
1801090581,
1801100230,
1801100236,
1801100406,
1801100549,
1801100643,
1801110206,
1801120172,
1801120203,
1801120473,
1801150281,
1801150396,
1801150441,
1801150596,
1801160385,
1801160519,
1801170350,
1801170378,
1801170396,
1801170457,
1801180092,
1801180355,
1801180402,
1801220109,
1801220210,
1801220400,
1801220635,
1801230128,
1801230149,
1801230152,
1801230274,
1801240393,
1801240630,
1801260289,
1801260353,
1801260534,
1801290180,
1801290397,
1801290406,
1801300121,
1801300136,
1801300335,
1801300450,
1801300604,
1801310282,
1801310478,
1801310639,
1801310668,
1802010112,
1802010142,
1802010161,
1802020052,
1802020275,
1802020564,
1802050202,
1802050205,
1802050229,
1802050242,
1802050418,
1802050419,
1802050598,
1802060228,
1802060463,
1802060593,
1802070344,
1802070347,
1802070383,
1802070458,
1802070678,
1802080117,
1802080131,
1802080147,
1802090073,
1802090204,
1802090213,
1802090392,
1802090446,
1802120241,
1802120446,
1802130192,
1802140292,
1802140407,
1802140408,
1802140471,
1802160183,
1802160402,
1802190129,
1802190226,
1802190261,
1802190358,
1802200170,
1802200574,
1802210314,
1802210359,
1802210481,
1802220112,
1802220281,
1802220463,
1802220507,
1802230192,
1802230430,
1802230445,
1802230529,
1802260078,
1802260103,
1802260211,
1802090021,
1802270051,
1802270301,
1802270524,
1803020192,
1803020225,
1803020298,
1803050207,
1803050272,
1803050316,
1803050498,
1803050516,
1803060257,
1803060353,
1803060354,
1803060555,
1803060631,
1803060633,
1803070333,
1803070600,
1803080422,
1803080435,
1803080444,
1803080462,
1803080468,
1803090108,
1803090456,
1803100005,
1803120447,
1803120454,
1803120458,
1803120464,
1803120467,
1803120748,
1803130226,
1803140350,
1803140379,
1803140500,
1803140501,
1803140565,
1803150135,
1803150150,
1803150231,
1803150293,
1803150540,
1803150544,
1803150551,
1803160013,
1803160114,
1803160216,
1803160421,
1803160422,
1803190177,
1803190181,
1803190190,
1803190279,
1803190418,
1803190498,
1803200024,
1803200324,
1803200326,
1803200477,
1803200615,
1803210139,
1803210514,
1803220297,
1803220440,
1803230257,
1803230426,
1803230468,
1803260220,
1803260257,
1803260357,
1803270299,
1803270331,
1803270339,
1803270366,
1803280355,
1803280607,
1803270154,
0
				)
	AND
		glpi_plugin_shipping_clients.groups_id=glpi_groups_tickets.groups_id
	AND
		glpi_users.id=glpi_tickets_users.users_id
    AND
        glpi_groups_tickets.tickets_id=glpi_tickets_users.tickets_id
limit 800
;