package NOCpulse::Probe::PriorState;

use strict;

use Carp;
use Data::Dumper;
use Error ':try';
use File::stat;
use IO::Dir;
use NOCpulse::Config;
use NOCpulse::Log::Logger;
use NOCpulse::Probe::Error;
use NOCpulse::Probe::MessageCatalog;
use NOCpulse::Probe::Result;
use NOCpulse::Probe::ItemStatus;

use Class::MethodMaker
  static_get_set =>
  [qw(
      probe_state_directory
      _instance
     )],
  new_with_init => '_create_singleton',
;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

# Version stamp every prior state file so that we can change
# it if need be.
use constant FILE_FORMAT_VERSION => '1.0';


sub init {
    my $self = shift;

    my $config = NOCpulse::Config->new();
    my $state_dir = $config->get('ProbeFramework', 'databaseDirectory');
    $state_dir
      or throw NOCpulse::Probe::Error('Cannot find probe state directory in NOCpulse.ini');
    $self->probe_state_directory($state_dir);
}

sub instance {
    my $class = shift;

    $class or throw NOCpulse::Probe::InternalError('Called without a class reference');

    unless ($class->_instance) {
        my $instance = $class->_create_singleton();
        $class->_instance($instance);
    }
    return $class->_instance;
}

# Returns an iterator over prior state probe IDs.
sub iterator {
    my $self = shift;
    return IO::Dir->new($self->probe_state_directory);
}

# Fetches the next ID from an iterator.
sub next_id {
    my ($self, $iterator) = @_;

    ref($iterator) eq 'IO::Dir' 
      or throw NOCpulse::Probe::InternalError("Wrong iterator type: '$iterator'");

    while (my $filename = $iterator->read()) {
        next unless $filename =~ /^state.(\d*)$/
			and -s join("/", $self->probe_state_directory, $filename);
        return $1;
    }
    $iterator->close();
    return undef;
}

sub all_schedules {
    my $self = shift;

    my @schedules = ();
    my $iter = $self->iterator();
    while (my $id = $self->next_id($iter)) {
        my $read_back = $self->load($id);
        push(@schedules, $read_back->{schedule});
    }
    return @schedules;
}

# Saves a reference to data for $probe_id in its probe state file.
# Optional $save_var_names is an arrayref with the names of the items
# in $save_data.
sub save {
    my ($self, $save_data, $save_var_names, $probe_id) = @_;

    my $probe_dir = $self->probe_state_directory 
      or throw NOCpulse::Probe::InternalError("No probe state directory provided");
    $probe_id >= 0 or throw NOCpulse::Probe::InternalError("No probe ID provided");
    $save_data or throw NOCpulse::Probe::InternalError("No data to save provided");

    my $dumper = Data::Dumper->new($save_data, $save_var_names);
    $dumper->Indent(1);

    my $filename = $self->filename($probe_id);
    my $tmpfilename = $filename . ".NEW";
    local * STATE;
    open STATE, '>', $tmpfilename
      or throw NOCpulse::Probe::InternalError("Cannot open $tmpfilename for writing: $!");
    print STATE $dumper->Dump();
    close STATE;
    rename $tmpfilename, $filename 
      or throw NOCpulse::Probe::InternalError("Cannot rename $tmpfilename to $filename: $!");
}

# Loads a probe state file for $probe_id and returns its contents.
sub load {
    my ($self, $probe_id) = @_;

    my $probe_dir = $self->probe_state_directory
      or throw NOCpulse::Probe::InternalError("No probe state directory provided");
    $probe_id or throw NOCpulse::Probe::InternalError("No probe ID provided");

    my $filename = $self->filename($probe_id);

    # A missing file is not a problem, because this might be the first run.
    -r $filename or return undef;

    if ($Log->loggable(5)) {
        $Log->log(5, "file $filename:\n", `cat $filename`);
    }

    my $data;
    unless ($data = do $filename) {
        $@ and throw NOCpulse::Probe::InternalError("Cannot parse $filename: $@");
        defined($data) 
          or throw NOCpulse::Probe::InternalError("Cannot read $filename: $!");
        $data 
          or throw NOCpulse::Probe::InternalError("Cannot get valid data from $filename");
    }
    return $data;
}

# Saves a probe result and local memory.
sub save_result {
    my ($self, $memory, $schedule, $result) = @_;
    
    $memory or throw NOCpulse::Probe::InternalError("No memory hashref to save provided");
    $result or throw NOCpulse::Probe::InternalError("No result to save provided");

    # Create a list of hashes with just the persistent values
    # from ItemStatus instances.
    my @stripped_item_list = ();
    foreach my $item ($result->item_named_values) {
        my %hash = ();
        my @fields = (NOCpulse::Probe::ItemStatus::PERSISTENT_FIELDS,
                      'renotified_count',
                      'status_notified_time');
        foreach my $field (@fields) {
            $hash{$field} = $item->{$field};
        }
        push(@stripped_item_list, \%hash);
    }

    my $data = { file_format       => FILE_FORMAT_VERSION, 
                 memory            => $memory,
                 schedule          => $schedule,
                 attempts          => $result->attempts,
                 error_caught_time => $result->error_caught_time,
                 non_ok_notif_out  => $result->non_ok_notif_out,
                 items             => \@stripped_item_list};
    $self->save([$data], ["result"], $result->probe_record->recid);
}

# Loads prior state and memory. Sets the result's prior_item_named hash
# to the prior state items. Returns memory hashref and schedule object.
sub load_result {
    my ($self, $result) = @_;

    my $memory;
    my $schedule;

    my $read_back = $self->load($result->probe_record->recid);

    if ($read_back) {
        if (ref($read_back) eq 'HASH') {
            my $file_format = $read_back->{file_format};
            $file_format eq FILE_FORMAT_VERSION
              or throw NOCpulse::Probe::PriorState::WrongFileFormat(
               "Prior state file " . $self->filename($result->probe_record->recid) .
               " has version '$file_format' instead of '" . FILE_FORMAT_VERSION . "'");

            $memory = $read_back->{memory};
            $schedule = $read_back->{schedule};
            $result->attempts($read_back->{attempts});
            $result->error_caught_time($read_back->{error_caught_time});
            $result->non_ok_notif_out($read_back->{non_ok_notif_out});

            my $items = $read_back->{items};
            foreach my $item_hash (@$items) {
                my $prior = NOCpulse::Probe::ItemStatus->new(%$item_hash);
                $result->prior_item_named($prior->name, $prior);
            }
        } else {
            throw NOCpulse::Probe::PriorState::FileCorrupted(
               "Prior state file " . $self->filename($result->probe_record->recid) .
               " does not have the expected contents");
        }
    }
    return ($memory, $schedule);
}

# Returns the probe state file name for $probe_id. Requires that
# probe_state_directory has been set.
sub filename {
    my ($self, $probe_id) = @_;
    return $self->probe_state_directory.'/state.'.$probe_id;
}

1;

__END__
