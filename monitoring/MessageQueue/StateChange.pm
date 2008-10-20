package NOCpulse::StateChange;

use strict;
use URI::Escape;

use NOCpulse::QueueEntry;
@NOCpulse::StateChange::ISA = qw ( NOCpulse::QueueEntry );


sub oid { shift->_elem('oid', @_); }
sub t { shift->_elem('t', @_); }
sub state { shift->_elem('state', @_); }
sub desc { shift->_elem('desc', @_); }

sub as_url_query
{
    my $self = shift;
    
    return join('&',
		'fn=insert',
                'oid='.uri_escape($self->oid, $NOCpulse::QueueEntry::badchars),
		't='.uri_escape($self->t, $NOCpulse::QueueEntry::badchars),
		'state='.uri_escape($self->state, $NOCpulse::QueueEntry::badchars),
		'desc='.uri_escape($self->desc, $NOCpulse::QueueEntry::badchars));
}

sub dehydrate
{
   my $self = shift;

   return $self->oid."\n".$self->t."\n".$self->state."\n".$self->desc;
}

sub hydrate
{
   my $class = shift;
   my $string = shift;

   my $self = NOCpulse::StateChange->newInitialized();
   
   my ($oid, $t, $state, $desc) = split("\n", $string);
   
   $self->oid($oid);
   $self->t($t);
   $self->state($state);
   $self->desc($desc);

   return $self;
}

1;















