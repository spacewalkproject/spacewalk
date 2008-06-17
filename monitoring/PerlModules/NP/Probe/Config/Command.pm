package NOCpulse::Probe::Config::Command;

use strict;

use Storable;
use NOCpulse::Probe::Config::CommandParameter;
use NOCpulse::Probe::Config::CommandMetric;


use Class::MethodMaker
  get_set => 
  [qw(
      command_id
      command_class
     )],
  # Command parameters indexed by name, and metrics indexed by ID
  hash =>
  [qw(
      parameters
      metrics
     )],
  # Command instances indexed by ID
  static_hash => 
  [qw(
      instances
     )],
  new_hash_init => 'new',
  ;

# Returns the command with this class name, or undef if none found.
sub named {
    my ($self, $class_name) = @_;
    foreach my $cmd ($self->instances_values) {
        return $cmd if ($cmd->command_class eq $class_name);
    }
    return undef;
}

# Lower-case all the field names to match the method names.
sub _lowercase_fields {
    my ($class, $rec) = @_;
    foreach my $field_name (keys %$rec) {
        next if ($field_name eq lc($field_name));
        $rec->{lc $field_name} = $rec->{$field_name};
        delete $rec->{$field_name};
    }
}

# Loads array of hashes of command params and metrics from a Storable file.
sub load {
    my ($class, $file) = @_;
    
    my $rec_arrayref = Storable::retrieve($file);
    scalar(@$rec_arrayref) == 2
      or throw NOCpulse::Probe::InternalError("Did not get two array entries for commands file: ",
                                              scalar(@$rec_arrayref));
    my $param_arrayref = $rec_arrayref->[0];
    my $metric_arrayref = $rec_arrayref->[1];

    foreach my $rec (@$param_arrayref) {
        $class->_lowercase_fields($rec);

        # Pull out the command class, which does not apply to params
        my $command_class = $rec->{command_class};
        delete $rec->{command_class};

        my $param = NOCpulse::Probe::Config::CommandParameter->new($rec);

        my $cmd = $class->instances($param->command_id);
        unless ($cmd) {
            # Haven't seen this command yet, so add it.
            $cmd = $class->new(command_id => $param->command_id, command_class => $command_class);
            $class->instances($param->command_id, $cmd);
        }
        # Add the param to the command.
        $cmd->parameters($param->param_name, $param);
    }

    foreach my $rec (@$metric_arrayref) {
        $class->_lowercase_fields($rec);

        my $metric = NOCpulse::Probe::Config::CommandMetric->new($rec);

        foreach my $cmd ($class->instances_values) {
            if ($cmd->command_class eq $metric->command_class) {
                $cmd->metrics($metric->metric_id, $metric);
            }
        }
    }
    return $class;
}

# Round up all the parameters for a metric.
# Returns a hash indexed by threshold type, with values being the
# parameter object from the probe configuration parameters.
sub threshold_params_for {
    my ($self, $metric) = @_;
    my %defs = ();
    while (my ($param_name, $param) = each %{$self->parameters}) {
        if ($metric eq $param->threshold_metric_id) {
            $defs{$param->threshold_type_name} = $param;
        }
    }
    return %defs;
}

1;
