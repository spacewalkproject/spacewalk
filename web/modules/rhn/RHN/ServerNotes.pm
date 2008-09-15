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

package RHN::ServerNotes;

use RHN::DB::Notes;

our @ISA = qw/RHN::DB::ServerNotes/;

sub lookup {
  my $class = shift;
  my $first_arg = $_[0];

  die "No argument to $class->lookup"
    unless $first_arg;

  if (substr($first_arg,0,1) eq '-') {
    return $class->SUPER::lookup(@_);
  }
  else {
    warn "deprecated use of unparameterized $class->lookup from (" . join(', ', caller) . ")\n";
    return $class->SUPER::lookup(-id => $first_arg);
  }
}

sub lookup_note {
  my $class = shift;

  warn "deprecated use of $class->lookup_foo from (" . join(', ', caller) . ").  Using $class->lookup instead\n";

  return $class->lookup(@_);
}

sub create {
  my $class = shift;

  return RHN::DB::ServerNotes->create_note(@_);
}

sub server_notes {
  my $self = shift;

  my $id;
  if(ref $self) {
    $id = $self->id;
  }
  else {
    $id = shift;
  }

  return RHN::DB::ServerNotes->notes_by_col("server_id",$id,@_);
}

1;

