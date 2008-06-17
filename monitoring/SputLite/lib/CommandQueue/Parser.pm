#######################################
package NOCpulse::CommandQueue::Parser;
#######################################

use strict;
use XML::Parser;
use NOCpulse::CommandQueue;
use NOCpulse::CommandQueue::Command;
use URI::Escape;

use vars qw(@ISA);
@ISA = qw(NOCpulse::CommandQueue);


######################################################
# Accessor methods
#
sub queue    { shift->_elem('queue',    @_); }
sub instance { shift->_elem('instance', @_); }
sub param    { shift->_elem('param',    @_); }


#########
sub new {
#########
  my($class)    = shift;
  my $self      = {};
  bless $self, $class;
}


###########
sub parse {
###########
  my $self    = shift;
  my $queue   = shift;
  my $content = shift;

  # Store the queue in $self so the event handlers can access it
  $self->queue($queue);

  $self->dprint(2, "\tCommandQueueParser parsing ", length($content), 
                   " bytes\n");

  # Go to it.
  my $p = new XML::Parser(Handlers => {Start => sub {$self->StartTag(@_)},
                                       Char  => sub {$self->Text(@_)},
                                      });
  eval {
    $p->parse($content);
  };

  if ($@) {
    $self->dprint(2, "\tERROR:  Parse failed: $@\n");
    return undef;
  } else {
    $self->dprint(2, "\tParser::parse returning ", $self->queue, "\n");
    $self->dprint(4, "\tQUEUE:  ", $self->queue->as_str, "\n");
    return $self->queue;
  }
}


########################
# XML::Parser routines


##############
sub StartTag {
##############
  my $self = shift;
  my($expat, $tag, %params) = @_;

  $self->dprint(4, "\tStartTag($tag)\n");

  if ($tag eq 'COMMANDS') {

    # Nothing to do
    $self->dprint(4, "\t\tNothing to do for $tag\n");

  } elsif ($tag eq 'INSTANCE') {

    $self->dprint(4, "\t\tCreating new instance\n");

    # Create a new Command object (including the debug handle)
    $self->instance(new NOCpulse::CommandQueue::Command($self->queue));
    $self->instance->debug($self->debug); 

    # Set the 'id' field in the new instance
    $self->instance->id($params{ID});

    # Add the instance to the CommandQueue
    $self->queue->add_instance($self->instance, $params{ID});
    $self->dprint(4, "\t\tCreated instance:  ", $self->instance->as_str(), "\n");
    $self->dprint(4, "\t\tCurrent queue:     ", $self->queue->as_str(), "\n");

  } else {

    $self->dprint(4, "\tStartTag creating new parameter\n");
    $self->param(lc($tag));
    $self->dprint(4, "\t\tParam:  ", $self->param, "\n");

  }

}

##########
sub Text {
##########
  my $self  = shift;
  my $expat = shift;
  my $str   = shift;
  my $text  = &uri_unescape($str);

  if ($text =~ /\S/) {

    $self->dprint(4, "\t\tAppending '$text' to value of ", $self->param, 
			" in ", $self->instance, "\n");

    $self->instance->append($self->param, $text);

  } else {

    $self->dprint(4, "\t\tNull text, ignoring\n");

  }

}


1;
