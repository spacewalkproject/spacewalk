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
use Spacewalk::Setup;
use Symbol qw(gensym);

my $usage = "usage: $0 --host=<databaseHost> --user=<username> --password=<password> --database=<databaseName> --schema-deploy-file=<filename>"
  . " [ --log=<logfile> ] [ --clear-db ] [ --nofork ] [ --postgresql ] [ --help ]\n";

my $user = '';
my $password = '';
my $database = '';
my $host = '';

my $schema_deploy_file = '';
my $log_file;
my $clear_db = 0;
my $nofork = 0;
my $postgresql = 0;
my $help = '';

GetOptions("host=s" => \$host, "user=s" => \$user, "password=s" => \$password, 
    "database=s" => \$database, "schema-deploy-file=s" => \$schema_deploy_file,
    "log=s" => \$log_file, "help" => \$help, "clear-db" => \$clear_db, 
    "postgresql" => \$postgresql, nofork => \$nofork);

if ($help
    or not ($user and $password and $database and $schema_deploy_file)) {
  die $usage;
}

if (not $postgresql) {
    my $ORACLE_HOME = qx{dbhome '*'};
    $ENV{PATH} .= ":$ORACLE_HOME/bin";
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

# Only used for PostgreSQL:
my $populate_cmd = "";
# Only used for Oracle:
my $dsn = sprintf('%s/%s@%s', $user, $password, $database);

if ($postgresql) {
    print "*** Installing PostgreSQL schema.\n";
    chdir("/usr/share/spacewalk/schema/postgresql/");
    $populate_cmd = "PGPASSWORD=$password psql -U $user -h $host -d $database -v ON_ERROR_STOP= -f $schema_deploy_file";
}
else {
    print "*** Installing Oracle schema.\n";
    $populate_cmd = "sqlplus $dsn \@$schema_deploy_file";
    chdir;
}

if (defined $log_file) {
  local *LOGFILE;
  open(LOGFILE, ">", $log_file) or die "Error writing log file '$log_file': $OS_ERROR";
  if (Spacewalk::Setup::have_selinux()) {
    system('/sbin/restorecon', $log_file) == 0 or die "Error running restorecon on $log_file.";
  }
  if ($postgresql) {
    $pid = open3(gensym, ">&LOGFILE", ">&LOGFILE", $populate_cmd);
  }
  else {
    $pid = open3(gensym, ">&LOGFILE", ">&LOGFILE", 'sqlplus', $dsn, "\@$schema_deploy_file");
  }
}
else {
  if ($postgresql) {
    $pid = open3(gensym, ">&STDOUT", ">&STDERR", $populate_cmd);
  }
  else {
    $pid = open3(gensym, ">&STDOUT", ">&STDERR", 'sqlplus', $dsn, "\@$schema_deploy_file");
  }
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
