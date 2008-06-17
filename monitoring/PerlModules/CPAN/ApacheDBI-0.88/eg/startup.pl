#!/usr/local/bin/perl -w

# to load this file when the server starts, add this to httpd.conf:
# PerlRequire /path/to/startup.pl

# make sure we are in a sane environment.
$ENV{GATEWAY_INTERFACE} =~ /^CGI-Perl/ or die "GATEWAY_INTERFACE not Perl!";

use Apache::Registry;
use Apache::DBI;
#use Apache::AuthDBI;
use strict;


# optional configuration for Apache::DBI.pm:

# choose debug output: 0 = off, 1 = quiet, 2 = chatty
#$Apache::DBI::DEBUG = 2;

# configure all connections which should be established during server startup.
# keep in mind, that if the connect does not succeeed, your server won't start
# until the connect times out (database dependent) !
# you may use a DSN with attribute settings specified within
#Apache::DBI->connect_on_init("dbi:driver(AutoCommit=>1):database", "userid", "passwd");

# configure the ping behavior of the persistent database connections
# you may NOT not use a DSN with attribute settings specified within
# $timeout = 0  -> always ping the database connection (default)
# $timeout < 0  -> never  ping the database connection
# $timeout > 0  -> ping the database connection only if the last access
#                  was more than timeout seconds before
#Apache::DBI->setPingTimeOut("dbi:driver:database", $timeout);


# optional configuration for Apache::AuthDBI.pm:

# choose debug output: 0 = off, 1 = quiet, 2 = chatty
#$Apache::AuthDBI::DEBUG = 2;

# set lifetime in seconds for the entries in the cache
#Apache::AuthDBI->setCacheTime(0);

# set minimum time in seconds between two runs of the handler which cleans the cache
#Apache::AuthDBI->setCleanupTime(-1);

# use shared memory of given size for the cache
#Apache::AuthDBI->initIPC(50000);


1;
