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

package RHN::AppInstall::Process::Step::Action;

use strict;

use RHN::Exception qw/throw/;
use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

# Actions can have either a single argument, or multiple named arguments

my %valid_fields = (acl => 0,
		    arguments => { type => ARRAYREF,
				   default => [],
				 },
		    name => 1,
		   );

sub valid_fields {
  return %valid_fields;
}

sub new {
  my $class = shift;

  if ($class eq 'RHN::AppInstall::Process::Step::Action') {
    throw "(constructor_error) Cannot create new ${class}: virtual base class";
  }

  my %fields = $class->valid_fields();
  my %attr = validate(@_, \%fields);

  my $self = bless { map { ( $_, undef ) } keys(%fields),
		   }, $class;

  foreach (keys %attr) {
    my $func = "set_${_}";
    throw "Invalid function: $func"
      unless $self->can($func);

    $self->$func($attr{$_});
  }

  return $self;
}

sub get_name {
  my $self = shift;

  return $self->{name};
}

sub set_name {
  my $self = shift;
  my $name = shift;

  $self->{name} = $name;

  return;
}

sub get_acl {
  my $self = shift;

  return $self->{acl};
}

sub set_acl {
  my $self = shift;
  my $acl = shift;

  $self->{acl} = $acl;

  return;
}

sub get_arguments {
  my $self = shift;

  return @{$self->{arguments}};
}

sub set_arguments {
  my $self = shift;
  my @args;

  if ($_[0] and ref $_[0] eq 'ARRAY') {
    @args = @{$_[0]};
  }
  else {
    @args = @_;
  }

  $self->{arguments} = \@args;

  return;
}

sub push_argument {
  my $self = shift;
  my @arguments = @_;

  foreach my $argument (@arguments) {
    throw "(set_error) $argument is not an RHN::AppInstall::Process::Step::Action::Arg"
      unless (ref $argument and $argument->isa('RHN::AppInstall::Process::Step::Action::Arg'));
  }

  push @{$self->{arguments}}, @arguments;

  return;
}

1;
