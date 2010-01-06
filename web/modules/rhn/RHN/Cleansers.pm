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

package RHN::Cleansers;

use strict;

use RHN::Exception qw/throw/;
use Apache2::RequestUtil ();
use PXT::Config;

use Params::Validate qw/:all/;

# Methods to verify access control to various objects by a user.

# A cleanser is called when a parameter is received by pxt.  The
# cleanser checks to ensure that the current user has permissions to
# the object specified.  The value of the param is almost always an
# 'id' - a primary key to an object in the RHN db.

# In the 'register_cleanser' calls, there will either be an
# 'accessmethod', which is the name of a method o the user object, or
# a 'test', which is a function reference.  For either type, the
# function is called with the current user, and the value(s) of the
# param.  The function should return 1 for pass, and 0 for fail.

# So when a URL such as 'systems.pxt?sid=1234' is requested, the
# 'verify_system_access' method of the current RHN::User object is
# called, with the '1234' passed in.  If it fails, it is marked.  If
# the code on the page or on the callback subsequently calls
# $pxt->param('sid'), then an exception is thrown.  An exception will
# also be thrown if the code calls $pxt->dirty_param('sid').
# $pxt->passthrough_param('sid') can be used for both kinds of
# parameters, but should only be used if you aren't sure what
# parameters will be used.

my %secure_params;

# older stuff
register_cleanser(-var => 'sid', -name => 'system', -accessmethod => 'verify_system_access');
register_cleanser(-var => 'sgid', -name => 'system group', -accessmethod => 'verify_system_group_access');
register_cleanser(-var => 'aid', -name => 'action', -accessmethod => 'verify_action_access');
register_cleanser(-var => 'hid', -name => 'history event', -accessmethod => 'verify_action_access');
register_cleanser(-var => 'cid', -name => 'channel', -test => \&verify_channel);
register_cleanser(-var => 'channel_label', -name => 'channel', -test => \&verify_channel_label);
register_cleanser(-var => 'cfam_id', -name => 'channel_family', -accessmethod => 'verify_cfam_access');
register_cleanser(-var => 'view_channel', -name => 'channel', -test => \&verify_viewed_channel);
register_cleanser(-var => 'current_channel', -name => 'channel', -accessmethod => 'verify_channel_access');
register_cleanser(-var => 'additional_channel', -name => 'channel', -accessmethod => 'verify_channel_access');
register_cleanser(-var => 'tid', -name => 'token', -accessmethod => 'verify_token_access');
register_cleanser(-var => 'oid', -name => 'order', -accessmethod => 'verify_order_access');
register_cleanser(-var => 'eid', -name => 'errata', -test => \&verify_errata);
register_cleanser(-var => 'advisory', -name => 'errata', -test => \&verify_errata_advisory);
register_cleanser(-var => 'pid', -name => 'package', -accessmethod => 'verify_package_access');
register_cleanser(-var => 'uid', -name => 'user', -accessmethod => 'verify_user_admin');
register_cleanser(-var => 'login', -name => 'user', -accessmethod => 'verify_user_admin_by_login');
register_cleanser(-var => 'sguid', -name => 'user', -accessmethod => 'verify_system_group_user_admin');
register_cleanser(-var => 'nid', -name => 'note', -accessmethod => 'verify_note_access');
register_cleanser(-var => 'prid', -name => 'system profile', -accessmethod => 'verify_system_profile_access');


# provisioning stuff
register_cleanser(-var => 'ccid', -name => 'namespace', -accessmethod => 'verify_config_channel_access');
register_cleanser(-var => 'cfid', -name => 'configfile', -accessmethod => 'verify_config_file_access');
register_cleanser(-var => 'crid', -name => 'configfile', -accessmethod => 'verify_config_revision_access');
register_cleanser(-var => 'ckid', -name => 'cryptokey', -accessmethod => 'verify_crypto_key_access');
register_cleanser(-var => 'target_crid', -name => 'configfile', -accessmethod => 'verify_config_revision_access');
register_cleanser(-var => 'acrid', -name => 'actionconfigrevision', -accessmethod => 'verify_actionconfigrevision_access');
register_cleanser(-var => 'cikid', -name => 'configfile', -accessmethod => 'verify_custominfokey_access');
register_cleanser(-var => 'ksid', -name => 'kickstart', -accessmethod => 'verify_kickstart_access');
register_cleanser(-var => 'kssid', -name => 'kickstart_session', -accessmethod => 'verify_kickstart_session_access');
register_cleanser(-var => 'kstid', -name => 'kickstartable tree', -accessmethod => 'verify_kickstartabletree_access');
register_cleanser(-var => 'ss_id', -name => 'snapshot', -accessmethod => 'verify_snapshot_access');
register_cleanser(-var => 'tag_id', -name => 'tag', -accessmethod => 'verify_tag_access');
register_cleanser(-var => 'sync_sid', -name => 'system', -accessmethod => 'verify_system_access');


# monitoring stuff
register_cleanser(-var => 'probe_id', -name => 'probe', -accessmethod => 'verify_probe_access');
register_cleanser(-var => 'cmid', -name => 'contact method', -accessmethod => 'verify_contact_method_access');
register_cleanser(-var => 'cgid', -name => 'contact group', -accessmethod => 'verify_contact_group_access');
register_cleanser(-var => 'scout_id', -name => 'scout', -accessmethod => 'verify_scout_access');

# support/tools/other
register_cleanser(-var => 'support_org_id', -name => 'supported org', -test => \&verify_support_var_access);
register_cleanser(-var => 'support_uid', -name => 'supported user', -test => \&verify_support_var_access);
register_cleanser(-var => 'support_sid', -name => 'supported system', -test => \&verify_support_var_access);
register_cleanser(-var => 'support_hid', -name => 'supported history event', -test => \&verify_support_var_access);
register_cleanser(-var => 'fid', -name => 'customer feedback', -test => \&verify_support_var_access);
register_cleanser(-var => 'flid', -name => 'file list', -accessmethod => 'verify_filelist_access');

#pkg/iso redirect
register_cleanser(-var => 'iso_path', -name => 'akamai file path', -accessmethod => 'verify_file_access');

sub register_cleanser {
  my %attr = validate_with(params => \@_,
			   spec => { var => { type => SCALAR },
				    name => { type => SCALAR },
				    test => { type => CODEREF, optional => 1 },
				    accessmethod => { type => SCALAR, optional => 1 } },
			   strip_leading => '-');

  my ($var, $name, $test, $access, $admin) = @attr{qw/var name test accessmethod/};

  if (exists ($secure_params{$var})) {
    throw "Duplicate cleanser registration: '$var'";
  }

  unless ($test or $access) {
    throw "No test or access param for cleanser registration: '$var'";
  }

  $secure_params{$var} = { name => $name, test => $test, accessmethod => $access };
}

sub secure_params { return keys %secure_params }

sub securable_param {
  my ($class, $var) = @_;
  return exists $secure_params{$var} ? 1 : 0;
}

sub cleanse {
  my $class = shift;
  my $pxt = shift;

  unless ($pxt->user and $pxt->user->isa('RHN::DB::User')) {
    return;
  }

  foreach my $var ($pxt->param) {
    my ($varname, $checkname);
    if ($var =~ /^(.*)_\d+$/) {
      $varname = $var;
      $checkname = $1;
    }
    else {
      $varname = $var;
      $checkname = $var;
    }

    my @vals = $pxt->{apr}->param($var);
    my $pass = $class->check_param($pxt->user, $checkname, @vals);

    if (not defined $pass) {
      # noop -- undef return means there's no cleanser
    }
    elsif ($pass) {
      $pxt->cleanse_param($varname);
    }
    else {
      $pxt->fail_param($varname, sprintf("[SECURITY] User %s (%d) has no access to %s '%s'",
					 $pxt->user->login, $pxt->user->id,
					 $secure_params{$checkname}->{name} . (scalar @vals == 1 ? '' : 's'),
					 join(", ", @vals)));
    }
  }
}

sub check_param {
  my $class = shift;
  my $user = shift;
  my $checkname = shift;
  my @vars = @_;

  if (exists $secure_params{$checkname}) {
    my $test = $secure_params{$checkname}->{test};
    my $accessmethod = $secure_params{$checkname}->{accessmethod};

    if (ref $test eq 'CODE') {
      return $secure_params{$checkname}->{test}->($user, @vars);
    }
    else {
      return $user->$accessmethod(@vars);
    }
  }
  else {
    return;
  }

}

sub verify_channel {
  my $user = shift;
  my @channels = @_;

  my $context = Apache2::RequestUtil->request->server->dir_config('channel_context') || '';
  if ($context eq 'manage') {
    return 0 unless $user->verify_channel_admin(@channels);
  }

  return $user->verify_channel_access(@channels);
}

sub verify_channel_label {
  my $user = shift;
  my @channels = @_;

  my @cids = map { RHN::Channel->channel_id_by_label($_) } @channels;

  my $context = Apache2::RequestUtil->request->server->dir_config('channel_context') || '';
  if ($context eq 'manage') {
    return 0 unless $user->verify_channel_admin(@cids);
  }

  return $user->verify_channel_access(@cids);
}


sub verify_viewed_channel {
  my $user = shift;
  my @channels = @_;

  foreach my $cid (@channels) {
    $cid =~ tr/0-9//cd;
  }

  return 0 unless $user->verify_channel_access(@channels);

  return 1;
}

sub verify_errata {
  my $user = shift;
  my @errata = @_;

  my $context = Apache2::RequestUtil->request->server->dir_config('errata_context') || '';
  if ($context eq 'manage') {
    return 0 unless $user->verify_errata_admin(@errata);
  }

  return $user->verify_errata_access(@errata);
}

sub verify_errata_advisory {
  my $user = shift;
  my @errata = @_;

  my @ids;
  foreach my $advisory (@errata) {
    my ($type, $version) = split /-/, $advisory;
    my @matches = RHN::Errata->find_by_advisory(-type => $type, -version => $version);

    push @ids, map { $_->[0] } @matches;
  }

  return $user->verify_errata_access(@ids);
}

sub verify_support_var_access {
  my $user = shift;

  throw "Value '$user' is not a user." unless (ref $user and $user->isa('RHN::DB::User'));

  my @vars = grep { defined $_ } @_;

  return 1 unless @vars;
  return 1 if $user->is('rhn_support');

  return 0;
}
