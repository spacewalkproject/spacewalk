package NOCpulse::Notif::FileQueue;             

use strict;
use Class::MethodMaker
  new_hash_init => 'new',
  get_set       => [qw (directory item_class _current_alert _current_file)],
  list          => [qw( _files )];

my $SUFFIX = '.inp';

use Data::Dumper;

use NOCpulse::Log::Logger;
my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

## Note: Be wary that directory doesn't contain subdirectories that do not start with the character '.'.  
##       They will be considered a file in the FileQueue.  ==:o


###############
sub _filelist {
###############
  my $self=shift;

  $Log->log(9,"in here\n");
  return $self->_files if @{$self->_files};
 
  # Parse the directory for more files
  $Log->log(9,"nothing in _files, getting more...\n");
  my $dir= `pwd`;
  chomp($dir);
  chdir $self->directory || die "unable to chdir";
  $Log->log(9,`ls -alt`,"\n");

  my @files=glob("*");
  $Log->dump(9,"\@files are ",\@files,"\n(@files)\n");

  # Prepend the directory name to the file names found
  $self->_files( (map { $self->directory . "/$_" } @files) );
  $Log->dump(9,"_files are ",$self->_files,"\n(_files)\n");
  chdir $dir;
  return $self->_files;
}

##########
sub peek {
##########
  my $self=shift;
  return $self->_current_alert if $self->_current_alert;

  if (@{$self->_filelist}) {
    my $file=$self->_filelist->[0];
    unless ($file) {
      $Log->log(9,$self->item_class,": peeking at nothing\n");
      return undef
    }
    unless (-e $file) {
      $Log->log(1,"$file no longer exists -- dequeuing\n");
      $self->_files_shift;
      return undef
    }
    if ($file =~ /$SUFFIX$/) { #prevent the .inp.inp.inp.yadayadayada
      $Log->log(9,"not renaming $file\n");
      $self->_current_file("$file");
    } else {
      $self->_current_file("$file$SUFFIX");
      rename($file,$self->_current_file);
      $Log->log(9,"renaming $file to $file$SUFFIX\n");
    }
    $self->_current_alert($self->item_class->from_file($self->_current_file));
    return $self->_current_alert
  }
  return undef
}

##########
sub skip {
##########
# Skip the next file and make it last
  my $self=shift;

  #Grab any new files
  $self->_filelist;
  $Log->log(9,"(skip) file list is ", &Dumper($self->_files),"\n");
    
  #Check for file being peeked at
  my $file=$self->_current_file;
  $Log->log(9,"(skip) peeked file is $file\n");

  #Remove .inp suffix if file exists
  if ($file =~ /^(.*)$SUFFIX$/) {
    rename($file,$1);
    $Log->log(9,"renaming $file back to $1\n");
  } 

  $file=$self->_files_shift;
  $Log->log(1,"(skip) file is $file\n");

  #There is no file to skip, i.e. queue is currently empty
  return unless $file;  

  #Put the skipped file last
  $self->_files_push($file);
  $self->_current_alert(undef);
  $self->_current_file(undef);
}

#############
sub dequeue {
#############
  my $self=shift;
  my $alert = $self->peek;
  unlink ($self->_current_file) if ($self->_current_file);
  my $val=shift(@{$self->_files});
  $Log->log(9,$self->item_class," dequeing $val\n");
  $self->_current_alert(undef);
  $self->_current_file(undef);
  return $alert
}

##################
sub current_file {
##################
  my $self=shift;
  return $self->_current_file
}

1;

__END__

=head1 NAME

NOCpulse::Notif::FileQueue - A file based queue.

=head1 SYNOPSIS

# Create a new file queue
$queue=NOCpulse::Notif::FileQueue->new(
  'directory'  => '/tmp/somequeuedir' 
  'item_class' => $class_name);

# Return the next object in the queue, but do not remove it from the queue
$object=$queue->peek();

# Return the next object in the queue, removing it from the queue
$object=$queue->dequeue();

=head1 DESCRIPTION

The C<FileQueue> object manages a directory of single files containing information to build a single object and returns these objects like a queue.

=head1 CLASS METHODS

=over 4

=item new ( [%args] )

Create a new object with the supplied arguments, if any.

=back

=head1 METHODS

=over 4

=item current_file ( )

Return the name of the file at the front of the queue.

=item directory ( [ $directory_name ] )

Get or set the directory name upon which this queue will read files from.

=item item_class ( [$class ] )

Get or set the name of the class that will be creating objects from the files managed by this queue.  This class must implement a from_file ($filename) constructor.

=item peek ( )

Return the next object in the queue, without removing it from the queue.  Returns undefined if the queue is empty.

=item dequeue ( )

Return the next object in the queue and remove it from the queue.  Returns undefined if the queue is empty.

=back

=head1 BUGS

No known bugs.

=head1 AUTHOR

Karen Jacqmin-Adams <kja@redhat.com>

Last update: $Date: 2004-11-18 17:13:13 $

=head1 SEE ALSO

B<NOCpulse::Notif::Alert>
B<NOCpulse::Notif::Acknowldegement>
B<NOCpulse::Notif::Request>
B</usr/bin/notifserver.pl>

=cut
