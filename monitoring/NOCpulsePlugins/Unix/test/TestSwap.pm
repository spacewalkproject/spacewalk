package Unix::test::TestSwap;

use strict;

use NOCpulse::Probe::Config::UnixOS qw(:constants);
use NOCpulse::Probe::DataSource::Factory;
use NOCpulse::Probe::Config::ProbeRecord;
use NOCpulse::Probe::Config::Command;
use NOCpulse::Probe::Result;

use Unix::Swap;

use base qw(Test::Unit::TestCase);

sub set_up {
  my $self = shift;

  $self->{probe_rec} = NOCpulse::Probe::Config::ProbeRecord->new(
    { recid   => 12345,
      os_name => PROBE_LINUX,
    });

  $self->{factory} = NOCpulse::Probe::DataSource::Factory->new(
      probe_record  => $self->{probe_rec},
      shell_os_name => LINUX);

  $self->{factory}->canned(1);
}

sub test_swap {
    my $self = shift;

    my $linux = "
             total       used       free     shared    buffers     cached
Mem:        255920     247888       8032      68088       5216      42800
-/+ buffers/cache:     199872      56048
Swap:       136544      84496      52048
";

    $self->{factory}->canned_results($linux);

    my $result  = NOCpulse::Probe::Result->new(probe_record   => $self->{probe_rec},
                                               command_record => 
                                               NOCpulse::Probe::Config::Command->new());

    my %probe_args = 
      ( 
       params => { warn => 100, sshuser => 'nocpulse' },
        result => $result,
        memory => {},
        data_source_factory => $self->{factory},
      );

    Unix::Swap::run(%probe_args);

    $self->assert($result->overall_status eq $result->OK, "Wrong status: ",
                  $result->overall_status);
    $self->assert(scalar(@{[ $result->item_named_keys ]}) == 3, "Not 3 items: ",
                  scalar(@{[ $result->item_named_keys ]}));

    my $used = $result->item_named('Used')->value;
    my $expect = 84496 / 1024 / 1024;
    $self->assert($used == $expect, "Wrong value for used: $used instead of $expect");
    my $pctfree = $result->item_named('pctfree')->formatted_value();
    $self->assert($pctfree == 38.12, "Wrong value for pctfree: $pctfree instead of 38.12");
}

1;
