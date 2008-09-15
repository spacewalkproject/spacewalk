package NOCpulse::Probe::Shell::Local;

use strict;

use base qw(NOCpulse::Probe::Shell::Unix);

sub init {
    my ($self, %in_args) = @_;

    my %args = $self->_transfer_args(\%in_args,
                                     ['timeout_seconds',
                                      'shell_command',
                                      'shell_switches']);

    $args{shell_command} = '/bin/sh' unless $args{shell_command};
    
    my $switches = $args{shell_switches};
    $args{shell_switches} = ['-s'];
    push(@{$args{shell_switches}}, $switches) if ($switches);

    $args{timeout_seconds} ||= 10;
    $args{write_timeout_seconds} = 1;
    
    $self->SUPER::init(%args);
}

1;

__END__

=head1 NAME

  NOCpulse::Probe::Shell::Local - Forks a local shell

=head1 SYNOPSIS

=head1 DESCRIPTION

=head2 Overview

Forks an instance of /bin/sh locally and sends it shellscripts to run.

=head2 Construction and initialization

=head2 Methods

=cut
