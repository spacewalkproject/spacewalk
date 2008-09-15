package ObjectProxyMessage;

use NOCpulse::Debug;
use Fcntl;



##########################################################
# Global variables
#

# Debug object for class methods
my $DEBUG = new NOCpulse::Debug;

##########################################################
# Accessor methods
#
sub data        { shift->_elem('data',        @_); }
sub debug       { shift->_elem('debug',       @_); }
sub opcode      { shift->_elem('opcode',      @_); }
sub params      { shift->_elem('params',      @_); }


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

  # Set up the debug object or use the one provided
  my $debug = $args{'Debug'} or $DEBUG;
  $self->debug($debug);

  # Store optional data fields
  $self->data($args{'Data'});
  $self->opcode($args{'Opcode'});
  $self->params($args{'Params'});

  return $self;
}


####################
sub setDebugObject {
####################
  my $class = shift;
  $DEBUG = shift;
}



#############
sub extract {
#############

  my $class = shift;

  # Extract complete ObjectProxyMessages from a string and return
  # any leftover bytes.

  my $buf = shift;
  my @msgs;

  $DEBUG->dprint(3, "*** OPM::extract($buf)\n");

  while (1) {

    if ($buf !~ /\n/) {
      # Partial message (no opline)
      $DEBUG->dprint(3, "\tNo opline, leaving extraction loop\n");
      last;
    }

    my($opline, $data) = split(/\n/, $buf, 2);
    my($opcode, $size, @params) = split(/\s+/, $opline);

    if (length($data) < $size) {

      # Incomplete message
      last;

    } else {

      # There's at least one complete message -- extract it.
      $data = substr($data, 0, $size, '');
      $buf  = $data;
      $DEBUG->dprint(3, "\tGot a complete message:\n");
      $DEBUG->dprint(3, "\t\tOpcode '$opcode', params: @params\n");
      $DEBUG->dprint(3, "\t\tData: >>>$data<<<\n");

      my $opmsg = new ObjectProxyMessage(Opcode => $opcode,
					 Params => [@params],
					 Data   => $data);

      push(@msgs, $opmsg);
    }

  }

  return (\@msgs, $buf);

}





##########################################################
# Instance methods
#

sub as_str {
  my $self = shift;

  # Create a textual representation of the object that can
  # be parsed by extract().

  my $opline = join(" ", $self->opcode, length($self->data),
                         @{$self->params});

  return join("\n", $opline, $self->data);

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
