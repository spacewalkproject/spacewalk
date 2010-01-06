#
# Copyright (c) 2008--2009 Red Hat, Inc.
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

package Sniglets::Utils;
use Data::Dumper;
use PXT::Utils;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag("rhn-bugzilla-link", \&rhn_bugzilla_link);
  $pxt->register_tag("rhn-redirect", \&rhn_redirect);
}

sub rhn_redirect {
  my $pxt = shift;
  my %params = @_;
  my $url;
  if ($url = $params{'url'}) {
    $pxt->redirect($url);
  }
}

sub rhn_bugzilla_link {
  my $pxt = shift;

  return '';
}

1;
