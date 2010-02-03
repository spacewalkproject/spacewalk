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

package Sniglets::Header;
use PXT::Utils;
use RHN::Org;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag('rhn-display-login' => \&display_login);
}

sub display_login {
  my $pxt = shift;
  my %params = @_;
  my $login = '';
  my $custnum = '';
  my $org = '';
  my $org_name = '';
  my $org_id = '';

  if ($pxt->user) {
    my $body = $params{__block__} || '';
    if ($pxt->user()) {
      $login = PXT::Utils->escapeHTML($pxt->user->login);

      $org = RHN::Org->lookup(-id => $pxt->user->org->id);
      $org_name = $org->name;
      $org_id = $org->id;
    }

    $body =~ s/\[org\]/$org_name/g;
    $body =~ s/\[login\]/$login/g;
    $body =~ s/\[oid\]/$org_id/g;
    return $body;
  }
  else {
    return "&#160;";
  }
}

1;
