package NOCpulse::TSDB::LocalQueue::test::TestFile;

use strict;

use File::stat;
use Error;
use NOCpulse::TSDB::LocalQueue::File;

use base qw(Test::Unit::TestCase);

my $tmpdir  = $ENV{TMPDIR} || 'tmp';
my $DIR     = "$tmpdir/tsdbq";
my $ARCHDIR = "$DIR/archive";

$Error::Debug = 1;

sub test_create {
    my $self = shift;

    my $file = NOCpulse::TSDB::LocalQueue::File->new(directory => $DIR);
    $file->create();
    my $path = $DIR . '/queue/' . $file->basename;
    $self->assert($file->full_path eq $path, "Pathname mismatch: expected " . $path .
                  ", got " . $file->full_path);
    $self->assert(-w $path, "No file $path");
    $self->assert(-l $file->symlink_name, "Symlink " . $file->symlink_name . " isn't");

    $file->delete();
    $self->assert(! -e $file->full_path, "File " . $file->full_path ." still exists");
    $self->assert(! -e $file->symlink_name, "Symlink " . $file->symlink_name ." still exists");
}

sub test_rotate {
    my $self = shift;

    my $file = NOCpulse::TSDB::LocalQueue::File->new(directory => $DIR);
    $file->create();
    my $prev = $file->full_path;
    $file->rotate();
    $self->assert(-e $prev, "Rotated file $prev no longer exists");
    my $new = readlink($file->symlink_name)
      or die "Cannot read link " . $file->symlink_name . ": $!\n";
    $self->assert($new ne $prev, "New and previous files are the same after rotate: $new");
    $self->assert($new eq $file->full_path, "Link $new does not match full path " .
                  $file->full_path);
    $file->delete();
    unlink $prev or die "Cannot delete $prev: $!";
}

sub test_auto_rotate {
    my $self = shift;

    my $file = NOCpulse::TSDB::LocalQueue::File->new(directory     => $DIR,
                                                    rotate_size_kb => 0.001);
    $file->create();
    my $prev = $file->full_path;
    $file->append('a' x 100);
    # Takes two appends because the size check is done before the write, not after
    $file->append('b' x 100);
    my $new = readlink($file->symlink_name)
      or die "Cannot read link " . $file->symlink_name . ": $!\n";
    $self->assert($new ne $prev, "Didn't rotate: Previous $prev, new $new");
    $file->delete();
    unlink $prev or die "Cannot delete $prev: $!";
}

sub test_archive {
    my $self = shift;

    my $file = NOCpulse::TSDB::LocalQueue::File->new(directory => $DIR);
    $file->create();
    my $path = $file->full_path;
    $file->archive($ARCHDIR);
    $self->assert(! -e $path, "Archived file $path still exists");
    my $archpath = "$ARCHDIR/" . $file->basename;
    $self->assert(-e $archpath, "Archived file $path does not exist");
    unlink $archpath or die "Cannot delete $archpath: $!";
}

1;
