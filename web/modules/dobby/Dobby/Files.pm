#
# Copyright (c) 2008 Red Hat, Inc.
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
use File::Basename qw/basename/;


# given source and dst, gzip a file into dst, returning the checksum
# of the original file
sub gzip_copy {
  my $class = shift;
  my $src = shift;
  my $dst = shift;

  open IN, "<$src" or die "open $src: $!\n";
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
  my $class = shift;
  my $src = shift;
  my $dst = shift;

  my $write;
  if ($dst) {
    open OUT, ">$dst" or die "open $dst: $!\n";
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

  return $ctx->hexdigest;
}

sub backup_file {
  my $class = shift;
  my $file = shift;
  my $backup_dir = shift;

  my $dest = sprintf("%s/%s.gz", $backup_dir, basename($file));
  $dest =~ s(//+)(/)g;
  my $then = time;

  my $file_entry = new Dobby::BackupLog::FileEntry;
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

1;
