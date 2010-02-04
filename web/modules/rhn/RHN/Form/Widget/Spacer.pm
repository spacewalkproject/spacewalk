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

package RHN::Form::Widget::Spacer;

use strict;
use RHN::Form::Widget;

our @ISA = qw/RHN::Form::Widget/;

sub valid_fields { return shift->SUPER::valid_fields() }

#A 'spacer' widget - purely a rendering convenience

sub editable { 0 }

sub render {
  my $self = shift;

  return '&#160;';
}

1;
