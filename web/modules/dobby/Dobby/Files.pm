#
# Copyright (c) 2008--2012 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
# 
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation. 
#

use strict;
package Dobby::Files;
use Digest::MD5;
use Compress::Zlib;
use File::Basename qw/basename dirname/;
use File::Spec;
use File::Path;

# given source and dst, gzip a file into dst, returning the checksum
# of the original file
sub gzip_copy {
  my $class = shift;
  my $src = shift;
  my $dst = shift;

  local * IN;
  open IN, '<', $src or die "open $src: $!\n";
  my $gz = gzopen("$dst", "wb") or die "gzopen: $!\n";
  my $ctx = new Digest::MD5;

  local $/ = \4096;
  while (<IN>) {
    $ctx->add($_);
    $gz->gzwrite($_) or die "gzwrite: $!\n";
  }

  $gz->gzclose;
  close IN;

  return $ctx->hexdigest;
}

# gunzip's a file from src to dst.  if dst is undef, then it the
# target is not written to (though digest is returned, so this checks
# integrity of the archive)

sub gunzip_copy {
  my ($class, $src, $dst, $uid, $gid) = @_;
  if (defined($uid) or defined($gid)) {
    # if not defined set it to -1 i.e. no change
    $uid = -1 if not defined $uid;
    $gid = -1 if not defined $gid;
  }

  my $write;
  local * OUT;
  if ($dst) {
    my $dst_directory = dirname($dst);
    if (my @dirs = File::Path::mkpath($dst_directory, 0, 0700)) {
      chown $uid, $gid, @dirs;
    }
    open OUT, '>', $dst or die "open $dst: $!\n";
    $write = 1
  }
  else {
    $write = 0;
  }

  my $gz = gzopen("$src", "rb") or die "gzopen $src: $!\n";
  my $ctx = new Digest::MD5;

  local $/ = \4096;
  while (1) {
    my $block;
    my $count = $gz->gzread($block);
    # count is zero on EOF
    last if $count == 0;
    die "read error: $!\n" if $count < 0;

    $ctx->add($block);
    if ($write) {
      print OUT $block
	or die "write to $dst: $!\n";
    }
  }

  $gz->gzclose;
  close OUT if $write;
  if (defined($dst)) {
    # if not defined set it to -1 i.e. no change
    $uid = -1 if not defined $uid;
    $gid = -1 if not defined $gid;
    chown $uid, $gid, $dst;
    chmod 0640, $dst;
  }

  return $ctx->hexdigest;
}

sub backup_file {
  my ($class, $rel_dir, $file, $backup_dir) = @_;

  if (-d $file) { #empty directory
    my $dir_entry = new Dobby::BackupLog::DirEntry;
    $dir_entry->from($file);
    print "  Empty directory $file\n";
    return $dir_entry;
  } else {
    my $file_entry = new Dobby::BackupLog::FileEntry;
    my $real_dest_dir = File::Spec->catdir($backup_dir, $rel_dir);
    File::Path::mkpath($real_dest_dir) or (-d $real_dest_dir) or die ("Error: could not create directory $real_dest_dir\n");
    my $dest = sprintf("%s/%s.gz", $real_dest_dir, basename($file));
    $dest =~ s(//+)(/)g;
    my $then = time;

    $file_entry->start(time);

    print "  $file -> $dest ... ";
    my $hexdigest = Dobby::Files->gzip_copy($file, $dest);
    print "done.\n";

    $file_entry->original_size(-s $file);
    $file_entry->compressed_size(-s $dest);
    $file_entry->from($file);
    $file_entry->to($dest);
    $file_entry->finish(time);
    $file_entry->digest($hexdigest);
    return $file_entry;
  }
}

1;
