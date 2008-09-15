package NOCpulse::Probe::DataSource::WindowsCommand;

use strict;

use Error ':try';
use NOCpulse::Probe::Error;
use NOCpulse::Probe::Shell::WindowsService;
use NOCpulse::Probe::Utils::WindowsUpdate;
use NOCpulse::Probe::DataSource::EventReaderOutput;
use NOCpulse::Probe::DataSource::WQLQuery;
use NOCpulse::Probe::DataSource::EventReaderOutput;

use base qw(NOCpulse::Probe::DataSource::AbstractOSCommand);

use Class::MethodMaker
  get_set =>
  [qw(
      auto_update
     )],
  new_with_init => 'new',
  ;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

sub init {
    my ($self, %in_args) = @_;

    my %own_args = ();

    $self->default_datasource_args(\%in_args, \%own_args);

    $self->datasource_arg('auto_update', 0, \%in_args, \%own_args);

    $own_args{shell} ||= NOCpulse::Probe::Shell::WindowsService->new(%in_args);

    $self->SUPER::init(%own_args);

    return $self;
}


sub connect {
    my $self = shift;

    $self->SUPER::connect();

    my $updater = NOCpulse::Probe::Utils::WindowsUpdate->new(windows_command => $self);
    $updater->update_if_needed();
}

# Throws an exception if the service version is less than the one given.
# This avoids downstream errors with missing perfdata counters etc.
# Raises NOCpulse::Probe::WindowsServiceVersionError if the installed
# version is too old.
sub require_version {
    my ($self, $version) = @_;

    my $cmp = NOCpulse::Probe::Utils::WindowsUpdate->compare_versions(
      $self->shell->host_service_version, $version);
    if ($cmp < 0) {
        my $msg = sprintf($self->_message_catalog->status('win_version_mismatch'),
                          $version, $self->shell->host_service_version);
        throw NOCpulse::Probe::WindowsServiceVersionError($msg);
    }
}


# Specific commands


# Prepares for file installation.
sub install {
    my ($self, $filename, $file_size, $version) = @_;

    ($filename and $file_size and $version)
      or throw NOCpulse::Probe::InternalError
        ("Usage: install(filename, size, version); got '$filename', '$file_size', '$version'");

    return $self->execute("install $filename $file_size $version");
}

# Runs the PerfData command.
sub perf_data {
    my ($self, $object, $counter, $instance) = @_;

    $object  or throw NOCpulse::Probe::InternalError("No object name provided");
    $counter or throw NOCpulse::Probe::InternalError("No counter name provided");

    my $old_die = $self->die_on_failure;
    $self->die_on_failure(0);

    my $command = "run PerfData.exe \"$object\" \"$counter\"";
    $instance and $command .= " \"$instance\"";

    my $result = $self->execute($command);
    my $errors = $self->errors || $result; # Adapt for v2 and v3 nocpd
    my $data;

    if ($result =~ /^Counter Value: (.+)/) {
        $data = $1;
        $data =~ s/\r//g;

    } elsif ($errors =~ /specified object/i) {
        # Wrong object: it's disabled manually or automatically or a it's coding error.
        my $msg = sprintf($self->_message_catalog->perfdata('no_object'), $object);
        throw NOCpulse::Probe::DataSource::PerfDataObjectError($msg);

    } elsif ($errors =~ /specified counter/i
             || $errors =~ /parse the counter path/i) {
        # Wrong counter: it's disabled manually or automatically or a it's coding error.
        my $msg = sprintf($self->_message_catalog->perfdata('no_counter'), $counter, $object);
        throw NOCpulse::Probe::DataSource::PerfDataCounterError($msg);

    } elsif ($errors =~ /specified instance/i) {
        # Wrong instance, probe writer handles this
        $data = undef;

    } else {
        $Log->log(1, "Unexpected PerfData output: output >>>$result<<<, errors >>$errors<<<\n");
    }

    $self->die_on_failure($old_die);

    return $data;
}

# Runs the PerfList command.
sub perf_list {
    my ($self, $object, $show_instances) = @_;

    my $command = "run PerfList.exe ";
    $show_instances and $command .= "-i ";
    $object and $command .= "\"$object\" ";

    return $self->execute($command);
}

# Reads event data. Possible arguments are log, eventtype, source, category,
# computer, eventid, and prevtime.
sub event_reader {
    my ($self, %args) = @_;

    $args{log} or throw NOCpulse::Probe::InternalError("No event log provided");

    my %translate = (category  => 'category',
                     computer  => 'computer',
                     eventid   => 'eventID',
                     eventtype => 'type',
                     prevtime  => 'timeGenerated',
                     source    => 'source',
                     log       => 'eventLog',
                    );
                     
    my @switches = ();
    foreach my $switch (keys %translate) {
        $args{$switch} ne '' and push(@switches, "--$translate{$switch}=\"$args{$switch}\"");
    }

    my $event_string = $self->execute('run EventReader.exe ' . join(' ', @switches));

    my @events = ();
    my $badEventError = undef;

    if ($event_string) {
        foreach my $rawEvent (split(/\n/, $event_string)) {
            try {
                push(@events,  NOCpulse::Probe::DataSource::EventReaderOutput->new($rawEvent));
            }
            catch NOCpulse::Probe::DataSource::MalformedEventError with {
                # Catch the error but keep going.  The error is only
                # treated as relevant if it is the only event.
                $badEventError = shift;
            }
        }
    }
    if ((@events == 0) && (defined $badEventError)) {
        throw $badEventError;
    }
    return @events;
}

# Parses df output and returns a DfOutput instance, which
# has a for_filesystem hash indexed by filesystem name.
sub df {
    my ($self, $drive) = @_;

    my $old_die = $self->die_on_failure;
    $self->die_on_failure(0);

    $self->execute("run df.exe -k \"$drive\"");
    $self->die_on_failure($old_die);

    if ($self->failed && $self->errors !~ /No such file or directory/i) {
        throw NOCpulse::Probe::DataSource::CommandFailedError($self->errors);
    }
    return NOCpulse::Probe::DataSource::DfOutput->new($self->results);
}

#<<<<<<< WindowsCommand.pm
# Parses WQLQuery output and returns a WQLQuery instance.
sub wql_query {
    my ($self, $query) = @_;
    my $results = undef;
    
    my $old_die = $self->die_on_failure;
    $self->die_on_failure(0);
    
    $self->execute("run WQLQuery.exe $query");
    
    $self->die_on_failure($old_die);
    
    if ($self->failed) {
    
        #invalid query
        #invalid instance

        # message returned by WQLQuery.exe if WMI is not supported
        if ($self->errors =~ /WMI not supported/i) {
            my $msg = $self->_message_catalog->wql_query('not_supported');
            throw NOCpulse::Probe::DataSource::WmiNotSupportedError($msg);

        # message returned by cmd if WQLQuery.exe could not be found.
        } elsif ($self->errors =~ /not recognized as an internal or external command/i) {
            my $msg = $self->_message_catalog->wql_query('not_present');
            throw NOCpulse::Probe::DataSource::WmiNotSupportedError($msg);

        # legacy message returned by bash if WQLQuery.exe could not be found.
        } elsif ($self->errors =~ /No such file or directory/i) {
            my $msg = sprintf($self->_message_catalog->wql_query('not_present'));
            throw NOCpulse::Probe::DataSource::WmiNotSupportedError($msg);
        }
	
    } elsif ($self->results) {
        $results = NOCpulse::Probe::DataSource::WQLQuery->new($self->results);
    }
    return $results;
}

# actions supported are stop, start and as of 3.0.5 status.
sub service {
    my ($self, $action, $service_name) = @_;

    my $old_die = $self->die_on_failure;
    $self->die_on_failure(0);

    my $result = $self->execute("run Service.exe $action $service_name");

    $self->die_on_failure($old_die);

    # Map the human readable message to the state string that WMI would return.
    my $state = undef;
    
    if ($result =~ /The service is running./) {
	$state = "Running";
    }
    elsif ($result =~ /The service start is pending./) {
	$state = "Start Pending";
    }
    elsif ($result =~ /The service continue is pending./) {
	$state = "Continue Pending";
    }
    elsif ($result =~ /The service pause is pending./) {
	$state = "Pause Pending";
    }
    elsif ($result =~ /The service is paused./) {
	$state = "Paused";
    }
    elsif ($result =~ /The service stop is pending./) {
	$state = "Stop Pending";
    }
    elsif ($result =~ /The service is stopped./) {
	$state = "Stopped";
    }
    elsif ($result =~ /The specified service does not exist as an installed service./) {
	#$state = undef;
    }
    else {
	# Something other than the things we know about.
	$state = $result;
    }
    return $state;
}    

1;

__END__
