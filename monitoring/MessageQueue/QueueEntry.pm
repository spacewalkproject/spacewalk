package NOCpulse::QueueEntry;

use strict;

$NOCpulse::QueueEntry::badchars = '^-_a-zA-Z0-9';

sub newInitialized
{
   my $class = shift;

   my $self = {};
   bless $self, $class;

   return $self;
}

sub _elem
{
    my $self = shift;
    my $elem = shift;
    my $old = $self->{$elem};
    $self->{$elem} = shift if (scalar(@_));
    return $old;
}

1;
