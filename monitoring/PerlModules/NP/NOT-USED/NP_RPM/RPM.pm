######################
package NOCpulse::RPM;
######################

use vars qw($VERSION);
$VERSION = (split(/\s+/, q$Id: RPM.pm,v 1.3 2003-08-29 20:39:03 cvs Exp $, 4))[2];

use strict;
use NOCpulse::Log::Logger;

# Globals
my $RPM_BIN = '/bin/rpm';
my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

###########
# Methods #
###########

###########
sub new   {
###########

  my ($class) = @_;
  my $self  = {};
  bless $self, $class;

  return $self;
}

# Accessor methods
#sub connected    { shift->_elem('connected',    @_); }

###########
sub _elem {
###########
# Stolen from LWP::MemberMixin

  my($self, $elem, $val) = @_;
  my $old = $self->{$elem};
  $self->{$elem} = $val if defined $val;
  return $old;
}


#### DAP - It hurts to have done this. Given the interface to exec()
####       however, the only other solution that strikes me as tenable
####       is to actually parse the params to figure out what's supposed
####       to get run.  If you guys have a better idea I'm all for it.

##########
sub set_build_mode {
##########
  my $self = shift();
  $RPM_BIN='/usr/bin/rpmbuild';
}

##########
sub set_query_mode {
##########
  my $self = shift();
  $RPM_BIN='/bin/rpm';
}

##########
sub exec {
##########

  my ($self, @params) = @_;

  # Prepare command for shell
  my $cmd = "$RPM_BIN @params";
        $cmd =~ /(.*)/;
        $cmd = $&;

  # Don't let it take too long!
#   my $tomsg   = "Timed out!\n";
  my $results;
  my $exitstatus;

  eval {
#     $SIG{'ALRM'} = sub {die $tomsg};
#     alarm($self->timeout);

    # Execute command and capture STDOUT & STDERR
    $results = `$cmd 2>&1`;

#     alarm(0);
  };

#   if ($@ eq $tomsg) {
#
#     $results = "Error: Timed out\n";
#     $exitstatus = 4;
#
#   } elsif ($@) {

  if ($@) {

    $results = "Error: $@\n";
    $exitstatus = 4;

  } else {
    # Interpret the exit status
    $exitstatus = $? >> 8;

  }
  # Return results
  $Log->log(3,"CMD: $cmd\nRESULTS:($exitstatus) $results\n");
  return($results, $exitstatus, $cmd);

}
