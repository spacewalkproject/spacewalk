package Test::Unit::Warning;

use strict;
use base 'Test::Unit::TestCase';

sub run_test {
    my $self = shift;
    $self->fail($self->{_message});
}

sub new {
    my $class = shift;
    my $self = $class->SUPER::new('warning');
    $self->{_message} = shift;
    return $self;
}

1;
