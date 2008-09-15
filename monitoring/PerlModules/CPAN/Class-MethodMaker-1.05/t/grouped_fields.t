#!/usr/local/bin/perl

package X;

use lib qw ( ./t );
use Test;

use Class::MethodMaker
  grouped_fields => [
		     'x' => [ qw / a b c / ],
		    ];

sub new { bless {}, shift; }
my $o = new X;

TEST { 1 };
my @f;
TEST { @f = $o->x };
TEST { scalar @f == 3 };
TEST { $f[0] eq 'a' and $f[1] eq 'b' and $f[2] eq 'c' };

TEST { $o->a(123) };
TEST { $o->a == 123 };
TEST { ! defined $o->clear_a };
TEST { ! defined $o->a };

TEST { $o->b(456) };
TEST { $o->b == 456 };
TEST { ! defined $o->clear_b };
TEST { ! defined $o->b };

TEST { $o->c('baz') };
TEST { $o->c eq 'baz' };
TEST { ! defined $o->clear_c };
TEST { ! defined $o->c };

exit 0;

