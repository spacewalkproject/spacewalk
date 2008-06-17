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
package RHN::Task::PackageCleanup;

our @ISA = qw/RHN::Task/;

use PXT::Config;
use File::Spec;
use Cwd qw/abs_path/;

sub delay_interval { 600 }

# This task deleted package files which have been deleted via the package management interface.

sub run {
  my $class = shift;
  my $center = shift;

  my $dbh = RHN::DB->connect();
  my $sth = $dbh->prepare(<<EOS);
SELECT PFDQ.path
  FROM rhnPackageFileDeleteQueue PFDQ
EOS

  $sth->execute();

  while (my ($path) = $sth->fetchrow) {
    next unless $path;
    $center->info("deleting orphaned package file '$path'");

    my $ret = $class->delete_file($path);

    $center->info("-$ret");
  }

  $sth = $dbh->prepare(<<EOQ);
DELETE FROM rhnPackageFileDeleteQueue
EOQ

  $sth->execute();

  $class->log_daemon_state($dbh, 'package_cleanup');
  $dbh->commit;
}

sub delete_file {
  my $class = shift;
  my $path = shift;

# clean up the path first
  my $mount_point = PXT::Config->get('mount_point');
  my ($vol, $dir, $file) = File::Spec->splitpath($path);

  $dir = File::Spec->catfile($mount_point, $dir);
  $dir = abs_path($dir);

  $path = File::Spec->catfile($dir, $file);

  if ($path !~ /^$mount_point.*rpm$/) {
    return "file '$path' did not point to an RPM under '$mount_point'"
  }

  if (not -e $path) {
    return "file does not exist";
  }

  if (not -w $path) {
    return "file is not writable by user";
  }

  if (not -f $path) {
    return "file is not a regular file";
  }

  my $success = unlink $path;

  if (not $success) {
    return "could not unlink file: ($0)";
  }

  return "file deleted";
}

1;
