package NOCpulse::Probe::DataSource::AbstractDataSource;

use strict;

use NOCpulse::Log::Logger;
use NOCpulse::Probe::MessageCatalog;

use Class::MethodMaker
  abstract =>
  [qw(
      connect
      disconnect
     )],
  get_set => 
  [qw(
      auto_connect
      probe_record
      results
      errors
      connected
      timed_out
      die_on_failure
      _message_catalog
     )],
  new_hash_init => 'hash_init',
  ;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);


# Initializes message catalog.
sub init {
    my ($self, %args) = @_;

    $args{_message_catalog} = NOCpulse::Probe::MessageCatalog->instance();
    $args{auto_connect} = 1 unless exists $args{auto_connect};

    $self->hash_init(%args);

    $self->connect() if $self->auto_connect;
}

# Transfer a datasource-specific argument from other arguments.
# Useful for separating out shell-creation arguments.
sub datasource_arg {
    my ($self, $key, $default, $in_args_ref, $own_args_ref) = @_;

    if (exists $in_args_ref->{$key}) {
        $own_args_ref->{$key} = $in_args_ref->{$key};
        delete $in_args_ref->{$key};
        return 1;
    } else {
        $own_args_ref->{$key} = $default;
        return 0;
    }
}

# Disconnects the data source when it goes out of scope.
sub DESTROY {
    # Preserve the eval error in case disconnect does its own eval.
    my $prev_err = $@;
    $_[0]->disconnect;
    $@ = $prev_err;
}

1;

__END__
