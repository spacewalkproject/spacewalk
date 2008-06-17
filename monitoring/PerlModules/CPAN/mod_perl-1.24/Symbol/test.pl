BEGIN {
    $^W=1;
    print "1..3\n";
}

use ExtUtils::testlib;
use Apache::Symbol ();

use strict;

package Foo;

@Foo::ISA = qw(Apache::Symbol);
sub one {1}

sub constant_one () {1}

#comment out the line below and you'll see something like:
#Subroutine one redefined at (eval 1) line 1.
#Constant subroutine constant_one redefined at (eval 2) line 1.

Foo->undef_functions;

eval "sub one {1}";
eval "sub constant_one () {1}";

print "ok 1\n";

my $name = Apache::Symbol::sv_name(\&Foo::one);
print "not " unless $name eq "Foo::one";

print "ok 2\n";

package main;

sub THREE () {3}
my $sv = Apache::Symbol::cv_const_sv(\&THREE) or print "not ";

$sv ||= "3 (failed!)";
print "ok $sv\n";




