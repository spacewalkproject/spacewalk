####################
package TSDBLogFile;
####################

use strict;

use IO::File;

use Class::MethodMaker 
  new_with_init  => 'new',
  get_set        => [qw(
    path
    _handle
    _inode
    rate
  )],
  ;


# Set up for logging
use NOCpulse::Log::LogManager;
use NOCpulse::Log::Logger;

NOCpulse::Log::LogManager->instance->stream(FILE => \*STDOUT);
my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

##########
sub init {
##########
  my $self = shift;
  my $file = shift;

  # Open the file
  my $fh = IO::File->new();
  $fh->open($file) or die "Couldn't open $file: $!";

  # Make the handle non-blocking
  $fh->blocking(0);

  # Record file data
  $self->path($file);
  $self->_handle($fh);
  $self->_inode($self->inode);

  # Seek max 1k back from the end
  if ($self->size > 1024) {
    $self->seek(-1024, 2);
  }

}


############
sub reopen {
############
  my $self = shift;

  $self->_handle->close();
  $self->_handle->open($self->path);
  $self->_inode($self->inode);

}

#################
sub update_rate {
#################
  my $self = shift;

  $Log->log(1, "Updating rate for ", $self->path, "\n");
  while (my $line = $self->_handle->getline()) {
    if ($line =~ m{Inserts:.* = (\d+) in (\d+) seconds}) {
      my($inserts, $secs) = ($1, $2);
      my $rate = sprintf("%0.2f", $inserts / $secs);
      $self->rate($rate);
      $Log->log(2, "Found rate ($inserts/$secs == $rate ips)\n");
    }
  }

  # Check for file rotation
  if ($self->inode != $self->_inode) {
    $Log->log(1, "Reopening rotated logfile\n");
    $self->reopen();
  }

}


##########
sub seek {
##########
  my $self = shift;
  return $self->_handle->seek(@_);
}


##########
sub size {
##########
  my $self = shift;

  return ($self->_handle->stat())[7];

}


###########
sub inode {
###########
  my $self = shift;

  return ($self->_handle->stat())[1];

}




1;
