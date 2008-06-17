package test::TestFlooz;
use Data::Dumper;

use strict;

use base qw(Test::Unit::TestCase);

use Flooz;

my $MODNAME = "Flooz";

############
sub set_up {
############
  my $self = shift;
  # Run before each test
  $self->{'flooz'} = $MODNAME->new();
}

###############
sub tear_down {
###############
  my $self = shift;
  # Run after each test
}

# Within tests, use:
#  $self->assert(<boolean>[,<message>]);
#  $self->assert(qr/<pattern>/, $result);
#  $self->assert(sub {$_[0] == $_[1] || die "Expected $_[0], got $_[1]"},
#                1, 2);
#  $self->fail(); # Should not have gotten here


######################
sub test_constructor {
######################
  my $self = shift;

  my $obj = $self->{'flooz'};

  # Make sure creation succeeded
  $self->assert(defined($obj), "Couldn't create $MODNAME object: $@");

  # Make sure we got the right type of object
  $self->assert(qr/$MODNAME/, "$obj");

  
}

################################
sub test_sort_by_numeric_value {
################################

  my $self = shift;

  # Create a sortable hash
  my %hash = (
    three => 3,
    Four  => 4,
    1     => 1,
    TWO   => 2,
  );

  # Sort the hash
  my @sortkeys = $self->{'flooz'}->sort_by_numeric_value(\%hash);

  # Make sure the hash is sorted correctly.
  for (my $i = 0; $i < keys %hash; $i++) {
    my $exp = (qw(1 TWO three Four))[$i];
    $self->assert($sortkeys[$i] == $exp, 
                   "Bad sort($i): expected $exp, got $sortkeys[$i]");
  }
}





1;

