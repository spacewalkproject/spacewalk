#!/usr/bin/perl
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
#
# $Id$

use strict;
use warnings;

use Getopt::Long;
use English;
use RHN::SatInstall;

use File::Spec;
use File::Copy;
use IPC::Open3;
use Symbol qw(gensym);

use Spacewalk::Setup ();

my $usage = "usage: $0 --dsn=<dsn> --schema-deploy-file=<filename>"
  . " [ --log=<logfile> ] [ --clear-db ] [ --nofork ] [ --help ]\n";

my $dsn = '';
my $schema_deploy_file = '';
my $log_file;
my $clear_db = 0;
my $nofork = 0;
my $help = '';

GetOptions("dsn=s" => \$dsn, "schema-deploy-file=s" => \$schema_deploy_file,
	   "log=s" => \$log_file, "help" => \$help, "clear-db" => \$clear_db,
	   nofork => \$nofork);

if ($help or not ($dsn and $schema_deploy_file)) {
  die $usage;
}

our $lockfile = '/var/lock/subsys/rhn-satellite-db-population';
if (-e $lockfile) {
  warn "lock file $lockfile present...database population already in progress\n";
  $lockfile = undef;
  exit 100;
}

sub clean_lockfile {
	if (defined $lockfile and -e $lockfile) {
		unlink $lockfile;
	}
}
$SIG{TERM} = $SIG{INT} = $SIG{QUIT} = $SIG{HUP} = \&clean_lockfile;
END {
	clean_lockfile();
}

system('/bin/touch', $lockfile);

# Move the old log file out of the way - prefork to avoid race
# condition
if (defined $log_file and -e $log_file) {
  my $backup_file = get_next_backup_filename($log_file);
  my $success = File::Copy::move($log_file, $backup_file);

  unless ($success) {
    die "Error moving log file '$log_file' to '$backup_file': $OS_ERROR";
  }
}

my $pid;

unless ($nofork) {
  $pid = fork();
}

# The parent process will exit so the child can do the work without
# blocking the web UI.
if ($pid) {
  exit 0;
}

if ($clear_db) {
  RHN::SatInstall->clear_db();
}

if (defined $log_file) {
  local *LOGFILE;
  open(LOGFILE, ">", $log_file) or die "Error writing log file '$log_file': $OS_ERROR";
  if (Spacewalk::Setup::have_selinux()) {
    system('/sbin/restorecon', $log_file) == 0 or die "Error running restorecon on $log_file.";
  }
  $pid = open3(gensym, ">&LOGFILE", ">&LOGFILE", 'sqlplus', $dsn, "\@$schema_deploy_file");
} else {
  $pid = open3(gensym, ">&STDOUT", ">&STDERR", 'sqlplus', $dsn, "\@$schema_deploy_file");
}
waitpid($pid, 0);
exit $? >> 8;

sub get_next_backup_filename {
  my $log_file = shift;
  my ($vol, $dir, $filename) = File::Spec->splitpath($log_file);
  my $index = 0;
  my $backup_file;

  do {
    $index++;
    $backup_file = File::Spec->catfile($dir, $filename . ".$index");
  } while (-e $backup_file);

  return $backup_file;
}
