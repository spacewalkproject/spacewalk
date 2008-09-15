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

package Sniglets::Manzier;

use RHN::SessionSwap;
use Digest::HMAC_SHA1 qw/hmac_sha1_hex/;
use RHN::Exception;
use RHN::User;

sub register_xmlrpc {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_xmlrpc('uids_by_login_prefix', \&uids_by_login_prefix);

  $pxt->register_xmlrpc('uid_by_login', \&uid_by_login);
  $pxt->register_xmlrpc('uid_by_order', \&uid_by_order);
  $pxt->register_xmlrpc('uid_by_customer_number', \&uids_by_customer_number);

  $pxt->register_xmlrpc('customer_details', \&org_details);
  $pxt->register_xmlrpc('user_details', \&user_details);
  $pxt->register_xmlrpc('user_site_details', \&user_site_details);

  $pxt->register_xmlrpc('orders_by_uid', \&orders_by_uid);
  $pxt->register_xmlrpc('products_by_uid', \&products_by_uid);
  $pxt->register_xmlrpc('orders_by_oid', \&orders_by_oid);
  $pxt->register_xmlrpc('products_by_oid', \&products_by_oid);
}

sub validate_token {
  my $class = shift;

  my ($time, $token) = split /[|]/, shift;
  my $key = "680297fc5e5d2d6b4c54e59041634d081f084800c602920396792aa3ef025617a711bb46eca7dbf8fe5e6a269d1cad6c965b1469d512585dd84cb64d0c92bb89";

  if (hmac_sha1_hex($time, $key) ne $token) {
    throw "mismatch on token '$token'";
  }

  if (time > $time + 120) {
    throw 'Auth credentials expired';
  }
}

sub uid_by_login {
  my $pxt = shift;
  my %params = @_;

  Sniglets::Manzier->validate_token($params{token});

  my $login = $params{login};

  my $user = RHN::User->lookup(-username => $login);

  if ($user) {
    return $user->id;
  }
  else {
    return 0;
  }
}

sub uids_by_login_prefix {
  my $pxt = shift;
  my %params = @_;

  Sniglets::Manzier->validate_token($params{token});

  my $login = $params{login};

  return [ RHN::User->uids_by_login_prefix($login) ];
}

sub uid_by_order {
  my $pxt = shift;
  my %params = @_;

  Sniglets::Manzier->validate_token($params{token});

  my $order = $params{order};

  my $user = RHN::User->lookup(-order => $order);

  if ($user) {
    return $user->id;
  }
  else {
    return 0;
  }
}

sub uids_by_customer_number {
  my $pxt = shift;
  my %params = @_;

  Sniglets::Manzier->validate_token($params{token});

  my $custnum = $params{custnum};

  my @ret = RHN::Org->support_user_overview(-custnum => $custnum);

  return \@ret;
}

sub orders_by_uid {
  my $pxt = shift;
  my %params = @_;

  Sniglets::Manzier->validate_token($params{token});

  my $uid = $params{uid};

  my @ret = RHN::User->orders_for_user($uid);

  return \@ret;
}

sub products_by_uid {
  my $pxt = shift;
  my %params = @_;

  Sniglets::Manzier->validate_token($params{token});

  my $uid = $params{uid};

  my @ret = RHN::User->products_for_user($uid);

  return cleanup_returns(\@ret);
}

sub orders_by_oid {
  my $pxt = shift;
  my %params = @_;

  Sniglets::Manzier->validate_token($params{token});

  my $oid = $params{oid};

  my @ret = RHN::Org->orders_for_org($oid);

  return cleanup_returns(\@ret);
}

sub products_by_oid {
  my $pxt = shift;
  my %params = @_;

  Sniglets::Manzier->validate_token($params{token});

  my $oid = $params{oid};

  my @ret = RHN::Org->products_for_org($oid);

  return cleanup_returns(\@ret);
}

sub user_details {
  my $pxt = shift;
  my %params = @_;

  Sniglets::Manzier->validate_token($params{token});

  my $uid = $params{uid};

  my $user = RHN::User->lookup(-id => $uid);

  my @ret;
  if ($user) {
    @ret = ($user->id, $user->login, $user->org_id, $user->oracle_contact_id, $user->org->oracle_customer_number,
	    $user->first_names, $user->last_name, $user->company, $user->title,
	    $user->phone, $user->fax, $user->email);
  }

  return cleanup_returns(\@ret);
}

sub org_details {
  my $pxt = shift;
  my %params = @_;

  Sniglets::Manzier->validate_token($params{token});

  my $oid = $params{oid};
  my $custnum = $params{custnum};
  if ($custnum =~ /\D/) {
    my $user = RHN::User->lookup(-username => $custnum);

    return [] unless $user and $user->org->oracle_customer_number;

    $custnum = $user->org->oracle_customer_number;
  }

  my $org = RHN::Org->lookup($oid ? (-id => $oid) : (-customer_number => $custnum));

  if ($org) {
    return [$org->id, $org->name, $org->oracle_customer_id, $org->oracle_customer_number, $org->customer_type];
  }
  else {
    return [];
  }
}

sub user_site_details {
  my $pxt = shift;
  my %params = @_;

  Sniglets::Manzier->validate_token($params{token});

  my $uid = $params{uid};

  my $user = RHN::User->lookup(-id => $uid);

  my @ret;
  foreach my $site ($user->sites) {
    push @ret, [ $site->site_type, $site->site_modified, $site->site_address1, $site->site_address2, $site->site_address3,
	         $site->site_city, $site->site_state, $site->site_zip, $site->site_country, $site->site_phone, $site->site_fax,
	       ];
  }

  return cleanup_returns(\@ret);
}

sub cleanup_returns {
  my $value = shift;

  if (ref $value and ref $value eq 'ARRAY') {
    return [ map { cleanup_returns($_) } @$value ];
  }

  if (not defined $value) {
    return '';
  }

  return $value;
}

1;
