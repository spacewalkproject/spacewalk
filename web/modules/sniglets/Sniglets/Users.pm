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

package Sniglets::Users;

use PXT::Utils;

use RHN::User;
use RHN::UserGroup;
use RHN::Org;
use RHN::Grail;
use PXT::HTML;
use RHN::UserActions;
use RHN::Exception qw/throw catchable/;
use RHN::SessionSwap;
use RHN::Mail;
use RHN::Postal;
use RHN::TemplateString;
use RHN::Utils;
use PXT::ACL;
use Mail::RFC822::Address;
use URI;

use Sniglets::Forms;
use Sniglets::Forms::Style;
use RHN::Form::ParsedForm;
use RHN::ContactMethod;
use RHN::ContactGroup;
use RHN::SatInstall;

use RHN::DataSource::SystemGroup;

use Digest::MD5;
use Date::Parse;

use Data::Dumper;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag('public-secure-links-if-logged-in' => \&secure_links_if_logged_in, 101);

  $pxt->register_tag('rhn-login-form', \&rhn_login_form);

  $pxt->register_tag('rhn-require' => \&rhn_require, -1000);

  $pxt->register_tag('rhn-user-site-view' => \&user_site_view);

  $pxt->register_tag('rhn-user-login' => \&rhn_user_login);
}

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_callback('rhn:login_cb', \&rhn_login_cb);
  $pxt->register_callback('rhn:forgot_password_cb', \&forgot_password_cb);
  $pxt->register_callback('rhn:forgot_accounts_cb', \&forgot_accounts_cb);

  $pxt->register_callback('rhn:user_prefs_edit_cb' => \&user_prefs_edit_cb);

  $pxt->register_callback('rhn:request_account_deactivation_cb' => \&request_account_deactivation_cb);
  $pxt->register_callback('rhn:user_default_system_groups_cb' => \&default_system_groups_cb);
  
  $pxt->register_callback('rhn:accepted' => \&tnc_accepted_cb);
}

#Can you see this
sub tnc_accepted_cb {
	my $pxt = shift;
	$pxt->push_message(site_info => 'Thank you for accepting the Terms and Conditions!');
	$pxt->redirect("/rhn/YourRhn.do");
}

# secures *all* intraserver links and all links to specified exterior servers
sub secure_links_if_logged_in {
  my $pxt = shift;
  my %params = @_;

  return $params{__block__} unless $pxt->user;

  #  intra server ones...
  #$params{__block__} =~ s/href="(http:\/\/.*?)"/'href="' . $pxt->derelative_url($1, 'https') . '"'/egism;

  #  inter server ones
  foreach my $server_str (split /[|]/, $params{servers}) {
    $params{__block__} =~ s{http://($server_str)}{https://$1}gism;
  }

  return $params{__block__};
}


sub request_account_deactivation_cb {
  my $pxt = shift;
  my $user = $pxt->user;

  die "no user!" unless $user;

  eval {
    $user->request_deactivation();
  };

  if ($@) {

    my $E = $@;

    if (ref $E and catchable($E) and $E->constraint_value eq 'RHN_UDQUEUE_UID_UQ') {
      $pxt->push_message(site_info => 'We have already logged your deactivation request and will complete the request as soon as possible.');
    }
    else {
      throw $E;
    }
  }
  else {
    $pxt->push_message(site_info => 'Request for account deactivation sent.');
  }

  $pxt->redirect('/network/account/details.pxt');
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

  if (PXT::Config->get('satellite_install')) {
    $pxt->redirect("/install/index.pxt");
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

  $body =~ s(\[login_form_hidden\])(<input type="hidden" name="pxt_trap" value="rhn:login_cb" />\n<input type="hidden" name="cookie_test" value="1" />\n$hidden)gmsi;

  $pxt->session->set('cookie_test' => 1);

  return $body;
}

sub forgot_password_cb {
  my $pxt = shift;

  my $user = RHN::User->lookup(-username => $pxt->dirty_param('username'));
  my $email = $pxt->dirty_param('email');

  my $previous_request = $pxt->session->get('previous_password_request');
  if ($previous_request) {
    if (uc($previous_request->{email}) eq uc($email) and
	$previous_request->{username} eq $pxt->dirty_param('username') and
	time - $previous_request->{time} < 60) {
      warn "attempt to rerequest password reset; ignoring";
      $pxt->push_message(site_info => 'Email sent.');
      return;
    }
  }

  if ($user and uc($user->email) eq uc($email)) {
    my $password = PXT::Utils->random_password(12);
    my $username = $user->login;

    if ($user->is('org_applicant')) {
      $pxt->push_message(local_alert => 'Your account has not yet been approved.  When it is, you will be notified via email.');
      return;
    }

    $user->set_password($password);
    $user->commit;
    
    my $letter = new RHN::Postal;
    $letter->template("forgot_password.xml");
    $letter->set_tag('email-address' => $email);
    $letter->set_tag('helpful-email-address' => PXT::Config->get('satellite') ?  "your satellite administrator" : "dev-null\@redhat.com");
    $letter->set_tag('username' => $username);
    $letter->set_tag('password' => $password);
    $letter->render;
    $letter->to($email);

    $pxt->session->set(previous_password_request => {email => $email, username => $pxt->dirty_param('username'), time => time });

    $pxt->push_message(site_info => 'Email sent.');
    $letter->send;
  }
  else {
    $pxt->push_message(local_alert => 'Either that username does not exist, or the supplied email address does not match our records.');
  }
}

sub forgot_accounts_cb {
  my $pxt = shift;

  my $email = $pxt->dirty_param('email');
  my @users = sort { $a->login_uc cmp $b->login_uc } map { RHN::User->lookup(-id => $_->[0]) } RHN::User->users_by_email($email);

  my $last_req = $pxt->session->get('previous_account_request');
  if ($last_req and time - $last_req < 300) {
    $pxt->push_message(site_info => "An email has already been sent; you may only request your account list every five minutes.");
    return;
  }
  if (not @users) {
    $pxt->push_message(site_info => 'There are no registered accounts with that email address.');
    return;
  }

  $pxt->session->set('previous_account_request' => time);
  my $letter = new RHN::Postal;
  $letter->template("forgot_accounts.xml");
  $letter->set_tag('email-address' => $email);
  $letter->set_tag('helpful-email-address' => PXT::Config->get('satellite') ?  "your satellite administrator" : "dev-null\@redhat.com");
  $letter->set_tag('account-list' => join("\n", map { "  " . $_->login } @users));
  $letter->set_header("X-RHN-Info" => "account_list");
  $letter->render;
  $letter->to($email);

  $pxt->push_message(site_info => 'Email sent.');

  $letter->send;
}

sub rhn_login_cb {
  my $pxt = shift;
  my $username = $pxt->dirty_param('username');
  my $password = $pxt->dirty_param('password');

  if ($pxt->dirty_param('cookie_test') and not $pxt->session->get('cookie_test')) {
#    warn "User does not have cookies enabled.";
    $pxt->redirect('/errors/cookies.pxt');
  }

  # log them out
  $pxt->clear_user;
  $pxt->session->uid(undef);

  if (PXT::Config->get('satellite') and not RHN::Org->validate_cert() ) {
    warn "Certificate is expired.";
    $pxt->redirect('/errors/cert-expired.pxt');
  }

  my $user = RHN::User->check_login($username, $password);
  
  if ($user) {
 
    #If user is disabled, don't log them in. Display error msg and return.
    if ($user->is_disabled()) {
      $pxt->push_message(local_alert => 'Account ' . $user->login . ' has been disabled.');
      return;
    }

    $pxt->log_user_in($user, 'system_list');
    $user->org->update_errata_cache(PXT::Config->get("errata_cache_compute_threshold"));

    my $incomplete = $user->has_incomplete_info;

    if ($incomplete and $incomplete eq 'details') {
      $pxt->redirect('/rhn/account/UserDetails.do');
    }
    else {
      if ($pxt->dirty_param('url_bounce') and $pxt->header_in('User-Agent') !~ /Konqueror/) {
	my $url = $pxt->dirty_param('url_bounce');

	if ($url =~ /\?/) {
	  $url .= "&r=" . int rand(1000000);
	}

	$pxt->redirect($url);
      }
      else {
	if ($pxt->header_in('User-Agent') =~ /Konqueror\/3.0.0/) {
	  $pxt->redirect('/konq.pxt');
	}
	else {
	  $pxt->redirect('/rhn/YourRhn.do');
	}
      }
    }
  }
  else {
    my $baduser = RHN::User->lookup(-username => $username);
    if ($baduser and $baduser->is('org_applicant')) {
      $pxt->push_message(local_alert => 'Your account has not yet been approved.  When it is, you will be notified via email.');
      return;
    }
    $pxt->push_message(local_alert => 'Either the password or username is incorrect.');
  }

}


sub user_site_view {
  my $pxt = shift;
  my %params = @_;

  my $uid = $pxt->param('uid') || $pxt->pnotes('uid') || $pxt->user->id;
  my $user = RHN::User->lookup(-id => $uid);

  die "no user" unless $user;

  if ($pxt->user->org_id != $user->org_id) {
    Carp::cluck "Orgs for admin user edit mistatch (admin: @{[$pxt->user->org_id]} != @{[$user->org_id]}";
    $pxt->redirect("/errors/permission.pxt");
  }

  if ($uid != $pxt->user->id and not $pxt->user->is('org_admin')) {
    Carp::cluck "Non-orgadmin attempting to edit another's record";
    $pxt->redirect("/errors/permission.pxt");
  }

  $pxt->pnotes(user_name => $user->login);

  my $type = uc $params{type} || $pxt->dirty_param('type') || $pxt->pnotes('type') || 'M';
  my $block = $params{__block__};
  my ($site) = $user->sites($type);

  unless ($site && $site->site_city && $site->site_state && $site->site_zip) {
    #($site) = $user->sites('M');
    my $link = PXT::HTML->link("edit_address.pxt?type=$type&amp;uid=$uid", 'Add this address');
    my $html = qq(<div>\n<strong>(Address not filled out)</strong></div>);
    $html .= qq(<div>\n$link\n</div>\n);

    return $html;
  }

  if ($user->id == $pxt->user->id) {
    if ($type eq 'M' and $pxt->uri =~ m(/network/account/edit_address.pxt) and $site and ($site->site_city eq '.' or $site->site_address1 eq '.')) {
      $pxt->push_message(site_info => 'Please take a moment and complete the information below for our records.');

      $site->$_('')
	foreach qw/site_address1 site_address2 site_address3 site_city site_state site_zip site_fax site_phone/;
    }
  }

  my %subst;

  my $site_addr = '';
  $site_addr .= $site->$_() ? PXT::Utils->escapeHTML($site->$_()) . '<br />' : ''
    foreach qw/site_address1 site_address2 site_address3/;

  $subst{site_address} = $site_addr;

  my $site_city = $site->site_city() || '';
  my $site_state = $site->site_state() || '';
  my $site_zip = $site->site_zip() || '';

  my $site_city_state_zip = $site_city ne '' ? "$site_city, $site_state" : $site_state;
  $site_city_state_zip .= $site_zip ? " $site_zip" : '';

  $subst{site_city_state_zip} = PXT::Utils->escapeHTML($site_city_state_zip);

  $subst{user_id} = $user->id;

  $subst{site_type} = $type;

  $subst{$_} = $site->$_() ? PXT::Utils->escapeHTML($site->$_()) || '' : ''
    foreach qw/site_phone site_fax/;

  return PXT::Utils->perform_substitutions($block, \%subst);
}


my @required_map =
  ( 'login' => 'Username',
    'password1' => 'Password',
    'password2' => 'Password Confirmation',
    'account_type' => 'Account Type',
    'prefix' => 'Title',
    'first_names' => 'First Name',
    'last_name' => 'Last Name',
    'email' => 'E-mail Address',
  );

unless (PXT::Config->get('satellite')) {
  push @required_map, ('address1' => 'Mailing Address',
		       'city' => 'City',
		       'zip' => 'Zip Code',
		       'phone' => 'Phone');

}

my %required_map = @required_map;
my @required_fields = map { $_ & 1 ? () : $required_map[$_] } 0..$#required_map;

# sort timezones, making the listed ones pop to the top
sub timezone_sort {
  my $class = shift;
  my @zones = @_;

  my $i = 10;
  my %preferred_zones =
    map { $_ => --$i }
      ( "United States (Eastern)",
	"United States (Central)",
	"United States (Indiana)",
	"United States (Mountain)",
	"United States (Arizona)",
	"United States (Pacific)",
	"United States (Alaska)",
	"United States (Hawaii)" );

  # now we we-order the timezones based on a random, euro-centric hueristic
  @zones =
    sort {
      my $a_name = $a->{DESCRIPTION};
      my $b_name = $b->{DESCRIPTION};
      my $a_score = $preferred_zones{$a_name} || -1;
      my $b_score = $preferred_zones{$b_name} || -1;

      return ($b_score <=> $a_score) || ($a->{OFFSET} <=> $b->{OFFSET}) || ($a_name cmp $b_name);
    } @zones;

  return @zones;
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

sub validate_user {
  my $pxt = shift;

  my @param_list = (qw/password1 password2 prefix first_names last_name/,
		    qw/genqual parent_company company title phone fax email pin/,
		    qw/first_names_ol last_name_ol address1 address2 city state zip country/,
		    qw/contact_call contact_email contact_fax contact_mail account_type education_account/);

  my %user_params = map { ("${_}" => ($pxt->dirty_param($_) || '')) } @param_list;
  $user_params{login} = $pxt->passthrough_param('login') || '';

  $user_params{alt_first_names} = $user_params{first_names};
  $user_params{alt_last_name} = $user_params{last_name};
  $user_params{$_} = $user_params{$_} ? 'Y' : 'N'
    foreach qw/contact_call contact_email contact_fax contact_mail/;

  $user_params{$_} =~ s/^\s+// foreach keys %user_params;
  $user_params{$_} =~ s/\s+$// foreach keys %user_params;

  my ($min_username, $max_username) = (PXT::Config->get('min_user_len'), PXT::Config->get('max_user_len'));


#-- BEGIN BASIC VALIDATION
  my $validator = 'valid';

  if (length $user_params{login} < $min_username) {
    PXT::Debug->log(7, "username too short");
    $pxt->push_message(local_alert =>"Usernames must be no shorter than $min_username characters.");
    $validator = 'invalid';
  }
  if (length $user_params{login} > $max_username) {
    PXT::Debug->log(7, "username too long");
    $pxt->push_message(local_alert =>"Usernames must be no longer than $max_username characters.");
    $validator = 'invalid';
  }

  if ( ( $user_params{login} !~ /^[\x20-\x7e]+$/ ) or ( $user_params{login} =~ /[&+\s%'`=#"]/ ) ) { #'
    PXT::Debug->log(7, "invalid login chars");
    $pxt->push_message(local_alert =>'The specified user name contains invalid characters. Please use alphanumeric characters.');
    $validator = 'invalid';
  }

  if (not PXT::Config->get('satellite')) {
    if ($user_params{login} =~ /\@redhat\.com$/i) {
      $pxt->push_message(local_alert => 'Usernames may not be of the form "*@redhat.com"');
      $validator = 'invalid';
    }
  }

  if ($user_params{education_account}) {
    unless ($user_params{company}) {
      $pxt->push_message(local_alert => 'You must enter a school.');
      $validator = 'invalid';
    }

    unless ($user_params{title}) {
      $pxt->push_message(local_alert => 'You must enter a grade, year, or position.');
      $validator = 'invalid';
    }
  }

  if ($user_params{account_type} eq 'create_corporate') {

    unless ($user_params{company}) {
      $pxt->push_message(local_alert => 'You must enter your company name.');
      $validator = 'invalid';
    }
  }

  my @missing;
  foreach my $field (@required_fields) {
    push @missing, $field if $user_params{$field} =~ /^\s*$/;
  }

  if (@missing) {
    my $msg = "The following fields are required to create or modify an account: <br />";
    if (@missing > 1) {
      $msg .= join(", ", @required_map{@missing[0..$#missing - 1]}) . ", and " . $required_map{$missing[-1]};
    }
    else {
      $msg .= $required_map{$missing[0]};
    }

    PXT::Debug->log(7, "missing fields");
    $pxt->push_message(local_alert =>$msg);
    $validator = 'invalid';
  }

  if (not Mail::RFC822::Address::valid($user_params{email})) {
    $pxt->push_message(local_alert =>'Email address is not valid.');
    $validator = 'invalid';
    # no need to display a message twice for invalid and dupe emails.
  }

  if ($user_params{country} eq 'US' and not $user_params{state}) {
    PXT::Debug->log(7, "no state");
    $pxt->push_message(local_alert =>'State is required for US citizens.');
    $validator = 'invalid';
  }

  if (length $user_params{password1} < 5) {
    PXT::Debug->log(7, "password short");
    $pxt->push_message(local_alert =>'Passwords must be at least 5 characters long.');
    $validator = 'invalid';
  }

  if (length $user_params{password1} > 32) {
    PXT::Debug->log(7, "password long");
    $pxt->push_message(local_alert =>'Passwords must be shorter than 32 characters long.');
    $validator = 'invalid';
  }

  if ($user_params{password1} ne $user_params{password2}) {
    PXT::Debug->log(7, "passwords don't match");
    $pxt->push_message(local_alert =>'Your passwords do not match; please re-confirm your password of choice.');
    $validator = 'invalid';
  }

  if ($user_params{account_type} eq 'into_org') {
    unless ($pxt->user->is('org_admin')) {
      PXT::Debug->log(7, "not an org admin");
      $pxt->push_message(local_alert =>'Only an Org Admin can add a user');
      $validator = 'invalid';
    }
  }

  $user_params{password} = $user_params{password1};

  PXT::Debug->log(7, "validator: $validator");

  return if $validator eq 'invalid';

  return \%user_params;
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
  #coma_author, coma_publisher, org_admin, org_applicant, or rhn_superuser.
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

sub default_system_groups_cb {
  my $pxt = shift;

  my $form = build_default_system_groups_form($pxt);
  my $response = $form->prepare_response;

  my $errors = Sniglets::Forms::load_params($pxt, $response);

  if (@{$errors}) {
    foreach my $error (@{$errors}) {
      $pxt->push_message(local_alert => $error);
    }
    return;
  }

  my @groups = $response->lookup_widget('default_system_groups')->value;

  if (ref $groups[0] eq 'ARRAY') {
    @groups = @{$groups[0]};
  }

  my $uid = $pxt->param('uid');
  my $user = RHN::User->lookup(-id => $uid);

  my @old_groups = $user->default_system_groups;
  $user->set_default_system_groups(@groups);

  if (RHN::Utils::sets_differ(\@groups, \@old_groups)) {
    $pxt->push_message(site_info => sprintf('Default system groups updated for <strong>%s</strong>.', $user->login));
  }

  my $url = $pxt->uri;
  $pxt->redirect($url . "?uid=" . $user->id);

  return;
}

sub build_default_system_groups_form {
  my $pxt = shift;
  my %attr = @_;

  my $form = new RHN::Form::ParsedForm(name => 'Default System Groups',
				       label => 'default_system_groups',
				       action => $attr{action},
				      );

  my $group_selectbox = new RHN::Form::Widget::Select(name => 'Default System Groups',
						      label =>'default_system_groups', 
						      multiple => 1,
						      size => 4);

  my $uid = $pxt->param('uid');
  my $user = RHN::User->lookup(-id => $uid);

  my $group_perms_ds = new RHN::DataSource::SystemGroup(-mode => 'user_permissions');
  my $data = $group_perms_ds->execute_full(-formvar_uid => $uid, -org_id => $user->org_id);

  foreach my $group ( @{$data} ) {
    my $name = $group->{GROUP_NAME};
    my $id = $group->{ID};

    if ($group->{HAS_PERMISSION}) {
      $name = '(*) ' . $name;
    }

    $group_selectbox->add_option( {value => $id,
				   label => $name,
				  } );
  }

  $group_selectbox->value([ $user->default_system_groups ]);

  unless (@{$data}) { #no system groups in org
    $form->add_widget( new RHN::Form::Widget::Literal(name => 'Default System Groups', value => '<strong>Your organization has no system groups.</strong>') );
    return $form;
  }

  $form->add_widget($group_selectbox);
  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'uid', value => $user->id) );
  $form->add_widget( new RHN::Form::Widget::Hidden(name => 'pxt:trap', value => 'rhn:user_default_system_groups_cb') );
  $form->add_widget( new RHN::Form::Widget::Submit(name => 'Update Defaults') );

  return $form;
}

1;
