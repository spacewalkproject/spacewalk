#
# Copyright (c) 2008--2012 Red Hat, Inc.
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

package RHN::Form::Widget;

use strict;

use RHN::Exception qw/throw/;
use PXT::Utils;

use RHN::Form::Filter;
use RHN::Form::Require;

my %valid_types = (literal => 'Literal',
		   text => 'Text',
		   textarea => 'TextArea',
		   select => 'Select',
		   checkbox_group => 'CheckboxGroup',
		   radio_group => 'RadiobuttonGroup',
		   hidden => 'Hidden', submit => 'Submit',
		   checkbox => 'Checkbox',
		   file => 'File',
		   );

my %valid_fields = (name => 'Anonymous Widget',
		    label => undef,
		    default => undef,
		    filters => [],
		    requires => [],
		    errors => [],
		    value => undef,
		    acl => undef);

sub valid_fields {
  my $self = shift;

  return ( %valid_fields );
}

sub find_class {
  my $class = shift;
  my $type = shift;

  throw "Cannot find RHN::Form::Widget class for type '$type'."
    unless (exists $valid_types{$type});

  return 'RHN::Form::Widget::' . $valid_types{$type};
}

sub deep_copy { # stolen from www.stonehenge.com/merlyn/UnixReview/col30.html
  my $this = shift;

  if (not ref $this) {
    return $this;
  }
  elsif (ref $this eq "SCALAR") {
    return $this;
  }
  elsif (ref $this eq "ARRAY") {
    return [map deep_copy($_), @$this];
  }
  elsif (ref $this eq "HASH") {
    return {map { $_ => deep_copy($this->{$_}) } keys %$this};
  }
  elsif (ref($this) =~ /^RHN::Form::Widget/) {
    return $this->clone;
  }
  else {
    throw "what type is '$this'?"
  }
}

sub new {
  my $class = shift;
  my %attr = @_;

  my $fields = deep_copy({$class->valid_fields});

  my $self = bless { %{$fields} }, $class;

  foreach (keys %{$fields}) {
    if (exists $attr{$_}) {
      $self->$_($attr{$_});
    }
  }

  $self->_init; # class-specific init code

  $self->label($self->name)
    unless $self->label;

  $self->name($self->label)
    unless (defined $attr{name});

  return $self;
}

sub _init { }

sub clone {
  my $self = shift;

  my %valid_fields = $self->valid_fields;

  my %new;
  foreach my $field (keys %valid_fields) {
    next if grep { $field eq $_ } qw/filters requires/;

    if ($field eq 'options') {
      $new{$field} = deep_copy([ $self->options() ]);
      next;
    }

    if ($field eq 'value') {
      $new{$field} = deep_copy($self->raw_value());
    }
    else {
      $new{$field} = deep_copy($self->$field());
    }
  }

  my $class = ref $self;
  my $widg = $class->new(%new);
  $widg->add_require($_->{label}, $_->{param}) foreach $self->requires();
  $widg->add_filter($_) foreach $self->filters();

  return $widg;
}

sub name {
  my $self = shift;
  my $name = shift;

  if (defined $name) {
    $self->{name} = $name;
  }

  return $self->{name};
}

sub label {
  my $self = shift;
  my $label = shift;

  if (defined $label) {
    throw "Attempt to set invalid label '$label' for widget '" . $self->name . "'."
      unless $label =~ /[\w:]/;
    throw "Label '$label' is longer than 64 characters"
      if (length $label > 64);

    $self->{label} = $label;
  }

  return $self->{label};
}

sub default {
  my $self = shift;
  my $default = shift;

  if (defined $default) {
    $self->{default} = $default;
  }

  return $self->{default};
}

sub acl {
  my $self = shift;
  my $acl = shift;

  if (defined $acl) {
    $self->{acl} = $acl;
  }

  return $self->{acl};
}

sub set_value { # lets us set the value to 'undef'
  my $self = shift;
  my $value = shift;

  my @values = ($value);
  if (ref $value eq 'ARRAY') {
    @values = @{$value};
  }

  foreach my $val (@values) {
    foreach my $filter ($self->filters) {
      $val = $self->$filter($val);
    }

    foreach my $req ($self->requires) {
      my $rule = $req->{rule};
      my $param = $req->{param};

      if (my $error = RHN::Form::Require->$rule($param, $val)) {
	$self->add_error($error, $req->{param});
      }
    }
  }
  my @errors = $self->errors;

  return \@errors if @errors;

  $self->{value} = (scalar @values > 1) ? \@values : $values[0];

  return; # No errors
}

sub value {
  my $self = shift;
  my $value = shift;

  if (defined $value) {
    return $self->set_value($value);
  }

  return defined $self->{value} ? $self->{value} : $self->{default};
}

sub raw_value {
  my $self = shift;
  my $value = shift;

  if ($value) {
    $self->{value} = $value;
  }

  return defined $self->{value} ? $self->{value} : $self->{default};
}

sub prefill_value {
  my $self = shift;
  my $value = shift;

  $self->{value} = $value;

  return $value;
}

sub add_filter {
  my $self = shift;
  my $filter = shift;

  if (ref $filter eq 'CODE') {
    push @{$self->{filters}}, $filter;
  }
  elsif (ref $filter eq 'HASH') {
    push @{$self->{filters}}, RHN::Form::Filter->lookup_filter($filter->{type});
  }
  elsif (! ref $filter) {
    push @{$self->{filters}}, RHN::Form::Filter->lookup_filter($filter);
  }
  else {
    throw "Unknown filter type: '$filter'.\n";
  }

  return;
}

sub filters {
  my $self = shift;
  my $filters = shift;

  if (defined $filters and (ref $filters eq 'ARRAY')) {
    delete $self->{filters};
    $self->{filters} = [];
    $self->add_filter($_) foreach (@{$filters});
  }

  return @{$self->{filters}};
}

sub add_require {
  my $self = shift;
  my $require = shift;
  my $param = shift;

  throw "No label provided to add_require." unless (defined $require);

  if (ref $require eq 'HASH') {
    foreach my $label (keys %{$require}) {
      throw "No param for '$label' requirement on widget: " . $self->label
	unless (defined $require->{$label});

      push @{$self->{requires}}, {label => $label,
				  rule => RHN::Form::Require->lookup_require($label),
 				  param => $require->{$label}};
    }
  }
  elsif ($param) {
    push @{$self->{requires}}, {label => $require,
				rule => RHN::Form::Require->lookup_require($require),
				param => $param};
  }
  else {
    throw "No param for '$require' requirement on widget: " . $self->label;
  }

  return;
}

sub requires {
  my $self = shift;
  my $requires = shift;

  if (ref $requires eq 'HASH') {
    $self->add_require($requires);
  }

  return @{$self->{requires}};
}

sub add_error {
  my $self = shift;
  my $error = shift;
  my $param = shift;

  my %attr = (widget_name => $self->name,
	      widget_label => $self->label,
	      param => $param);

  $error = PXT::Utils->perform_substitutions($error, \%attr);

  push @{$self->{errors}}, $error;

  return;
}

sub errors {
  my $self = shift;

  return @{$self->{errors}};
}

sub render {
  my $self = shift;

  throw "Method 'render' called on virtual base class 'RHN::Form::Widget'.";
}

# checks to see if this widget requires a response
sub is_required {
  my $self = shift;

  return 1 if ( grep { $_->{label} eq 'response' or $_->{label} eq 'min-length' } $self->requires );

  return 0;
}

1;

