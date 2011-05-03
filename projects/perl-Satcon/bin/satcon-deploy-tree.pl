#!/usr/bin/perl -w
# Copyright (c) 2008--2011 Red Hat, Inc.
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

use Satcon;
use File::Find;
use File::Path;
use Data::Dumper;
use Getopt::Long;

my $usage = "usage: $0 --source=<source-tree> --dest=<dest-tree>"
  . " --conf=<conf-file> [ --start-delim=<delimiter> ]"
  . " [ --end-delim=<delimiter> ] [ --backupdir=<dir> ] [ --help ]\n";

my $sourcedir = '';
my $destdir = '';
my $conf_file = '';
my $backupdir = '';
my $open = '@@';
my $close = '@@';
my $help = '';

GetOptions("source=s" => \$sourcedir, "dest=s" => \$destdir,
	   "conf=s" => \$conf_file, "start-delim:s" => \$open,
	   "end-delim:s" => \$close, "backupdir=s" => \$backupdir) or die $usage;

die $usage unless ($sourcedir and $destdir and $conf_file);

$sourcedir =~ s(/+)(/)g;
$destdir =~ s(/+)(/)g;
$backupdir =~ s(/+)(/)g;
$sourcedir =~ s(/$)();
$destdir =~ s(/$)();
$backupdir =~ s(/$)();

my $engine = new Satcon $open, $close;
$engine->load_conf_file($conf_file);

if ($backupdir){
  mkdir $backupdir, 0770;
}

find( { no_chdir => 1, wanted => sub { process_file($engine, $sourcedir, $destdir) } }, $sourcedir);

sub process_file {
  my ($engine, $sourcedir, $destdir) = @_;
  my $full_path = $File::Find::name;

  if ($full_path =~ m(/CVS$|\.orig$)) {
    $File::Find::prune = 1;
    return;
  }

  my $relative_path = $full_path;
  $relative_path =~ s/^$sourcedir//;

  print "$sourcedir$relative_path -> $destdir$relative_path\n";

  if (-d "$sourcedir/$relative_path") {
    if (-d "$destdir/$relative_path" && $backupdir) {
      mkdir "$backupdir/$destdir/$relative_path", 0770;
    } else {
    mkdir "$destdir/$relative_path", 0770;
    }
  }
  else {
    if (-e "$destdir/$relative_path" && $backupdir && ! -e "$backupdir/$destdir/$relative_path") {
      print " * Making backup of $destdir$relative_path to $backupdir$destdir$relative_path\n";
      system('/bin/cp', '-p', "$destdir/$relative_path", "$backupdir/$destdir/$relative_path") == 0
        or die "Cannot copy $destdir/$relative_path to $backupdir/$destdir/$relative_path";
    }
    open IF, "<$sourcedir/$relative_path"
      or die "Cannot open $sourcedir/$relative_path: $!";

    open OF, ">$destdir/$relative_path"
      or die "Cannot open $destdir/$relative_path: $!";

    # save permissions also but clear access for other
    my $mode =  (stat("$sourcedir/$relative_path"))[2] & 07770;
    chmod $mode, "$destdir/$relative_path";
    # chgrp apache
    chown 0, scalar(getgrnam("apache")), "$destdir/$relative_path";

    system '/sbin/restorecon', '-vv', "$destdir/$relative_path";

    while (<IF>) {
      my $out = $engine->perform_substitutions($_);
      print OF $out;
    }

    close IF;
    close OF;
  }
}

warn "Unsubstituted Tags:\n" if $engine->unsubstituted_tags;
foreach my $kw (sort $engine->unsubstituted_tags) {
  warn "  $kw\n";
}

exit 0;
