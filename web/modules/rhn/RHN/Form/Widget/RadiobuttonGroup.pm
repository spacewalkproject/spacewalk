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

package RHN::Form::Widget::RadiobuttonGroup;

use strict;
use RHN::Form::Widget;

our @ISA = qw/RHN::Form::Widget/;

my %valid_fields = (options => []);

sub valid_fields { return (shift->SUPER::valid_fields(), %valid_fields) }

sub editable { 1 }

sub _init {
  my $self = shift;

  $self->add_filter('valid_option_filter');

  return;
}

sub add_option {
  my $self = shift;
  my $option = shift;

  push @{$self->{options}}, $option;
}

sub options {
  my $self = shift;
  my $options = shift;

  if (defined $options and (ref $options eq 'ARRAY')) {
    $self->{options} = [];
    $self->add_option($_) foreach (@{$options});
  }

  return @{$self->{options}};
}

sub render {
  my $self = shift;

  my @ret;

  my @options = $self->options;

  my $selected = $self->value || $self->default || '';

  foreach my $option (@options) {
    push @ret, $self->render_option($option, $selected);
  }

  return @ret;
}

sub render_option {
  my $self = shift;
  my $opt = shift;
  my $selected = shift;

  my %extra_options;

  if ($opt->{disabled}) {
    $extra_options{-disabled} = 1;
  }

  my $ret = PXT::HTML->radio_button(-name => $self->label,
				    -value => $opt->{value} || '',
				    -checked => ($opt->{value} eq $selected),
				    %extra_options);

  $ret .= $opt->{label};
  return $ret;
}

1;
