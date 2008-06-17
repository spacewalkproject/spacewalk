package TimeSeriesDatapoint;

use strict;
use URI::Escape;

use NOCpulse::QueueEntry;
@TimeSeriesDatapoint::ISA = qw ( QueueEntry );

sub oid { shift->_elem('oid', @_); }
sub t { shift->_elem('t', @_); }
sub v { shift->_elem('v', @_); }

sub as_url_query
{
    my $self = shift;
    
    return join('&',
		'fn=insert',
                'oid='.uri_escape($self->oid(), $QueueEntry::badchars),
		't='.uri_escape($self->t(), $QueueEntry::badchars),
		'v='.uri_escape($self->v(), $QueueEntry::badchars));
}

sub dehydrate
{
   my $self = shift;

   return $self->oid."\n".$self->t."\n".$self->v;
}

sub hydrate
{
   my $class = shift;
   my $string = shift;

   my $self = TimeSeriesDatapoint->newInitialized();
   
   my ($oid, $t, $v) = split("\n", $string);
   $self->oid($oid);
   $self->t($t);
   $self->v($v);

   return $self;
}

1;

