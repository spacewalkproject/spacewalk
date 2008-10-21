=head1 NAME
 
SpreadServers - a collection of classes that implement abstract stand-alone Spread servers
 

=head1 SYNOPSIS

  
my $server = SpreadServer->newInitialized({
                                'privateName'=>'mycon',
                                'readTimeout'=>0,
				'messageProcessor'=>\&myMessageProcessor(),
				'groups'=>['myservice']
                        });

$server->processEvents; 
 


=head1 DESCRIPTION
 

SpreadNetwork defines two classes: SpreadServer and ForkingSpreadServer
 

=item
SpreadServer - a class who's instances encapsulate behavior required to implement a non-forking spread server.  Users can either specify a messageProcessor (a vector to a method to run whenever a message is received) or write a subclass that overrides the processMessage() method.
 

=item
ForkingSpreadServer - a subclass of SpreadServer that runs message processing in a forked process.
 

=item
SpreadServer is a subclass of SpreadNetwork's SpreadConnection class.


=head1 CLASS SpreadServer

 

=head2 Instance variables
 


=item 
All instance variables are accessable by calling get_xxx (where xxx is the instance variable name).  All instance variables are settable by calling set_xxx.  All instance variable values can be set on construction by passing a hash reference in with key-value pairs appropriately (see newInitialized)



=item
messageProcessor [default=undef]: Can contain a vector to a method to call when a message is received.  The base class' default behavior is to call this or do nothing.  Another option is to subclass SpreadServer (or ForkingSpreadServer).

=item
shouldProcessEvents [default=1]: When you set this  false (0), processEvents will return.

=item
autoReconnect [default=1]: If true and a disconnection is detected, the server will automatically try to reconnect with the SpreadConnection reconnect() method.

=item
groups [default=[] ]: Groups that this server should belong to - you should specify this in the constructor call.


=head2 Class Methods
 

=item
newInitialized({key=>value,[...]}): Takes as it's argument a ref to a hash that contains key-value pairs describing initial instance variable values.  Returns an instance of SpreadServer that will be connected to the spread network.  To cause this server to serve requests, run processEvents().



=head2 Instance Methods



=item
processMessage(<aSpreadMessage>): This method is where an incoming message is processed.  The base class will call any method specified by the messageProcessor instance variable, passing to it the message in question.  You can also choose to subclass SpreadServer and override this method.

=item
joinGroups(): Joins all the groups listed in the groups instance variable.  This happens when the instance is constructed.

=item
topOfLoopTasks(): This does nothing in SpreadServer, but you can choose to override it if you want.  It gets called before any spread network stuff happens.  ForkingSpreadServer has child-culling behavior here.

=item
routeMessage(<aSpreadMessage>): This is called nextMessage() returns.  In the base class it checks to see if the message is defined, and if so calls callProcessMessage(), else does nothing. There's probably not much use to overriding this, but you can if you want.

=item
callProcessMessage(<aSpreadMessage>):  This is called after routeMessage has determined that the message needs to be handled.  In the base class this is just a call to processMessage().  In ForkingSpreadServer the actual forking occurs here.

=item
processEvents(): This is the server loop.  It looks like this:

	while ($self->get_shouldProcessEvents) {

		$self->topOfLoopTasks;

		if ($self->isConnected) {
			my $message = SpreadMessage->NextFrom($self);
			$self->routeMessage($message);
		} else {
			if ($self->get_autoReconnect) {
				$self->reconnect;
			}
		}
	}


=item
replyConnection(): Returns a connection through which you can send a reply.  In the base class this simply returns self.  ForkingSpreadConnection creates a new connection with a unique name.




=head1 CLASS ForkingSpreadServer

 

=head2 Instance variables
 


=item 
All instance variables are accessable by calling get_xxx (where xxx is the instance variable name).  All instance variables are settable by calling set_xxx.  All instance variable values can be set on construction by passing a hash reference in with key-value pairs appropriately (see newInitialized).

ForkingSpreadServer adds no new instance variables - see SpreadServer for details.



=head2 Class Methods
 

=item
newInitialized({key=>value,[...]}): Takes as it's argument a ref to a hash that contains key-value pairs describing initial instance variable values.  Returns an instance of ForkingSpreadServer that will be connected to the spread network.  To cause this server to serve requests, run processEvents().



=head2 Instance Methods



=item
topOfLoopTasks(): Override of SpreadServer's behavior - this method does dead child reaping.

=item
callProcessMessage(): Override of SpreadServer's behavior - this method does the forking, and ensures that the child's copy of self won't call disconnect when its' destroyed.

=item
replyConnection(): Override of SpreadServer's behavior.  This method returns a new connection.  By default (with no parameters) the method returns a connection to a spread server at localhost on the default spread port with a unique name that's based on the current unix time + a 5 position random number.  You can pass to this method any/all of the things you can pass to a SpreadConnection, each of which will override any default behavior this method might otherwise provide.





=cut



#################################################################################
#           CODE STARTS HERE
#################################################################################

package SpreadServer;
use NOCpulse::SpreadNetwork;
use NOCpulse::Object;
@ISA=qw(SpreadConnection);


sub instVarDefinitions {
	my $self = shift();
	$self->addInstVar('messageProcessor',undef);
	$self->addInstVar('shouldProcessEvents',1);
	$self->addInstVar('autoReconnect',1);
	$self->addInstVar('groups',[]);
	$self->SUPER::instVarDefinitions;
}

sub initialize {
	my ($self,@params) = @_;
	my $result = $self->SUPER::initialize(@params);
	$self->joinGroups;
	return $result;
}

sub processMessage {
	my ($self,$message) = @_;
	if ($self->get_messageProcessor) {
		my $processor = $self->get_messageProcessor;
		&{$processor}($self,$message);
	}
}

sub joinGroups {
	my ($self,@groups) = @_;
	my $ogroups = $self->get_groups;
	my $gname;
	foreach $gname (@groups) {
		$self->dprint(3,"Joining group $gname\n");
		$self->join($gname);
	}
	foreach $gname (@$ogroups) {
		$self->dprint(3,"Joining group $gname\n");
		$self->join($gname);
	}
}

sub topOfLoopTasks {
}

sub routeMessage {
	my ($self,$message) = @_;
	if (! $message ) {
		$self->dprint(9,".");
	} else {
		$self->callProcessMessage($message);
	}
}

sub callProcessMessage {
	my ($self,$message) = @_;
	$self->processMessage($message);
}


sub processEvents {
	my $self = shift();
	$self->dprint(3,"Waiting for messages");
	while ($self->get_shouldProcessEvents) {

		$self->topOfLoopTasks;

		if ($self->isConnected) {
			$self->dprint(3,"Waiting for message\n");
			my $message = SpreadMessage->NextFrom($self);
			$self->routeMessage($message);
		} else {
			if ($self->get_autoReconnect) {
				$self->dprint(3,"Reconnecting...\n");
				$self->reconnect;
			}
		}
	}
}

sub replyConnection
{
	my $self = shift();
	return $self;
}

package ForkingSpreadServer;
use POSIX ":sys_wait_h";
@ISA=qw(SpreadServer);

sub topOfLoopTasks {
	my $self = shift();
	$kid = undef;
	do {
		$self->dprint(3,"Collecting offspring\n");
		$kid = waitpid(-1,&WNOHANG);
		$self->dprint(3,"Got $kid\n");
	} until $kid < 1;
}

sub callProcessMessage {
	my ($self,$message) = @_;

	if (fork()) {
		# Parent
		$self->dprint(3,"Forked\n");
	} else {
		# Child
		$self->set_doAutoDisconnect(0);
		$self->processMessage($message);
		exit;
	}
}

sub replyConnection
{
	my ($self,$name,$options) = @_;
	if (! $name) {
	        $name = $self->uniquePrivateName;
	}
	if (! $options) {
		$options = {};
	}
	if (! exists($$options{'address'})) {
		$$options{'address'} = 'localhost';
	}
	if (! exists($$options{'privateName'})) {
		$$options{'privateName'} = $name;
	}
        return SpreadConnection->newInitialized($options);
}

