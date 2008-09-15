package TornDown;

use base qw(Test::Unit::TestCase);

sub new {
    my $self = shift()->SUPER::new(@_);
    $self->{_TornDown} = 0;
    return $self;
}

sub tear_down {
    my $self = shift;
    $self->{_TornDown} = 1;
}

sub torn_down {
    my $self = shift;
    return $self->{_TornDown};
}

sub run_test {
    my $self = shift;
    my $e = new Test::Unit::Error();
    die $e;
}

1;
