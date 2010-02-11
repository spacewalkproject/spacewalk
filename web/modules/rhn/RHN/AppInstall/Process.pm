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

package RHN::AppInstall::Process;

use strict;

use RHN::Exception qw/throw/;
use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

my %valid_fields = (steps => { type => ARRAYREF,
			       default => [],
			     },
		    acl => 0,
		   );

sub valid_fields {
  return %valid_fields;
}

sub new {
  my $class = shift;
  my %fields = $class->valid_fields;
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

sub lookup_step {
  my $self = shift;
  my $index = shift;

  my $step;

  if (exists $self->{steps}->[$index]) {
    $step = $self->{steps}->[$index];
  }

  return $step;
}

sub push_step {
  my $self = shift;
  my @steps = @_;

  foreach my $step (@steps) {
    throw "(set_error) $step is not an RHN::AppInstall::Process::Step"
      unless (ref $step and $step->isa('RHN::AppInstall::Process::Step'));
  }

  push @{$self->{steps}}, @steps;

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

1;
