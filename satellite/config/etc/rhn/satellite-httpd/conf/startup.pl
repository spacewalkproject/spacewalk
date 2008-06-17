#!/usr/bin/perl -w
use strict;
use lib '/var/www/lib';

use Apache2::SizeLimit;
$Apache2::SizeLimit::MAX_PROCESS_SIZE = 400_000;  # 400,000 kbytes, ie, 400 meg
$Apache2::SizeLimit::CHECK_EVERY_N_REQUESTS = 1;

use RHN::DB;

use Apache2::ServerUtil ();
Apache2::ServerUtil->server->push_handlers(PerlChildInitHandler => sub { RHN::DB->apache_child_init_handler } );

1;
