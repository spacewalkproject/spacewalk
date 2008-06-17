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
package Cypress::Channel;
use Grail::Component;

@Cypress::Channel::ISA = qw/Grail::Component/;

my @component_modes =
  (
   [ 'package_list', 'package_list', undef, undef ]
  );

sub component_modes {
  return @component_modes;
}

sub package_list {
  my $self = shift;
  my $pxt = shift;

  $pxt->context(package_installable_list_view_mode => 'channel');
  $pxt->context(package_installable_list_view_mode_param => $pxt->param('cid'));

  # put this in a pxi?
  my $channel = RHN::Channel->lookup(-id => $pxt->param('cid'));
  my $channel_name = $channel->name;

  my $header = <<EOH;
<table width="100%" border="0" cellspacing="0" cellpadding="6">
  <tr>
    <td class="redbar" align="left">Channel Packages for $channel_name</td>
    <td class="redbar" align="right"><a href="/help/basic/sm-channels-packages.html#SM-CHANNEL-LIST"><img src="/img/icon_help.gif" border="0"></a></td>
  </tr>
</table>
EOH

  return $header . $pxt->include('/network/components/packages/installable_package_list.pxi');
}

1;
