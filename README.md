## MMTOP
This is mmtop, standing for "Multiple Mysql Top".  It's designed to replace mytop 
in larger production environments, where multiple database servers must be monitored
simultaneously. 

# Features
  * Monitor the queries of many mysql servers at once
  * Kill many overly long (the site's about to die!) queries with a keystroke or two
  * Some things that mytop supports; explain query, kill query. 
  * List client connection counts to find out who is actually connecting to your database
  * "wedge" monitoring -- detect when the query load is too high and log it
  * Written in perl.  Is that a feature anymore?  Probably not.

# Installation

# You'll need perl.
# You'll need one perl modules that isn't stock:
  - Term::ReadKey (ubuntu: apt-get install libterm-readkey-perl)

