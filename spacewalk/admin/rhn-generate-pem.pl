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

use File::Spec;

$ENV{PATH} = '/bin:/usr/bin';

my $usage = "usage: $0 --ssl-dir=<ssl_directory> [ --out-file=<out_file> ] [ --help ]\n";

my $ssl_dir = '';
my $out_file = '';
my $help = '';

GetOptions("ssl-dir=s" => \$ssl_dir, "out-file:s" => \$out_file, "help" => \$help);

if ($help or not $ssl_dir) {
  die $usage;
}

unless (-d $ssl_dir) {
  die "$ssl_dir is not a directory";
}

my @files_to_cat = (File::Spec->catfile($ssl_dir, 'server.crt'),
		    File::Spec->catfile($ssl_dir, 'server.key'));

my @content;

foreach my $file (@files_to_cat) {

  unless (-r $file) {
    die "Could not read ${file}.";
  }

  open(SSL_FILE, $file) or die "Could not open '$file' for reading: $OS_ERROR";

  my @lines = <SSL_FILE>;
  push @content, @lines;
}

close(SSL_FILE);

if ($out_file) {
  open(PEM_FILE, ">$out_file") or die "Could not open '$out_file' for writing: $OS_ERROR";

  print PEM_FILE @content;

  close(PEM_FILE);

  chmod(0600, $out_file); # rw by current user (probably root) only

  my ($uid, $gid) = lookup_user_ids('jabberd');

  # some installs of jabber use jabberd user, while others use jabber
  if (not $uid) {
      ($uid, $gid) = lookup_user_ids('jabber');
  }

  if($uid) {
      chown($uid, $gid, $out_file);
  }
}
else {
  print @content;
}

exit 0;

sub lookup_user_ids {
  my $username = shift;

  my ($login, $pass, $uid, $gid) = getpwnam($username);

  return ($uid, $gid);
}
