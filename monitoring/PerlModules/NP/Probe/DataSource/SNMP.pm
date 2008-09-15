package NOCpulse::Probe::DataSource::SNMP;

use strict;

use Carp;
use Net::SNMP;
use Error;
use NOCpulse::Log::Logger;
use NOCpulse::Probe::Error;

use base qw(NOCpulse::Probe::DataSource::AbstractDataSource);

use Class::MethodMaker
  get_set =>
  [qw(
      ip
      port
      community
      version
      net_snmp
      raw_error
     )],
  static_hash =>
  [qw(
      COUNTER_WRAP
     )],
  new_with_init => 'new',
  new_hash_init => 'hash_init',
  ;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

use constant DEFAULT_COMMUNITY => 'public';
use constant DEFAULT_VERSION   => 1;
use constant DEFAULT_PORT      => 161;
my $SNMP_ERR_REGEX = qr/noSuch(Name|Object|Instance)/;

# SNMP types

# Any textual string (no thresholds are checked)
use constant STRING_TYPE => 'OCTET_STRING';
# Any number value (commas are inserted)
use constant NUMBER_TYPE => 'INTEGER';
# Any 32 bit counter (result is events per second)
use constant SMALL_COUNTER_TYPE => 'COUNTER32';
# Any 64 bit counter (result is events per second)
use constant BIG_COUNTER_TYPE => 'COUNTER64';
# Any value that has a digit as the result that is translated to a state
use constant STATE_VALUE_TYPE => 'STATE_VALUE';

use constant VALID_TYPES =>
  {
   STRING_TYPE()        => 1, 
   NUMBER_TYPE()        => 1, 
   SMALL_COUNTER_TYPE() => 1, 
   BIG_COUNTER_TYPE()   => 1,
   STATE_VALUE_TYPE()   => 1,
  };

# Detecting counter wraparound -- see /usr/local/snmp/share/snmp/mibs/SNMPv2-MIB.txt
NOCpulse::Probe::DataSource::SNMP->COUNTER_WRAP
  (
   COUNTER32 => 4294967295,
   COUNTER64 => 18446744073709551615,
  );


# Sets up defaults for port, community, and version.
# Raises DataSource::ConfigError if there's no IP or host name.
sub init {
    my ($self, %args) = @_;

    $args{port}      ||= DEFAULT_PORT;
    $args{community} ||= DEFAULT_COMMUNITY;
    $args{version}   ||= DEFAULT_VERSION;
    $args{ip} or throw NOCpulse::Probe::DataSource::ConfigError('snmp', 'no_ip');

    $self->SUPER::init(%args);
}

# Connects to the SNMP agent. Raises DataSource::ConnectError if
# connection fails.
sub connect {
    my $self = shift;
    my ($net_snmp, $error) =
      Net::SNMP->session(hostname  => $self->ip,
                         community => $self->community,
                         version   => $self->version,
                         port      => $self->port);
    if ($error) {
        $self->errors($error);
        $self->connected(0);
    } else {
        $self->net_snmp($net_snmp);
        $self->connected(1);
    }

    unless ($self->connected) {
        $self->_raise_connect_error();
    } else {
        $Log->log(2, 'Connected to ', $self->_connect_info, "\n");
    }
    return $self->connected;
}

# Disconnects from the SNMP agent.
sub disconnect {
    my $self = shift;
    $self->net_snmp->close if $self->net_snmp;
    if ($self->connected) {
        $Log->log(2, 'Disconnected from ', $self->_connect_info, "\n");
        $self->connected(0);
    }
}

# Fetches and returns the value for a single OID. The value
# is also assigned to the results field.
# Raises DataSource::NotConnected if connect has not been called.
sub fetch_oid_value {
    my ($self, $oid) = @_;
    
    $self->results(undef);
    
    $self->_ensure_connected();
    
    $Log->log(2, "Get OID $oid\n");
    
    my $response = $self->net_snmp->get_request($oid);

    if ($self->_response_problem($response, $oid)) {
        $self->_describe_fetch_error($response, $oid);
        if ($self->raw_error =~ /Connection refused/) {
            $self->_raise_connect_error();
        }
        return undef;

    } else {
        $Log->log(2, "Got ", $response->{$oid}, "\n");
        $self->results($response->{$oid});
        $self->errors(undef);
        return $response->{$oid};
    }
}

# Fetches and returns a hash ref with key "index_suffix" holding the index suffix
# and "value" the value of an index OID in an SNMP table. The suffix is
# the portion of the index OID after the requested OID; this index can
# then be appended to other OIDs to get the equivalent entry for a
# different table.
# The chosen row is matched based on a case-insensitive
# comparison to the "match" argument, if any; otherwise returns the first
# table row.
# Raises DataSource::NotConnected if connect has not been called.
sub fetch_index {
    my ($self, $index_oid, $match) = @_;
    
    $self->results(undef);
    
    $self->_ensure_connected();
    
    $Log->log(4, "Get index $index_oid, match '$match'\n");
    my $response = $self->net_snmp->get_table($index_oid);
    $Log->log(4, "Got $response\n");
    
    if ($self->_response_problem($response, $index_oid)) {
        $self->_describe_fetch_error($response, $index_oid);
        if ($self->raw_error =~ /Connection refused/) {
            $self->_raise_connect_error();
        }
        
    } else {
        my $match_first = !(defined $match);
        
        my $lc_match_value = lc($match) unless $match_first;
        
        while (my ($key, $value) = each %{ $response }) {
            $Log->log(4, "Got key $key, value $value\n");
            if ($match_first || lc($value) eq $lc_match_value) {
                $Log->log(4, "Key matched", $match_first ? ' (first match)' : '', "\n");
                my $suffix = substr($key, length($index_oid));
                $self->results({index_suffix => $suffix, value => $value});
                last;
            }
        }
        $self->errors(undef);
    }
    
    return $self->results;
}

# Same as fetch_index, but first checks whether the value for a
# cached index OID is still the right one. If it is, returns the
# index key and value passed in, otherwise refetches the table and
# does the index lookup. If the cached index suffix is null behaves
# like a call to fetch_index.
sub fetch_cached_index {
    my ($self, $index_oid, $cached_index_sufix, $match) = @_;
    
    $self->results(undef);
    
    $self->_ensure_connected();
    
    $Log->log(4, "Get index $index_oid, ".
              "previous value '$cached_index_sufix', ".
              "match '$match'\n");
    
    if ($cached_index_sufix) {
        my $value = $self->fetch_oid_value($index_oid.$cached_index_sufix);
        if (lc($value) eq lc($match)) {
            $self->results({index_suffix => $cached_index_sufix, value => $value});
            $Log->log(4, "Hit\n");
        } else {
            # Clear the results of the erroneous fetch.
            $self->results(undef);
        }
    }
    unless ($self->results) {
        $Log->log(4, "Miss\n");
        $self->fetch_index($index_oid, $match);
    }
    
    return $self->results;
}



# Helper methods


# Raises DataSource::ConnectError with the appropriate message.
sub _raise_connect_error {
    my $self = shift;
    my $msg = sprintf($self->_message_catalog->snmp('connect_failed'),
                      $self->ip, $self->port, $self->version);
    $Log->log(1, 'Connection failed: ', $self->_connect_info, "\n");
    throw NOCpulse::Probe::DataSource::ConnectError($msg);
}

# Raises DataSource::NotConnected if connect has not been called.
sub _ensure_connected {
    my ($self) = @_;
    unless ($self->net_snmp) {
        $Log->log(1, "Error: no current SNMP session\n");
        $self->results(undef);
        $self->errors('SNMP->connect has not been called');
        my $msg = $self->_message_catalog->snmp('not_connected');
        throw NOCpulse::Probe::DataSource::NotConnected($msg);
    }
}

# Formats a string with connection information. This is
# for logging only, because it includes the community string.
sub _connect_info {
    my $self = shift;
    return "host " . $self->ip . 
      ", community " . $self->community .
        ", version " . $self->version .
          ", port " . $self->port;
}

# Returns true if the response is undefined or its value looks
# like an SNMP error message.
sub _response_problem {
    my ($self, $response, $oid) = @_;

    $oid or throw NOCpulse::Probe::InternalError("No OID provided");

    return 1 unless $response;
    return $response->{$oid} =~ /$SNMP_ERR_REGEX/;
}

# Sets the errors field to contain the translated SNMP error message.
sub _describe_fetch_error {
    my ($self, $response, $oid) = @_;
    $self->results(undef);
    my $error;
    if ($response) {
        $error = $response->{$oid};
    } else {
        $error = $self->net_snmp->error;
    }
    $Log->log(1, "Error: ", $error, "\n");
    $self->raw_error($error);
    $self->errors($self->_translate_snmp_error($error));
}

# Translates the SNMP error to a message catalog error.
sub _translate_snmp_error {
    my ($self, $orig_message) = @_;
    my $error_id;
    my $translated_error;
    while (($error_id, $translated_error) = each (%{$self->_message_catalog->snmp_translated})) {
        last if ($orig_message =~ /$error_id/);
    }
    return $translated_error if ($translated_error);
    return $orig_message;
}

1;
