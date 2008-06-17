package NOCpulse::Probe::Config::test::TestUnixOS;

use strict;

use NOCpulse::Probe::Config::UnixOS qw(:constants);

use base qw(Test::Unit::TestCase);

sub test_mappings {
    my $self = shift;

    my @configs = sort keys %{CONFIGURED_TO_UNAME_OS()};
    foreach my $config (@configs) {
        my $uname = os_configured_to_uname($config);
        $self->assert($uname, "No uname for $config\n");
        if ($config eq PROBE_SATELLITE) {
            $self->assert(os_uname_to_configured($uname) eq PROBE_LINUX,
                          "Match failed for config $config, uname $uname: ",
                          os_uname_to_configured($uname));
        } else {
            $self->assert(os_uname_to_configured($uname) eq $config,
                          "Match failed for config $config, uname $uname: ",
                          os_uname_to_configured($uname));
        }
    }

    my @unames = sort keys %{UNAME_TO_CONFIGURED_OS()};
    foreach my $uname (@unames) {
        my $config = os_uname_to_configured($uname);
        $self->assert($config, "No config for $uname\n");
        if ($uname eq IRIX64) {
            $self->assert(os_configured_to_uname($config) eq IRIX,
                          "Match failed for uname $uname, config $config: ",
                          os_configured_to_uname($config));
        } else {
            $self->assert(os_configured_to_uname($config) eq $uname,
                          "Match failed for uname $uname, config $config: ",
                          os_configured_to_uname($config));
        }
    }
}

sub test_match {
    my $self = shift;

    $self->assert(os_matches(LINUX, PROBE_LINUX), "OS mismatch for linux");
    $self->assert(os_matches(LINUX, PROBE_SATELLITE), "OS mismatch for sat");
    $self->assert(os_matches(IRIX, PROBE_IRIX), "OS mismatch for irix");
    $self->assert(os_matches(IRIX64, PROBE_IRIX), "OS mismatch for irix64");
    $self->assert(os_matches(SOLARIS, PROBE_SOLARIS), "OS mismatch for solaris");
    $self->assert(os_matches(HPUX, PROBE_HPUX), "OS mismatch for hpux");

    $self->assert(!os_matches(SOLARIS, PROBE_LINUX), "No OS mismatch for solaris/linux");

    $self->assert(os_is_irix(IRIX), "IRIX not irix");
    $self->assert(os_is_irix(IRIX64), "IRIX64 not irix");
    $self->assert(!os_is_irix(SOLARIS), "Solaris is irix");
}

1;
