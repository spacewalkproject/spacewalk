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

package Sniglets::Navi::Style;
use strict;

sub new {
  my $class = shift;
  my $style_name = shift;

  if ($style_name) {
    return bless { style_name => $style_name }, "${class}::$style_name";
  }
  else {
    return bless { style_name => "ul" }, "${class}::ul";
  }
}

1;
