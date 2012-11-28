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

#### Display

The following columns are displayed by default:

The server status line:

```
| hostname         | pid   | time | #cx | slave   | delay | qps    | comment | Wed Nov 28 22:51:23 +0000 2012        |
| db22 -------------------------- | 217 |         |       | 0      | ------------------------------------------------|
```

```
hostname: the hostname of the mysql server
     #cx: number of clients currently connected to this host
   slave: a status column indicating whether the slave on this host is currently running
   delay: if a slave is configured, the time behind the master this slave is
     qps: queries per second, calculated with each screen refresh
 comment: a user configurable note about this host
```

The query status line:

```
| hostname         | pid   | time | #cx | slave   | delay | qps    | comment | Wed Nov 28 22:51:23 +0000 2012        |
|            app16 | 1     | 1    | SELECT * FROM `example` where status_id = 5     |
```

```
hostname: the hostname of the client running this query
     pid: a virtual PID of the query you can refer to when killing/examining the query -- note that this bears no relation to the actual mysql query PID.
    time: amount of time this query has been running for
```

#### Entering/exiting command mode:

Hit "p" while queries are flying by to enter command mode. 
Once in command mode, hit [enter] on a line by itself to exit command mode.


#### Once in command mode

The following commands are available:

```

--------------------------------------------------------------------------------------------------------------------------------------------------+
| command                                  | notes
--------------------------------------------------------------------------------------------------------------------------------------------------+
| ex[plain] PID                            | run an explain of the query on the server where the query is operating
| filter add BLOCK | NAME [INDEX]          | adds a filter to the query list, explained more in the FILTERS section
| filter available                         | lists available pre-cooked filters
| filter list                              | lists active filters
| filter rm INDEX                          | removes the filter at position INDEX
| help                                     | show help text, yup.
| kill PID                                 | kills the given query
| kill long TIME [SERVER]                  | brings up the kill multiple dialog
|                                          |   limited to SELECT queries longer than TIME seconds and optionally only where host == [SERVER] 
| kill /regexp/                            | brings up the kill multiple dialog
|                                          |   limited to queries matching the given regexp
| list SERVER                              | lists active connections to the given host
| map_topology                             | if replication topology automapping is enabled, try to re-figure the topology
| quit                                     | exit mmtop
| sleep [TIME]                             | control how long mmtop will sleep between query listings
--------------------------------------------------------------------------------------------------------------------------------------------------+
```

#### Questions? 
Feel free to message me here on github with bugs or what not. 



