
package NOCpulse::MockApacheRequest;

use strict;
use Apache::FakeRequest;
use NOCpulse::MockApacheLog;

@NOCpulse::MockApacheRequest::ISA = qw ( Apache::FakeRequest );


sub new
{
    my $class = shift;
    my @args = @_;

    my $self = Apache::FakeRequest->new(@args);
    bless $self, $class;

    $self->{'log'} = NOCpulse::MockApacheLog->new();

    $self->{'output'} = "";
    
    return $self;
}

sub log
{
    my $self = shift;

    return $self->{'log'};
}

sub print
{
    my $self = shift;
    
    $self->{'output'} .= join("", @_);
}

sub output
{
    my $self = shift;
    $self->{'output'};
}

1;

