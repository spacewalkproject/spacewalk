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

package RHN::AppInstall::ACL;

use strict;

use RHN::Exception qw/throw/;
use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

my %valid_fields = (name => 1,
		    argument => 0,
		    failed_message => 0,
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

sub to_string {
  my $self = shift;

  return sprintf("%s(%s)", $self->get_name, $self->get_argument);
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

sub get_argument {
  my $self = shift;

  return $self->{argument};
}

sub set_argument {
  my $self = shift;
  my $argument = shift;

  $self->{argument} = $argument;

  return;
}

sub set_failed_message {
  my $self = shift;
  my $failed_message = shift;

  $self->{failed_message} = $failed_message;

  return;
}

1;
