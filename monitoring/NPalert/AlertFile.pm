package NOCpulse::Notif::AlertFile;

use strict;
use Config::IniFiles;
use Class::MethodMaker 
  new_hash_init => 'new',
  get_set       => [qw( alert file _lock )];

use NOCpulse::Notif::Alert;
use NOCpulse::Log::LogManager;

my $lock_ext=".lock";

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

######### CLASS METHODS ################

###############
sub open_file {
###############
  my ($class,$filename)=@_;

  my $instance = $class->new( file => $filename );
  $instance->acquire_lock || return undef;
  my $alert = NOCpulse::Notif::Alert->from_file($filename);

  if ($alert) {
    $instance->alert($alert);
  } else {
    $instance->release_lock;
    warn "Unable to read alert from file $filename";
    return 0;
  }
  
  return $instance;
}

##################
sub remove_locks {
##################
  my ($class,$directory,$prog,$pid)=@_;
  $Log->log(9,"remove locks: @_\n");

  my $pattern = "$directory/*$lock_ext";
  my @files=glob($pattern);
  $Log->log(9,"files are @files\n");

  foreach my $f (@files) {
    $Log->log(9,"lock file: $f\n");
    open(FILE,"< $f");
    my @contents=<FILE>;
    close(FILE);
    my $content=join('',@contents);
    $Log->log(9,"lock file contents: $content\n");

    # content is in format <prog-name>-<process id>
    # beware that prog-name itself can contain dash
    $content=~m/(.*)-(\d+)/;
    my ($program_name, $process_id)=($1, $2);
    $Log->log(9,"program name: $program_name, process_id: $process_id\n");
    
    if ($prog && ($program_name !~ /$prog/)) {
      $Log->log(9,"program name exists and doesn't match\n");
      next
    }
    if ($pid && ($process_id != $pid)) {
      $Log->log(9,"process id exists and doesn't match\n");
      next
    }
    
    unlink($f) || warn "Unable to unlink $f\n";
  } 
  return @files
}


##################
sub acquire_lock {
##################
  my $self=shift;

  unless ($self->file) {
    $Log->log(1,"FATAL ERROR: AlertFile->acquire_lock file not specified\n");
    print STDERR "FATAL ERROR: AlertFile->acquire_lock file not specified\n";
    die "file not specified";
  }
  my $lockfile=$self->file . $lock_ext;


### For debugging locking issues:  ###

#  my ($package, $file, $line) = caller(1);
#  $Log->log(9,"caller (1): $package, $file, $line\n");
#  ($package, $file, $line) = caller(2);
#  $Log->log(9,"caller (2): $package, $file, $line\n");
#  ($package, $file, $line) = caller(3);
#  $Log->log(9,"caller (3): $package, $file, $line\n");

### (End) For debugging locking issues:  ###

  
  if (-e $lockfile) {
    open(FILE,$lockfile);
    my @lines=<FILE>;
    close(FILE);
    my $err= "$$ Unable to acquire lock on " . $self->file . " " . 
              join("\n",@lines);
    $Log->log(1,"$err\n");
    warn $err;
    return undef;
  } else {
    unless (open(LOCK,">$lockfile")) {
      my $msg = "Unable to open lock on " . $self->file;
      $Log->log(1,"FATAL ERROR: $msg");
      print STDERR "FATAL ERROR: AlertFile->acquire_lock $msg";
      die $msg;
    } 
    print LOCK $0, '-', $$;
    unless (close(LOCK)) {
      warn "Unable to complete lock on " . $self->file;
      $Log->log(1,"FATAL ERROR: Unable to complete lock on " , $self->file , "\n");
    }
    $self->_lock($lockfile);
  }
  return $lockfile;
}

################
sub close_file {
################
  my $self=shift;
  $self->write;
  $self->release_lock;
}

##################
sub release_lock {
##################
  my $self=shift;
  unless (unlink $self->_lock) {
    warn "Unable to release lock " . $self->_lock;
  } 
  $self->_lock(undef);
}

############
sub delete {
############
  my $self=shift;
  if ($self->file) {
    unlink $self->file if $self->file;
    $self->file(undef);
  }
  if ($self->_lock) {
    unlink $self->_lock if $self->_lock;
    $self->_lock(undef);
  }
}

###########
sub write {
###########
  my $self=shift;
  if ($self->_lock) {
    $self->alert->to_file($self->file);
  } else {
    warn "Unable to write " . $self->file . ", lock not obtained";
  }
}

__END__

=head1 NAME

NOCpulse::Notif::AlertFile - A file-based Alert.

=head1 SYNOPSIS

 # Reads the alert from file (Storable format) and locks it for use
 my $alert = NOCpulse::Notification::AlertFile->open_file($filename);

 # Writes the contained alert to disk, preserving locking
 $alert->write;

 # Writes the contained alert to disk and unlocks the file
 $alert->close_file;

=head1 DESCRIPTION

An C<AlertFile> represents a file on disk containing an Alert.

=head1 CLASS METHODS

=over 4

=item open_file ( $filename )

Reads the alert with the given filename and locks the file.

=item new ( %args )

Create a new object initializing it with the supplied arguments.

=item remove_locks ( $directory [$program, $pid] )

Remove any lock files from the directory given, matching program name and pid, if specified.

=back

=head1 METHODS

=over 4

=item acquire_lock ( )

Acquires a lock on the alert file on disk.

=item alert ( $alert )

Get or set the alert associated with this file.

=item close_file ( )

Writes the alert back to disk and releases the lock.

=item delete ( )

Remove the alert file and its lock from disk.

=item file ( $filename ) 

Get the name of the file associated with this object.

=item release_lock ( )

Releases the lock on the alert file.

=item write ( )

Write the alert to disk without releasing the lock.

=back

=head1 BUGS

No known bugs.

=head1 AUTHOR

Karen Jacqmin-Adams <kja@redhat.com>

Last update: $Date: 2004-11-18 17:13:13 $

=head1 SEE ALSO

B<NOCpulse::Notif::Alert>

=cut
