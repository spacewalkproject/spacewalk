package NOCpulse::CommandOutput;

use strict;
use URI::Escape;

use NOCpulse::QueueEntry;
@NOCpulse::CommandOutput::ISA = qw ( NOCpulse::QueueEntry );

sub instance_id { shift->_elem('instance_id', @_); }
sub netsaint_id { shift->_elem('netsaint_id', @_); }
sub execution_time { shift->_elem('execution_time', @_); }
sub stdout { shift->_elem('STDOUT', @_); }
sub stderr { shift->_elem('STDERR', @_); }
sub date_executed { shift->_elem('date_executed', @_); }
sub target_type { shift->_elem('target_type', @_); }
sub exit_status { shift->_elem('exit_status', @_); }
sub cluster_id { shift->_elem('cluster_id', @_); }

sub as_url_query
{
    my $self = shift;
    
    return join('&',
		'instance_id='.uri_escape($self->instance_id(), $NOCpulse::QueueEntry::badchars),
		'netsaint_id='.uri_escape($self->netsaint_id(), $NOCpulse::QueueEntry::badchars),
		'execution_time='.uri_escape($self->execution_time(), $NOCpulse::QueueEntry::badchars),
		'STDOUT='.uri_escape($self->stdout(), $NOCpulse::QueueEntry::badchars),
		'STDERR='.uri_escape($self->stderr(), $NOCpulse::QueueEntry::badchars),
		'date_executed='.uri_escape($self->date_executed(), $NOCpulse::QueueEntry::badchars),
		'target_type='.uri_escape($self->target_type(), $NOCpulse::QueueEntry::badchars),
		'exit_status='.uri_escape($self->exit_status(), $NOCpulse::QueueEntry::badchars),
		'cluster_id='.uri_escape($self->cluster_id(), $NOCpulse::QueueEntry::badchars));
}

sub dehydrate
{
   my $self = shift;

   return
       "instance_id\n".$self->instance_id."\n".
       "netsaint_id\n".$self->netsaint_id."\n".
       "execution_time\n".$self->execution_time."\n".
       "STDOUT\n".uri_escape($self->stdout)."\n".
       "STDERR\n".uri_escape($self->stderr)."\n".
       "date_executed\n".$self->date_executed."\n".
       "target_type\n".$self->target_type."\n".
       "exit_status\n".$self->exit_status."\n".
       "cluster_id\n".$self->cluster_id."\n"
	   ;
}

sub hydrate
{
   my $class = shift;
   my $string = shift;

   my $self = NOCpulse::CommandOutput->newInitialized();
   
   my %fields = split("\n", $string);

   $self->instance_id($fields{'instance_id'});
   $self->netsaint_id($fields{'netsaint_id'});
   $self->execution_time($fields{'execution_time'});
   $self->stdout(uri_unescape($fields{'STDOUT'}));
   $self->stderr(uri_unescape($fields{'STDERR'}));
   $self->date_executed($fields{'date_executed'});
   $self->target_type($fields{'target_type'});
   $self->exit_status($fields{'exit_status'});
   $self->cluster_id($fields{'cluster_id'});

   return $self;
}

1;

