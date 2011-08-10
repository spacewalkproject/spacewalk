package NOCpulse::Probe::Config::ProbeRecord;

use strict;

use Error;
use Data::Dumper;

use NOCpulse::Probe::Error;

use Class::MethodMaker
  get_set =>
  [qw(
      auto_update
      check_interval
      command_group_name 
      command_id
      command_long_name
      contact_group_customers
      contact_group_names
      contact_groups
      customer_id
      description
      host_id
      host_ip
      host_name
      llconfig
      max_attempts
      notification_interval
      notify_critical
      notify_recovery
      notify_warning
      notify_unknown
      os_id
      os_name
      parameters
      physical_location_name
      probe_type
      queue_urls
      recid
      retry_interval
      sat_cluster_id
     )],
  new_with_init => 'new',
  new_hash_init => 'hash_init',
  ;

my %FIELD_MAP = 
  (
   CHECK_COMMAND         => 'command_id',
   HOST_NAME             => undef,
   NETSAINT_ID           => 'sat_cluster_id',
   PARENT_PROBES_ID      => undef,
   ADDRESS               => undef,
   contactGroupCustomers => 'contact_group_customers',
   contactGroupNames     => 'contact_group_names',
   HOSTADDRESS           => 'host_ip',
   HOSTNAME              => 'host_name',
   hostRecid             => 'host_id',
   parsedCommandLine     => 'parameters',
  );

# Maps field names to lower case, or renames according to the field map.
sub init {
    my ($self, $arg_hashref) = @_;

    $arg_hashref && ref($arg_hashref)
      or throw NOCpulse::Probe::InternalError("Must provide hashref instead of '$arg_hashref'");

    my %renamed_args = ();

    foreach my $field (keys %$arg_hashref) {
        if (exists $FIELD_MAP{$field}) {
            my $mapped = $FIELD_MAP{$field};
            # An undef for the mapped value means to skip the field.
            $renamed_args{$mapped} = $arg_hashref->{$field} if ($mapped);
        } else {
            $renamed_args{lc($field)} = $arg_hashref->{$field};
        }
    }
    $self->hash_init(%renamed_args);
}

sub to_string {
    my $self = shift;

    return Dumper($self);
}

1;
