package NOCpulse::Probe::DataSource::UptimeOutput;

use strict;

use NOCpulse::Probe::Config::UnixOS ':constants';

use Class::MethodMaker
  get_set =>
  [qw(
      found
      one_minute_load
      five_minute_load
      fifteen_minute_load
     )],
  new_with_init => 'new',
  ;

sub init {
    my ($self, $unix_command, $shell_os_name) = @_;

    $self->found(0);

    my $command = '/usr/bin/uptime';

    if ($shell_os_name eq IRIX || $shell_os_name eq IRIX64) {
        $command = '/usr/bsd/uptime';
    }

    $unix_command->execute($command);

    if ($unix_command->results =~ /load average[s]?: ([\d.]+), ([\d.]+), ([\d.]+)$/) {
        $self->found(1);
        $self->one_minute_load($1);
        $self->five_minute_load($2);
        $self->fifteen_minute_load($3);
    }
}

1;
