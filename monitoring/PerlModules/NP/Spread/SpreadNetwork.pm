use Spread qw(:MESS); # Need to export message service types


=head1 NAME
 
SpreadNetwork - a collection of classes for working with Spread networks

=item

=head1 SYNOPSIS



my $connection = SpreadConnection->newInitialized({
				'privateName'=>'mycon',
				'readTimeout'=>90
			});

SpreadMessage->newInitialized({
			'contents'=>'hello world',
			'addressee'=>['someone']
		})->sendVia($connection);

$message = $connection->nextMessage;
 

=head1 DESCRIPTION

=over
=item
SpreadNetwork defines three classes: SpreadConnection, SpreadMessage, and SpreadMembershipInfo, thus:

=item
SpreadConnection - a class who's instances encapsulate all interaction with the spread network.  It 
is capable of generating instances of SpreadMessage.

=item
SpreadMessage - a class who's instances represent a message received from the spread network.  SpreadMessage
is capable of generating instances of SpreadMembershipInfo.

=item
SpreadObjectMessage - a class who's instances serialize themselves when encoded and deserialize when
decoded.  (This is just a subclass of SpreadMessage that overrides encode() and decoded())

=item
SpreadMembershipInfo - a class who's instances encapsulate all the logic required to understand Spread
membership messages.

=item
For more information on spread proper see http://www.spread.org/docs/docspread.html

=back

=head1 CLASS SpreadConnection

=head2 Instance variables

All instance variables are accessable by calling get_xxx (where xxx is the instance variable name).  All instance variables are settable by calling set_xxx.  All instance variable values can be set on construction by passing a hash reference in with key-value pairs appropriately (see newInitialized)

=item
mbox [default=undef]:  The filehandle of connection to spread.  This is mostly meaningful only to the SpreadConnection class.

=item
mailbox [default=undef]: The fully qualified private group name per Spread::connect()

=item
address [default='127.0.0.1']: The address of Spread server to connect to

=item
port [default=4803]: The port to connect to on address

=item
privateName [default=undef]: The unqualified private group name per constructor

=item
priority [default=0]: Currently undefined (no effect).

=item
receiveMembershipInfo [default=0]: Whether or not to receive membership messages

=item
joinedGroups [default={}]: List of all groups this connection belongs to

=item
readTimeout [default=60]: Seconds before timeout in nextMessage (0 = infinite)

=item
doAutoDisconnect [default=1]: If true, disconnect when connection object is destroyed

=item
discardSelfMessages [default=0]: If true, messages from self are discarded

=head2 Class Methods

=item newInitialized({key=>value,[...]}): Takes as it's argument a ref to a hash that contains key-value pairs describing initial instance variable values.  Returns an instance of SpreadConnection where the instance will (barring erorrs) be connected to the spread network.

=head2 Instance Methods

=item
spreadError(): returns spread error number for the last operation

=item
spreadErrorMessage(): returns spread error message for the last operation

=item
connect({key=>value,[...]}): Called by the constructor (so you normally won't need to call this).  Takes as it's parameter a ref to a hash that contains instance variable key-value pairs.

=item
disconnect():  Call this to explicity disconnect from the spread network.

=item
reconnect(): Call this to reconnect to the spread network.  This method first ensures the instance is disconnected by calling disconnect(), then attempts to connect via connect().  Once it succeeds, it re-joins all groups that the connection had been joined to prior to the call.  Note that this method contains a loop - it will try forever if there's some problem talking to the spread server.

=item
isConnected(): Returns true if the connection is connected, false if it isn't.

=item
join('groupname1'[,'groupname2'[,'groupnameN']]): Causes the connection to join whatever group(s) are provided.

=item
leave('groupname1'[,'groupname2'[,'groupnameN']]): Causes the connection to leave whatever group(s) are provided.

=item
send($message): Sends the instance of SpreadMessage you pass in.

=item
incomingBytes(): Returns however many bytes are waiting to be received by this connection.

=item
messageWaiting(): Returns true if there's more than 0 incomingBytes().

=item
nextMessage(aClass): Returns the next message from the connection in the form of an instance of either SpreadMessage or whatever class name you pass in (assumes that you pass in the name of a class that answers all of SpreadMessage's protocols).  If messageWaiting() is false at the time of the call, this will be a blocking call up to readTimeout seconds.  If discardSelfMessages is true, a message from self will cause this method to return undef.  

=item
DESTROY(): If doAutoDisconnect is true (which is the default), the object will do a Spread::disconnect before it is garbage collected.


=head1 CLASS SpreadMessage

=head2 Instance variables

All instance variables are accessable by calling get_xxx (where xxx is the instance variable name).  All instance variables are settable by calling set_xxx.  All instance variable values can be set on construction by passing a hash reference in with key-value pairs appropriately (see newInitialized)

=item
serviceType [default= SAFE_MESS]: One of AGREED_MESS, CAUSAL_MESS, FIFO_MESS, RELIABLE_MESS, SAFE_MESS, TRANSITION_MESS, UNRELIABLE_MESS (see Spread documentation)

=item
addressee [default=undef]: List of one or more recipients for this message

=item
type [default=0]:   A 16 bit "subject" field - currently unused by this framework (and thus available).  In the future this framework might implement an optional "large message mode" that would claim all or some of these bits.

=item
contents [default=undef]: Message contents - can be up to maxMessageSize bytes.  Returns true (1) if the contents were actually set.  They might not have been if the message is greater than maxMessageSize bytes and failOversizeMessages is true, in which case returns 0.  Also, if truncateOversizeMessages is true, the contents might have been truncated - if this happened, the return will be 2.

=item
sender [default=undef]: Only meaningful for inbound messages - contains the private name of the sender

=item
endian [default=undef]:   Whether or not there's an endian mismatch between the machine the sender of this message is on and the current machine

=item
maxMessageSize [default=100000]:   Max content size for a message.  This is something of a "mysterious" value in the spread world - see Spread documentation for details.  The default value should work in most situations.

=item
failOversizeMessages [default=0]: If this is true, behavior of set_contents changes.  See contents (above)

=item
truncateOversizeMessages [default=1]: If this is true, behavior of set_contents changes.  See contents (above)

=item
oversizeContents [default=0]:   True if too much data was given to set_contents

=head2 Class Methods

=item newInitialized({key=>value,[...]}): Takes as it's argument a ref to a hash that contains key-value pairs describing initial instance variable values.  Returns an instance of SpreadMessage.

=head2 Instance Methods

=item
NextFrom(<aSpreadConnection>): Another way to say $connection->nextMessage(aClass).  In this case aClass will be whatever class the caller is an instance of.

=item
sendVia(<aSpreadConnection>): Sends this message via aSpreadConnection

=item
encoded(): Returns contents encoded appropriately.  Base class returns contents, subclasses can override

=item
decoded(): Decode message contents appropriately and return decoded instance.  Base does nothing and returns
self. Subclasses can override.  Bear in mind that whatever is returned from this method is what nextMessage
returns!

=item
asObject(): If the contents of the message are a perl entity serialized by the FreezeThaw package, returns the object in question, otherwise returns the contents as they are.

=item
isAgreed(): Returns true if this is an AGREED_MESS (see Spread docs for details)

=item
isCausal(): Returns true if this is a CAUSAL_MESS (see Spread docs for details)

=item
isFifo(): Returns true if this is a FIFO_MESS (see Spread docs for details)

=item
isMembership(): Returns true if this is a MEMBERSHIP_MESS (see Spread docs for details).  If this is true, membershipInfo will return an instance of SpreadMembershipInfo.

=item
isRegular(): Returns true if this is a REGULAR_MESS (see Spread docs for details)

=item
isReliable(): Returns true if this is a RELIABLE_MESS (see Spread docs for details)

=item
isSafe(): Returns true if this is a SAFE_MESS (see Spread docs for details)

=item
isUnreliable(): Returns true if this is an UNRELIABLE_MESS (see Spread docs for details)

=item
setAgreed(): Sets serviceType to AGREED_MESS (see Spread docs for details)

=item
setCausal(): Sets serviceType to CAUSAL_MESS (see Spread docs for details)

=item
setFifo(): Sets serviceType to FIFO_MESS (see Spread docs for details)

=item
setReliable(): Sets serviceType to RELIABLE_MESS (see Spread docs for details)

=item
setSafe(): Sets serviceType to SAFE_MESS (see Spread docs for details)

=item
setUnreliable(): Sets serviceType to UNRELIABLE_MESS (see Spread docs for details)

=item
membershipInfo(): If $message->isMembership, returns an instance of SpreadMembershipInfo

=head1 CLASS SpreadMembershipInfo

=head2 Instance variables

All instance variables are accessable by calling get_xxx (where xxx is the instance variable name).  All instance variables are settable by calling set_xxx.

=item
message [default=undef]: Contains the message from which the info is derived

=item
groupId [default=[] ]: Contains the three-byte group id of the group that had the membership change.

=item
numMembers [default=0]: Contains the number of members in the group

=item
transMembers [default='']: Contains a list of the members involved in the transition.

=head2 Class Methods

=item newInitialized(<aSpreadMessage>): Takes as it's argument an instance of SpreadMessage, returns an instance of SpreadMembershipInfo

=head2 Instance Methods

=item
isSelfLeave(): True if this is a  "self leave" message

=item
get_serviceType():

=item
isRegularMembership(): True if this is a "regular membership" message

=item
isTransition(): True if this is a "transition" message - in this case the only other valid question to ask is groupInQuestion() (below).

=item
isCausedByJoin(): True if this membership message was caused by someone joining the groupInQuestion().

=item
isCausedByLeave(): True if this membership message was caused by someone leaving the groupInQuestion().

=item
isCausedByDisconnect(): True if this membership message was caused by someone disconnecting (and thus leaving the groupInQuestion()).

=item
isCausedByNetwork(): True if this membership message was caused by a network partition (and thus having potentially several connections leave the groupInQuestion()).

=item
groupInQuestion(): Returns the group in which the membership change occurred.

=item
whoDisconnected(): Returns the name of the connection that disconnected.

=item
whoJoined(): Returns the name of the connection that joined.

=item
whoLeft(): Returns the name of the connection that left.

=item
whoIsNotPartitioned(): Returns a list of those connections that are NOT partitioned.

=item
whoIsInTheGroup(): Returns a list of those connections who are in the group as of this message

=item
isSelfJoin(<privateName>): True or false depending on whether or not the message was caused by the given private name's having joined a group

=cut

########################################################################################
# CODE STARTS HERE
########################################################################################

package SpreadConnection;
use Spread qw(:MESS :ERROR);
use NOCpulse::Object;
@ISA=qw(Object);

sub instVarDefinitions
{
	my $self = shift();
	$self->addInstVar('mbox',undef);		# filehandle of connection
	$self->addInstVar('mailbox',undef);		# fully qualified private group naem
	$self->addInstVar('address','127.0.0.1');	# address of server to connect to
	$self->addInstVar('port',4803);			# port to connect to
	$self->addInstVar('privateName',undef);		# unqualified private group name per constructor
	$self->addInstVar('priority',0);		# currently undefined (no effect)
	$self->addInstVar('receiveMembershipInfo',0);	# whether or not to receive membership msgs
	$self->addInstVar('joinedGroups',{});		# list of all groups this connection belongs to
	$self->addInstVar('readTimeout',60);		# seconds before timeout in nextMessage (0 = infinite)
	$self->addInstVar('doAutoDisconnect',1);	# If true, disconnect when conn obj is destroyed
	$self->addInstVar('discardSelfMessages',0);	# If true, messages from self are discarded
	$self->addInstVar('filter',undef);		# Filter instance through which content will pass
	# To be implemented
	$self->addInstVar('autoSplitBigMessages',0);	# If true, big msgs will be auto-split
}

sub initialize
{
	my ($self,@params) = @_;
	$self->connect(@params);
	return $self;
}

sub spreadError
{
	return $Spread::sperrno;
}

sub spreadErrorMessage
{
	return "$Spread::sperrno";
}

sub connect
{
	my ($self,$options) = @_;
	if (defined($options)) {
		# $options should be a hash containing any of
		# address,port,privateName,priority,receiveMembershipInfo
		my ($key,$value);
		while (($key,$value) = each(%$options)) {
			$self->set($key,$value);
		}
	}
	my $server = $self->get_port;
	if ($self->get_address) {
		$server = $server.'@'.$self->get_address;
	}
	my ($mbox,$mailbox) = 
		Spread::connect({
			spread_name=>$server,
			private_name=>$self->get_privateName,
			priority=>$self->get_priority,
			group_membership=>$self->get_receiveMembershipInfo
		});
	if ($mbox) {
		# Strange situation requires this:
		# IF sperrno is nonzero when a successful
		# connection occurs (we get an MBOX number),
		# it seems that sperrno is not properly updated
		# by the library.  So we clear it here. I strongly
		# suspect it's a problem with the perl to C
		# interface which I think is the XS stuff.
		$Spread::sperrno = 0;
	}
	$self->set_mbox($mbox);
	$self->set_mailbox($mailbox);
	return $self->isConnected;
}

sub disconnect
{
	my $self = shift();
	my $result = 1;
	if ($self->get_mbox) {
		$result = Spread::disconnect($self->get_mbox);
		$self->set_mbox(undef);
	}
	return ($result == 0);
}

sub reconnect
{
	my ($self,$attempts) = @_;
	# undef for attempts == infinite
	$self->disconnect;
	while (($attempts gt 0) or (! defined($attempts))) {
		sleep(1);
		if ($self->connect) {
			my $groupHash = $self->get_joinedGroups;
			my @groups = keys(%$groupHash);
			$self->set_joinedGroups({});
			$self->join(@groups);
			$attempts = 0;
		} else {
			if (defined($attempts)) {
				$attempts = $attempts - 1;
			}
		}
	}
	return $self->isConnected;
}

sub isConnected
{
	my $self = shift();
	my $spreadError = $self->spreadError;
	# Other/different flags might be appropriate here as well.
	# Need to investigate. Note that Java classes don't appear
	# to try to answer this.
	my $badSession = ($spreadError == CONNECTION_CLOSED or
			  $spreadError == ILLEGAL_SESSION or
			  $spreadError == COULD_NOT_CONNECT or
			  $spreadError == REJECT_NOT_UNIQUE);
	return ($self->get_mbox && (! $badSession));
}

sub _addGroup
{
	my ($self,$groupName) = @_;
	my $groups = $self->get_joinedGroups;
	$groups->{$groupName} = time();
}

sub _delGroup
{
	my ($self,$groupName) = @_;
	my $groups = $self->get_joinedGroups;
	delete($groups->{$groupName});
}

sub join
{
	my ($self,@groupNames) = @_;
	return undef if (! $self->isConnected);
	my @joinedGroups = grep(
					Spread::join(
						$self->get_mbox,
						$_
					),
					@groupNames
				);
	map($self->_addGroup($_),@joinedGroups);
	return (scalar(@joinedGroups) == scalar(@groupNames));
}

sub leave
{
	my ($self,@groupNames) = @_;
	return undef if (! $self->isConnected);
	my @leftGroups = grep(
					Spread::leave(
						$self->get_mbox,
						$_
					),
					@groupNames
				);
	map($self->_delGroup($_),@leftGroups);
	return (scalar(@leftGroups) == scalar(@groupNames));
}

sub filter
{
	my ($self,$data) = @_;
	$self->dprint(3,'Filter input = '.$data."\n");
	if ($self->get_filter) {
		return $self->get_filter->encode($data);
	} else {
		return $data;
	}
}

sub unfilter
{
	my ($self,$data) = @_;
	$self->dprint(3,'Un-Filter input = '.$data."\n");
	if ($self->get_filter) {
		return $self->get_filter->tail->decode($data);
	} else {
		return $data;
	}
}

sub send
{
	my ($self,$message) = @_;
	return undef if (! $self->isConnected);
	my $contents = $message->encoded;
	$contents = $self->filter($contents);
	$self->dprint(9,"Sending $message to addressee(s)".$message->get_addressee."\n");
	my $addressee = $message->get_addressee;
	my @addrs;
	if (ref($addressee)) {
		@addrs = @$addressee;
	} elsif (defined($addressee)) {
		push(@addrs,$addressee);
	}
	return (Spread::multicast(	
			$self->get_mbox,
			$message->get_serviceType,
			@addrs,
			$message->get_type,
			$contents
	) > 0);
}

sub incomingBytes
{
	my $self = shift();
	return undef if (! $self->isConnected);
	return Spread::poll($self->get_mbox);
}

sub messageWaiting
{
	return shift()->incomingBytes;
}

sub nextMessage
{
	# This blocks
	my ($self,$msgClass) = @_;
	if (! $msgClass) {
		$msgClass = 'SpreadMessage';
	}
	return undef if (! $self->isConnected);
	my $rv = eval {
		local $SIG{"ALRM"} = sub {die undef};
 		# if zero, no alarm is scheduled
        	alarm($self->get_readTimeout);
		my ($service_type,$sender,$groups,$mess_type,$endian,$message) = Spread::receive($self->get_mbox);
		if (($sender eq $self->get_mailbox) && ($self->get_discardSelfMessages)) {
			return undef
		}
		$self->dprint(9,"$$|$service_type|$sender|$groups|$mess_type|$endian|$message\n");
		$message = $self->unfilter($message);
		$result = $msgClass->newInitialized({
			serviceType=>$service_type,
			addressee=>$groups,
			sender=>$sender,
			endian=>$endian,
			type=>$mess_type,
			contents=>$message
		});
		alarm(0);
		return $result->decoded;
	};
	if ($@) {
		return undef
	} else {
		return $rv
	}
}

sub uniquePrivateName
{
	return substr(time(),-4,4).substr(rand(),-5,5)
}

sub DESTROY
{
	my $self = shift();
	if ($self->get_doAutoDisconnect) {
		$self->disconnect;
	}
}

package SpreadMessage;
use Spread qw(:MESS :ERROR);
use NOCpulse::Object;
@ISA=qw(Object);


sub NextFrom
# A constructor - really just calls $connection->nextMessage, but passing in ref($self) so
# that SpreadConnection can know that it needs to return an instance of whatever we are
# (possibly) instead of a plain old SpreadMessage
{
	my($selfishness,$connection) = @_;
	my $class = ref($selfishness)||$selfishness;
	return $connection->nextMessage($class);
}

sub instVarDefinitions
{
	my $self = shift();
	$self->addInstVar('serviceType',SAFE_MESS);
	$self->addInstVar('addressee'); # can be an array
	$self->addInstVar('type',0); # 16 bits available
	$self->addInstVar('contents',undef);
	$self->addInstVar('sender',undef); # Only meaningful for received messages 
	$self->addInstVar('endian',undef); # Whether or not there's an endian mismatch
	$self->addInstVar('maxMessageSize',100000); # Max content size for a message
	$self->addInstVar('failOversizeMessages',0); # Too big = don't set contents, return 0
	$self->addInstVar('truncateOversizeMessages',1); # Too big = truncate to maxMessageSize and return 2
	$self->addInstVar('oversizeContents',0); # True if too much data was given to set_contents
}

sub set
{
	my ($self,$name,$value) = @_;
	if ($name eq 'contents') {
		if (length($value) > $self->get_maxMessageSize) {
			$self->set_oversizeContents(1);
			if ($self->get_failOversizeMessages) {
				return 0;
			}
			if ($self->get_truncateOversizeMessages) {
				$self->SUPER::set('contents',substr($value,0,$self->get_maxMessageSize));
				return 2;
			}
			$self->SUPER::set('contents',$value); # the call to multicast will fail
		} else {
			$self->set_oversizeContents(0);
			$self->dprint(8,ref($self).": Setting $name to $value\n");
			$self->SUPER::set('contents',$value);
			return 1;
		}
	} else {
		$self->dprint(8,ref($self).": Setting $name to $value\n");
		return $self->SUPER::set($name,$value);
	}
}

sub initialize
{
	my ($self,$options) = @_;
	my ($key,$value);
	while (($key,$value) = each(%$options)) {
		$self->set($key,$value);
	}
	return $self;
}

sub encoded
{
	return shift()->get_contents;
}

sub decoded
{
	return shift();
}

sub get_groups
{
	return shift()->get_addressee;
}

sub sendVia
{
	my ($self,$connection) = @_;
	return $connection->send($self);
}

sub asObject
{
	my $self = shift();
	if (substr($self->get_contents,0,4) eq 'FrT;') {
		return Object->fromStoreString($self->get_contents);
	} else {
		return $self->get_contents
	}
}
sub isAgreed
{
	my $self = shift();
	return ($self->isRegular & AGREED_MESS);
}
sub isCausal
{
	my $self = shift();
	return ($self->isRegular & CAUSAL_MESS);
}
sub isFifo
{
	my $self = shift();
	return ($self->isRegular & FIFO_MESS);
}
sub isMembership
{
	my $self = shift();
	return ($self->get_serviceType & MEMBERSHIP_MESS);
}
sub isRegular
{
	my $self = shift();
	return ($self->get_serviceType & REGULAR_MESS);
}
sub isReliable
{
	my $self = shift();
	return ($self->isRegular & RELIABLE_MESS);
}
sub isSafe
{
	my $self = shift();
	return ($self->isRegular & SAFE_MESS);
}
sub isUnreliable
{
	my $self = shift();
	return ($self->isRegular & UNRELIABLE_MESS);
}
sub setAgreed
{
	my $self = shift();
	$self->set_serviceType(AGREED_MESS);
}
sub setCausal
{
	my $self = shift();
	$self->set_serviceType(CAUSAL_MESS);
}
sub setFifo
{
	my $self = shift();
	$self->set_serviceType(FIFO_MESS);
}
sub setReliable
{
	my $self = shift();
	$self->set_serviceType(RELIABLE_MESS);
}
sub setSafe
{
	my $self = shift();
	$self->set_serviceType(SAFE_MESS);
}
sub setUnreliable
{
	my $self = shift();
	$self->set_serviceType(UNRELIABLE_MESS);
}

sub membershipInfo
{
	my $self = shift();
	if ($self->isMembership) {
		return SpreadMembershipInfo->newInitialized($self);
	} else {
		return undef;
	}
}



package SpreadObjectMessage;
use FreezeThaw qw(freeze thaw);
@ISA=qw(SpreadMessage);

sub encoded
{
	my $self = shift();
	return freeze($self);
}
sub decoded
{
	my $self = shift();
	my $result = $self->asObject;
	if ($result->can('addInstVar')) {
		# These will/may have changed, re-map them
		$result->addInstVar('sender',$self->get_sender);
		$result->addInstVar('addressee',$self->get_addressee);
		$result->addInstVar('endian',$self->get_endian);
	}
	return $result;
}




package SpreadMembershipInfo;
use Spread qw(:MESS :ERROR);
use Config;
use NOCpulse::Object;
@ISA=qw(Object);

sub instVarDefinitions
{
	my $self = shift();
	$self->addInstVar('message');
	$self->addInstVar('groupId',\[]);
	$self->addInstVar('numMembers',0);
	$self->addInstVar('transMembers','');
}

sub initialize
{
	my ($self,$message) = @_;
	$self->set_message($message);
	my $contents = $message->get_contents;
	my $byteOrder = $Config{'byteorder'}; #1234 - little endian, 4321 - big endian
	my $longType;
	if ($byteOrder == 1234) {
		$longType = 'V'
	} elsif ($byteOrder == 4321) {
		$longType = 'N'
	} else {
		die("Unknown byte ordering on this platform ($byteOrder)");
	}
	if ($self->get_message->get_endian) { # endian mismatch, so unpack opposite of whatever we are
		if ($longType eq 'V') {
			$longType = 'N'
		} else {
			$longType = 'V'
		}
	}
	# First three longs are group id, fourth long is number of members, remainder is Z string of group(s)
	my $packaging = $longType.
			$longType.
			$longType.
			$longType.
			'a*';
	my @parts = unpack($packaging,$contents);
	my @groupId;
	push (@groupId,shift(@parts));
	push (@groupId,shift(@parts));
	push (@groupId,shift(@parts));
	$self->set_groupId(\@groupId);
	$self->set_numMembers(shift(@parts));
	my $rawMembers = shift(@parts);
	my @members = split(/\0+/,$rawMembers);
	$self->set_transMembers(\@members);
	return $self;
}

sub isSelfLeave
{
	my $self = shift();
	return ((! $self->isTransition) && (! $self->isRegularMembership))
}

sub get_serviceType
{
	my $self = shift();
	return $self->get_message->isMembership;
}

sub isRegularMembership
{
	my $self = shift();
	return ($self->get_serviceType & REG_MEMB_MESS);
}

sub isTransition
{
	my $self = shift();
	# If this is true, getGroup is the only valid get function for the instance.
	return ($self->get_serviceType & TRANSITION_MESS);
}

sub isCausedByJoin
{
	my $self = shift();
	return ($self->isRegularMembership && ($self->get_serviceType & CAUSED_BY_JOIN));
}

sub isCausedByLeave
{
	my $self = shift();
	return ($self->isRegularMembership && ($self->get_serviceType & CAUSED_BY_LEAVE));
}

sub isCausedByDisconnect
{
	my $self = shift();
	return ($self->isRegularMembership && ($self->get_serviceType & CAUSED_BY_DISCONNECT));
}

sub isCausedByNetwork
{
	my $self = shift();
	return ($self->isRegularMembership && ($self->get_serviceType & CAUSED_BY_NETWORK));
}

sub groupInQuestion
{
	my $self = shift();
	return $self->get_message->get_sender;
}

sub whoDisconnected
{
	my $self = shift();
	return $self->get_transMembers;
}

sub whoJoined
{
	my $self = shift();
	return $self->get_transMembers;
}

sub whoLeft
{
	my $self = shift();
	return $self->get_transMembers;
}

sub whoIsNotPartitioned
{
	my $self = shift();
	return $self->get_transMembers;
}

sub whoIsInTheGroup
{
	my $self = shift();
	return $self->get_message->get_groups;
}

sub isSelfJoin
{
	my ($self,$myPrivName) = @_;
	return  ($self->isCausedByJoin && ($self->whoJoined->[0] eq $myPrivName));
}


