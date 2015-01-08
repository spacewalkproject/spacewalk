#
# Copyright (c) 2008--2012 Red Hat, Inc.
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

package Sniglets::Users;

use PXT::Utils;

use RHN::User;
use RHN::Org;
use PXT::HTML;
use RHN::Mail;
use PXT::ACL;
use Mail::RFC822::Address;
use URI;

use Sniglets::Forms;
use Sniglets::Forms::Style;
use RHN::ContactMethod;
use RHN::ContactGroup;
use RHN::SatInstall;

use RHN::DataSource::SystemGroup;

use Digest::MD5;
use Date::Parse;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag('rhn-login-form', \&rhn_login_form);

  $pxt->register_tag('rhn-require' => \&rhn_require, -1000);

  $pxt->register_tag('rhn-user-login' => \&rhn_user_login);
}

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_callback('rhn:user_prefs_edit_cb' => \&user_prefs_edit_cb);
}




sub errata_summary {
  my $pxt = shift;
  my %params = @_;
  my $block = $params{__block__};

  my $html;

  my $number = $params{number} || 10;
  my $shown_errata;
  my $relevant_errata;

  my $errata_summary;

  my @recent_errata = $pxt->user->recent_errata_overview($number, \$shown_errata, \$relevant_errata);

  $shown_errata ||= 0;

  foreach my $errata (@recent_errata) {

    my $x = { };

    @{$x}{qw/id type name update_date affected_server_count/} = @{$errata}[0 .. 5];

    push @{$errata_summary}, $x;
  }

  $block =~ m(<rhn-recent-errata>(.*?)</rhn-recent-errata>)s;

  my $inner = $1;

  my %errata_icons =
    ( 'Security Advisory' => '/img/wrh_security-grey.gif',
      'Bug Fix Advisory' => '/img/wrh_bug-grey.gif',
      'Product Enhancement Advisory' => '/img/wrh_feature-grey.gif',
      'Enhancement Advisory' => '/img/wrh_feature-grey.gif' );

  my $replacement;

  foreach my $line (@{$errata_summary}) {
    my $copy = $inner;

    my $link;

    if ($line->{affected_server_count} > 0) {
      $link = qq(<a href="/rhn/errata/details/SystemsAffected.do?eid={errata_id}">{errata_affected_server_count}</a>);
    }
    else {
      $link = '0';
    }

    $copy =~ s/\{errata_affected_server_link\}/$link/g;

    foreach (qw/id type name affected_server_count/) {
      $copy =~ s/\{errata_$_\}/$line->{$_}/eg;
    }

    $copy =~ s/\{errata_alt_label\}/$line->{type}/eg;
    $copy =~ s/\{errata_type_icon\}/$errata_icons{$line->{type}}/eg;

    $replacement .= $copy;
  }

  $replacement ||= '<tr class="graydata"><td align="center" colspan="3">No Relevant Errata</td></tr>';

  my $show_applied = $pxt->user->get_pref('show_applied_errata') || 'N';
  my $total_errata = $pxt->user->errata_count || 0;

  $block =~ s[<rhn-recent-errata-summary>(.*?)</rhn-recent-errata-summary>][($shown_errata > 0 && $show_applied eq 'Y') ? $1 : '&#160;' ]se;
  $block =~ s[<rhn-all-errata-summary>(.*?)</rhn-all-errata-summary>][($shown_errata > 0 && $show_applied ne 'Y') ? $1 : '&#160;']se;
  $block =~ s/\{errata_shown\}/$shown_errata/g;
  $block =~ s/\{errata_total\}/$total_errata/g;
  $block =~ s/\{errata_relevant\}/$relevant_errata || '0'/eg;
  $block =~ s/\{errata_displayed\}/scalar @{$errata_summary}/eg;
  $block =~ s(<rhn-recent-errata>(.*?)</rhn-recent-errata>)($replacement)s;
  $block =~ s(<a href=[^>]*>0</a>)(0)gism;

  return $block;
}

sub rhn_login_form {
  my $pxt = shift;
  my %params = @_;

  if ($pxt->user) {
    $pxt->redirect("/rhn/YourRhn.do");
  }

  if (not $pxt->ssl_request and $pxt->ssl_available) {
    # ssl available?  useragent look like a real user?  then it likely
    # *IS* a real user (mozilla in user-agent) and not a
    # bot... redirect to ssl login page

    if ($pxt->method ne 'HEAD' and $pxt->header_in('User-Agent') =~ /mozilla/i) {
      $pxt->redirect($pxt->derelative_url("/", "https"));
    }

    return sprintf("Please click %s to sign in securely.", PXT::HTML->link($pxt->derelative_url("/", "https"), "here"));
  }

  my $body = $params{__block__};
  $body = $pxt->prefill_form_values($body);

  my $hidden = '';
  if ($params{url_passthrough} or $pxt->context('url_passthrough')) {
    # why use the_request instead of uri?  because we're likely in a
    # subrequest and uri is /errors/permission.pxt.  ugly.
    my ($method, $url) = (split /\s+/, $pxt->the_request)[0, 1];

    if ($method eq 'GET' or $pxt->dirty_param('url_bounce')) {
      $hidden .= PXT::HTML->hidden(-name => 'url_bounce', -value => PXT::Utils->escapeHTML(($pxt->dirty_param('url_bounce') || $url)));
    }
  }

  return $body;
}

sub user_prefs_edit_cb {
  my $pxt = shift;

  my $user;

  if ($pxt->user->is('org_admin') and $pxt->param('uid')) {
    $user = RHN::User->lookup(-id => $pxt->param('uid'));
  }
  else {
    $user = $pxt->user;
  }

  $user->set_pref('email_notify', $pxt->dirty_param('email_notifications') || '0');

  $user->$_($pxt->dirty_param($_) ? 'Y' : 'N')
    foreach qw/contact_call contact_mail contact_email contact_fax/;

  # the reason for this oddball multiplication/division is because the
  # pref value column is varchar2(1) and it means working circles
  # around it.

  my $pagesize = $pxt->dirty_param('preferred_page_size') || $user->preferred_page_size;
  $pagesize = 5 if $pagesize < 5;
  $pagesize = 50 if $pagesize > 50;

  $user->set_pref('page_size', $pagesize);
  $user->set_pref('timezone_id', $pxt->dirty_param('time_zone') ? $pxt->dirty_param('time_zone') : 0);

  $user->commit;

  $pxt->push_message(site_info => "Preferences modified.");

  return;
}

sub rhn_require {
   my $pxt = shift;
   my %params = @_;

   my $pass;
   if (exists $params{acl}) {
     my $mixins = [];
     if ($params{acl_mixins}) {
       $mixins = [ split(/,\s*/, $params{acl_mixins}) ];
     }

     my $acl = new PXT::ACL (mixins => $mixins);
     $pass = $acl->eval_acl($pxt, $params{acl});
   }
   else {
     $pass = Sniglets::Users->check_perms($pxt, %params) || 0;
   }

   return $params{__block__} if $pass;

   if (my $url = $params{redirect}) {
     if ($params{__block__}) {
       die "Attempt to redirect in rhn_require in block context";
     }
     $pxt->redirect($url);
   }

   return '';
}

#abstracting permission checking code from rhn_require to here
#takes a 'pxt' and a hash of params, and checks for various states and permissions
#returns true for success, false for failure
sub check_perms {
  my $class = shift;
  my $pxt = shift;
  my %params = @_;

  if ($params{config}) {
    if ($params{config} =~ /^!(.*)$/) {
      return if (PXT::Config->get($1));
    }
    else {
      return unless (PXT::Config->get($params{config}));
    }
  }

  my @set_stats;
  my %sets;

  $params{valid_user} = 1
    if exists $params{set} or exists $params{role} or exists $params{entitlement};

  if ($params{valid_user}) {
    return unless $pxt->user;
    @set_stats = $pxt->user->selection_details;
    %sets = map {$_->[0] => $_->[1]} @set_stats;
  }

  if ($params{invalid_user}) {
    return if $pxt->user;
  }

  #role - property of a user - currently channel_admin, coma_admin,
  #coma_author, coma_publisher, org_admin.
  if ($params{role}) {
    if ($params{role} =~ /^!(.*)$/) {
      return if $pxt->user->is($1);
    }
    else {
      return unless $pxt->user->is($params{role});
    }
  }

  #org_role - property of an org - does this org contain at least one
  #user with the following role?
  if ($params{org_role}) {
    if ($params{org_role} =~ /^!(.*)$/) {
      return if $pxt->user->org->has_role($1);
    }
    else {
      return unless $pxt->user->org->has_role($params{org_role});
    }
  }

  #entitlement - property of an org
  #currently sw_mgr_enterprise for workgroup, sw_mgr_personal for basic (org)
  if ($params{entitlement}) {
    if ($params{entitlement} =~ /^!(.*)$/) {
      return if $pxt->user->org->has_entitlement($1);
    }
    else {
      return unless $pxt->user->org->has_entitlement($params{entitlement});
    }
  }

  # entitled_server - property of a server
  # requires 'sid' param
  # 1 for some level of entitlement, 0 if unentitled
  if (defined $params{entitled_server}) {
    my $sid = $pxt->param('sid');
    die "Attempt to check for server_entitlement without an sid" unless $sid;

    my $server_entitlement = RHN::Server->lookup(-id => $sid)->is_entitled;
    my $desired_entitlement = $params{entitled_server};
    return ( ($server_entitlement and $desired_entitlement) or (!$server_entitlement and !$desired_entitlement));
  }

  # server_entitlement - property of a server
  # requires 'sid' param
  # currently enterprise_entitled for workgroup, sw_mgr_entitled for basic.
  if ($params{server_entitlement}) {
    my $sid = $pxt->param('sid');
    die "Attempt to check for server_entitlement without an sid" unless $sid;

    if ($params{server_entitlement} =~ /^!(.*)$/) {
      return if RHN::Server->lookup(-id => $sid)->is_entitled;
    }
    else {
      my $server_entitlement = RHN::Server->lookup(-id => $sid)->is_entitled;
      return unless defined $server_entitlement and $server_entitlement eq $params{server_entitlement};
    }
  }

  #channel family entitlement - property of an org
  #requires channel family label as param - currently used from rhn-proxy and rhn-satellite
  if ($params{channel_family_entitlement}) {
    return unless $pxt->user->org->has_channel_family_entitlement($params{channel_family_entitlement});
  }

  if ($params{set}) {
    return unless $sets{$params{set}};
  }

  #ran the gauntlet
  return 1;
}

sub rhn_user_login {
  my $pxt = shift;

  my $uid = $pxt->param('uid');
  my $user;
  if (defined $uid) {
    $user = RHN::User->lookup(-id => $uid);
  }
  else {
    my $cmid = $pxt->param('cmid');
    $user = RHN::User->lookup(-contact_method_id => $cmid);
    if (defined $user) {
      $pxt->param(uid => $user->id);
      $pxt->cleanse_param('uid');
    } else {
      $user = RHN::User->lookup(-id => $pxt->user->id);
    }
  }
  return $user->login;
}

1;
