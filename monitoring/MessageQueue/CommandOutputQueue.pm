
use strict;

package CommandOutputQueue;

use NOCpulse::SMONQueue;
use NOCpulse::CommandOutput;

@CommandOutputQueue::ISA = qw ( SMONQueue );

# Keep in synch with sputnik/SputLite/lib/UploadResults.pm
my $PROTOCOL_VERSION = '1.0';

sub new
{
    my $class = shift;
    my %args = @_;

    my $self = SMONQueue->new(%args);
    bless $self, $class;

    $self->directory($self->config()->get('queues', 'queuedir').'/'.$self->id());
    $self->maxsize($self->config()->get('queues', $self->id().'_maxsize'));
    $self->protocol_version($PROTOCOL_VERSION);

    return $self;
}

sub hydrate_entry
{
    my $self = shift;
    my $data = shift;

    return CommandOutput->hydrate($data);
}

sub id
{
    return 'commands';
}

sub name
{
    return "SputLite Commands";
}

1;
