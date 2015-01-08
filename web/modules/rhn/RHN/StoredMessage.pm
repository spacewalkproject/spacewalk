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
package RHN::StoredMessage;

our $VERSION = 1.12;

sub new {
  my $class = shift;
  my $msg = shift;

  my $self = bless { msg => $msg, version => $VERSION }, $class;
}

sub is_valid {
  my $self = shift;

  return $self->{version} == $VERSION;
}

sub render {
  my $self = shift;

  return $self->{msg};
}

1;
