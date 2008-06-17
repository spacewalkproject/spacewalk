package NOCpulse::TSDB::LocalQueue::FileManager;

use strict;

use DirHandle;
use Errno;
use Error qw(:try);
use File::Basename;
use File::Spec;
use File::stat;
use IO::AtomicFile;
use IO::File;
use IO::Select;

use NOCpulse::Utils::Error;
use NOCpulse::TSDB::LocalQueue::File;
use NOCpulse::Log::Logger;

$Error::Debug = 1;

use Class::MethodMaker
  get_set =>
  [qw(
      directory
      queue_file_directory
      archive_directory
     )],
  hash =>
  [qw(
      current_file
      old_file
      file_position
     )],
  new_with_init => 'new',
  new_hash_init => 'hash_init',
  ;

use constant QUEUE_FILE_DIR   => NOCpulse::TSDB::LocalQueue::File::QUEUE_FILE_DIR;
use constant ARCHIVE_FILE_DIR => NOCpulse::TSDB::LocalQueue::File::ARCHIVE_FILE_DIR;
use constant MARK_FILE        => 'queuefile.positions';
use constant READABLE_TIMEOUT => 1;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

sub init {
    my ($self, %args) = @_;

    $self->hash_init(%args);

    $self->directory or throw NOCpulse::Utils::Error("No queue directory specified");
    my $position_hash;
    my $filename = File::Spec->catfile($self->directory, MARK_FILE);
    if (-e $filename) {
        unless ($position_hash = do $filename) {

            $@ and throw NOCpulse::Utils::Error("Cannot parse $filename: $@");

            defined($position_hash)
              or throw NOCpulse::Utils::Error("Cannot read $filename: $!");

            $position_hash
              or throw NOCpulse::Utils::Error("Cannot get valid data from $filename");
        }
        $self->file_position($position_hash);
    }

    $self->archive_directory(File::Spec->catfile($self->directory, ARCHIVE_FILE_DIR));
}

# Scans the queue directory, gathering up current and old queue files,
# tracking live symlinks, and deleting dead ones.
sub scan_directory {
    my $self = shift;

    $self->directory or throw NOCpulse::Utils::Error("No queue directory specified");
    $self->queue_file_directory(File::Spec->catfile($self->directory, QUEUE_FILE_DIR));

    my $dir = DirHandle->new($self->queue_file_directory)
      or throw NOCpulse::Utils::Error("Cannot scan files in queue directory " .
                             $self->queue_file_directory . ": $!");

    $Log->log(3, "scanning ", $self->queue_file_directory, "\n");

    $self->current_file_clear();
    $self->old_file_clear();

    my $symlink_prefix = NOCpulse::TSDB::LocalQueue::File::CURRENT_SYMLINK_PREFIX();
    my %links = ();
    my @full_paths = ();
    while (defined(my $filename = $dir->read())) {
        my $full_path = File::Spec->catfile($self->queue_file_directory, $filename);
        next if -d $full_path;
        if (-l $full_path) {
            # It's a link...
            if ($full_path =~ /$symlink_prefix([\d]*)$/) {
                # ...and it's one of ours.
                $Log->log(4, "symlink $filename\n");
                $links{$full_path} = $1;
            }
        } else {
            $Log->log(4, "$filename\n");
            push(@full_paths, $full_path);
        }
    }
    while (my ($link, $pid) = each %links) {
        $self->_process_link($link, $pid);
    }
    foreach my $full_path (@full_paths) {
        $self->_process_file($full_path);
    }

    # Clear out position entries for nonexistent files.
    my %exists = ();
    foreach my $file ($self->current_file_values, $self->old_file_values) {
        $exists{$file->hash_key} = $file;
    }
    foreach my $pos_name ($self->file_position_keys) {
        $self->file_position_delete($pos_name) unless $exists{$pos_name};
    }
}

# Scans the queue directory and reads from all current files until they are fully read,
# at least for one round. Returns a list of all lines read.
sub read_current_to_end {
    my ($self, $timeout) = @_;

    $timeout ||= 0.5;

    my @current = $self->select_current($timeout);
    my @results = ();
    foreach my $file (@current) {
        push(@results, $self->read_to_end($file));
    }
    return @results;
}

# Returns a list of queue files currently being written that are ready for reading.
sub select_current {
    my ($self, $timeout) = @_;

    defined($timeout) or $timeout = READABLE_TIMEOUT;

    my $selected = IO::Select->new();
    foreach my $file ($self->current_file_values) {
        if (-r $file->full_path) {
            $file->filehandle(IO::File->new($file->full_path, O_RDONLY));
            $selected->add($file->filehandle);
        } else {
            # A race has occurred -- file vanished out from under us
            $self->current_file_delete($file->hash_key);
        }
    }
    my @readable = ();
    my @readable_fh = $selected->can_read($timeout);
    foreach my $fh (@readable_fh) {
        foreach my $file ($self->current_file_values) {
            if ($file->filehandle eq $fh) {
                push(@readable, $file);
            }
        }
    }
    return @readable;
}

# Reads from the last known position in the file to the end and
# remembers the ending position. Returns a list of the data lines read.
sub read_to_end {
    my ($self, $file) = @_;

    $file or throw NOCpulse::Utils::Error("No file specified");
    ref($file) or throw NOCpulse::Utils::Error("File $file is not an object");

    my $last_read = $self->file_position($file->hash_key) || 0;
    $Log->log(3, "Read to end of ", $file->basename, " starting at $last_read\n");

    my $pos = sysseek($file->filehandle, $last_read, 0)
      or throw NOCpulse::Utils::Error("Cannot seek to $last_read in " .
                                      $file->basename . ": $!");

    my $buffer;
    my $buffer_offset = 0;
    while ((my $nread = sysread($file->filehandle, $buffer, 4096, $buffer_offset)) > 0) {
        $Log->log(4, "Read $nread bytes\n");
        $Log->log(5, ">>>", substr($buffer, $buffer_offset), "<<<\n");
        $buffer_offset += $nread;
    }

    my @lines = ();

    if ($buffer_offset > 0) {
        my $last_nl = rindex($buffer, "\n");
        if ($last_nl == -1) {
            # No newlines at all, assume a partial write or corrupted file
            $Log->log(1, "No newlines found in reading from $last_read in ",
                      $file->basename, "\n");
        } else {
            $self->_mark($file, $last_read + $last_nl + 1);
            @lines = split(/\n/, substr($buffer, 0, $last_nl));
        }
    }

    $Log->log(4, "Read ", length($buffer), " bytes, ", scalar(@lines), " lines\n");

    $file->filehandle->close();

    return @lines;
}

# Returns the next old file to be read from.
sub most_recent_old_file {
    my $self = shift;

    my @names = sort { $b cmp $a } $self->old_file_keys();
    if (scalar(@names)) {
        return $self->old_file($names[0]);
    }
    return undef;
}

# Reads a set of lines from a non-current file.
sub read_old_file {
    my ($self, $file, $line_count) = @_;

    $file or throw NOCpulse::Utils::Error("No file provided to read from");
    unless (-r $file->full_path) {
        $Log->log(4, "nonexistent file ", $file->full_path, "\n");
        return ();
    }

    $Log->log(3, "up to $line_count lines from ", $file->basename, "\n");

    $file->filehandle(IO::File->new($file->full_path, O_RDONLY))
      or throw NOCpulse::Utils::Error("Cannot open file " . $file->full_path . ": $!");

    my $offset = $self->file_position($file->hash_key) || 0;
    $Log->log(4, "from offset $offset\n");
    seek($file->filehandle, $offset, 0)
      or throw NOCpulse::Utils::Error("Cannot seek to position $offset in " .
                             $file->full_path . ": $!");

    my @lines = ();
    my $line;
    while ($line = $file->filehandle->getline()) {
        chomp $line;
        $Log->log(5, "read $line\n");
        push(@lines, $line);
        last if scalar(@lines) == $line_count;
    }
    my $read_err = $file->filehandle->error();
    my $eof = !defined($line);
    $Log->log(3, "eof = '$eof'\n");
    unless ($eof) {
        # More to go, mark it
        $self->_mark($file, tell($file->filehandle));
        $Log->log(4, "next offset ", $self->file_position($file->hash_key), "\n");
    }
    $file->filehandle->close();
    $read_err and throw NOCpulse::Utils::Error("Cannot read from " .
                                               $file->basename . ": $read_err");

    if ($eof) {
        # All done, archive the file and remove it from the old list
        $Log->log(2, "archiving ", $file->basename, "\n");
        $file->archive($self->archive_directory);
        $self->old_file_delete($file->hash_key);
    }

    return @lines;
}

# Saves to disk the last byte read from all files being processed.
sub save_positions {
    my $self = shift;

    $self->directory or throw NOCpulse::Utils::Error("No queue directory specified");

    my $hashref = $self->file_position();
    my $dumper = Data::Dumper->new([$hashref], ['position_hash']);
    $dumper->Indent(1);

    my $filename = File::Spec->catfile($self->directory, MARK_FILE);
    my $FH = IO::AtomicFile->open($filename, 'w')
      or throw NOCpulse::Utils::Error("Cannot open $filename.TMP for writing: $!");
    print $FH $dumper->Dump();
    $FH->close() or throw NOCpulse::Utils::Error("Cannot save $filename: $!");
}



#
# Internal methods
#


# Stores the current position in a file for later reading in the file_position hash.
# Does not save to disk; see save_positions for that.
sub _mark {
    my ($self, $file, $pos) = @_;
    $self->file_position($file->hash_key, $pos);
}

sub _process_link {
    my ($self, $link, $pid) = @_;

    # Symlink from a dead process, blitz it
    unless (kill 0, $pid) {
        unlink $link;
        return 0;
    }

    my $real_filename = readlink $link;

    # Avoid race with the creator by ignoring links pointing nowhere
    if (-r $real_filename) {
        my $file = NOCpulse::TSDB::LocalQueue::File->new(
            basename     => basename($real_filename),
            full_path    => $real_filename,
            symlink_name => $link);
        $self->current_file($real_filename, $file);
        return 1;
    } else {
        return 0;
    }
}

sub _process_file {
    my ($self, $full_path) = @_;

    if (not $self->current_file_exists($full_path)) {
        my $file = NOCpulse::TSDB::LocalQueue::File->new(
           basename  => basename($full_path),
           full_path => $full_path);
        $self->old_file($file->hash_key, $file);
    }
}

1;

__END__

=head1 NAME

NOCpulse::TSDB::LocalQueue::FileManager - Manage local queue files


=head1 SYNOPSIS

 use NOCpulse::TSDB::LocalQueue::FileManager;

 my $mgr = NOCpulse::TSDB::LocalQueue::FileManager->new(directory => '/tmp/local_queue');

 while (1) {
   # Read all the files currently being written until they are
   # empty, at least for now
   my @lines = ();
   while (1) {
       my @results = $mgr->read_current_to_end(0.75);
       push(@lines, @results);
       last if scalar(@lines) > 0 && scalar(@results) == 0;
       select undef, undef, undef, 0.5;
   }
   # Do something interesting with @lines...

   # Read an old file for a bounded period
   my $start = time();
   my $until = $start + 3;
   while (time() <= $until) {
       $file = $mgr->most_recent_old_file();
       # Read up to 50 lines from this file
       @lines = $mgr->read_old_file($file, 50);
       # Do something with these lines
   }
 }

=head1 DESCRIPTION

Provides methods to read from a set of queue files. There are two
kinds of files: current files that are being written concurrently with
being read, and old files that are no longer being written to. Current
files are assumed to be the most important to read quickly, and old
files can read if there is time.


=head1 METHODS

=over 4

=item read_current_to_end ( [$timeout] )

  my @lines = $mgr->read_current_to_end(0.5);

Scans the queue directory and reads from all current files until they
are fully read, at least for one round. Returns a list of all lines
read. The C<$timeout> parameter defines how long to wait for files to
become readable and defaults to one second.


=item most_recent_old_file ( )

Returns the next old file to be read from, if any. The files are
returned in newest-to-oldest order, assuming that the filename sorts
by time.


=item read_old_file ( $file, $line_count )

  if (my $file = $mgr->most_recent_old_file()) {
      my @lines = $mgr->read_old_file($file, 100);
  }

Reads a set of lines from a file that is not currently being written
to. If the file is read to completion, archives it and removes it from
the C<old_file> hash.


=item save_positions ( )

Saves to disk the byte positions read for all currently-known files.
Should be called periodically so that a restart picks up from where
it left off instead of at the start.


=item scan_directory ( )

Scans the queue directory, gathering up current and old queue files,
tracking live symlinks, and deleting dead ones (those created by a
process that no longer exists).


=item file_position ( )

Provides a hash table, indexed by $file->hash_key, of the last position
in each file that has not been read to completion (current and ole).


=item current_file ( )

  my $files = $mgr->current_file($full_path);
  my @files = $mgr->current_file_values();
  my @paths = $mgr->current_file_keys();

Provides a hash table, indexed by $file->hash_key, of the files that are
currently being written to by. This is indicated by the existence of a
symlink pointing to the file that was written by a process that is
still running.


=item old_file ( )

  my $files = $mgr->old_file($full_path);
  my @files = $mgr->old_file_values();
  my @paths = $mgr->old_file_keys();

Provides a hash table, indexed by $file->hash_key, of the files that are
I<not> currently being written to, as indicated by the existence of a
symlink pointing to the file, but have not been read to completion.


=item directory ( [$new_dir] )

Gets or sets the top directory for the local queue. This contains a
queue file directory named F<queue>, an archive directory (where
fully-read queue files go) named F<archive>, and a file containing the
byte positions for all files that have not been fully read,
F<queuefile.positions>.


=item queue_file_directory ( [$new_dir] )

The queue file directory path.


=item archive_directory ( [$new_dir] )

The archive directory path.


=back

=head1 BUGS

=head1 AUTHOR

Rod McChesney <rmcchesney@nocpulse.com>

Last update: $Date: 2003-12-11 00:54:09 $

=head1 SEE ALSO

L<NOCpulse::TSDB::LocalQueue::File|tsdb::LocalQueue::File>

=cut
