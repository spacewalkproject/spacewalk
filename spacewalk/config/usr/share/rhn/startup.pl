#!/usr/bin/perl -w
use strict;
use lib '/var/www/lib';

use RHN::DB;

use Apache2::ServerUtil ();
Apache2::ServerUtil->server->push_handlers(PerlChildInitHandler => sub { RHN::DB->apache_child_init_handler } );

1;
