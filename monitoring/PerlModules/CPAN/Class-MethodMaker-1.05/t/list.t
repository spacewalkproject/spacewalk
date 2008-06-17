#!/usr/local/bin/perl

package X;

use lib qw ( ./t );
use Test;

use Class::MethodMaker
  list => [ qw / a b / ],
  list => 'c';

sub new { bless {}, shift; }
my $o = new X;

# 1--6
TEST { 1 };
TEST { ! scalar @{$o->a} };
TEST { $o->push_a(123, 456) };
TEST { $o->unshift_a('baz') };
TEST { $o->pop_a == 456 };
TEST { $o->shift_a eq 'baz' };

#7--8
TEST { $o->b(123, 'foo', [ qw / a b c / ], 'bar') };
TEST {
  my @l = $o->b;
  $l[0] == 123 and
  $l[1] eq 'foo' and
  $l[2] eq 'a' and
  $l[3] eq 'b' and
  $l[4] eq 'c' and
  $l[5] eq 'bar'
};

# 9
TEST {
  $o->splice_b(1, 2, 'baz');
  my @l = $o->b;
  $l[0] == 123 and
  $l[1] eq 'baz' and
  $l[2] eq 'b' and
  $l[3] eq 'c' and
  $l[4] eq 'bar'
};

# 10--12
TEST { ref $o->b_ref eq 'ARRAY' };
TEST { ! scalar @{$o->clear_b} };
TEST { ! scalar @{$o->b} };

$o->b (qw/ a b c /);
my @x = $o->b_index (2, 1, 1, 2);
# 13--15
TEST { @x == 4 };
TEST { $x[0] eq 'c' and $x[3] eq 'c' };
TEST { $x[1] eq 'b' and $x[2] eq 'b' };

$o->b_set ( 1 => 'd' );
@x = $o->b;
# 16--19
TEST { @x == 3 };
TEST { $x[0] eq 'a' };
TEST { $x[1] eq 'd' };
TEST { $x[2] eq 'c' };

eval {
  $o->b_set ( 0 => 'e', 1 );
};
# 20
TEST { $@ };
exit 0;

