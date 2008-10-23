######################
package NOCpulse::CVS;
######################

use vars qw($VERSION);
$VERSION = (split(/\s+/, q$Id: CVS.pm,v 1.4 2004-12-15 23:09:27 mmccune Exp $, 4))[2];

use strict;
use NOCpulse::Log::Logger;

# Globals
my $CVS_BIN = '/usr/bin/cvs';
my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);


###########
# Methods #
###########

###########
sub new	 {
###########

	my ($class) = @_;
	my $self	= {};
	bless $self, $class;

	return $self;
}

# Accessor methods

##########
sub exec {
##########

  my ($self, @params) = @_;

  # Prepare command for shell
  my $cmd = "$CVS_BIN @params";

  my $results;
  my $exitstatus;
  my $done=0;
  my $count=0;

  while (!$done) {

    $count++;
    $cmd =~ /(.*)/;
    $cmd = $&;
    $results = `$cmd 2>&1`;

    # Interpret the exit status
    $exitstatus = $? >> 8;

    $done=1;
    if ($exitstatus==1) {
      $done=0 if ($results =~ /Connection reset by peer/) && ($count <= 3);
      print STDERR "\n$results\nRetrying...\n";
    }
}

  # Return results
  $Log->log(3,"CMD: $cmd\nRESULTS:($exitstatus) $results\n");
  return($results, $exitstatus, $cmd);

}
