## MMTOP
This is mmtop, standing for "Multiple Mysql Top".  It's designed to replace mytop 
in larger production environments, where multiple database servers must be monitored
simultaneously. 

#### Features
  * Monitor the queries of many mysql servers at once
  * Kill many overly long (the site's about to die!) queries with a keystroke or two
  * Some things that mytop supports; explain query, kill query. 
  * List client connection counts to find out who is actually connecting to your database
  * "wedge" monitoring -- detect when the query load is too high and log it

#### Installation

  * gem install mmtop
  * copy mmtop_example to ~/.mmtop_config, edit as needed.
  * run "mmtop"

#### Using the thing

Once mmtop is up and running, you can start watching the queries from different servers fly 
by.  


Your most important commands while commands go by:
		"p": Pause the listing.  Bring up a prompt.
		"q": Quit

Now from the prompt:
    "help": show some help.
		"x [PID]": Show the full text of the query, its state, and what host it's running on
		"k [PID]": Kill the query.  mmtop will prompt you to make sure, as the author is a bonehead sometimes.
		"ex [PID]": Explain the query
		"l [HOST]": List the clients (and their connection count) currently connected to this host
    (and others)

#### TODO: 
Housekeeping.  k-long should be better.  help from the prompt.  QPS for hosts, maybe some innodb stats too. 

#### Questions? 
No one ever has any questions.  Feel free to message me here on github with bugs or what
not. 



