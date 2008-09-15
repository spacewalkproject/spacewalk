package Apache::test::TestStatusPage;

use strict;

use Error(':try');

use NOCpulse::Probe::Error;
use NOCpulse::Probe::Result;
use NOCpulse::Probe::DataSource::Factory;
use NOCpulse::Probe::Config::ProbeRecord;
use Apache::StatusPage;

use base qw(Test::Unit::TestCase);

sub set_up {
    my $self = shift;
    $self->{factory} = NOCpulse::Probe::DataSource::Factory->new();
    $self->{factory}->canned(1);
}


sub test_uptime {
    my $self = shift;



}


sub test_traffic {
    my $self = shift;



}

sub test_processes {
    my $self = shift;



}



1;
