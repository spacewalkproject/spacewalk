package ObjectProxyPeer;

use NOCpulse::Debug;
use ObjectProxyMessage;
use Fcntl;


##########################################################
# Global variables
#
my $BLOCKSIZE = 1024 * 1024;


##########################################################
# Accessor methods
#
sub blocksize   { shift->_elem('blocksize',   @_); }
sub buffer      { shift->_elem('buffer',      @_); }
sub connection  { shift->_elem('connection',  @_); }
sub debug       { shift->_elem('debug',       @_); }
sub messages    { shift->_elem('messages',    @_); }
sub requests    { shift->_elem('requests',    @_); }


##########################################################
# Class methods
#

#########
sub new {
#########
  my $class = shift;
  my %args  = @_;
  $class    = ref($class) || $class;
  my $self  = {};
  bless $self,$class;

  # Enable non-blocking reads on the socket
  my $conn  = $args{'Connection'};
  unless (fcntl($conn, F_SETFL, O_NONBLOCK)) {
    $@ = "Couldn't make conn $conn non-blocking: $!";
    return undef;
  }
  $self->connection($conn);

  # Set up the debug object or use the one provided
  my $debug = $args{'Debug'} or new NOCpulse::Debug;
  $self->debug($debug);

  # Set the network block size
  $self->blocksize($args{'Blocksize'} or $BLOCKSIZE);

  # Set up an empty read buffer and an emtpy message queue
  $self->buffer("");
  $self->messages([]);

  return $self;
}





##########################################################
# Instance methods
#

##############
sub read_buf {
##############

  my $self   = shift;

  # Read all pending data into the buffer
  my $conn   = $self->connection();
  my $buf    = $self->buffer();
  my $block  = $self->blocksize();

  $self->dprint(3, "\tBEFORE BLOCK READ: Buf is ", length($buf), " bytes\n");

  my($nread, $totalread);
  while (1) {
    $self->dprint(4, "\t\tBEFORE READ: Buf is ", length($buf), " bytes\n");
    $nread = read($conn, $buf, $block, length($buf));
    $totalread += $nread;
    $self->dprint(4, "\t\tAFTER READ:  Buf is ", length($buf), " bytes\n");
    $self->dprint(3, "\t\t(read $nread bytes)\n");
    last unless ($nread);
    sleep 1;
  }
  $self->dprint(3, "\tAFTER BLOCK READ: Buf is ", length($buf), " bytes\n");
  $self->buffer($buf);

  return $totalread;
}


#################
sub get_request {
#################
  my $self = shift;

  # First, read any pending data into my buffer
  $self->dprint(2, "Reading buffer\n");
  my $nbytes = $self->read_buf();
  $self->dprint(3, "\tGot $nbytes bytes\n");

  # If we got any new data, parse the buffer for 
  # complete messages.
  if ($nbytes) {
    $self->dprint(2, "Parsing buffer for messages\n");

    my($msgref, $buf) = ObjectProxyMessage->extract($self->buffer);

    if (scalar(@$msgref)) {

      # Messages were extracted -- return the first, store the rest,
      # and save any leftover bytes
      my $rv = shift(@$msgref);
      push(@{$self->messages()}, @$msgref);
      $self->buffer($buf);
      return $rv;

    }

  } else {

    $self->dprint(2, "Not parsing buffer (no new data)\n");

  }

  return undef;


}


##################
sub get_response {
##################

  my $self = shift;
  $self->dprint(3, "Entering get_response()\n");

  # Blocking form of get_request -- keep reading the socket until
  # we get a complete message.
  my $msg;
  my $readvec;
  vec($readvec, fileno($self->connection), 1) = 1;

  while (! defined($msg)) {
    $self->dprint(3, "Trying to read message ...\n");
    $msg = $self->get_request();
    last if (defined($msg));

    $self->dprint(3, "No message yet, blocking until more data\n");
    select($readvec, undef, undef, undef);

  }

  $self->dprint(3, "Got message: $msg\n");
  $self->dprint(3, "Leaving get_response()\n");
  return $msg;

}


##########
sub send {
##########
  my $self = shift;
  my $msg  = shift;

  my $conn = $self->connection();
  my $str = $msg->as_str;

  $self->dprint(3, "Writing message (", length($str), " bytes) to peer\n");

  # Set up a write vector for the select() call
  my $writevec;
  vec($writevec, fileno($self->connection), 1) = 1;

  my($written, $wv);
  while ($written < length($str)) {
    $self->dprint(3, "\tWriting to peer\n");
    my $nb    = syswrite($conn, $str, length($str), $written) + 0;
    $written += $nb;
    $self->dprint(3, "\tWrote $nb bytes to peer ($written total, ",
                      length($str) - $written, " left)\n");

    $self->dprint(3, "\tWaiting for writable socket\n");
    unless ($nb) {
      my $rv = select(undef, $wv=$writevec, undef, undef);
      $self->dprint(3, "\t\tSelect returns: $rv\n");
    }
  }

  $self->dprint(3, "Message sent\n");

  #print $conn $msg->as_str();

}


############
sub dprint {
############
   my $self = shift;

   $self->{'debug'}->dprint(@_);

}





# Accessor implementation (stolen from LWP::MemberMixin,
# by Martijn Koster and Gisle Aas)
###########
sub _elem {
###########
  my($self, $elem, $val) = @_;
  my $old = $self->{$elem};
  $self->{$elem} = $val if defined $val;
  return $old;
}

1;
