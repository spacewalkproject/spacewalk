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

use strict;

package RHN::Kickstart::Post;

# The 'Post' section - this package is really to hold 'helper' methods.

use PXT::Utils;

use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

sub new {
  my $class = shift;
  my $val = shift;

  die "'$val' is a ref." if (ref $val);

  $val =~ s/\r\n/\n/g; # wash textbox input
  $val =~ s/\r/\n/g;

  my $self = bless \$val, $class;

  return $self;
}

sub as_string {
  my $self = shift;

  return $$self;
}

1;
