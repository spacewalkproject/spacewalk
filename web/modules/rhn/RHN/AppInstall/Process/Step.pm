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

package RHN::AppInstall::Process::Step;

use strict;

use RHN::Exception qw/throw/;
use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

my %valid_fields = (description => 1,
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

sub get_description {
  my $self = shift;

  return $self->{description};
}

sub set_description {
  my $self = shift;
  my $description = shift;

  throw "(set_error) $self must have a description"
    unless $description;

  $self->{description} = $description;
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
