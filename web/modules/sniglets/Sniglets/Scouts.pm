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

package Sniglets::Scouts;

use RHN::SatCluster;
use RHN::DB::SatCluster;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag("rhn-show-public-key" => \&show_public_key);
}

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;

}


#####################
sub show_public_key {
#####################
  my $pxt = shift;

  my $scout_id = $pxt->param('scout_id');
  my $scout = RHN::SatCluster->lookup(-recid => $scout_id);

  my $desc = $scout->description;
  my $key = $scout->public_key;
  my $html;

  if ($key) {
    $html .= "RHNMD public key for <strong>$desc</strong>: <br/>\n";
    $html .= "<pre>$key</pre>";
  }
  else {
    $html .= "No RHNMD Public Key found for scout <strong>$desc</strong>";
  }

  return $html;
}

1;
