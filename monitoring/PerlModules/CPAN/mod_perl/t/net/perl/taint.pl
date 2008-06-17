#!/usr/local/bin/perl -w

use Apache ();
use strict;

my $r = Apache->request;
local $ENV{PATH} = "/bin";

$r->content_type("text/plain");
$r->send_http_header;

#with perl 5.003_96 and hpux10.10, trapping an "...insecure dependency..."
#more than once during the same perl_call_sv core dumps
#we get by with one at a time for now.

my $sub = $r->args;
$sub =~ s/\W+//g;

my $tests = {
    args => sub {
	eval { system $r->args };
	die "TaintCheck failed, I can `system \$r->args'" unless $@;
	#warn "TRAPPED: `system \$r->args' '$@'\n";
    },
    env => sub {
	eval { system $ENV{SERVER_SOFTWARE} };
	die "TaintCheck failed, I can `system $ENV{SERVER_SOFTWARE}'" 
	    unless $@;
	#warn "TRAPPED: `system \$ENV{SERVER_SOFTWARE}' '$@'\n";
    },
    header_in => sub {
	eval { system $r->header_in('User-Agent') };
	die "TaintCheck failed, I can `system \$r->header_in('User-Agent')'"
	    unless $@;
	#warn "TRAPPED: `system \$r->header_in('User-Agent')' '$@'\n";
    },
    content => sub {
	my $content = $r->content;

	eval { system $content };
	die "TaintCheck failed, I can `system $content'" unless $@;
	#warn "TRAPPED: `system \$r->content' '$@'\n";
    },
};

&{ $tests->{$sub} };

$r->print("OK");






