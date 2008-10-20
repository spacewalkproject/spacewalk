package NOCpulse::StateChangeQueue;

use strict;
use NOCpulse::SMONQueue;
use NOCpulse::StateChange;

@NOCpulse::StateChangeQueue::ISA = qw ( NOCpulse::SMONQueue );

# Keep in synch with scdb/SCDB.pm
my $PROTOCOL_VERSION = '1.0';

sub new
{
    my $class = shift;
    my %args = @_;

    my $self = NOCpulse::SMONQueue->new(%args);
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

    return NOCpulse::StateChange->hydrate($data);
}

sub id
{
    return 'sc_db';
}

sub name
{
    return "State Change";
}

1;
