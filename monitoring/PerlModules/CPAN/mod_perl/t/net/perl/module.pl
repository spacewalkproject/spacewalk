
use Apache::test;

my $r = shift;
$r->send_http_header('text/plain');

unless(have_module "Apache::Module", '0.10' and
       Apache->module('mod_include.c') and
       Apache->module('mod_access.c'))
{
    print "1..0\n";
    return;
}

use strict;
use Apache::Constants qw(:common :args_how);

print "1..10\n";
my $i = 0;
my $top = Apache::Module->top_module;

test ++$i, $top;

my $h = $top->find("mod_perl");

test ++$i, $h;

test ++$i, $h->cmds->find("PerlTaintCheck")->errmsg =~ /-T switch/;

test ++$i, 
    $top->find("mod_include")->cmds->find("XBitHack")->args_how == TAKE1;

my $rr = $r->lookup_uri("/perl/perl-status");

test ++$i, $h->logger->($rr) == DECLINED;

test ++$i, $top->find("mod_access")->access_checker->($rr) == OK;

test ++$i, $top->find("http_core")->handlers->content_type;

test ++$i, $top->find("http_core")->handlers->handler->($rr) == NOT_FOUND;

$rr->filename($0);

test ++$i, $top->find("http_core")->handlers->handler->($rr) == OK;

$h = $top->find("no_chance");

test ++$i, not $h;








