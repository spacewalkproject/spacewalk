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

package RHN::Form::Widget::Text;

use strict;
use PXT::HTML;
use PXT::Utils;

use RHN::Form::Widget;

our @ISA = qw/RHN::Form::Widget/;

my %valid_fields = (size => undef,
		    maxlength => undef);

sub valid_fields { return (shift->SUPER::valid_fields(), %valid_fields) }

sub editable { 1 }

sub size {
  my $self = shift;
  my $size = shift;

  if (defined $size) {
    $self->{size} = $size;
  }

  return $self->{size};
}

sub maxlength {
  my $self = shift;
  my $maxlength = shift;

  if (defined $maxlength) {
    $self->{maxlength} = $maxlength;
  }

  return $self->{maxlength};
}

#Always escape text box output
sub value {
  my $self = shift;

  my $ret = $self->SUPER::value(@_);

  return PXT::Utils->escapeHTML(defined $ret ? $ret : '');
}

sub render {
  my $self = shift;
  my $value = defined $self->value ? $self->value : defined $self->default ? $self->default : '';

  my $ret = PXT::HTML->text(-name => $self->label,
			    -value => $value,
			    -maxlength => $self->maxlength,
			    -size => $self->size);

  return $ret;
}

1;
