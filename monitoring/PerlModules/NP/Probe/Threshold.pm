package NOCpulse::Probe::Threshold;

use strict;

use Carp;
use NOCpulse::Log::Logger;
use NOCpulse::Probe::MessageCatalog;
use NOCpulse::Probe::Config::CommandParameter;
use NOCpulse::Probe::ItemStatus;

use Class::MethodMaker 
  hash =>
  [qw(
      probe_param_values
     )],
  static_hash =>
  [qw(
      threshold_as_status
     )],
  new_with_init => 'new',
  new_hash_init => 'hash_init',
  ;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

use constant CRITICAL_MINIMUM => 'crit_min';
use constant CRITICAL_MAXIMUM => 'crit_max';
use constant WARNING_MINIMUM  => 'warn_min';
use constant WARNING_MAXIMUM  => 'warn_max';

NOCpulse::Probe::Threshold->threshold_as_status
  (
   CRITICAL_MINIMUM() => NOCpulse::Probe::ItemStatus->CRITICAL,
   CRITICAL_MAXIMUM() => NOCpulse::Probe::ItemStatus->CRITICAL,
   WARNING_MINIMUM()  => NOCpulse::Probe::ItemStatus->WARNING,
   WARNING_MAXIMUM()  => NOCpulse::Probe::ItemStatus->WARNING,
  );
                                             

sub init {
    my ($self, %args) = @_;
    $self->hash_init(%args);
}

# If the item's value breaks a threshold, returns the threshold's name.
# Otherwise returns undef.
sub metric_crossed {
    my ($self, $name, $value, $threshold_command_params) = @_;

    $threshold_command_params 
      or throw NOCpulse::Probe::InternalError("No threshold parameters provided");

    if ($Log->loggable(4)) {
        $Log->log(4, "Thresholds:\n");
        while (my ($k, $v) = each %{$threshold_command_params}) { 
            $Log->log(4, "\t$k => $v\n");
        }
    }

    # Get the threshold values. The threshold_params hash has 
    # CommandParameter instances indexed by threshold type name, e.g., crit_min.
    # This loop gets the threshold values from the probe_param_values entry
    # for the metric's threshold parameter of each type.
    my %thresholds = ();
    while (my ($thresh_type, $param) = each %$threshold_command_params) {
        $thresholds{$thresh_type} = $self->probe_param_values($param->param_name);
    }

    return $self->value_crossed($name, $value, %thresholds);
}

# If a non-metric item's value breaks a threshold, returns the threshold's type name,
# otherwise returns undef. The param values should be of the form
# crit_min => <threshold_value>, etc.
# In array context returns ($crossed_type, $threshold_value).
sub value_crossed {
    my ($self, $name, $value, %thresholds) = @_;

    my $crossed;
    my $threshold_value;

    ($crossed, $threshold_value) = $self->_check($name, $value, CRITICAL_MINIMUM, -1, %thresholds);

    ($crossed, $threshold_value) = $self->_check($name, $value, CRITICAL_MAXIMUM, +1, %thresholds)
      unless ($crossed);

    ($crossed, $threshold_value) = $self->_check($name, $value, WARNING_MINIMUM,  -1, %thresholds)
      unless ($crossed);

    ($crossed, $threshold_value) = $self->_check($name, $value, WARNING_MAXIMUM,  +1, %thresholds)
      unless ($crossed);

    if ($crossed) {
        $Log->log(2, "$name crossed $crossed: value $value <=> $threshold_value\n");
    } else {
        $Log->log(2, "$name did not cross\n");
    }

    return wantarray ? ($crossed, $threshold_value) : $crossed;
}

# Compares a probe param value to a threshold value and
# returns the threshold type if it is outside the range.
# The compare_type param is -1 for minimum thresholds,
# +1 for maximums.
sub _check {
    my ($self, $name, $value, $thresh, $compare_type, %thresholds) = @_;

    my $param_value = $thresholds{$thresh};

    my $ret;
    if (defined($value)
        and defined($param_value)
        and ($value <=> $param_value) == $compare_type) {
        $ret = $thresh;
    }
    $Log->log(4, "Compare param '$name' = '$value' ",
              $compare_type < 0 ? '<' : '>', " $thresh of '$param_value' = $ret\n");
    return ($ret, $param_value);
}


1;

__END__
