#!/usr/local/bin/perl

package X;

use lib qw ( ./t );
use Test;

use Class::MethodMaker
  method => [ qw / a b / ],
  method => 'c';
sub new { bless {}, shift; }
sub meth { $_[0] };
sub foo { "foo" };
sub bar { $_[0] };
my $o = new X;

TEST { 1 };
#TEST { eval { $o->a }; !$@ }; # Ooops! this is broken at the moment.
TEST { $o->a(\&foo) };
TEST { $o->a eq 'foo' };
TEST { $o->b(\&bar) };
TEST { $o->b('xxx') eq $o };
TEST { $o->c(sub { "baz" } ) };
TEST { $o->c eq 'baz' };

exit 0;

