#
# Copyright (c) 2008--2010 Red Hat, Inc.
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

package PXT::Debug;

use strict;

use PXT::Config ();
use Data::Dumper ();

sub log {
  my $class = shift;
  my $level = shift;
  my @msg = @_;

  if ($level < PXT::Config->get('debug')) {
    my (undef, $file, $line) = caller;
    my @frame = caller(1);

    warn "$frame[3] ($file:$line): " . join(" ", @msg) . "\n";
  }
}

sub log_dump {
  my $class = shift;
  my $level = shift;
  my @structs = @_;

  if ($level < PXT::Config->get('debug')) {
    my (undef, $file, $line) = caller;
    my @frame = caller(1);

    warn sprintf("$frame[3] ($file:$line): %s\n", Data::Dumper->Dump(\@structs));
  }
}

1;

