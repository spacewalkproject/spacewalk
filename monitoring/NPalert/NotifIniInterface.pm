package NOCpulse::Notif::NotifIniInterface;

use strict;
use strict;
use Class::MethodMaker
  new_with_init => 'new',
  new_hash_init => '_hash_init',
  get_set       => [qw( config_dir )];

use Date::Parse;
use NOCpulse::Log::Logger;
use NOCpulse::Notif::PagerContactMethod;
use NOCpulse::Notif::EmailContactMethod;
use NOCpulse::Notif::SimpleEmailContactMethod;
use NOCpulse::Notif::ContactGroup;
use NOCpulse::Notif::BroadcastStrategy;
use NOCpulse::Notif::EscalateStrategy;
use NOCpulse::Notif::RotateFirstEscalateStrategy;
use NOCpulse::Notif::Customer;
use NOCpulse::Notif::MessageFormat;
use NOCpulse::Notif::Redirect;
use NOCpulse::Notif::AutoAckRedirect;
use NOCpulse::Notif::BlackholeRedirect;
use NOCpulse::Notif::MeTooRedirect;
use NOCpulse::Notif::RedirectCriterion;
use NOCpulse::Notif::Schedule;
use NOCpulse::Notif::ScheduleDay;
use NOCpulse::Notif::NotificationIni;

# Globals
my $cfg        = new NOCpulse::Config;
my $PRODCFG    = $cfg->get('notification', 'config_dir');
my $CONFIGBASE = "$PRODCFG";
my $CONFIG     = "$CONFIGBASE/generated";
my $STAGEBASE  = "$CONFIGBASE/stage";
my $STAGEDIR   = "$STAGEBASE/config";
my $STAGE      = "$STAGEDIR/generated";

my $nini = new NOCpulse::Notif::NotificationIni;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

# Constants for time conversion
my $SECS  = 1;
my $MINS  = 60 * $SECS;
my $HOURS = 60 * $MINS;

my @DOW = qw(Sunday Monday Tuesday Wednesday Thursday Friday Saturday);

##########
sub init {
##########
  my ($self, %args) = @_;

  my $config = $args{'config'};
  if ($config =~ /stage/) {
    $self->config_dir($STAGE);
    delete($args{'config'});
  }
  unless ($self->config_dir) {
    $self->config_dir($CONFIG);
  }

  $self->_hash_init(%args);
} ## end sub init

#########################
sub buildContactMethods {
#########################

  # Get a list of all contact methods from the ini file.
  # Returns a hash keyed on recid.

  my ($self, $formats, $schedules) = @_;

  #### HERE  ####

  my $fn = sub {
    my ($hashptr) = @_;

    my $type = $hashptr->{'method_type_id'};

    my $method = undef;

    if ($type == 1) {

      # pager
      $method = new NOCpulse::Notif::PagerContactMethod;
      $method->pager_max_message_length($hashptr->{'pager_max_message_length'});
      $method->split_long_messages($hashptr->{'pager_split_long_messages'});
      $method->email($hashptr->{'pager_email'});
    } elsif ($type == 2) {

      # email
      $method = new NOCpulse::Notif::EmailContactMethod;
      $method->email($hashptr->{'email_address'});
    }

    if ($method) {
      $method->olson_tz_id($hashptr->{'olson_tz_id'});
      $method->message_format(
                            $formats->{ $hashptr->{'notification_format_id'} });
      $method->contact_id($hashptr->{'contact_id'});

      my $key = join(' ', $hashptr->{'schedule_id'}, $hashptr->{'olson_tz_id'});
      my $schedule = $schedules->{$key};
      die(  "no schedule found for $key: schedule_id "
          . $hashptr->{'schedule_id'}
          . ", olson_tz_id:  "
          . $hashptr->{'olson_tz_id'})
        unless $schedule;
      $method->schedule($schedule);

      $method->recid($hashptr->{'recid'});
      $method->name($hashptr->{'method_name'});
    } ## end if ($method)
    return $method;
  };

  #Clear out the key_attrib list kept by Class::MethodMaker
  my $ref = NOCpulse::Notif::ContactMethod->find_recid();
  undef(%$ref);

  $nini->file_name($self->config_dir . "/contact_methods.ini");
  my $hashptr = $nini->create_hash($fn, 'recid');

  return $hashptr;

}    # End of buildContactMethods

#########################
sub buildContactGroups {
#########################

  # Get a list of all contact_groups from the ini file.
  # Returns a hash keyed on recid.

  my ($self, $contacts, $customers) = @_;

  my $fn = sub {

    my ($hashptr) = @_;

    my $group = new NOCpulse::Notif::ContactGroup;
    $group->customer_id($hashptr->{'customer_id'});
    $group->name($hashptr->{'contact_group_name'});
    $group->recid($hashptr->{'recid'});

    my ($contact_strategy, $ack_completed) =
      split(/:/, $hashptr->{'strategy'}, 2);
    my $rotate = $hashptr->{'rotate_first'};

    if ($contact_strategy =~ /Escalate/) {

      #Escalate
      if ($rotate) {
        $group->strategy('NOCpulse::Notif::RotateFirstEscalateStrategy');
      } else {
        $group->strategy('NOCpulse::Notif::EscalateStrategy');
      }
    } else {

      #Broadcast
      $group->strategy('NOCpulse::Notif::BroadcastStrategy');
    }
    $group->ack_method($ack_completed);
    $group->ack_wait($hashptr->{'ack_wait'});

    foreach (split(',', $hashptr->{'members'})) {
      $_ =~ s/^i//g;
      my $contact = $contacts->{$_};
      if ($contact) {
        $group->add_destination($contact);
        $contact->customer_id($group->customer_id);
      }
    }
    return $group;
  };

  #Clear out the key_attrib list kept by Class::MethodMaker
  my $ref = NOCpulse::Notif::ContactGroup->find_recid();
  undef(%$ref);

  $nini->file_name($self->config_dir . "/contact_groups.ini");
  my $hashptr = $nini->create_hash($fn, 'recid');

  return $hashptr;

}    # End of buildContactGroups

sub checkCustomersExist {
  my $self = shift;
  return (-f ($self->config_dir . "/customers.ini"));
}

####################
sub buildCustomers {
####################

  # Get a list of all customers from the ini file.
  # Returns a hash keyed on recid.

  my ($self) = @_;

  my $fn = sub {
    my ($hashptr) = @_;
    delete($hashptr->{'redirects'});
    my $group = new NOCpulse::Notif::Customer(@_);
  };

  #Clear out the key_attrib list kept by Class::MethodMaker
  my $ref = NOCpulse::Notif::Customer->find_recid();
  undef(%$ref);

  $nini->file_name($self->config_dir . "/customers.ini");
  my $hashptr = $nini->create_hash($fn, 'recid');

  return $hashptr;

}    # End of buildCustomers

#########################
sub buildMessageFormats {
#########################

  # Get a list of all formats` from the ini file.
  # Returns a hash keyed on recid.

  my ($self) = @_;

  my $fn = sub {
    my $obj = NOCpulse::Notif::MessageFormat->new(%{ $_[0] });
    return $obj;
  };

  #Clear out the key_attrib list kept by Class::MethodMaker
  my $ref = NOCpulse::Notif::MessageFormat->find_recid();
  undef(%$ref);

  $nini->file_name($self->config_dir . "/message_formats.ini");
  my $hashptr = $nini->create_hash($fn, 'recid');

  return $hashptr;

}    # End of buildMessageFormats

####################
sub buildRedirects {
####################

  # Get a list of all redirects from the ini file.
  # Returns a hash keyed on recid.

  my ($self, $customers, $groups, $methods) = @_;

  my $fn = sub {
    my ($ptr) = @_;
    my $redirect;
    my $type    = $ptr->{'redirect_type'};
    my $targets = $ptr->{'targets'};

    delete($ptr->{'targets'});

    if ($type eq 'ACK') {
      $redirect = new NOCpulse::Notif::AutoAckRedirect($ptr);
    } elsif ($type eq 'BLACKHOLE') {
      $redirect = new NOCpulse::Notif::BlackholeRedirect($ptr);
    } elsif ($type eq 'METOO') {
      $redirect = new NOCpulse::Notif::MeTooRedirect($ptr);
    } else {
      $redirect = new NOCpulse::Notif::Redirect($ptr);
    }

    # Process the redirect targets
    my @targets = split(',', $targets);
    foreach (@targets) {
      my $new_target;
      my ($prefix, $id) = split(//, $_, 2);
      if ($prefix eq 'g') {
        $new_target = $groups->{$id};
      } elsif ($prefix eq 'i') {
        $new_target = $methods->{$id};
      } else {
        $new_target =
          NOCpulse::Notif::SimpleEmailContactMethod->new(
                    'email'          => $id,
                    'message_format' => NOCpulse::Notif::MessageFormat->default,
                    'contact_id'     => $ptr->{'contact_id'}
          );
      }
      if ($new_target) {
        $redirect->add_target($new_target);
      } else {
        $Log->log(1,
                 "DATA Corruption: cannot find redirect target $prefix$id for ",
                 $redirect->recid, "\n");
      }
    } ## end foreach (@targets)

    # Add the redirect to the appropriate customer
    my $customer_id = $redirect->customer_id();
    my $customer    = $customers->{$customer_id};
    if ($customer_id) {
      if ($customer) {
        $customer->addRedirect($redirect);
      } else {

        # Can't find the specified customer; this is an error
        $Log->log(
          1,
"DATA Corruption: cannot find customer target $customer_id for redirect #",
          $redirect->recid,
          "\n"
        );
      } ## end else [ if ($customer)
    } else {

      # If the customer_id is null, this must apply to all customers
      foreach (values(%$customers)) {
        $_->addRedirect($redirect);
      }
    }

    return $redirect;
  };

  #Clear out the key_attrib list kept by Class::MethodMaker
  my $ref = NOCpulse::Notif::Redirect->find_recid();
  undef(%$ref);

  #Clear out the redirects kept by Customer in case we load redirects only
  foreach (values(%$customers)) {
    $_->redirects_clear;
  }

  $nini->file_name($self->config_dir . "/redirects.ini");
  my $hashptr = $nini->create_list_hash($fn, 'recid', '-');

  my $fn2 = sub {
    my ($ptr) = @_;
    my $hack_map = {
      'check' => 'ServiceProbe',
      'host'  => 'HostProbe',
      ## 'suite'      => '',
      ## 'satcluster' => '',
      ## 'satnode'    => '',
      'url' => 'LongLegs'
                   };
    my $item = new NOCpulse::Notif::RedirectCriterion($ptr);

    # Convert new host probe types to old ones
    if ($item->match_param() eq 'PROBE_TYPE') {
      my $type = $item->match_value();
      if (exists($hack_map->{$type})) {
        $item->match_value($hack_map->{$type});
      }
    }

    my $redirects = $hashptr->{ $item->redirect_id() };
    foreach my $redirect (@$redirects) {
      if ($redirect) {
        $redirect->add_criterion($item) if $redirect;
      } else {
        $Log->log(1, "DATA Corruption: cannot find redirect ",
                  $item->redirect_id, "\n");
      }
    }
    return $item;
  };

  #Clear out the key_attrib list kept by Class::MethodMaker
  $ref = NOCpulse::Notif::RedirectCriterion->find_recid();
  undef(%$ref);

  $nini->file_name($self->config_dir . "/redirect_criteria.ini");
  $nini->create_collection($fn2, 'recid');

  return $hashptr;

  #Process email targets.  Note gui doesn't allow contact groups or methods

}    # End of buildRedirects

###################
sub _convertStart {
###################
  # Convert the start time in hours and minutes to seconds since midnight.
  my $self   = shift();
  my $string = shift();
  return undef unless $string;
  my ($hours, $mins) = split(/:/, $string);
  return ($hours * $HOURS) + ($mins * $MINS);
}

#################
sub _convertEnd {
#################
  # Convert the end time in hours and minutes to seconds since midnight.
  # Add an additional 59 seconds to get us to the exact end of the timeframe
  # specified in the ini file.
  my $self   = shift();
  my $string = shift();
  return undef unless $string;
  my ($hours, $mins) = split(/:/, $string);
  return $hours * $HOURS + $mins * $MINS + 59;
} ## end sub _convertEnd

####################
sub buildSchedules {
####################

  # Get a list of all schedules from the ini file.
  # Returns a hash keyed on recid.

  my ($self) = @_;

  my $fn = sub {
    my ($hashptr) = @_;

    my @keys = qw(start1 end1 start2 end2 start3 end3 start4 end4);

    my %days;
    foreach my $index (0 .. 6) {
      my @array = split(/[,-]/, $hashptr->{ $DOW[$index] }, 8);
      my $day =
        NOCpulse::Notif::ScheduleDay->new(
                                    'start1' => $self->_convertStart($array[0]),
                                    'end1'   => $self->_convertEnd($array[1]),
                                    'start2' => $self->_convertStart($array[2]),
                                    'end2'   => $self->_convertEnd($array[3]),
                                    'start3' => $self->_convertStart($array[4]),
                                    'end3'   => $self->_convertEnd($array[5]),
                                    'start4' => $self->_convertStart($array[6]),
                                    'end4'   => $self->_convertEnd($array[7]),
                                    'dayNum' => $index
        );
      delete($hashptr->{ $DOW[$index] });
      $days{$index} = $day;
    } ## end foreach my $index (0 .. 6)

    my $schedule = new NOCpulse::Notif::Schedule(@_);
    my ($key, $value);
    while (($key, $value) = each(%days)) {
      $schedule->add_day($key, $value);
    }
    return $schedule;
  };

  #Clear out the key_attrib list kept by Class::MethodMaker
  my $ref = NOCpulse::Notif::ScheduleDay->find_recid();
  undef(%$ref);

  $nini->file_name($self->config_dir . "/schedules.ini");
  my $hashptr = $nini->create_hash($fn);

  return $hashptr;

} ## end sub buildSchedules

1;

__END__

=head1 NAME

NOCpulse::Notif::NotifIniInterface - Interface to ini files to create the object required to run the notification system.

=head1 SYNOPSIS

# Create a new interface
$interface=NOCpulse::Notif::NotifIniInterface->new(
  'config'     => 'stage',
  'config_dir' => '/etc/notification/generated');

# Create a hash of customers
$customers=$interface->buildCustomers();

# Create a hash of formats
$formats=$interface->buildMessageFormats();

# Create a hash of schedules
$schedules=$interface->buildSchedules();

# Create a hash of contact methods
$methods=$interface->buildContactMethods($formats,$schedules);

# Create a hash of contact groups
$groups=$interface->buildContactGroups($contacts,$customers);
=head1 DESCRIPTION

The C<NotifIniInterface> object is the means of creating objects to run the notification system from ini files created by generate-config.

=head1 CLASS METHODS

=over 4

=item new ( [%args] )

Create a new object with the supplied arguments, if any.

=back

=head1 METHODS

=over 4

=item buildContactGroups ( $contacts, $customers )

Return a reference to a hash containing pairs where the key is the recid and the value is a ContactGroup object.  Requires a reference to similar hash of Contacts and Customers.

=item buildContactMethods ( $formats, $schedules )

Return a reference to a hash containing pairs where the key is the recid and the value is a ContactMethod object.  Requires a reference to similar hash of MessageFormats and Schedules.

=item buildCustomers ( )

Return a reference to a hash containing pairs where the key is the recid and the value is a Customer object.

=item buildMessageFormats ( )

Return a reference to a hash containing pairs where the key is the recid and the value is a MessageFormat object.

=item buildRedirects ( $cstuomers, $groups, $methods )

Return a reference to a hash containing pairs where the key is the recid and the value is a Redirect object.  Requires a reference to similar hash of Customers, ContactGroups, and ContactMethods.

=item buildSchedules ( )

Return a reference to a hash containing pairs where the key is the recid and the value is a Schedule object.

=item config_dir ( [$dirname] )

Get or set the directory name containing the ini configuration files.

=item init ( @args )

Initialize the object with the given arguments.

=back

=head1 BUGS

No known bugs.

=head1 AUTHOR

Karen Jacqmin-Adams <kja@redhat.com>

Last update: $Date: 2005-06-03 20:05:54 $

=head1 SEE ALSO

B<NOCpulse::Notif::ContactGroup>
B<NOCpulse::Notif::ContactMethod>
B<NOCpulse::Notif::Customers>
B<NOCpulse::Notif::MessageFormat>
B<NOCpulse::Notif::Redirect>
B<NOCpulse::Notif::Schedule>
B</bin/dir/notifserver.pl>

=cut
