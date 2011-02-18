###############################
package NOCpulse::CommandQueue;
###############################

use strict;
use Data::Dumper;
use LWP::UserAgent;
use NOCpulse::Config;
use NOCpulse::Debug;
use NOCpulse::CommandQueue::Parser;
use NOCpulse::SatCluster;

# Global variables
my %DEBUG_PARAMS;
my $HBFREQ = 60;  # Heartbeat once a minute by default
my $PROTOCOL_VERSION = '1.0';  # Keep in synch with fetch_commands.cgi

######################################################
# Accessor methods
#
sub commands           { shift->_elem('commands',          @_); }
sub debug              { shift->_elem('debug',             @_); }
sub heartbeatfile      { shift->_elem('heartbeatfile',     @_); }
sub heartbeatfreq      { shift->_elem('heartbeatfreq',     @_); }
sub lastcompletedfile  { shift->_elem('lastcompletedfile', @_); }
sub laststartedfile    { shift->_elem('laststartedfile',   @_); }
sub nsdesc             { shift->_elem('nsdesc',            @_); }
sub queue              { shift->_elem('queue',             @_); }
sub url                { shift->_elem('url',               @_); }
sub cluster            { shift->_elem('cluster',           @_); }
sub cfg                { shift->_elem('cfg',               @_); }

######################################################
# Class methods
#

#########
sub new {
#########
  my $class  = shift;
  my $id     = shift;
  my $self   = {};
  bless $self, $class;

  # Fetch configuration variables
  my $cfg = new NOCpulse::Config;

  $self->cfg($cfg);
  $self->cluster( NOCpulse::SatCluster->newInitialized($cfg));  
  $self->url(               $cfg->get('CommandQueue', 'queueServer')       );
  $self->laststartedfile(   $cfg->get('CommandQueue', 'lastStartedFile')   );
  $self->lastcompletedfile( $cfg->get('CommandQueue', 'lastCompletedFile') );
  $self->queue(             $cfg->get('CommandQueue', 'queueName')         );

  # Set defaults
  $self->heartbeatfreq($HBFREQ);

  $self->debug(new NOCpulse::Debug());
  my $stream = $self->debug->addstream(%DEBUG_PARAMS);

  return $self;
}


##############
sub setDebug {
##############
  $DEBUG_PARAMS{'LEVEL'} = shift;
}


####################
sub setDebugParams {
####################
  my %params = @_;
  my $param;
  foreach $param (keys %params) {
    $DEBUG_PARAMS{$param} = $params{$param};
  }
}



######################################################
# Instance methods
#


# Print debugging statements
############
sub dprint {
############
  my($self) = shift;
  if ($self->debug) {
    $self->debug->dprint(@_);
    $self->debug->flush();
  }
}


############
sub as_str {
############
  my $self = shift;
  return &Dumper($self);
}



##################
sub add_instance {
##################
  my $self     = shift;
  my $instance = shift;
  my $iid      = shift;

  $instance->cluster_id($self->cluster()->get_id());

  $self->{'commands'}->{$iid} = $instance;
}



####################
sub fetch_commands {
####################

  my $self = shift;
  my $queue;

  # Clear out any old commands
  $self->commands({});

  my $url = $self->url();

  my $ua = new LWP::UserAgent;
  $ua->timeout(30);

  my $cluster = $self->cluster();
  $cluster->refreshHAView();
  my $clusterid = $cluster->get_id();
  my $nodeid = $cluster->get_nodeId();
  my $role;
  if ($cluster->get_currentNode->get_isLead)
  {
    $role = "lead";
  }

  my $requrl = "$url?cluster_id=$clusterid&node_id=$nodeid&role=$role&version=$PROTOCOL_VERSION";
  $self->dprint(3, "\tQueue server URL:  $requrl\n");
  my $req = new HTTP::Request(GET => $requrl);

  my $res = $ua->request($req);

  if ($res->is_success) {

    $self->dprint(2, "\tSuccessfully got command list\n");
    $self->dprint(4, "\t\tCOMMAND LIST:\n", $res->content, "\n");

    my $parser = new NOCpulse::CommandQueue::Parser;
    $parser->debug($self->debug);  # Propagate the debug object

    $parser->parse($self, $res->content());

  } else {

    $@ = sprintf("HTTP error:  %s %s", $res->code, $res->message);
    $self->dprint(2, "\tFailed to get command list: $@\n");
    return undef;

  }

  $self->dprint(2, "\tCQ::fetch_commands returning $self\n");
  $self->dprint(4, "\t\tQUEUE:  ", $self->as_str, "\n");
  return $self;

}


###############
sub heartbeat {
###############
  my $self = shift;

  # Maintain a heartbeat file.

  my $hbfile = $self->heartbeatfile;
  if (defined($hbfile)) {
    $self->dprint(3, "Freshening heartbeat file $hbfile\n");
    local * HB;
    open(HB, '>', $hbfile);
    print HB "Last updated ", scalar(localtime(time)), " by PID $$\n";
    close(HB);
    return 1;
  } else {
    $self->dprint(3, "No heartbeat file to freshen\n");
    return undef;
  }
}






# Accessor implementation (stolen from LWP::MemberMixin
# by Martijn Koster and Gisle Aas)
#########
sub _elem
#########
{
        my($self, $elem, $val) = @_;
        my $old = $self->{$elem};
        $self->{$elem} = $val if defined $val;
        return $old;
}


1;
