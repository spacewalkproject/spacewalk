package StateChange;

use strict;
use URI::Escape;

use NOCpulse::QueueEntry;
@StateChange::ISA = qw ( QueueEntry );


sub oid { shift->_elem('oid', @_); }
sub t { shift->_elem('t', @_); }
sub state { shift->_elem('state', @_); }
sub desc { shift->_elem('desc', @_); }

sub as_url_query
{
    my $self = shift;
    
    return join('&',
		'fn=insert',
                'oid='.uri_escape($self->oid, $QueueEntry::badchars),
		't='.uri_escape($self->t, $QueueEntry::badchars),
		'state='.uri_escape($self->state, $QueueEntry::badchars),
		'desc='.uri_escape($self->desc, $QueueEntry::badchars));
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

   my $self = StateChange->newInitialized();
   
   my ($oid, $t, $state, $desc) = split("\n", $string);
   
   $self->oid($oid);
   $self->t($t);
   $self->state($state);
   $self->desc($desc);

   return $self;
}

1;















