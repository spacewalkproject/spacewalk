package NOCpulse::Probe::SNMP::MibEntryList;

use strict;

use Error;
use NOCpulse::Log::Logger;
use NOCpulse::Probe::Result;
use NOCpulse::Probe::SNMP::MibEntry;
use NOCpulse::Probe::MessageCatalog;

use Class::MethodMaker
  get_set =>
  [qw(
      _message_catalog
     )],
  list =>
  [qw(
      entries
     )],
  hash =>
  [qw(
      entry_named
     )],
  new_with_init => 'new',
  ;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

use constant MEMORY_PREFIX => 'MIB-CACHED-INDEX-';


sub init {
    my ($self, @entry_hash_list) = @_;

    $self->_message_catalog(NOCpulse::Probe::MessageCatalog->instance());

    my @mib_entries = ();
    map { push(@mib_entries, NOCpulse::Probe::SNMP::MibEntry->new($_)) } @entry_hash_list;
    $self->add_entries(@mib_entries);
}

sub add_entries {
    my ($self, @mib_entries) = @_;

    $self->entries_push(@mib_entries);

    foreach my $entry (@mib_entries) {
        $self->entry_named($entry->name, $entry);
    }
}

sub run {
    my ($self, %args) = @_;
    my $factory = $args{data_source_factory};
    my %params = %{$args{params}};

    my $snmp = $factory->snmp(ip           => $params{ip},
                              port         => $params{port},
                              version      => $params{version},
                              community    => $params{community},
                              auto_connect => 1);
    $self->process($snmp, $args{result}, $args{memory});
    $snmp->disconnect();
}

sub process {
    my ($self, $snmp_data_source, $result, $memory) = @_;
    
    # The suffix of the last index OID looked up
    my $current_index_suffix = '';
    
    foreach my $entry ($self->entries) {
        $Log->log(2, "MIB entry: ", $entry->name, "\n");
        $Log->dump(4, "", $entry, "\n");
        
        if ($entry->is_index) {
            # Look up an index for use in subsequent fetches.
            $current_index_suffix = $self->fetch_index($entry, $snmp_data_source,
                                                       $result, $memory);
            if ($snmp_data_source->errors) {
                throw NOCpulse::Probe::DataSource::ConnectError($snmp_data_source->errors);
            }
            last unless $current_index_suffix;  # Not defined means no match

        } else {
            # Plain OID
            my $data = $snmp_data_source->fetch_oid_value($entry->oid.$current_index_suffix);

            unless (defined($data)) {
                # Can't find the OID, implies a connection problem or coding error.
                if ($snmp_data_source->errors) {
                    throw NOCpulse::Probe::DataSource::ConnectError($snmp_data_source->errors);
                } else {
                    $Log->log(2, "OID ", $entry->oid, " not found\n");
                    $result->internal_data_not_found($entry->metric);
                }

            } else {
                $Log->log(2, "OID value '$data'\n");

                $entry->fetched_value($data);

                if ($entry->data_type eq $snmp_data_source->SMALL_COUNTER_TYPE
                    || $entry->data_type eq $snmp_data_source->BIG_COUNTER_TYPE) {

                    # Convert the counter to a rate.
                    my $wrap = $snmp_data_source->COUNTER_WRAP($entry->data_type);
                    my $item = $result->metric_rate($entry->metric,
                                                    $data,
                                                    $entry->value_format,
                                                    1,
                                                    $wrap);

                } elsif ($entry->metric) {
                    # Record the metric, dividing by the divisor if present.
                    $data /= $entry->divisor if $entry->divisor;
                    $result->metric_value($entry->metric, $data, $entry->value_format);

                } elsif ($entry->data_type eq $snmp_data_source->STATE_VALUE_TYPE) {
                    # Translate the output string to the vendor's value,
                    # and the state to our status value. These cannot be
                    # metrics because they are not numeric values.
                    my $item;
                    if ($entry->vendor_enum) {
                        $item = $result->item_value($entry->label, $entry->vendor_enum($data));
                    } else {
                        $item = $result->item_value($entry->label, $data, $entry->value_format);
                    }
                    if ($entry->status_enum) {
                        $item->status($entry->status_enum($data));
                    }                            

                } else {
                    # Not a metric or state, just record it
                    my $save_as = $entry->label;
                    $save_as ||= $entry->name;
                    $result->item_value($save_as, $data, $entry->value_format);
                }
            }
        }
    }
}

# Returns the index suffix of an SNMP table whose value matches
# a user-entered string, or undef if none found.
sub fetch_index {
    my ($self, $entry, $snmp_data_source, $result, $memory) = @_;

    $Log->log(2, "Fetch ", $entry->name, "\n");

    my $match_value = $self->match_value($entry, $result);

    my $cached = $entry->cached_index_suffix;
    my $cache_key = MEMORY_PREFIX . $entry->name;
    $cached ||= $memory->{$cache_key};

    my $data = $snmp_data_source->fetch_cached_index($entry->oid, $cached, $match_value);
    my $current_index_suffix;

    if (defined($data->{index_suffix})) {
        $current_index_suffix = $data->{index_suffix};
        $entry->fetched_value($data->{value});
        $memory->{$cache_key}= $data->{index_suffix};

        # Save this one as the context.
        my $context = $entry->label . " " . $data->{value};
        my $existing_context = $result->context;
        if ($existing_context) {
            $context = "$existing_context, $context";
        }
        $result->context($context);
        $Log->log(2, "Got suffix $current_index_suffix, value ", $data->{value}, "\n");
        
    } else {
        # Can't find the index, implies a user misconfiguration.
        # No point in continuing because everything downstream
        # depends on the index being found.
        $Log->log(2, "No match for ", $match_value, "\n");
        if ($entry->match_any) {
            # Means the index OID failed to match, because any hit will work
            $result->internal_data_not_found($entry->name);
        } else {
            $result->user_data_not_found($entry->label || $entry->name, $match_value);
        }
    }
    return $current_index_suffix;
}

# Returns the value to match in an index lookup. 
# The entry can directly define the value to match or give the
# parameter whose value is the value to match.
sub match_value {
    my ($self, $entry, $result) = @_;

    # Match any means the first row in the table is fetched, flagged
    # by not setting a match value, so the value starts as undef.
    $entry->match_any and return undef;

    my $match_value;

    if ($entry->match_index_param and not $entry->match_index_value) {
        # Use the current value of the match parameter.
        my $param_name = $entry->match_index_param;

        $match_value = $result->probe_record->parameters->{$param_name};
        my $param = $result->command_record->parameters->{$param_name};

        if ($param) {
            # Set the entry's label to the parameter's description unless
            # it already has a label.
            $entry->label($param->description) unless $entry->label;
            $match_value ||= $param->description . ' not specified';

        } else {
            # Internal misconfiguration, die violently
            throw NOCpulse::Probe::InternalError("Cannot find index parameter '$param_name' in "
                                                 . $entry->to_string);
        }
    } else {
        # Use the value specifically set
        $match_value = $entry->match_index_value;
    }

    $match_value ||= '<unspecified>';  # Assign a bogus match value if undefined

    return $match_value;
}

1;
