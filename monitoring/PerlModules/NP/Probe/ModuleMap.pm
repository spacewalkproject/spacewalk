package NOCpulse::Probe::ModuleMap;

# Temporary hack to support running new probe framework probes
# from the scheduler.

use strict;

use Carp;
use NOCpulse::Config;

use Class::MethodMaker
  static_get_set =>
  [qw(
      filename
      _map_config
      _instance
     )],
  static_hash =>
  [qw(
      probe_class
     )],
  new_with_init => '_create_singleton',
;

sub init {
    my $self = shift;

    my $config = NOCpulse::Config->new();
    $self->filename($config->get('netsaint', 'configDir') . '/probe_module_map.ini');
    $self->_map_config(NOCpulse::Config->new($self->filename));
}

sub instance {
    my $class = shift;

    $class or throw NOCpulse::Probe::InternalError("Called without a class reference");
    $class->_instance($class->_create_singleton()) unless ($class->_instance);
    return $class->_instance;
}

sub module_for {
    my ($self, $module) = @_;
    my $new_module;
    if ($self->_map_config) {
        $new_module = $self->_map_config->get('Modules', $module);
    }
    return $new_module || $module;
}

1;
