package NOCpulse::Probe::test::TestThreshold;

use strict;
use NOCpulse::Probe::Threshold;
use NOCpulse::Probe::Config::Command;
use NOCpulse::Probe::Config::CommandParameter;

use base qw(Test::Unit::TestCase);

sub set_up {
    my $self = shift;

    $self->{cmd_param_args} = 
      [
       { command_id  => 1234,
         param_name  => 'SomethingElse',
         description => 'i am nobody',
         param_type  => 'config',
         threshold_metric_id => 'NA',
         threshold_type_name => 'NA',
       },
       { command_id  => 1234,
         param_name  => 'CriticalMinimum',
         description => 'i am critical min',
         param_type  => 'threshold',
         threshold_metric_id => 'a metric',
         threshold_type_name => 'crit_min',
       },
       { command_id  => 1234,
         param_name  => 'WarningMinimum',
         description => 'i am warning min',
         param_type  => 'threshold',
         threshold_metric_id => 'a metric',
         threshold_type_name => 'warn_min',
       },
       { command_id  => 1234,
         param_name  => 'AnotherConfigParam',
         description => 'i am also nobody',
         param_type  => 'config',
         threshold_metric_id => 'NA',
         threshold_type_name => 'NA',
       },
       { command_id  => 1234,
         param_name  => 'WarningMaximum',
         description => 'i am warning max',
         param_type  => 'threshold',
         threshold_metric_id => 'a metric',
         threshold_type_name => 'warn_max',
       },
       { command_id  => 1234,
         param_name  => 'CriticalMaximum',
         description => 'i am critical max',
         param_type  => 'threshold',
         threshold_metric_id => 'a metric',
         threshold_type_name => 'crit_max',
       },
      ];
}

sub test_threshold {
    my $self = shift;

    my %cmd_params = ();
    foreach my $param_args (@{$self->{cmd_param_args}}) {
        $cmd_params{$param_args->{param_name}} = 
                    NOCpulse::Probe::Config::CommandParameter->new(%{$param_args});
    }
    my $cmd = NOCpulse::Probe::Config::Command->new(command_id => 1234, parameters => \%cmd_params); 
    my %threshold_params = $cmd->threshold_params_for('a metric');

    my %probe_params = (SomethingElse => 'foo', 
                        CriticalMinimum => 10,
                        WarningMinimum => 20,
                        WarningMaximum => 50,
                        CriticalMaximum => 100,
                       );
 
   my $threshold = NOCpulse::Probe::Threshold->new(probe_param_values => \%probe_params);

    $self->assert(!$threshold->metric_crossed('a metric', 40, \%threshold_params),
                  "Incorrectly crossed at 40");
    $self->assert(!$threshold->metric_crossed('a metric', 50, \%threshold_params),
                  "Incorrectly crossed at 50");
    $self->assert(!$threshold->metric_crossed('a metric', 20, \%threshold_params),
                  "Incorrectly crossed at 20");
    $self->assert(qr/warn_min/, 
                  $threshold->metric_crossed('a metric', 10, \%threshold_params));
    $self->assert(qr/warn_max/, 
                  $threshold->metric_crossed('a metric', 60, \%threshold_params));
    $self->assert(qr/crit_min/, 
                  $threshold->metric_crossed('a metric', 9, \%threshold_params));
    $self->assert(qr/crit_max/, 
                  $threshold->metric_crossed('a metric', 101, \%threshold_params));
}

sub test_non_metric {
    my $self = shift;

    my @cmd_params = 
      (NOCpulse::Probe::Config::CommandParameter->new(%{$self->{cmd_param_args}->[0]}));
    my %probe_params = (SomethingElse => 'foo');
    my $cmd = NOCpulse::Probe::Config::Command->new(command_id => 22, parameters => \@cmd_params); 
    my $threshold = NOCpulse::Probe::Threshold->new(probe_param_values => \%probe_params);
    my %threshold_params = $cmd->threshold_params_for('a metric');
    $self->assert(!$threshold->metric_crossed('SomethingElse', 40, \%threshold_params),
                  "Incorrectly crossed non-metric");
}

1;
