package NOCpulse::Config::test::TestConfig;

use strict;
use NOCpulse::Config;

use base qw(Test::Unit::TestCase);

sub test_load {
    my $self = shift;
    my $config = NOCpulse::Config->new();
    my $file = $NOCpulse::Config::FILENAME;
    $self->assert(qr/$file/, $config->filename);

    my $url = $config->get('satellite', 'configGenUrl');
    $self->assert(defined $url, 'No configGenUrl found');

    my $sat_section = $config->getSection('satellite');
    $self->assert(ref $sat_section eq 'HASH', 'Spacewalk section not a hashref: $sat_section');

    $self->assert(qr/$url/, $sat_section->{configGenUrl});
}

sub test_cache {
    my $self = shift;
    my $config = NOCpulse::Config->new();
    my $sat_section = $config->getSection('satellite');

    my $new_config = NOCpulse::Config->new();
    $self->assert($sat_section eq $config->getSection('satellite'),
                  "Did not get cached satellite section");

    NOCpulse::Config->clearCached();

    my $newer_config = NOCpulse::Config->new();

    $self->assert($sat_section ne $newer_config->getSection('satellite'),
                  "Still getting cached satellite section after clearing");
}

1;
