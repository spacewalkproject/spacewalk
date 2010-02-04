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

package RHN::Form::Widget::Checkbox;

use strict;
use PXT::HTML;
use PXT::Utils;

use RHN::Form::Widget;

our @ISA = qw/RHN::Form::Widget/;

my %valid_fields = (disabled => undef,
		    checked => undef,
                    auto_submit => undef);

sub valid_fields { return (shift->SUPER::valid_fields(), %valid_fields) }

sub editable { 1 }

sub disabled {
  my $self = shift;
  my $disabled = shift;

  if (defined $disabled) {
    $self->{disabled} = $disabled;
  }

  return $self->{disabled};
}

sub checked {
  my $self = shift;
  my $checked = shift;

  if (defined $checked) {
    $self->{checked} = $checked;
  }
  return $self->{checked};
}

sub auto_submit {
  my $self = shift;
  my $on = shift;

  if (defined $on) {
    $self->{auto_submit} = $on;
  }

  return $self->{auto_submit};
}


sub prefill_value {
  my $self = shift;
  my $value = shift;

  $self->checked($value);

  return $value;
}


sub render {
  my $self = shift;

  my @auto_submit = $self->{auto_submit} ? (-onClick => 'this.form.submit()') : ();

  my $ret = PXT::HTML->checkbox(-name => $self->label,
				-value => $self->value || $self->default || '',
				-disabled => $self->disabled,
				-checked => $self->checked,
				@auto_submit);

  return $ret;
}

1;
