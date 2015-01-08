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

package RHN::Kickstart::Multi;

use RHN::Exception qw/throw/;

sub prefix { '' }

sub new {
  my $class = shift;
  my @lines = @_;

  my $self = bless [ ], $class;

  foreach my $line (@lines) {
    $self->add($line);
  }

  return $self;
}

sub add {
  my $self = shift;
  my $line = shift;

  throw "(ks_multi_add_no_arg) add() called with no argument" unless (defined $line);
  throw "(ks_multi_add_line_not_arrayref) ($line) is not an arrayref" unless (ref $line eq 'ARRAY');
  throw "(ks_multi_add_label_already_exists) A line with label '" . $line->[0] . "' already exists."
    if (grep { $_->[0] eq $line->[0] } @{$self});

  push @{$self}, $line;

  return;
}

sub remove {
  my $self = shift;
  my $label = shift;

  my $index = 0;

  for (my $index = 0; $index < @{$self};$index++) {
    my $line = $self->[$index];
    if ($line->[0] eq $label) {
      splice @{$self}, $index, 1;
      last;
    }
  }

  return;
}

sub render {
  my $self = shift;

  my @ret;

  foreach my $line (@{$self}) {
    push @ret, join(" ", $self->prefix, @{$line});
  }

  return unless @ret;
  return join("\n", @ret);
}

sub export {
  my $self = shift;

  my @ret;

  foreach my $line (@{$self}) {
    push @ret, join(" ", @{$line});
  }

  return @ret;
}

1;

