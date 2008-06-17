package NOCpulse::Probe::Config::test::TestCommand;

use strict;
use NOCpulse::Config;
use NOCpulse::Probe::Config::Command;
use NOCpulse::Probe::Config::CommandParameter;
use NOCpulse::Probe::Config::ProbeRecord;

use base qw(Test::Unit::TestCase);

sub new {
    my $self = shift()->SUPER::new(@_);
    $self->{'config'} = new NOCpulse::Config;
    return $self;
}

# Custom suite so that we test loading before anything else.
sub suite {
    my $self = shift;
    my $suite = Test::Unit::TestSuite->empty_new("Command record tests");
    $suite->add_test(NOCpulse::Probe::Config::test::TestCommand->new("test_load"));
    $suite->add_test(NOCpulse::Probe::Config::test::TestCommand->new("test_join_command_params"));
    return $suite;
}

sub set_up {
    my $self = shift;
    my $file = $self->{'config'}->get('netsaint', 'commandParameterDatabase');
    NOCpulse::Probe::Config::Command->load($file);
}

sub test_load {
    my $self = shift;
    my $instances = NOCpulse::Probe::Config::Command->instances;
    $self->assert(defined($instances)
                  && ref($instances) eq 'HASH'
                  && scalar(keys %$instances) > 0,
                  'No command records');
}

sub test_join_command_params {
    my $self = shift;
    
    my $hashref = Storable::retrieve($self->{'config'}->get('netsaint', 'probeRecordDatabase'));
    
    foreach my $rec (values %$hashref) {
        my $probe_rec = NOCpulse::Probe::Config::ProbeRecord->new($rec);
        my $cmd_id = $probe_rec->command_id;

        if ($cmd_id != 2) {  # Skip LongLegs, has no args
            my $cmd_line = $probe_rec->parameters;
            $self->assert(defined($cmd_line) && scalar(keys %$cmd_line) > 0, 'No command line args');
        
            $self->assert(NOCpulse::Probe::Config::Command->instances($cmd_id),
                          "No command parameters for command $cmd_id");
        }
    }
}

1;
