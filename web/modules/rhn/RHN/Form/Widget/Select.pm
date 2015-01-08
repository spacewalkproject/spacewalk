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

package RHN::Form::Widget::Select;

use strict;
use RHN::Exception qw/throw/;
use RHN::Form::Widget;

our @ISA = qw/RHN::Form::Widget/;

my %valid_fields = (options => [],
                    multiple => 0,
                    size => 1,
                    auto_submit => 0,
                    populate_options => 0,
                   );

sub valid_fields { return (shift->SUPER::valid_fields(), %valid_fields) }

sub editable { 1 }

sub _init {
  my $self = shift;

  $self->add_filter('valid_option_filter');

  return;
}

sub auto_submit {
  my $self = shift;
  my $on = shift;

  if (defined $on) {
    $self->{auto_submit} = $on;
  }

  return $self->{auto_submit};
}

sub multiple {
  my $self = shift;
  my $mult = shift;

  if ($mult) {
    $self->{multiple} = 1;
  }

  return $self->{multiple};
}

sub size {
  my $self = shift;
  my $size = shift;

  if (defined $size) {
    $self->{size} = $size;
  }

  return $self->{size};
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

sub populate_options {
  my $self = shift;
  my $pop_method = shift;

  return unless $pop_method;

  my ($class, $method) = split /->/, $pop_method;
  PXT::Utils->untaint(\$class);
  PXT::Utils->untaint(\$method);

  eval "require $class";
  if ($@) {
    throw "(class_error) Could not load '$class': $@";
  }

  eval {
    $self->options([ $class->$method() ]);
  };
  if ($@) {
    throw "(set_options_error) There was a problem setting options from ${class}->${method}: $@";
  }

  return;
}

sub render {
  my $self = shift;

  my $value = $self->value || $self->default || '';
  my %selected;

  if (ref $value eq 'ARRAY') {
    %selected = map { $_, 1 } @{$value};
  }
  else {
    $selected{$value} = 1;
  }

  my @auto_submit = $self->{auto_submit} ? (-onChange => 'this.form.submit()') : ();

  my $ret = PXT::HTML->select(-name => $self->label,
                              -size => $self->size,
                              -multiple => $self->multiple,
                              -options => [ map { [ $_->{label},
                                                    $_->{value},
                                                    $selected{$_->{value}},
                                                    $_->{optgroup} ? 1 : 0,
                                                  ] } $self->options ],
                              @auto_submit,
                             );

  return $ret;
}

1;
