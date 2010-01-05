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

package RHN::Package;

use strict;

use RHN::DB::Package;

our @ISA = qw/RHN::DB::Package/;

sub lookup {
  my $class = shift;
  my $first_arg = $_[0];

  die "No argument to $class->lookup"
    unless $first_arg;

  if (substr($first_arg,0,1) eq '-') {
    return $class->SUPER::lookup(@_);
  }
  else {
    die "deprecated use of unparameterized $class->lookup from (" . join(', ', caller) . ")\n";
    return $class->SUPER::lookup(-id => $first_arg);
  }
}

my $RPMSENSE_LESS = 2;
my $RPMSENSE_GREATER = 4;
my $RPMSENSE_EQUAL = 8;

# parse out the >, <, >=, <=, = value for an rpm dependency sense...
# if it's '=', send empty string back
sub parse_dep_sense_flags {
  my $class = shift;
  my $flags = shift;

  my $sense = '';
  # from rpmlib.h ...
  if ($flags & $RPMSENSE_LESS) {
    $sense = '<';
  }
  elsif ($flags & $RPMSENSE_GREATER) {
    $sense = '>';
  }

  if ($flags & $RPMSENSE_EQUAL) {
    $sense .= '=' if $sense;
  }

  return $sense;
}

sub parse_sense_flag { 
  my $class = shift;
  my $sense = shift;

  return $sense == 1 ? 'conflicts with' : 'requires';
}

1;
