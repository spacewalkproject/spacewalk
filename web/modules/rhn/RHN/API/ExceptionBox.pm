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
package RHN::API::ExceptionBox;

sub new {
  my $class = shift;

  my $self = bless { label_map => {}, code_map => {}, exceptions => [] }, $class;

  return $self;
}

sub add_exception {
  my $self = shift;
  my $label = shift;
  my $code = shift;
  my $description = shift;

  my $found;
  for my $current ($self->lookup_by_label($label), $self->lookup_by_code($code)) {
    # already exist?  if so, and if it is different, bomb out; otherwise return silent success
    if ($current) {
      $found++;
      if ($current->{label} ne $label or $current->{code} != $code) {
	die "Exception ($label, $code) already in exception box as ($current->{label}, $current->{code})";
      }
    }
  }

  # found one, and it was consistent...
  return if $found;

  # the index will be the next entry; since scalar(@a) == $#a + 1, we
  # can just set it like this, then push

  my $index = @{$self->{exceptions}};
  push @{$self->{exceptions}}, { code => $code, label => $label, index => $index, description => $description };
  $self->{label_map}->{$label} = $self->{code_map}->{$code} = $index;
}

sub lookup_by_label {
  my $self = shift;
  my $label = shift;

  my $found_idx = $self->{label_map}->{$label};

  return undef unless $found_idx;

  return $self->{exceptions}->[$found_idx];
}

sub lookup_by_code {
  my $self = shift;
  my $code = shift;

  my $found_idx = $self->{code_map}->{$code};

  return undef unless $found_idx;

  return $self->{exceptions}->[$found_idx];
}

sub is_empty {
  my $self = shift;

  return (@{$self->{exceptions}} ? 0 : 1);
}

1;
