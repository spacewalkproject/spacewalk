#
# Copyright (c) 2008--2011 Red Hat, Inc.
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

package Sniglets::ActivationKeys;

use RHN::Token;
use PXT::Utils;

sub register_tags {
  my $class = shift;
  my $pxt = shift;
  $pxt->register_tag('rhn-token-details' => \&token_details);
}



sub create_token {
  my $class = shift;
  my $pxt = shift;

  my $token = RHN::Token->create_token;
  $token->user_id($pxt->user->id);
  $token->org_id($pxt->user->org_id);

  return $token;
}

sub token_details {
  my $pxt = shift;
  my %attr = @_;

  throw "not an activation key admin - uid = '" . $pxt->user->id . "'" unless $pxt->user->is('activation_key_admin');

  my $html = $attr{__block__};
  my $tid = $pxt->param('tid');
  my $token;


  if ($tid) {
    throw "org does not own this token - tid = '$tid', uid = '" . $pxt->user->id . "'"
      unless ($pxt->user->verify_token_access($tid));

    $token = RHN::Token->lookup(-id => $tid);
  }
  else {
    $token = RHN::Token->blank_token;
    $token->user_id($pxt->user->id);
    $token->org_id($pxt->user->org_id);
    $token->activation_key_token('');
  }


  #do the easy ones first
  foreach my $field (qw/note activation_key_token usage_limit/) {
    my $val = $token->$field() || $pxt->dirty_param("token:$field") || '';
    $html =~ s/\{token:$field\}/PXT::Utils->escapeHTML($val)/ge;
  }

  my $deploy_val = $token->deploy_configs() || $pxt->dirty_param('deploy_configs') || '';
  $html =~ s/\{token:deploy_configs\}/$deploy_val eq 'Y' ? 'Yes' : 'No'/ge;
  $html =~ s/\{tid\}/$token->id || 0/ge;

  my $org_default_val = $token->org_default || $pxt->dirty_param('org_default') || 0;
  $html =~ s/\{token:org_default\}/$org_default_val ? 'Yes' : 'No'/ge;

  return $html;
}


1;
