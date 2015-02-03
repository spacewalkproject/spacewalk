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

use strict;
package RHN::DataSource::Simple;
use RHN::DataSource;
use Carp;

our @ISA = qw/RHN::DataSource/;

sub valid_fields {
  my $class = shift;

  return ('querybase', $class->SUPER::valid_fields);
}

sub new {
  my $class = shift;
  my %attr = @_;

  croak "RHN::DataSource::Simple constructor called with no querybase" unless exists $attr{-querybase};

  return $class->SUPER::new(%attr);
}

sub querybase {
  my $self = shift;

  if (@_) {
    $self->{querybase} = shift;
  }
  return $self->{querybase};
}

sub data_file {
  my $self = shift;

  return "$self->{querybase}.xml";
}

1;
