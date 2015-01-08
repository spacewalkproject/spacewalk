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

package RHN::Kickstart::Logvols;

use RHN::Kickstart::Multi;
our @ISA = qw/RHN::Kickstart::Multi/;

sub prefix { 'logvol' }

sub add {
  my $self = shift;
  my $line = shift;

  if ($line->[0] eq 'swap') {
    my @others = grep { substr($_->[0], 0, 4) eq 'swap' } @{$self};
    $line->[0] = 'swap' . (@others + 1);
  }

  return $self->SUPER::add($line, @_);
}

sub render {
  my $self = shift;

  my @ret;

  foreach my $line (@{$self}) {
    my @elems;

    if (substr($line->[0], 0, 4) eq 'swap') {
      @elems = ('swap', @{$line}[ 1 .. (scalar @$line - 1) ]);
    }
    else {
      @elems = @{$line};
    }

    push @ret, join(" ", $self->prefix, @elems);
  }

  return unless @ret;
  return join("\n", @ret);
}

sub export {
  my $self = shift;

  my @ret;

  foreach my $line (@{$self}) {
    my @elems;

    if (substr($line->[0], 0, 4) eq 'swap') {
      @elems = ('swap', @{$line}[ 1 .. (scalar @$line - 1) ]);
    }
    else {
      @elems = @{$line};
    }

    push @ret, join(" ", @elems);
  }

  return @ret;
}

1;
