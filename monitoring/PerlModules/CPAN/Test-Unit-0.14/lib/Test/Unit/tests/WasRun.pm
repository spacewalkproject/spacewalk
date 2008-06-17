package WasRun;
use strict;

use base qw(Test::Unit::TestCase);

sub new {
    my $self = shift()->SUPER::new(@_);
    $self->{_TornDown} = 0;
    return $self;
}

sub run_test {
    my $self = shift;
    $self->{_WasRun} = 1;
}

sub was_run {
    my $self = shift;
    return $self->{_WasRun};
}

1;
