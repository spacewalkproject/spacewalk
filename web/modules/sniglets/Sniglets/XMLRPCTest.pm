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

package Sniglets::XMLRPCTest;

sub register_xmlrpc {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_xmlrpc("listdir", \&listdir_xmlrpc);
}

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag("listdir", \&listdir_tag);
}

sub listdir_tag {
  my $pxt = shift;

  my $ret;

  foreach my $dir (generate_dir_listing($pxt->param("dir") || "/tmp")) {
    $ret .= "$dir->[0]<br>";
  }

  return $ret;
}

# return a list of files in a dir, w/o extra info
sub listdir_xmlrpc {
  my $pxt = shift;
  my $dir = shift;

  return map { $_->[0] } generate_dir_listing($dir);
}

# return a list of files in a dir, including stat() info
sub generate_dir_listing {
  my $dir = shift;

  opendir D, $dir
    or die "can't open dir: $!";
  my @dir = readdir D;
  closedir D;

  return map { [ $_, stat("$dir/$_") ] } @dir;
}

1;
