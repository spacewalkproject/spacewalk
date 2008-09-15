package NOCpulse::Probe::Config::CommandMetric;

use strict;
use Data::Dumper;

use Class::MethodMaker
  get_set =>
  [qw(
      command_class
      metric_id
      label
      description
      unit_label
      unit_description
     )],
  new_hash_init => 'new',
  ;

sub to_string {
    my $self = shift;
    return Dumper($self);
}

1;
