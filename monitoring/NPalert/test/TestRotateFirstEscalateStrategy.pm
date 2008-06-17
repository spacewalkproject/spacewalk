package test::TestRotateFirstEscalateStrategy;

use strict;

use base qw(Test::Unit::TestCase);

use NOCpulse::Notif::RotateFirstEscalateStrategy;
use NOCpulse::Notif::EmailContactMethod;
use NOCpulse::Notif::ContactGroup;
use NOCpulse::Notif::Alert;

use NOCpulse::Log::Logger;
my $Log = NOCpulse::Log::Logger->new(__PACKAGE__,9);

my $MODULE = 'NOCpulse::Notif::RotateFirstEscalateStrategy';

my $MY_INTERNAL_EMAIL = 'kja@redhat.com';
my $MY_EXTERNAL_EMAIL = 'nerkren@yahoo.com';
my $NOWHERE_EMAIL     = 'nobody@nocpulse.com';

$| = 1;

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

  $self->{'internal_dest'}=NOCpulse::Notif::EmailContactMethod->new( 'email' => $MY_INTERNAL_EMAIL);
  $self->{'external_dest'}=NOCpulse::Notif::EmailContactMethod->new( 'email' => $MY_EXTERNAL_EMAIL);
  $self->{'nowhere_dest'} =NOCpulse::Notif::EmailContactMethod->new( 'email' => $NOWHERE_EMAIL);

  $self->{'group'}=NOCpulse::Notif::ContactGroup->new();

  $self->{'group'}->add_destination($self->{'internal_dest'});
  $self->{'group'}->add_destination($self->{'external_dest'});
  $self->{'group'}->add_destination($self->{'nowhere_dest'});

  $self->{'alert'}=NOCpulse::Notif::Alert->new();
}

# INSERT INTERESTING TESTS HERE

########################
sub test_new_for_group {
########################
  my $self=shift;
  
  my $strategy=$MODULE->new_for_group($self->{'group'},$self->{'alert'});
  my @list=map { $_->destination } @{$strategy->sends};
  $Log->dump(9,"(1)\n",@list,"\n");
  my $item=shift(@list);
  $self->assert($item->email eq $MY_INTERNAL_EMAIL,"internal email (1)");
  $item=shift(@list);
  $self->assert($item->email eq $MY_EXTERNAL_EMAIL,"external email (1)");
  $item=shift(@list);
  $self->assert($item->email eq $NOWHERE_EMAIL,"nowhere email (1)");

  $strategy=$MODULE->new_for_group($self->{'group'},$self->{'alert'});
  @list=map { $_->destination } @{$strategy->sends};
  $Log->dump(9,"(2)\n",@list,"\n");
  $item=shift(@list);
  $self->assert($item->email eq $MY_EXTERNAL_EMAIL,"external email (2)");
  $item=shift(@list);
  $self->assert($item->email eq $NOWHERE_EMAIL,"nowhere email (2)");
  $item=shift(@list);
  $self->assert($item->email eq $MY_INTERNAL_EMAIL,"internal email (2)");

  $strategy=$MODULE->new_for_group($self->{'group'},$self->{'alert'});
  @list=map { $_->destination } @{$strategy->sends};
  $Log->dump(9,"(3)\n",@list,"\n");
  $item=shift(@list);
  $self->assert($item->email eq $NOWHERE_EMAIL,"nowhere email (3)");
  $item=shift(@list);
  $self->assert($item->email eq $MY_INTERNAL_EMAIL,"internal email (3)");
  $item=shift(@list);
  $self->assert($item->email eq $MY_EXTERNAL_EMAIL,"external email (3)");

  $strategy->new_for_group($self->{'group'},$self->{'alert'});

  @list=map { $_->destination } @{$strategy->sends};
  $Log->dump(9,"(4)\n",@list,"\n");
  $item=shift(@list);
  $self->assert($item->email eq $MY_INTERNAL_EMAIL,"internal email (4)");
  $item=shift(@list);
  $self->assert($item->email eq $MY_EXTERNAL_EMAIL,"external email (4)");
  $item=shift(@list);
  $self->assert($item->email eq $NOWHERE_EMAIL,"nowhere email (4)");
} 
