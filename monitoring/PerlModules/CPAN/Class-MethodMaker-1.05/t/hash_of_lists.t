#!/usr/local/bin/perl

package X;

use lib qw ( ./t );
use Test;

use Class::MethodMaker
  hash_of_lists => [ qw / a b / ],
  hash_of_lists => 'c',
  hash_of_lists => [qw/ -static d /];

sub new { bless {}, shift; }
my $o = new X;

# 1--2
TEST { ! scalar @{$o->a} };
TEST { my @a = $o->a ('foo'); scalar @a == 0 };

# 3
$o->a_push ('foo', 'biff');
TEST {
  my @a = $o->a ('foo'); @a == 1 and $a[0] eq 'biff'
};

# 4
$o->a_push ('bar', 'glarch');
$o->a_push ('wiz', 'lark');
TEST {
  my @l = $o->a ([qw/ foo bar /]);
  @l == 2 and $l[0] eq 'biff' and $l[1] eq 'glarch'
};

# 5
TEST {
  my %x = map {$_,1} qw( biff glarch lark );
  my $l;
  my $ok = 1;
  foreach $l ($o->a) {
    $ok = 0 if ! exists $x{$l};
    delete $x{$l};
  }
  $ok &&= keys %x == 0;
};


# 6
TEST {
  $o->a_push('foo', qw / a b c d / );
  my @l = sort $o->a;

  $l[0] eq 'a' and
    $l[1] eq 'b' and
      $l[2] eq 'biff' and
	$l[3] eq 'c' and
	  $l[4] eq 'd' and
	    $l[5] eq 'glarch'
};

# 7
TEST {
  my @l = sort $o->a_splice ('foo', 1, 3);
  $l[0] eq 'a' and
    $l[1] eq 'b' and
      $l[2] eq 'c'
};

# 8
$o->a_clear(qw / foo bar / );
TEST {
  my @a = $o->a;
  @a == 1 and $a[0] eq 'lark';
};

# 9--10
$o->c_push ('foo', 'bar');
TEST { ($o->c ('foo'))[0] eq 'bar' };
$o->c_delete('foo');
TEST { my @a = $o->c('foo'); @a == 0 };

# 11--15
my @keys = qw/a b c/;
$o->c_push ([@keys],qw/ d e f /);
TEST {
  ($o->c ('a'))[2] eq 'f'
    and ($o->c ('b'))[1] eq 'e'
      and ($o->c ('c'))[0] eq 'd'
};
TEST {
  my @sorted_keys = sort @keys;
  my @k = sort $o->c_keys;
  my $ok = (@k == @sorted_keys);


  for (0..$#k) {
    $ok &&= ( $k[$_] eq $sorted_keys[$_] );
  }
  $ok;
};
TEST {
  $o->c_exists (@keys);
};
TEST {
  @a = $o->c_pop (@keys);
  my $ok = (@a == @keys);
  for (@a) {
    $ok &&= $_ eq 'f';
  }
  $ok;
};
TEST {
  ! $o->c_exists (@keys, 'duck');
};


# 16
TEST {
  $o->c_delete(qw/ a c /);
  my @a = $o->c_keys;
  @a == 1 and $a[0] eq 'b';
};

# 17
$o->c_unshift ([qw/ b c /], 'e');
TEST {
  my @a = $o->c (qw/ c b /);
  my @expect = qw/ e e d e /;
  my $ok = @a == @expect;
  for (0..$#a) {
    $ok &&= $a[$_] eq $expect[$_];
  }
  return $ok;
};

# 18
$o->c_shift (qw/ b /);
TEST {
  my @a = $o->c (qw/ c b /);
  my @expect = qw/ e d e /;
  my $ok = @a == @expect;
  for (0..$#a) {
    $ok &&= $a[$_] eq $expect[$_];
  }
  return $ok;
};

# 19--20
$o->c_splice ('b', 1, 0, 'e');
$o->c_splice ('b', 0, 1);
TEST {
  my @a = $o->c (qw/ c b /);
  my @expect = qw/ e e e /;
  my $ok = @a == @expect;
  for (0..$#a) {
    $ok &&= $a[$_] eq $expect[$_];
  }
  return $ok;
};
TEST {
  $o->c_count (qw/ c b /) == 3;
};

# 21--22

my $p = new X;
$o->d_push (foo => qw/ bar baz /);
my @a = $p->d ('foo');
TEST {
  @a == 2;
};
TEST {
  $a[0] eq 'bar' and $a[1] eq 'baz';
};

# 23
TEST {
  ($p->d_index (foo => 1))[0] eq 'baz';
};

$o->d_remove ('foo' => 0);
# 24
TEST {
  ($p->d_index (foo => 0))[0] eq 'baz';
};

$p->d_push ([qw/ foo bob /], qw/ arthur harry jimbob /);
# 25--26
TEST {
  my @b = $o->d ('foo');
  @b == 4 and
    $b[0] eq 'baz' and
    $b[1] eq 'arthur' and
    $b[2] eq 'harry' and
    $b[3] eq 'jimbob';
};
TEST {
  my @b = $o->d ('bob');
  @b == 3 and
    $b[0] eq 'arthur' and
    $b[1] eq 'harry' and
    $b[2] eq 'jimbob';
};

$p->d_sift
  ({
    filter => sub { $_[0] eq $_[1] },
    values => [qw/ arthur harry /],
   });
# 27--28
TEST {
  my @b = $o->d ('foo');
  @b == 2 and
    $b[0] eq 'baz' and
    $b[1] eq 'jimbob';
};
TEST {
  my @b = $o->d ('bob');
  @b == 1 and
    $b[0] eq 'jimbob';
};


my @b = $o->d_index ([qw/ foo bob /], 0, 1);
# 29--33
TEST {
  @b == 4;
};
TEST {
  $b[0] eq 'baz';
};
TEST {
  $b[1] eq 'jimbob';
};
TEST {
  $b[2] eq 'jimbob';
};
TEST {
  ( ! $^V or $^V lt v5.6.0  or eval 'exists $b[3]' ) and
    ! defined $b[3];
};

@b = $p->d_last (qw/ foo bob /);
# 34--36
TEST {
  @b == 2;
};
TEST {
  $b[0] eq 'jimbob';
};
TEST {
  $b[1] eq 'jimbob';
};

@b = $p->d_last (qw/ foo bob /);
# 37--39
TEST {
  @b == 2;
};
TEST {
  $b[0] eq 'jimbob';
};
TEST {
  $b[1] eq 'jimbob';
};

$p->d_set (foo => ( 3 => 'kirk', 4 => 'mccoy' ));
@b = $o->d ('foo');
# 40--43
TEST {
  @b == 5;
};
TEST {
  $b[0] eq 'baz' and
    $b[1] eq 'jimbob';
};
TEST {
  ! defined $b[2];
};
TEST {
  $b[3] eq 'kirk' and
    $b[4] eq 'mccoy';
};


exit 0;

