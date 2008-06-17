package NOCpulse::Probe::SNMP::MibEntry;

use strict;

use Data::Dumper;

use NOCpulse::Log::Logger;
use NOCpulse::Probe::DataSource::SNMP;

use Class::MethodMaker
  # Note: is_message_context is true if this entry's value acts
  # as context for the whole output string
  get_set =>
  [qw(
      name
      oid
      label
      data_type
      metric
      match_any
      match_index_param
      match_index_value
      cached_index_suffix
      fetched_value
      divisor
      value_format
      is_index
      is_message_context
     )],
  hash =>
  [qw(
      vendor_enum
      status_enum
     )],
  new_with_init => 'new',
  new_hash_init => 'hash_init',
  ;

sub init {
    my $self = shift;
    my %args = (scalar @_ == 1 and ref($_[0]) eq 'HASH') ? %{ $_[0] } : @_;

    $self->hash_init(%args);

    # Validate the data type.
    unless (NOCpulse::Probe::DataSource::SNMP::VALID_TYPES()->{$self->data_type}) {
        my $msg = sprintf(NOCpulse::Probe::MessageCatalog->instance->snmp('bad_data_type'),
                          $self->data_type, 
                          join(', ', 
                               sort keys %{NOCpulse::Probe::DataSource::SNMP::VALID_TYPES()}));
        throw NOCpulse::Probe::InternalError($msg);
    }                                            

    # Add a default label to enums.
    if (not defined($self->label) and $self->data_type eq 'STATE_VALUE') {
        $self->label('State');
    }

    # Add a default format based on data type.
    unless ($self->value_format) {
        if ($self->data_type eq 'INTEGER') {
            $self->value_format('%d');
        } elsif ($self->data_type =~ /^COUNTER\d\d/) {
            $self->value_format('%.2f');
        }
    }
}

sub to_string {
    my $self = shift;
    return Dumper($self);
}

1;
