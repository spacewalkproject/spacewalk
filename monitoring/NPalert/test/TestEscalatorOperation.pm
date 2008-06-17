package test::TestEscalatorOperation;

use strict;
use base qw(Test::Unit::TestCase);

use NOCpulse::Notif::EscalatorOperation;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__,9);

my $MODULE = 'NOCpulse::Notif::EscalatorOperation';

######################
sub test_constructor {
######################
  my $self = shift;
  my $obj = $MODULE->new();

  # Make sure creation succeeded
  $self->assert(defined($obj), "Couldn't create $MODULE object: $@");

  # Make sure we got the right type of object
  $self->assert(qr/$MODULE/, "$obj");
}

############
sub set_up {
############
  my $self = shift;
  # This method is called before each test.

  $self->{'item'}=$MODULE->new;
  $self->{'item'}->operation('addition');
  $self->{'item'}->parameters(1,2,3);
}

###############
sub tear_down {
###############
}

#################
sub get_message {
#################
}


# INSERT INTERESTING TESTS HERE


######################
sub test_from_string {
######################
  my $self=shift;

  my $item=$self->{'item'};
  my $string=$item->store_string;
  my $risen=$MODULE->from_string($string);

  $self->assert($item->operation eq $risen->operation,"test_from_string operation");
  $self->assert($item->parameters_shift == 1,"test_from_string 1");
  $self->assert($item->parameters_shift == 2,"test_from_string 2");
  $self->assert($item->parameters_shift == 3,"test_from_string 3");
}

###############
sub test_init {
###############
  my $self=shift;
  my $item=$self->{'item'};
  $self->assert(1,"test_init (does nothing)");
}

##################
sub test_perform {
##################
  my $self=shift;
  my $item=$self->{'item'};
  my $escalator=test::TestEscalatorOperation::EscalatorStub->new;
  $item->perform($escalator);
  my $result=$item->results_shift;

  $self->assert($result == 6, "test_perform");
}

#######################
sub test_store_string {
#######################
  my $self=shift;

  my $item=$self->{'item'};
  my $string=$item->store_string;
  my $risen=$MODULE->from_string($string);

  $self->assert($item->operation eq $risen->operation,"test_store_string operation");
  $self->assert($item->parameters_shift == 1,"test_store_string 1");
  $self->assert($item->parameters_shift == 2,"test_store_string 2");
  $self->assert($item->parameters_shift == 3,"test_store_string 3");
}

package test::TestEscalatorOperation::EscalatorStub;
use Class::MethodMaker
  new_hash_init => 'new';

##############
sub addition {
##############
    my ($self,@parms)=@_;
    my $sum;
    
    while (my $num = shift(@parms)) {
        $sum += $num;
    }
    return $sum
}

1;
