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
use Data::Dumper;
use PXT::Utils;

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

  if ($pxt->user) {
    my $body = $params{__block__} || '';
    if ($pxt->user()) {
      $login = PXT::Utils->escapeHTML($pxt->user->login);
    }

    $body =~ s/\[login\]/$login/g;
    return $body;
  }
  else {
    return "&#160;";
  }
}

1;
