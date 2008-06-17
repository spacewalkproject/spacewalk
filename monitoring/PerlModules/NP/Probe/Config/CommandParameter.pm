package NOCpulse::Probe::Config::CommandParameter;

use strict;
use Data::Dumper;

use Class::MethodMaker
  get_set =>
  [qw(
      command_id
      param_name
      param_type
      description
      threshold_metric_id
      threshold_type_name
      threshold_metric_units
      mandatory
     )],
  new_hash_init => 'new',
  ;

sub to_string {
    my $self = shift;
    return Dumper($self);
}

1;
