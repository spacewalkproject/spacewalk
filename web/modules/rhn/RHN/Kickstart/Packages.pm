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

package RHN::Kickstart::Packages;

sub new {
  my $class = shift;
  my @pkgs = @_;

  my $self = bless [ ], $class;

  foreach my $pkg (@pkgs) {
    $self->add($pkg);
  }

  return $self;
}

sub add {
  my $self = shift;
  my @pkgs = @_;

  return unless (@pkgs);
  my $count = 0;

  foreach my $pkg (@pkgs) {
    next if (grep { $_ eq $pkg } @{$self});
    push @{$self}, $pkg;
    $count++;
  }

  return $count;
}

sub remove {
  my $self = shift;
  my $label = shift;

  my $index = 0;

  for (my $index = 0; $index < @{$self};$index++) {
    my $pkg = $self->[$index];
    if ($pkg eq $label) {
      splice @{$self}, $index, 1;
      last;
    }
  }

  return;
}

sub render {
  my $self = shift;

  return join("\n", @{$self});
}

1;

