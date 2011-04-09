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
  * Written in perl.  Is that a feature anymore?  Probably not.

#### Installation

  * You'll need perl.
  * You'll need one perl modules that isn't stock:
    * Term::ReadKey (ubuntu: apt-get install libterm-readkey-perl)

Copy the mmtop binary someplace (I hear /usr/local/bin is nice this time of year).  Copy
mmtop_config.example to ~/.mmtop_config, and edit to your liking.  

#### Running the thing

Once mmtop is up and running, you can start watching the queries from different servers fly 
by.  Here's how mine looks:

		+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
		| tm|  pid| Query | Sat Apr  9 19:58:13 UTC 2011                                                                                                                               |
		|---|-----| db01  !sql 3 cxs---------------------------------------------------------------------------------------------------------------------------------------------------|
		|---|-----| db02  !io !sql 1 cxs-----------------------------------------------------------------------------------------------------------------------------------------------|
		|---|-----| db03  !io !sql 1 cxs-----------------------------------------------------------------------------------------------------------------------------------------------|
		|---|-----| db04  !io !sql 1 cxs-----------------------------------------------------------------------------------------------------------------------------------------------|
		|---|-----| db05  !io !sql 279 cxs---------------------------------------------------------------------------------------------------------------------------------------------|
		|---|-----| db06 0 265 cxs-----------------------------------------------------------------------------------------------------------------------------------------------------|
		|  0|  528|                           
		|---|-----| account01 298 cxs--------------------------------------------------------------------------------------------------------------------------------------------------|



#### Questions? 

No one ever has any questions.  Feel free to message me here on github with bugs or what
not. 



