package NOCpulse::NotificationQueue;
use strict;

use NOCpulse::SMONQueue;
use NOCpulse::Notification;
use NOCpulse::Gritch;

@NOCpulse::NotificationQueue::ISA = qw ( NOCpulse::SMONQueue );

# Keep in synch with Notification.pm
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

    return NOCpulse::Notification->hydrate($data);
}

sub id
{
    return 'notif';
}

sub name
{
    return "Notification";
}

1;
