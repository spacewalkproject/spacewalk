package NOCpulse::TSDB::LocalQueue::File;

use strict;

use Error qw(:try);
use IO::File;
use File::Spec;
use NOCpulse::Log::Logger;
use NOCpulse::Utils::Error;

$Error::Debug = 1;

use constant CURRENT_SYMLINK_PREFIX => 'current.';
use constant QUEUE_FILE_DIR         => 'queue';
use constant ARCHIVE_FILE_DIR       => 'archive';
use constant FAILED_POINTS_DIR      => 'failed';

use Class::MethodMaker
  get_set =>
  [qw(
      directory
      queue_file_directory
      basename
      full_path
      symlink_name
      rotate_size_kb
      filehandle
     )],
  new_with_init => 'new',
  new_hash_init => 'hash_init',
  ;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

sub init {
    my ($self, %args) = @_;

    $args{rotate_size_kb} ||= 100;

    $self->hash_init(%args);
    $self->queue_file_directory(File::Spec->catfile($self->directory, QUEUE_FILE_DIR))
      unless $self->queue_file_directory;
}

sub create {
    my $self = shift;

    $self->_maybe_create_dir($self->queue_file_directory, 'queue');

    # Ensure a unique file name.
    my $pid = $$;
    while (1) {
        $self->basename(time() . '.' . $pid);
        if (-e File::Spec->catfile($self->queue_file_directory, $self->basename)) {
            sleep(1);
        } else {
            last;
        }
    }

    my $taintedSymlinkName = File::Spec->catfile($self->queue_file_directory, CURRENT_SYMLINK_PREFIX . $$);
    ($taintedSymlinkName) = $taintedSymlinkName =~ /(.*)/;
    $self->symlink_name($taintedSymlinkName);

    # Lose the old link...
    $Log->log(2, "Removing any existing symlink named ", $self->symlink_name, "\n");
    unlink $self->symlink_name;

    # ...create the file...
    my $tainted = File::Spec->catfile($self->queue_file_directory, $self->basename);
    ($tainted) = $tainted =~ /(.*)/;
    $self->full_path($tainted);
    $Log->log(2, "Creating file ", $self->full_path, "\n");
    $self->filehandle(IO::File->new($self->full_path, O_CREAT|O_WRONLY|O_APPEND))
      or throw NOCpulse::Utils::Error("Cannot open " . $self->full_path . " for writing: $!");

    # ...and relink. The reader can then be sure that the current link either points
    # to nowhere or to the actual current file.
    symlink $self->full_path, $self->symlink_name
      or throw NOCpulse::Utils::Error("Cannot create symlink to " . $self->basename . ": $!");

    return 1;
}

sub append {
    my ($self, @data) = @_;

    $self->filehandle
      or throw NOCpulse::Utils::Error("Cannot append to " . $self->full_path .
                                      " that has not been created");
    my $data;

    if (scalar(@data) == 1) {
        $data = $data[0];
    } else {
        $data = join(',', @data);
    }

    my $size_kb = tell($self->filehandle) / 1024;
    if ($size_kb >= $self->rotate_size_kb) {
        $Log->log(2, "Rotating ", $self->basename, ": $size_kb kb > ", $self->rotate_size_kb,
                  " kb\n");
        $self->rotate();
    }

    $Log->log(4, ">>>$data<<< to ", $self->basename, "\n");

    return $self->filehandle->printflush($data, "\n");
}

sub delete {
    my $self = shift;

    unlink $self->full_path;
    unlink $self->symlink_name;
}

sub rotate {
    my $self = shift;

    return $self->create();
}

sub archive {
    my ($self, $dir) = @_;

    $dir or throw NOCpulse::Utils::Error("No archive directory provided");
    $self->_maybe_create_dir($dir, 'archive');

    rename $self->full_path, File::Spec->catfile($dir, $self->basename)
      or throw NOCpulse::Utils::Error("Cannot archive " . $self->basename . " to $dir: $!");
}

sub hash_key {
    my $self = shift;
    return $self->full_path;
}

sub _maybe_create_dir {
    my ($self, $dir, $type) = @_;

    $dir or throw NOCpulse::Utils::Error("No $type directory specified");
    my @dirs = split(/\//, $dir);
    my $create_dir = '';
    foreach my $subdir (@dirs) {
        next unless length($subdir);
        $create_dir .= "/$subdir";
        unless (-d $create_dir) {
          mkdir($create_dir, 0777)
            or throw NOCpulse::Utils::Error("Cannot create $type directory $create_dir: $!");
      }
}
}

1;

__END__

=head1 NAME

NOCpulse::TSDB::LocalQueue::File - Local queue file being written by an Apache TSDB handler

=head1 SYNOPSIS

 # Instantiates the file object but does not create it
 my $file = NOCpulse::TSDB::LocalQueue::File->new(
    directory => '/opt/NOCpulse/tsdb_queue');

 # Creates a new file named timestamp.pid and symlinks to it as current.pid
 $file->create();

 # Calls create to get the symlink pointed to a new file
 $file->rotate();

 # Moves a file to an archive directory.
 $file->archive($archive_dir);

=head1 DESCRIPTION

The C<File> object represents a single file in the TSDB local queue. Its purpose is to
accept time series datapoints as fast as they arrive, so that the HTTP processes are
not blocked waiting for the real TSDB write to finish.

Files are named as <timestamp>.<pid>, for instance, C<1027982815.25313>.

Files that are currently being written to also have a symlink of the form C<current>.<pid>
pointing to them. To avoid race conditions, either the symlink points to the current
file being written or it points to nothing. The pid should be checked, however, because
an Apache child process that crashes could leave dead symlinks around.

=head1 METHODS

=over 4

=item directory ( [$new_dir] )

Gets or sets the directory in which the file and symlink exist.


=item basename ( )

The filename, set by C<create()>.


=item symlink_name ( )

The name of the symbolic link for the file, set by C<create()>. If this file
is an old one, C<symlink_name> returns C<undef>.


=item full_path ( )

The full path name.


=item hash_key ( )

The string to use when storing this file object in a hash.


=item rotate_size_kb ( [$new_size] )

Gets or sets the size at which the file is rotated to a new one.


=item create ( )

Creates a new file and a symlink to it.


=item append ( $data )

Writes C<$data> to the end of the file, first rotating the file if it has reached
C<rotate_size_kb> kilobytes. Appends a newline to the data being written.


=item rotate ( )

Recreates the file and symlink. This is avoids files growing to huge
sizes if the dequeuer is down for an extended period.


=item archive ( $archive_dir )

Moves a file to an archive directory. This should only be done for old files,
not for current ones.

=item delete

Deletes the file and its symlink.


=back

=head1 BUGS

=head1 AUTHOR

Rod McChesney <rmcchesney@nocpulse.com>

Last update: $Date: 2004-11-18 17:13:28 $

=head1 SEE ALSO

L<NOCpulse::TSDB::LocalQueue::FileManager|tsdb::LocalQueue::FileManager>

=cut
