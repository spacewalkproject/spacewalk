package test::TestContactGroup;

use strict;

use base qw(Test::Unit::TestCase);

use NOCpulse::Notif::Alert;
use NOCpulse::Notif::ContactGroup;
use NOCpulse::Notif::EmailContactMethod;

use NOCpulse::Log::Logger;
my $Log = NOCpulse::Log::Logger->new(__PACKAGE__,9);

my $MODULE = 'NOCpulse::Notif::ContactGroup';

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

  $self->{'internal_dest'} = NOCpulse::Notif::EmailContactMethod->new( 'email' => $MY_INTERNAL_EMAIL);
  $self->{'external_dest'} = NOCpulse::Notif::EmailContactMethod->new( 'email' => $MY_EXTERNAL_EMAIL);
  $self->{'nowhere_dest'}  = NOCpulse::Notif::EmailContactMethod->new( 'email' => $NOWHERE_EMAIL);

  $self->{'group'}=$MODULE->new();

}

# INSERT INTERESTING TESTS HERE

#sub test_send {
#}

##########################
sub test_add_destination {
##########################
  my $self=shift;
  my $group=$self->{'group'};

  $group->add_destination($self->{'internal_dest'});
  $group->add_destination($self->{'external_dest'});
  $group->add_destination($self->{'nowhere_dest'});
  
  my $item=shift(@{$group->destinations});
  $self->assert($item->email eq $MY_INTERNAL_EMAIL,"internal email");
  $item=shift(@{$group->destinations});
  $self->assert($item->email eq $MY_EXTERNAL_EMAIL,"external email");
  $item=shift(@{$group->destinations});
  $self->assert($item->email eq $NOWHERE_EMAIL,"nowhere email");
}

###################################
sub test_rotate_first_destination {
###################################
  my $self=shift;
  my $group=$self->{'group'};

  $group->add_destination($self->{'internal_dest'});
  $group->add_destination($self->{'external_dest'});
  $group->add_destination($self->{'nowhere_dest'});

  my @list=$group->rotate_first_destination;
  $Log->dump(9,"(1)\n",@list,"\n");
  my $item=shift(@list);
  $self->assert($item->email eq $MY_INTERNAL_EMAIL,"internal email (1)");
  $item=shift(@list);
  $self->assert($item->email eq $MY_EXTERNAL_EMAIL,"external email (1)");
  $item=shift(@list);
  $self->assert($item->email eq $NOWHERE_EMAIL,"nowhere email (1)");

  @list=$group->rotate_first_destination;
  $Log->dump(9,"(2)\n",@list,"\n");
  $item=shift(@list);
  $self->assert($item->email eq $MY_EXTERNAL_EMAIL,"external email (2)");
  $item=shift(@list);
  $self->assert($item->email eq $NOWHERE_EMAIL,"nowhere email (2)");
  $item=shift(@list);
  $self->assert($item->email eq $MY_INTERNAL_EMAIL,"internal email (2)");

  @list=$group->rotate_first_destination;
  $Log->dump(9,"(3)\n",@list,"\n");
  $item=shift(@list);
  $self->assert($item->email eq $NOWHERE_EMAIL,"nowhere email (3)");
  $item=shift(@list);
  $self->assert($item->email eq $MY_INTERNAL_EMAIL,"internal email (3)");
  $item=shift(@list);
  $self->assert($item->email eq $MY_EXTERNAL_EMAIL,"external email (3)");

  @list=$group->rotate_first_destination;
  $Log->dump(9,"(4)\n",@list,"\n");
  $item=shift(@list);
  $self->assert($item->email eq $MY_INTERNAL_EMAIL,"internal email (4)");
  $item=shift(@list);
  $self->assert($item->email eq $MY_EXTERNAL_EMAIL,"external email (4)");
  $item=shift(@list);
  $self->assert($item->email eq $NOWHERE_EMAIL,"nowhere email (4)");
} 

######################
sub test_designation {
######################
  my $self = shift;
  my $group = $self->{'group'};
  my $designation = $group->designation;
  $self->assert($designation eq 'g',"test_designation");
}

#################################
sub test_new_strategy_for_alert {
#################################
  my $self = shift;
  my $group = $self->{'group'};
  $group->strategy('NOCpulse::Notif::BroadcastStrategy');
  my $alert = NOCpulse::Notif::Alert->new( 
    'fmt_subject' => 'test subject one',
    'fmt_message' => 'this is the body of test one',
    'send_id'     => '0101');

  my $strategy = $group->new_strategy_for_alert($alert);
  $self->assert(qr/NOCpulse::Notif::BroadcastStrategy/,"$strategy");
}

1;
