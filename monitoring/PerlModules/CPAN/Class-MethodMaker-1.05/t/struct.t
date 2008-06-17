#!/usr/local/bin/perl

package X;

use lib qw ( ./t );
use Test;

use Class::MethodMaker
  struct => [ qw / a b c d / ],
  struct => 'e';

sub new { bless {}, shift; }
my $o = new X;

TEST { 1 };

TEST { ! $o->a };
TEST { ! $o->b };
TEST { ! $o->c };
TEST { ! $o->d };
TEST { ! $o->e };

my @f;
TEST { @f = $o->struct_fields; print "@f\n"; };
TEST {
  $f[0] eq 'a' and 
  $f[1] eq 'b' and 
  $f[2] eq 'c' and 
  $f[3] eq 'd' and 
  $f[4] eq 'e'
};

TEST { $o->struct(0,1,2,3,4) };

my %h;
TEST { %h = $o->struct_dump };
TEST {
  $h{'a'} == 0 and 
  $h{'b'} == 1 and 
  $h{'c'} == 2 and 
  $h{'d'} == 3 and 
  $h{'e'} == 4
};

TEST { $o->a('foo') };
TEST { $o->a eq 'foo' };

TEST { ! defined $o->clear_a };
TEST { ! defined $o->a };

exit 0;

