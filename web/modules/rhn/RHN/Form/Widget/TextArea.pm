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

package RHN::Form::Widget::TextArea;

use strict;
use PXT::HTML;

use RHN::Form::Widget;

our @ISA = qw/RHN::Form::Widget/;

my %valid_fields = (rows => undef,
		    cols => undef,
                    wrap => undef);

sub valid_fields { return (shift->SUPER::valid_fields(), %valid_fields) }

sub editable { 1 }

sub rows {
  my $self = shift;
  my $rows = shift;

  if (defined $rows) {
    $self->{rows} = $rows;
  }

  return $self->{rows};
}

sub cols {
  my $self = shift;
  my $cols = shift;

  if (defined $cols) {
    $self->{cols} = $cols;
  }

  return $self->{cols};
}

sub wrap {
  my $self = shift;
  my $wrap = shift;

  if (defined $wrap) {
    $self->{wrap} = $wrap;
  }

  return $self->{wrap};
}

sub render {
  my $self = shift;

  my $ret = PXT::HTML->textarea(-name => $self->label,
				-value => PXT::Utils->escapeHTML($self->value || $self->default || ''),
				-cols => $self->cols,
				-rows => $self->rows,
                                -wrap => $self->wrap);

  return $ret;
}

1;
