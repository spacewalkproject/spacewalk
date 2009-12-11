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

package RHN::DB::User;

use Authen::PAM;
use Carp;
use Data::Dumper;
use Date::Parse;
use POSIX;
use Apache2::RequestUtil ();

use Params::Validate;
Params::Validate::validation_options(strip_leading => "-");

use PXT::Utils;
use PXT::Config;

use RHN::DB;
use RHN::Org;
use RHN::Date;
use RHN::DB::TableClass;
use RHN::DB::JoinClass;
use RHN::EmailAddress;
use RHN::CustomInfoKey;
use RHN::FileList;
use RHN::SystemSnapshot;
use RHN::Tag;
use RHN::KSTree;

use RHN::Exception qw/throw/;

my @contact_fields = qw/ID ORG_ID LOGIN LOGIN_UC PASSWORD OLD_PASSWORD ORACLE_CONTACT_ID IGNORE_FLAG/;

my @pi_fields = (qw/PREFIX FIRST_NAMES LAST_NAME GENQUAL PARENT_COMPANY COMPANY TITLE/,
		 qw/PHONE FAX EMAIL PIN CREATED:longdate MODIFIED FIRST_NAMES_OL LAST_NAME_OL GENQUAL_OL/,
		 qw/PARENT_COMPANY_OL COMPANY_OL TITLE_OL/,
		 qw/WEB_USER_ID/
		);

my @contact_info_fields = (qw/WEB_USER_ID EMAIL MAIL CALL FAX/);

my @site_fields = (qw/ID WEB_USER_ID EMAIL ALT_FIRST_NAMES ALT_LAST_NAME ADDRESS1 ADDRESS2 ADDRESS3 CITY/,
		   qw/STATE ZIP COUNTRY PHONE FAX URL IS_PO_BOX TYPE ORACLE_SITE_ID NOTES CREATED/,
		   qw/MODIFIED ADDRESS4 ALT_FIRST_NAMES_OL ALT_LAST_NAME_OL ADDRESS1_OL ADDRESS2_OL/,
		   qw/ADDRESS3_OL CITY_OL STATE_OL ZIP_OL/);

my $o = new RHN::DB::TableClass("web_contact", "U", "", @contact_fields);
my $p = new RHN::DB::TableClass("WEB_USER_PERSONAL_INFO", "P", "", @pi_fields);
my $c = new RHN::DB::TableClass("WEB_USER_CONTACT_PERMISSION", "C", "contact", @contact_info_fields);
my $s = new RHN::DB::TableClass("WEB_USER_SITE_INFO", "S", "site", @site_fields);


my $j = $o->create_join([ $p, $c ], { "web_contact" => { "web_contact" => [ "ID", "ID" ],
						     "rhnOrganization" => [ "org_id", "ID" ],
						     "WEB_USER_PERSONAL_INFO" => [ "ID", "WEB_USER_ID" ],
						     "WEB_USER_CONTACT_PERMISSION" => [ "ID", "WEB_USER_ID" ] } });

my %method_criteria =
  (login => qr//,
   password => qr//,
   first_names => qr//,
   last_name => qr//);

# given a user id, quickly find the username; several orders of
# magnitude faster than instantiating entire object
sub find_username_fast {
  my $class = shift;
  my $user_id = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare("SELECT login FROM web_contact WHERE id = :user_id");
  $sth->execute_h(user_id => $user_id);

  my ($ret) = $sth->fetchrow;
  $sth->finish;

  return $ret;
}

sub lookup {
  my $class = shift;
  my %params = validate(@_, { id => 0, username => 0, order => 0, contact_method_id => 0 });

  my $dbh = RHN::DB->connect;

  my $query;

  my $sth;
  if (exists $params{username}) {
    $query = $j->select_query("U.login_uc = ?");
#    warn "query: $query";
    $sth = $dbh->prepare($query);
    $sth->execute(uc $params{username});
  }
  elsif (exists $params{id}) {
    $query = $j->select_query("U.id = ?");
    $sth = $dbh->prepare($query);
    $sth->execute($params{id});
  }
  elsif (exists $params{order}) {
    $query = $j->select_query("U.id = (SELECT web_user_id FROM web_user_order WHERE id = ?)");
    $sth = $dbh->prepare($query);
    $sth->execute($params{order});
  }
  elsif (exists $params{contact_method_id}) {
    $query = $j->select_query("U.id = (SELECT contact_id FROM rhn_contact_methods WHERE recid = ?)");
    $sth = $dbh->prepare($query);
    $sth->execute($params{contact_method_id});
  }
  else {
    local $" = ", ";
    die "$class->lookup_user(@_) error: neither -username nor -id provided for lookup";
  }

  my @columns = $sth->fetchrow;
  $sth->finish;

  my $ret;
  if ($columns[0]) {
    $ret = $class->_blank_user;

    $ret->{__id__} = $columns[0];
    $ret->{"__" . $_ . "__"} = shift @columns foreach $j->method_names;
    delete $ret->{":modified:"};
  }
  else {
    return undef;
  }

  $query = <<EOQ;
SELECT  DISTINCT UGT.label
  FROM  rhnUserGroupMembers UGM, rhnUserGroupType UGT, rhnUserGroup UG
 WHERE  UGM.user_id = ?
   AND  UGM.user_group_id = UG.id
   AND  UGT.id = UG.group_type
EOQ
  $sth = $dbh->prepare($query);
  $sth->execute($ret->id);

  my %roles;
  while (my ($role) = $sth->fetchrow) {
    $roles{$role} = 1;
  }

  # Is org-admin one of these roles?  If so, push channel-admin on to the
  # role stack if it isn't there already.  This same mechanism can be used
  # any time we want the org_admin role to imply another role.

  my %implied = map { $_ => 1 } 
      qw/channel_admin config_admin system_group_admin activation_key_admin monitoring_admin/;
  if (exists $roles{org_admin}) {
    for my $role ($ret->org->available_roles) {
      if (exists $implied{$role}) {
	$roles{$role} = 1;
      }
    }
  }

  # the cert admin role implies rhn_support
  my $implied_cert_admin_role = 'rhn_support';
  if(exists $roles{cert_admin}) {
    if (grep { $implied_cert_admin_role eq $_ } $ret->org->available_roles) {
      $roles{$implied_cert_admin_role} = 1;
    }
  }
  
  $ret->roles(keys %roles);

  return $ret;
}

# walks a user's sets to ensure nothing has corrupted them... hopefully isn't too expensive
sub cleanse_sets {
  my $self = shift;


  # server sets
  my @server_sets = (qw/system_list entitled_system_list inprogress_system_list removable_system_list/,
		     qw/remove_systems_list system_search system_search_prev target_systems target_systems_list/,
		    );
  my $dbh = RHN::DB->connect();
  my $query = <<EOQ;
DELETE FROM rhnSet
 WHERE user_id = :user_id
   AND label = :label
   AND NOT EXISTS (SELECT 1 FROM rhnUserServerPerms WHERE user_id = :user_id and server_id = element)
EOQ

  my $sth = $dbh->prepare($query);

  foreach my $set_label (@server_sets) {
    $sth->execute_h(user_id => $self->id, label => $set_label);
  }

  $dbh->commit;
}


sub _change_user_state {
  my $self = shift;
  my $doer_id = shift;
  my $state_label = shift;

  my $transaction = shift;

  my $dbh = $transaction || RHN::DB->connect();

  my $query = <<EOQ;
INSERT INTO rhnWebContactChangelog (id, web_contact_id, web_contact_from_id, change_state_id)
SELECT rhn_wcon_disabled_seq.nextval, :target_id, :doer_id, id
  FROM rhnWebContactChangeState
 WHERE label = :state_label
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute_h(target_id => $self->id, doer_id => $doer_id, state_label => $state_label);

  unless ($transaction) {
    $dbh->commit;
  }

  return $transaction;
}

sub disable_user {
  my $self = shift;
  my $doer_id = shift;

  return $self->_change_user_state($doer_id, 'disabled');
}

sub enable_user {
  my $self = shift;
  my $doer_id = shift;

  return $self->_change_user_state($doer_id, 'enabled');
}


sub delete_user {
  my $class = shift;
  my $user_id = shift;

  die "no user_id" unless $user_id;

  my $dbh = RHN::DB->connect();

  $dbh->call_procedure('rhn_org.delete_user', $user_id);
}


# queues up a user to be deleted/disabled
sub request_deactivation {
  my $self = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare("INSERT INTO rhnUserDeletionQueue (user_id) VALUES (?)");

  $sth->execute($self->id);
  $dbh->commit;
}


sub create_custom_data_key {
  my $self = shift;
  my %params = validate(@_, {label => 1, description => 1});

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
INSERT INTO rhnCustomDataKey (id, org_id, label, description, created_by, last_modified_by)
VALUES (rhn_cdatakey_id_seq.nextval, :org_id, :label, :description, :user_id, :user_id)
EOQ
  $sth->execute_h(user_id => $self->id,
		  org_id => $self->org_id,
		  label => $params{label},
		  description => $params{description},
		 );

  $dbh->commit;
}



sub roles {
  my $self = shift;

  if (@_) {
    $self->{__roles__} = [ @_ ];
  }

  return @{$self->{__roles__} || []};
}


my %role_cache;

sub rebuild_role_cache {
  my $class = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare('SELECT DISTINCT label, name FROM rhnUserGroupType');
  $sth->execute;

  my @roles;
  while (my ($role, $label) = $sth->fetchrow) {
    push @roles, [ $role, $label ];
  }

  @role_cache{map { $_->[0] } @roles} = map { $_->[1] } @roles;
}

sub is {
  my $self = shift;
  my $role = shift;

  if (not keys %role_cache) {
    $self->rebuild_role_cache;
  }

  my $found = grep { $_ eq $role } $self->roles;

  if ($found) {
    return $found;
  }
  elsif (exists $role_cache{$role}) {
    return 0;
  }
  else {
    die "Invalid role $role; available roles are " . join(", ", sort keys %role_cache);
  }
}

sub role_labels {
  my $self = shift;

  if (not keys %role_cache) {
    $self->rebuild_role_cache;
  }

  return map { $role_cache{$_} } $self->roles;
}

sub _blank_user {
  my $class = shift;

  my $self = bless { }, $class;

  return $self;
}

sub create_new_user {
  my $class = shift;
  my %params = @_;

  my $dbh = RHN::DB->connect;
  my $commit_org = 0;

  # type 'S' (a placeholder for the first satellite user)
  if (exists $params{-customer_type} and $params{-customer_type} eq 'S') {

    # check to be sure we really are running in satellite mode
    die "Attempt to create satellite user when not running a satellite" unless
      PXT::Config->get('satellite');

    # check to be sure the one and only org for this satellite was created
    my $sth = $dbh->prepare('SELECT id FROM web_customer');
    $sth->execute;
    my ($org_id) = $sth->fetchrow;
    if (not defined $org_id) {
      die "Attempt to create satellite user when no orgs exist";
    }

    if ($sth->fetchrow) {
      die "Attempt to create satellite user when more than one org exists";
    }

    $sth->finish;

    # check to be sure there are no other users on this satellite
    $sth = $dbh->prepare('SELECT id FROM web_contact');
    $sth->execute;
    my ($existing_user) = $sth->fetchrow;
    $sth->finish;

    if ($existing_user) {
      die "Attempt to create satellite user when a user already exists";
    }

    $params{-customer_type} = 'P';
    $params{-org_id} = $org_id;
  }

  if (not $params{-org_id} or $params{-org_id} < 1) {
    @params{'-org_id', '-org_admin_group', '-org_app_group'} =
      RHN::Org->create_new_org(-org_name => $params{-org_name} || "$params{-first_names} $params{-last_name}",
			       -org_password => $params{-org_password} || PXT::Utils->random_password(16),
			       -oracle_customer_number => $params{-oracle_customer_number},
			       -oracle_customer_id => $params{-oracle_customer_id},
			       -customer_type => $params{-customer_type} || 'P',
			       -commit => 0);
    $commit_org = 1;
  }


  if (PXT::Config->get('encrypted_passwords')) {
    my $salt = '$1$' . PXT::Utils->generate_salt(8);

    $params{-password} =  crypt($params{-password}, $salt);
  }

  my $sth = $dbh->prepare(<<EOQ);
BEGIN
  :user_id := CREATE_NEW_USER(org_id_in => :org_id, login_in => :login, password_in => :password,
                              oracle_contact_id_in => :oracle_contact_id, prefix_in => :prefix,
                              first_names_in => :first_names, last_name_in => :last_name, genqual_in => :genqual,
                              parent_company_in => :parent_company, company_in => :company, title_in => :title,
                              phone_in => :phone, fax_in => :fax, email_in => :email, pin_in => :pin,
                              first_names_ol_in => :first_names_ol, last_name_ol_in => :last_name_ol,
                              address1_in => :address1, address2_in => :address2, address3_in => :address3,
                              city_in => :city, state_in => :state, zip_in => :zip, country_in => :country,
                              alt_first_names_in => :alt_first_names, alt_last_name_in => :alt_last_name,
                              contact_call_in => :contact_call,
                              contact_mail_in => :contact_mail,
                              contact_email_in => :contact_email,
                              contact_fax_in => :contact_fax);
END;
EOQ

# warn "Param dump for new user: " . Data::Dumper->Dump([\%params]);
  foreach (qw/org_id login password oracle_contact_id prefix/,
	   qw/first_names last_name genqual parent_company company title phone/,
	   qw/fax email pin first_names_ol last_name_ol contact_call/,
	   qw/contact_mail contact_email contact_fax address1 address2 address3/,
	   qw/city state zip country alt_first_names alt_last_name/) {
    $sth->bind_param(":${_}" => $params{"-$_"});
  }

  my $user_id;
  $sth->bind_param_inout(':user_id' => \$user_id, 4096);
  $sth->execute;

  my $ret = RHN::User->lookup(-id => $user_id);
  $dbh->commit;

  if ($commit_org) {
    my $org = RHN::Org->lookup(-id => $params{-org_id});
    $org->oai_customer_sync();
  }

  $ret->oai_contact_sync();

  return $ret;
}

sub create {
  my $class = shift;

  my $user = $class->_blank_user();
  $user->{__id__} = -1;
  $user->{__newly_created__} = 1;

  return $user;
}

# build some accessors
foreach my $field ($j->method_names) {
  my $sub = q {
    sub [[field]] {
      my $self = shift;
      if (@_ and "[[field]]" ne "id" and !("[[field]]"=~ m/web_user_id/)) {
        my $value = shift;
	# die "RHN::DB::User->[[field]] fails criteria" unless $value =~ $method_criteria{[[field]]};
        $self->{":modified:"}->{[[field]]} = 1;
        $self->{__[[field]]__} = $value;
      }
      return $self->{__[[field]]__};
    }
  };

  $sub =~ s/\[\[field\]\]/$field/g;
  eval $sub;

  if ($@) {
    die $@;
  }
}

# and now build some for RHN::DB::UserSite.  READ ONLY accessors
foreach my $field ($s->method_names) {
  my $sub = q {
    sub RHN::DB::UserSite::[[field]] {
      my $self = shift;
      if (@_ and "[[field]]" ne "id") {
        my $value = shift;
	# die "RHN::DB::UserSite->[[field]] fails criteria" unless $value =~ $method_criteria{[[field]]};
        $self->{":modified:"}->{[[field]]} = 1;
        $self->{__[[field]]__} = $value;
      }
      return $self->{__[[field]]__};
    }
  };

  $sub =~ s/\[\[field\]\]/$field/g;
  eval $sub;

  if ($@) {
    die $@;
  }
}

sub users_by_email {
  my $class = shift;
  my $email = shift;

  my $dbh = RHN::DB->connect;
  # WARNING:  This uses an oracle hint.  
  # See BZ 147452 for more info
  my $sth = $dbh->prepare('SELECT /*+ index(wupi_upper_email_idx) */ web_user_id FROM web_user_personal_info WHERE upper(email) = ?');
  $sth->execute(uc($email));

  return $sth->fullfetch;
}

# NOTE: do not use this unless you know you have cleansed any Oracle
# regexps from the input pattern
sub users_like_email {
  my $class = shift;
  my $pattern = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare('SELECT web_user_id FROM web_user_personal_info WHERE email LIKE ?');
  $sth->execute($pattern);

  return $sth->fullfetch;
}

sub full_opt_out {
  my $self = shift;

  $self->contact_email('N');
  $self->contact_mail('N');
  $self->contact_call('N');
  $self->contact_fax('N');
  $self->set_pref('email_notify', '0');

  $self->commit;
}

sub set_password {
  my $self = shift;
  my $new_pw = shift;

  if (PXT::Config->get('encrypted_passwords')) {
    my $salt = '$1$' . PXT::Utils->generate_salt(8);

    $self->password(crypt($new_pw, $salt));
  }
  else {
    $self->password($new_pw);
  }
}

sub validate_password {
  my $self = shift;
  my $pw = shift;

  # first; pam and user has pam enabled?
  if (PXT::Config->get('pam_auth_service') and $self->get_pref('use_pam_authentication') eq 'Y') {
    return $self->validate_password_pam($pw);
  }

  # no pam, okay, auth against the db, encrypted or otherwise
  if (PXT::Config->get('encrypted_passwords')) {
    return crypt($pw, $self->password) eq $self->password;
  }
  else {
    return $pw eq $self->password;
  }
}

# closures would be a pain; simply store it in a global

our $global_pam_pw = undef;

sub pam_conversation_func {
  my @ret;

  die "gruesome death: global_pam_pw is not defined in pam_conversation_func"
    unless defined $global_pam_pw;

  while(@_) {
    my $msg_type = shift;
    my $msg = shift;

    if ($msg_type == Authen::PAM::PAM_ERROR_MSG()) {
      warn "PAM error: $msg";
    }

    if ($msg_type == Authen::PAM::PAM_PROMPT_ECHO_ON() or
	$msg_type == Authen::PAM::PAM_PROMPT_ECHO_OFF()) {
      push @ret, Authen::PAM::PAM_SUCCESS(), $global_pam_pw;
    }
    else {
      push @ret, Authen::PAM::PAM_SUCCESS(), "";
    }
  }

  push @ret, Authen::PAM::PAM_SUCCESS();

  return @ret;
}

sub validate_password_pam {
  my $self = shift;
  my $pw = shift;

  $global_pam_pw = undef;
  local $global_pam_pw = $pw;

  my $service = PXT::Config->get('pam_auth_service');
  my $pam = new Authen::PAM($service, $self->login, \&pam_conversation_func);

  my $ret = $pam->pam_authenticate;

  if ($ret != Authen::PAM::PAM_SUCCESS) {
    warn "PAM auth failure: " . $pam->pam_strerror($ret);
    return 0;
  }
  else {
    return 1;
  }

}

sub org {
  my $self = shift;

  return undef unless $self->org_id;
  return $self->{__orgobj__} if exists $self->{__orgobj__};

  $self->{__orgobj__} = RHN::Org->lookup(-id => $self->org_id);
  return $self->{__orgobj__};
}

sub get_tz_str {
  my $self = shift;

  return RHN::Date->user_short_timezone($self);
}

sub get_timezone {
  my $self = shift;

  my $zone_id = $self->get_pref('timezone_id');
  if (not defined $zone_id) {
    my $olson_name = PXT::Utils->olson_from_offset($self->get_pref('tz_offset'));
    $zone_id = RHN::DB::User->zone_id_from_olson($olson_name);
    $self->set_pref("timezone_id", $zone_id);
  }

  return RHN::DB::User->datetime_from_zone_id($zone_id);
}

sub zone_id_from_olson {
  my $class = shift;
  my $olson_name = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare("SELECT id FROM rhnTimezone WHERE olson_name = :olson");
  $sth->execute_h(olson => $olson_name);
  my ($id) = $sth->fetchrow;
  $sth->finish;

  return $id;
}

sub datetime_from_zone_id {
  my $class = shift;
  my $zone_id = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare("SELECT olson_name FROM rhnTimezone WHERE id = :zone_id");
  $sth->execute_h(zone_id => $zone_id);
  my ($olson) = $sth->fetchrow;
  $sth->finish;

  return new DateTime::TimeZone(name => $olson);;
}

#  converts string to user's preferred timezone string date/time,
#  trying to preserve the original format if possible.  input time is
#  in localtime to the app server and database.
sub convert_time {
  my $self = shift;
  my $old_time = shift;
  my $format = shift;

  throw "no time to convert!" unless $old_time;

  if ($old_time =~ /^\d+$/) {
    throw "convert_time no longer supported on epoch times";
  }

  my $dtime = new RHN::Date(string => $old_time, user => $self);

  my $rv;
  if (defined $format) {
    $rv = $dtime->strftime($format);
  }
  else {
    $rv = $dtime->strftime("%m/%e/%y %l:%M:%S %p") . " " . $dtime->user_short_timezone($self);
  }

  return $rv;
}

my %server_action_names = (
                           'Package List Refresh' => 'package_list_refresh',
                           'Hardware List Refresh' => 'hardware_list_refresh',
                           'Package Install' => 'package_install',
                           'Package Removal' => 'package_removal',
                           'Errata Update' => 'errata_update',
			   'Profile Match' => 'profile_match'
                          );

sub action_list_overview {
  my $self = shift;
  my %params = @_;

  my ($lower, $upper, $total_ref, $mode, $all_ids) =
    map { $params{"-" . $_} } qw/lower upper total_rows mode all_ids/;

  $lower ||= 1;
  $upper ||= 100000;


  my $dbh = RHN::DB->connect;

  my $query;

  if ($mode eq 'pending_actions') {
    $query = <<EOQ;
SELECT  AO.type_name, TO_CHAR(AO.earliest_action, 'YYYY-MM-DD HH24:MI:SS') EARLIEST, AO.total_count, AO.successful_count, AO.failed_count, AO.in_progress_count, AO.action_id, DECODE(AO.name, NULL, AO.type_name, AO.name)
  FROM  rhnActionOverview AO
 WHERE  AO.org_id = ?
   AND  EXISTS (SELECT 1 FROM rhnServerAction SA WHERE SA.action_id = AO.action_id AND status IN (0, 1))
   AND  AO.archived = 0
ORDER BY EARLIEST DESC
EOQ
  }
  elsif ($mode eq 'completed_actions') {
    $query = <<EOQ;
SELECT  AO.type_name, TO_CHAR(AO.earliest_action, 'YYYY-MM-DD HH24:MI:SS') EARLIEST, AO.total_count, AO.successful_count, AO.failed_count, AO.in_progress_count, AO.action_id, DECODE(AO.name, NULL, AO.type_name, AO.name)
  FROM  rhnActionOverview AO
 WHERE  AO.org_id = ?
   AND  EXISTS (SELECT 1 FROM rhnServerAction SA WHERE SA.action_id = AO.action_id AND status = 2)
   AND  AO.archived = 0
ORDER BY EARLIEST DESC
EOQ
  }
  elsif ($mode eq 'failed_actions') {
    $query = <<EOQ;
SELECT  AO.type_name, TO_CHAR(AO.earliest_action, 'YYYY-MM-DD HH24:MI:SS') EARLIEST, AO.total_count, AO.successful_count, AO.failed_count, AO.in_progress_count, AO.action_id, DECODE(AO.name, NULL, AO.type_name, AO.name)
  FROM  rhnActionOverview AO
 WHERE  AO.org_id = ?
   AND  EXISTS (SELECT 1 FROM rhnServerAction SA WHERE SA.action_id = AO.action_id AND status = 3)
   AND  AO.archived = 0
ORDER BY EARLIEST DESC
EOQ
  }
  elsif ($mode eq 'archived_actions') {
    $query = <<EOQ;
SELECT  AO.type_name, TO_CHAR(AO.earliest_action, 'YYYY-MM-DD HH24:MI:SS') EARLIEST, AO.total_count, AO.successful_count, AO.failed_count, AO.in_progress_count, AO.action_id, DECODE(AO.name, NULL, AO.type_name, AO.name)
  FROM  rhnActionOverview AO
 WHERE  AO.org_id = ?
   AND  AO.archived = 1
ORDER BY EARLIEST DESC
EOQ
  }
  else {
    croak 'no supported mode!  mode == '.$mode;
  }

#  warn "Action list query:  $query\n".$self->org_id.", ".$self->login;

  my $sth = $dbh->prepare($query);
  $sth->execute($self->org_id);

  $$total_ref = 0;
  my $i = 1;
  my @actions;
  while (my @action = $sth->fetchrow) {
    $$total_ref = $i;
        push @$all_ids, $action[6] if $all_ids;
    if ($i >= $lower and $i <= $upper) {
#      push @actions, [@action, $server_action_names{$action[0]}];
      $action[1] = $self->convert_time($action[1]);
      push @actions, [ @action ];
    }
    $i++;
  }

  return @actions;
}

sub commit {
  my $self = shift;
  my $dbh = RHN::DB->connect;
  my $sth;
  my @columns_to_use;
  my $mode = 'update';

  if ($self->{__newly_created__}) {
    croak "$self->commit called on newly created object when id != -1\nid == $self->{__id__}" unless $self->{__id__} == -1;
    $sth = $dbh->prepare("SELECT rhn_user_id_seq.nextval FROM DUAL");
    $sth->execute;
    my ($id) = $sth->fetchrow;
    die "No new user id from seq rhn_user_id_seq (possible error: " . $sth->errstr . ")" unless $id;
    $sth->finish;
    $self->{":modified:"}->{id} = 1;
    $self->{__id__} = $id;
    $self->{":modified:"}->{web_user_id} = 1;
    $self->{__web_user_id__} = $id;
    $self->{":modified:"}->{contact_web_user_id} = 1;
    $self->{__contact_web_user_id__} = $id;

    $mode = 'insert';
  }
  die "$self->commit called on user without valid id" unless $self->id;

  my @modified = keys %{$self->{":modified:"}};
  my %modified = map { $_ => 1 } @modified;

  return unless @modified;

  my @queries;

  if ($mode eq 'update') {
    @queries = $j->update_queries($j->methods_to_columns(@modified));
  } else {
    die "can't make new users here";
  }

  foreach my $query (@queries) {
    local $" = ":";
#    carp "update/insert query:  ".$query->[0]."\n";
    my $sth = $dbh->prepare($query->[0]);
    my @vars = ((map { $self->$_() } grep { exists $modified{$_} } @{$query->[1]}), $modified{id} ? () : $self->id);
#    carp "vars:\n" . Data::Dumper->Dump([@vars]);
    $sth->execute(@vars);
  }

  $dbh->commit;
  $self->oai_contact_sync();
}

sub oai_contact_sync {
  my $self = shift;

  if (PXT::Config->get('enable_oai_sync')) {
    my $dbh = RHN::DB->connect;

    $dbh->call_procedure("XXRH_OAI_WRAPPER.sync_contact", $self->id);
    $dbh->commit;
  }
  else {
    # nop
  }
}

sub new_site {
  my $self = shift;
  my $type = shift;

  my $site = bless { }, 'RHN::DB::UserSite';
  $site->{__newly_created__} = 1;
  $site->{__site_id__} = -1;
  $site->site_type($type);
  return $site;
}

# instance OR class method
sub sites {
  my $class = shift;
  my $uid = shift;
  my $type = shift;

  if (ref $class) {
    $type = $uid;
    $uid = $class->id;
  }

  my $dbh = RHN::DB->connect;

  my $type_clause = '';
  $type_clause = "AND TYPE = ?" if $type;

  my $query = $s->select_query("S.WEB_USER_ID = ? $type_clause ORDER BY MODIFIED DESC");
  my $sth = $dbh->prepare($query);
  $sth->execute($uid, $type_clause ? $type : ());

  my @ret;
  while (my @row = $sth->fetchrow) {
    push @ret, bless { map { ("__${_}__" => shift @row) } $s->method_names }, "RHN::DB::UserSite";
  }

  return @ret;
}

sub default_bill_address {
  my $self = shift;

  my $site = ($self->sites('B'))[0] || ($self->sites('M'))[0] || ($self->sites('S'))[0];

  $site = $self->new_site('B') if not $site;

  return $site;
}

# Now an object method because we need a user who owns the set
sub add_users_to_groups {
  my $self = shift;
  my @users = @{+shift};
  my @groups = @{+shift};
  my $pending = shift;

  return unless @users and @groups;

  my $dbh = RHN::DB->connect;

  my $query = "delete from rhnSet where user_id = :user_id and label = :label";
  my $sth0 = $dbh->prepare($query);
  $sth0->execute_h(user_id => $self->id, label => "user_group_list");

  my $sth1 = $dbh->prepare(<<EOQ);
INSERT INTO rhnSet (user_id, label, element, element_two)
    values (:set_owner, 'user_group_list', :user_id, :ugid)
EOQ

  my $pending_group = RHN::Org->org_applicant_group_from_ugid($groups[0]);

  foreach my $user_id (@users) {
    foreach my $group_id (@groups) {
      next if ($pending_group and ($group_id == $pending_group) and (!$pending));
      $sth1->execute_h(set_owner => $self->id, user_id => $user_id, ugid => $group_id);
    }
  }

  $dbh->call_procedure("rhn_user.add_users_to_usergroups", $self->id);
  $sth0->execute_h(user_id => $self->id, label=>"user_group_list");

  $dbh->commit;
}

# Now an object method because we need a user who owns the set
sub remove_users_from_groups {
  my $self = shift;
  my @users = @{+shift};
  my @groups = @{+shift};

  return unless @users and @groups;
  my $dbh = RHN::DB->connect;

  my $query = "delete from rhnSet where user_id = :user_id and label = :label";
  my $sth0 = $dbh->prepare($query);
  $sth0->execute_h(user_id=>$self->id, label=>"user_group_list");

  my $sth1 = $dbh->prepare(<<EOQ);
INSERT INTO rhnSet (user_id, label, element, element_two)
    values (:owner, 'user_group_list', :user_id, :ugid)
EOQ

  for my $user (@users) {
    for my $group (@groups) {
      $sth1->execute_h(owner=>$self->id, user_id=>$user, ugid=>$group);
    }
  }

  $dbh->call_procedure("rhn_user.remove_users_from_servergroups", $self->id);

  $sth0->execute_h(user_id=>$self->id, label=>"user_group_list");
  $dbh->commit;
}

sub group_list_for_user {
  my $self = shift;

  my $dbh = RHN::DB->connect;
  my $query = <<EOS;
  SELECT MAX(DECODE(user_id, ?, 1, 0)), GROUP_ID, GROUP_NAME, GROUP_TYPE
    FROM rhnUserGroupMembership
   WHERE ORG_ID = ?
GROUP BY group_id, group_name, group_type
ORDER BY UPPER(group_name), group_id
EOS

  my $sth = $dbh->prepare($query);
  $sth->execute($self->id, $self->org_id);

  my @ret;
  while (my ($user_member, $id, $name, $group_type) = $sth->fetchrow) {
    push @ret, [ $user_member, $id, $name, $group_type ];
  }

  return @ret;
}


# this crap is foobared.  unfoobar it later.
sub RHN::DB::UserSite::commit {
  my $self = shift;
  my $dbh = RHN::DB->connect;
  my $sth;
  my $mode = 'update';

  if ($self->{__newly_created__}) {
    croak "$self->commit called on newly created object when id != -1\nid == $self->{__site_id__}" unless $self->{__site_id__} == -1;
    $sth = $dbh->prepare("SELECT web_user_site_info_id_seq.nextval FROM DUAL");
    $sth->execute;
    my ($id) = $sth->fetchrow;
    #warn "fetched id == ".$id;
    die "No new usersite id from seq web_user_site_id_seq (possible error: " . $sth->errstr . ")" unless $id;
    $sth->finish;
    $self->{":modified:"}->{site_id} = 1;
    $self->{__site_id__} = $id;

    $mode = 'insert';
  }
  #RHN::DB->objectify_error("$self->commit called on user_site without valid id") unless $self->site_id;

  my @modified = keys %{$self->{":modified:"}};
  my %modified = map { $_ => 1 } @modified;

  return unless @modified;

  my $query;
  if ($mode eq 'update') {
    $query = $s->update_query($s->methods_to_columns(@modified));
    $query .= "S.ID = ?";
  }
  else {
    $query = $s->insert_query($s->methods_to_columns(@modified));
  }

  PXT::Debug->log(7, "user site commit query:  $query");

  $sth = $dbh->prepare($query);
  my @vals = (map { $self->$_() } grep { $modified{$_} } $s->method_names), ($modified{site_id} ? () : $self->site_id);
  $sth->execute(@vals, $mode eq 'insert' ? () : $self->site_id);

  $dbh->commit;
  $self->oai_site_sync();
}

sub RHN::DB::UserSite::oai_site_sync {
  my $self = shift;

  if (PXT::Config->get('enable_oai_sync')) {
    my $dbh = RHN::DB->connect;

    $dbh->call_procedure("XXRH_OAI_WRAPPER.sync_address", $self->site_id);
    $dbh->commit;
  }
  else {
  }
}

sub RHN::DB::UserSite::associated_with_order {
  my $self = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare("SELECT id FROM web_user_order WHERE web_user_id = ? AND (bill_to_contact_id = ? OR ship_to_contact_id = ?)");

  $sth->execute($self->site_web_user_id, $self->site_id, $self->site_id);
  my ($id) = $sth->fetchrow;

  $sth->finish;

  return $id ? 1 : 0;
}

sub selection_details {
  my $self = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare("SELECT label, COUNT(user_id) FROM rhnSet WHERE user_id = ? GROUP BY label ORDER BY label");
  $sth->execute($self->id);

  my @ret;
  while (my @row = $sth->fetchrow) {
    push @ret, [ @row ];
  }

  return @ret;
}

sub clear_selections {
  my $self = shift;
  my @sets_to_skip = @_;

  my $to_skip = join(',', map { "'" . $_ . "'" } @sets_to_skip);

  my $dbh = RHN::DB->connect;
  my $sth;

  if ($to_skip eq '') {
    $sth = $dbh->prepare("DELETE FROM rhnSet WHERE user_id = ?");
  }
  else {
    $sth = $dbh->prepare("DELETE FROM rhnSet WHERE user_id = ? AND label NOT IN ($to_skip)");
  }
  $sth->execute($self->id);

  $dbh->commit;
}

sub verify_probe_access {
  my $self = shift;
  my @probe_ids = @_;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
SELECT probe_id
  FROM rhn_check_probe
 WHERE probe_id = :probe_id
   AND EXISTS (
  SELECT server_id
    FROM rhnUserServerPerms
   WHERE user_id = :user_id
     AND server_id = host_id
)
EOQ

  foreach my $probe_id (@probe_ids) {
    $sth->execute_h(user_id => $self->id, probe_id => $probe_id);

    my ($first_row) = $sth->fetchrow;
    $sth->finish;

    return 0 unless $first_row;
  }

  return 1;
}

sub verify_scout_access {
  my $self = shift;
  my @scout_ids = @_;

  ## N.B. scout_ids are really sat_cluster_ids

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
SELECT recid
  FROM rhn_sat_cluster
 WHERE recid = :scout_id
EOQ

  foreach my $scout_id (@scout_ids) {
    $sth->execute_h(scout_id => $scout_id);

    my ($first_row) = $sth->fetchrow;
    $sth->finish;

    return 0 unless $first_row;
  }

  return 1;
}

sub verify_tag_access {
  my $self = shift;
  my @tag_ids = @_;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare("SELECT id FROM rhnTag WHERE org_id = :org_id AND id = :id");

  foreach my $tag_id (@tag_ids) {
    $sth->execute_h(org_id => $self->org_id, id => $tag_id);

    my ($first_row) = $sth->fetchrow;
    $sth->finish;

    return 0 unless $first_row;
  }

  return 1;
}

sub verify_snapshot_access {
  my $self = shift;
  my @snapshot_ids = @_;

  die "no snapshot ids" unless @snapshot_ids;

  foreach my $snapshot_id (@snapshot_ids) {
    my $snapshot = RHN::SystemSnapshot->lookup(-id => $snapshot_id);
    die "no snapshot for given id $snapshot_id" unless $snapshot;

    return 0 unless $snapshot->org_id == $self->org_id;

    # rhnSnapshot.server_id is nullable...
    my $sid = $snapshot->server_id();
    return 0 if $sid and not $self->verify_system_access($sid);
  }

  return 1;
}

sub verify_custominfokey_access {
  my $self = shift;
  my @key_ids = @_;

  die "no key ids" unless @key_ids;

  foreach my $key_id (@key_ids) {

    my $key = RHN::CustomInfoKey->lookup(-id => $key_id);
    die "no key for given id" unless $key;

    return 0 unless $key->org_id == $self->org_id;
  }

  return 1;
}

sub verify_filelist_access {
  my $self = shift;
  my @filelist_ids = @_;

  die "no file list ids" unless @filelist_ids;

  foreach my $filelist_id (@filelist_ids) {

    my $flid = RHN::FileList->lookup(-id => $filelist_id);
    die "no file list for given id" unless $flid;

    return 0 unless $flid->org_id == $self->org_id;
  }

  return 1;
}


sub verify_system_access {
  my $self = shift;
  return $self->verify_permission_function_helper('rhn_server.check_user_access', $self->id, @_);
}

sub verify_system_group_access {
  my $self = shift;
  my @sg_ids = @_;

  if ($self->is('system_group_admin')) {
    if ($self->org->owns_server_groups(@sg_ids)) {
      return 1;
    }
    else {
      return 0;
    }
  }

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOW);
SELECT 1
  FROM rhnUserManagedServerGroups UMSG
 WHERE UMSG.user_id = ?
   AND UMSG.server_group_id = ?
EOW

  foreach my $sg_id (@sg_ids) {
    $sth->execute($self->id, $sg_id);

    my ($first_row) = $sth->fetchrow;
    $sth->finish;

    return 0 unless $first_row;
  }

  return 1;
}

sub verify_action_access {
  my $self = shift;
  my @action_ids = @_;

  my $dbh = RHN::DB->connect;
   my $sth = $dbh->prepare(<<EOQ);
SELECT  1
  FROM  rhnServerAction SA
 WHERE  SA.action_id = :hid
   AND  EXISTS (SELECT 1 FROM rhnUserServerPerms USP WHERE user_id = :user_id AND server_id = SA.server_id)
UNION ALL
SELECT  1
  FROM  rhnServerHistory SH
 WHERE  SH.id = :hid
   AND  EXISTS (SELECT 1 FROM rhnUserServerPerms USP WHERE user_id = :user_id AND server_id = SH.server_id)
EOQ

  foreach my $action_id (@action_ids) {

    $sth->execute_h(hid => $action_id, user_id => $self->id);

    return 0 unless ($sth->fetchrow);

    $sth->finish;
  }

  return 1;
}

sub verify_permission_function_helper {
  my $self = shift;
  my $function = shift;
  my $test_param = shift;
  my @ids = @_;

  my $dbh = RHN::DB->connect;
  for my $id (@ids) {
    next unless $id;

    my $val = $dbh->call_function($function, $id, $test_param);
    return 0 unless $val;
  }

  return 1;
}

sub verify_channel_access {
  my $self = shift;

  return $self->verify_permission_function_helper('rhn_channel.get_org_access', $self->org_id, @_);
}

sub verify_cfam_access {
  my $self = shift;
  return $self->verify_permission_function_helper('rhn_channel.get_cfam_org_access', $self->org_id, @_);
}

sub verify_channel_subscribe {
  my $self = shift;
  my @channel_ids = @_;

  return 1 if $self->is('rhn_superuser');

  for my $cid (@channel_ids) {
    return 0 unless $self->verify_channel_role($cid, 'subscribe');
  }

  return 1;
}

sub verify_system_profile_access {
  my $self = shift;
  my @profile_ids = @_;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare("SELECT 1 FROM rhnServerProfile WHERE org_id = :org_id AND id = :profile_id");

  foreach my $profile_id (@profile_ids) {
    $sth->execute_h(org_id => $self->org_id, profile_id => $profile_id);

    my ($first_row) = $sth->fetchrow;
    $sth->finish;

    return 0 unless $first_row;
  }

  return 1;
}

sub verify_crypto_key_access {
  my $self = shift;
  my @crypto_key_ids = @_;

  return 0 unless $self->is('config_admin');

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare("SELECT 1 FROM rhnCryptoKey WHERE org_id = ? AND id = ?");

  foreach my $ckid (@crypto_key_ids) {
    next unless $ckid;
    $sth->execute($self->org_id, $ckid);

    my ($first_row) = $sth->fetchrow;
    $sth->finish;

    return 0 unless $first_row;
  }

  return 1;
}

sub verify_token_access {
  my $self = shift;
  my @token_ids = @_;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare("SELECT 1 FROM rhnRegToken WHERE org_id = ? AND id = ?");

  foreach my $tid (@token_ids) {
    next unless $tid;
    $sth->execute($self->org_id, $tid);

    my ($first_row) = $sth->fetchrow;
    $sth->finish;

    return 0 unless $first_row;
  }

  return 1;
}

sub verify_kickstart_access {
  my $self = shift;
  my @ks_ids = @_;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare("SELECT 1 FROM rhnKSData WHERE org_id = ? AND id = ?");

  foreach my $ksid (@ks_ids) {
    next unless $ksid;
    $sth->execute($self->org_id, $ksid);

    my ($first_row) = $sth->fetchrow;
    $sth->finish;

    return 0 unless $first_row;
  }

  return 1;
}

sub verify_kickstart_session_access {
  my $self = shift;
  my @kss_ids = @_;

  return unless $self->is('config_admin');

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare("SELECT 1 FROM rhnKickstartSession WHERE org_id = ? AND id = ?");

  foreach my $kssid (@kss_ids) {
    next unless $kssid;
    $sth->execute($self->org_id, $kssid);

    my ($first_row) = $sth->fetchrow;
    $sth->finish;

    return 0 unless $first_row;
  }

  return 1;
}

sub verify_order_access {
  my $self = shift;
  my @order_ids = @_;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare("SELECT 1 FROM web_user_order WHERE web_user_id = ? AND id = ?");

  foreach my $oid (@order_ids) {
    $sth->execute($self->id, $oid);

    my ($first_row) = $sth->fetchrow;
    $sth->finish;

    return 0 unless $first_row;
  }

  return 1;
}

sub verify_note_access {
  my $self = shift;
  my @note_ids = @_;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
SELECT  1
  FROM  rhnServerNotes SN
 WHERE  SN.id = :nid
   AND  EXISTS (SELECT 1 FROM rhnUserServerPerms USP WHERE USP.user_id = :user_id AND USP.server_id = SN.server_id)
EOQ

  foreach my $nid (@note_ids) {
    $sth->execute_h(nid => $nid, user_id => $self->id);

    my ($server_note) = $sth->fetchrow;

    $sth->finish;

    return 0 unless $server_note;
  }

  return 1;
}

sub verify_transaction_access {
  my $self = shift;
  my @transaction_ids = @_;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
SELECT  1
  FROM  rhnTransaction T
 WHERE  T.id = :tid
   AND  EXISTS (SELECT 1 FROM rhnUserServerPerms USP WHERE USP.user_id = :user_id AND USP.server_id = T.server_id)
EOQ

  foreach my $tid (@transaction_ids) {
    $sth->execute_h(tid => $tid, user_id => $self->id);

    my ($first_row) = $sth->fetchrow;

    $sth->finish;

    return 0 unless $first_row;
  }

  return 1;
}

sub verify_errata_access {
  my $self = shift;
  my @errata_ids = @_;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
SELECT  1
  FROM  rhnChannelErrata CE
 WHERE  CE.errata_id = :eid
   AND  CE.channel_id IN(SELECT channel_id FROM rhnAvailableChannels WHERE org_id = :org_id)
EOQ

  foreach my $eid (@errata_ids) {
    next unless $eid;
    $sth->execute_h(eid => $eid, org_id => $self->org_id);

    my ($first_row) = $sth->fetchrow;
    $sth->finish;

    unless ($first_row) { # Well then, does the org own the errata?
      return 0 unless $self->verify_errata_admin($eid);
    }
  }

  return 1;
}

sub verify_package_access {
  my $self = shift;
  my @package_ids = @_;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
SELECT  1
  FROM  dual
 WHERE  EXISTS (
        SELECT  1
          FROM  rhnPackage P
         WHERE  P.id = :pid
           AND  P.org_id = :org_id
 ) OR   EXISTS (
        SELECT  1
          FROM  rhnChannelPackage CP,
                rhnAvailableChannels AC
         WHERE  AC.org_id = :org_id
           AND  AC.channel_id = CP.channel_id
           AND  CP.package_id = :pid
 )
EOQ

  foreach my $pid (@package_ids) {
    $sth->execute_h(pid => $pid, org_id => $self->org_id);

    my ($first_row) = $sth->fetchrow;
    $sth->finish;

    return 0 unless $first_row;
  }

  return 1;
}

sub verify_package_admin {
  my $self = shift;
  my @package_ids = @_;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
SELECT  1
  FROM  rhnPackage P
 WHERE  P.id = :pid
   AND  P.org_id = :org_id
EOQ

  foreach my $pid (@package_ids) {
    $sth->execute_h(pid => $pid, org_id => $self->org_id);

    my ($first_row) = $sth->fetchrow;
    $sth->finish;

    throw "user '", $self->id, "' does not have admin access to package '$pid'" unless $first_row;
  }

  return;
}

sub verify_kickstartabletree_access {
  my $self = shift;
  my @ktids = @_;

  my $valid_trees = RHN::KSTree->kstrees_for_user($self->id);

  return 0 unless (ref $valid_trees and ref $valid_trees eq 'ARRAY');

  foreach my $ktid (@ktids) {
    return 0 unless grep { $_->{ID} eq $ktid } @{$valid_trees};
  }

  return 1;
}

# need to refactor verify_system_group_user_admin and verify_user_admin
sub verify_user_admin {
  my $self = shift;
  my @user_ids = @_;

  return 1 if $self->is('rhn_superuser');

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare("SELECT org_id FROM web_contact WHERE id = ?");

  my $context = Apache2::RequestUtil->request->server->dir_config('user_context') || '';

  foreach my $uid (@user_ids) {
    $sth->execute($uid);

    my ($org_id) = $sth->fetchrow;
    $sth->finish;

    if ($self->is('org_admin')) {
      return 0 unless $org_id == $self->org_id;
    }
    elsif ($context eq 'monitoring_admin') {
      return 0 unless $org_id == $self->org_id;
      return 0 unless $self->is('monitoring_admin');
    }
    else {
      return 0 unless $uid == $self->id;
    }
  }

  return 1;
}

sub verify_user_admin_by_login {
  my $self = shift;
  my @logins = @_;

  my @uids = map { my $u = RHN::User->lookup(-username => $_); $u->id() } @logins;

  return $self->verify_user_admin(@uids);
}

sub verify_system_group_user_admin {
  my $self = shift;
  my @user_ids = @_;

  return 1 if $self->is('rhn_superuser');

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare("SELECT org_id FROM web_contact WHERE id = ?");

  foreach my $uid (@user_ids) {
    $sth->execute($uid);

    my ($org_id) = $sth->fetchrow;
    $sth->finish;

    if ($self->is('org_admin') or $self->is('system_group_admin')) {
      return 0 unless $org_id == $self->org_id;
    }
    else {
      return 0 unless $uid == $self->id;
    }
  }

  return 1;
}


sub verify_channel_admin {
  my $self = shift;
  my @channel_ids = @_;

  return 1 if $self->is('rhn_superuser');

  for my $cid (@channel_ids) {
    next unless $cid;
    return 0 unless $self->verify_channel_role($cid, 'manage');
  }

  return 1;
}

sub verify_channel_role {
  my $self = shift;
  my $channel_id = shift;
  my $role = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
BEGIN
  :result := rhn_channel.user_role_check_debug(:cid, :user_id, :role, :reason);
END;
EOQ

  my ($result, $reason);
  $sth->execute_h(cid => $channel_id,
		  user_id => $self->id,
		  role => $role,
		  result => \$result,
		  reason => \$reason);

  return wantarray ? ($result, $reason) : $result;
}
sub verify_errata_admin {
  my $self = shift;
  my @errata_ids = @_;

  return 1 if $self->is('rhn_superuser');

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
SELECT 1 FROM rhnErrata E
 WHERE E.org_id = :org_id AND E.id = :eid
EOQ

  my $sth_temp = $dbh->prepare(<<EOQ);
SELECT 1 FROM rhnErrataTmp E
 WHERE E.org_id = :org_id AND E.id = :eid
EOQ

  foreach my $eid (@errata_ids) {
    next unless $eid;
    $sth->execute_h(org_id => $self->org_id, eid => $eid);
    my ($row) = $sth->fetchrow;
    $sth->finish;

    $sth_temp->execute_h(org_id => $self->org_id, eid => $eid);
    my ($row_temp) = $sth_temp->fetchrow;
    $sth_temp->finish;

    return 0 unless ($row or $row_temp);
  }

  return 1;
}

sub verify_config_channel_access {
  my $self = shift;
  return $self->verify_permission_function_helper('rhn_config_channel.get_user_chan_access', $self->id, @_);
}

sub verify_config_file_access {
  my $self = shift;
  my @cf_ids = @_;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
SELECT 1
  FROM rhnConfigFile CF, rhnConfigChannel CC
 WHERE CC.org_id = :org_id
   AND CF.id = :cfid
   AND CF.config_channel_id = CC.id
EOQ

  foreach my $cfid (@cf_ids) {
    next unless $cfid;

    $sth->execute_h(org_id => $self->org_id, cfid => $cfid);

    my ($first_row) = $sth->fetchrow;
    $sth->finish;

    return 0 unless $first_row;
  }

  return 1;
}

sub verify_config_revision_access {
  my $self = shift;
  return $self->verify_permission_function_helper('rhn_config_channel.get_user_revision_access', $self->id, @_);
}

sub verify_actionconfigrevision_access {
  my $self = shift;
  my @acr_ids = @_;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOS);
SELECT 1
  FROM rhnActionConfigRevision ACR
 WHERE ACR.id = :acrid
   AND EXISTS (SELECT 1 FROM rhnUserServerPerms WHERE user_id = :user_id AND server_id = ACR.server_id)
EOS

  foreach my $acrid (@acr_ids) {
    next unless $acrid;

    $sth->execute_h(user_id => $self->id, acrid => $acrid);

    my ($first_row) = $sth->fetchrow;
    $sth->finish;

    return 0 unless $first_row;
  }

  return 1;
}


sub verify_contact_method_access {
  my $self = shift;
  my @cm_ids = @_;

  my $context = Apache2::RequestUtil->request->server->dir_config('user_context') || '';

  # if a user is an org_admin,
  # or, if the user is a monitoring_admin, *and* we are operating in that context
  # then he has access to everyone is his org's methods.
  if ($self->is('org_admin')
      or ($context eq 'monitoring_admin' and $self->is('monitoring_admin'))
     ) {
    my $dbh = RHN::DB->connect;
    my $sth = $dbh->prepare(<<EOW);
SELECT 1
  FROM rhn_contact_methods CM,
       web_contact WC
 WHERE CM.contact_id = WC.id
   AND CM.recid = ?
   AND WC.org_id = ?
EOW

    foreach my $cm_id (@cm_ids) {
      $sth->execute($cm_id, $self->org_id);

      my ($first_row) = $sth->fetchrow;
      $sth->finish;

      return 0 unless $first_row;
    }
    return 1;
  }

  #verify that the current user owns this contact method.
  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOW);
SELECT 1
  FROM rhn_contact_methods CM
 WHERE CM.contact_id = ?
   AND CM.recid = ?
EOW

  foreach my $cm_id (@cm_ids) {
    $sth->execute($self->id, $cm_id);

    my ($first_row) = $sth->fetchrow;
    $sth->finish;

    return 0 unless $first_row;
  }
  return 1;
}


sub verify_contact_group_access {
  my $self = shift;
  my @cg_ids = @_;

  # if a user is an org_admin, he has access to everybody's groups.
  if ($self->is('org_admin')) {
    my $dbh = RHN::DB->connect;
    my $sth = $dbh->prepare(<<EOW);
SELECT 1
  FROM rhn_contact_groups CG
 WHERE CG.recid = ?
   AND CG.customer_id = ? 
EOW

    foreach my $cg_id (@cg_ids) {
      $sth->execute($cg_id, $self->org_id);

      my ($first_row) = $sth->fetchrow;
      $sth->finish;

      return 0 unless $first_row;
    }
    return 1;
  }

  #verify that the current user owns this contact group.
  # note that this is an artifical sense of ownership that is only
  # valid due the the coincidence there a contact group currently
  # consists of only a single method.
  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOW);
SELECT 1
  FROM rhn_contact_group_members CGM, rhn_contact_methods CM
 WHERE CM.recid = CGM.member_contact_method_id
   AND CM.contact_id = ?
   AND CGM.contact_group_id = ?
EOW

  foreach my $cg_id (@cg_ids) {
    $sth->execute($self->id, $cg_id);

    my ($first_row) = $sth->fetchrow;
    $sth->finish;

    return 0 unless $first_row;
  }
  return 1;
}


sub preferred_page_size {
  my $self = shift;

  # the reason for this oddball multiplication/division is because the
  # pref value column is varchar2(1) and it means working circles
  # around it.

  my $size = $self->get_pref('page_size');
  $size = 20 unless $size;
  $size = 20 if not $size or $size < 5;
  $size = 500 if $size > 500;

  return $size;
}

# can't reuse the pref code since we need the longer date format.
# perhaps we should simply make the whole rhnUserInfo table a
# tableclass?

sub last_logged_in {
  my $self = shift;

  if (exists $self->{__pref_cache__}->{last_logged_in}) {
    return $self->{__pref_cache__}->{last_logged_in};
  }

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare("SELECT TO_CHAR(last_logged_in, 'YYYY-MM-DD HH24:MI:SS') FROM rhnUserInfo WHERE user_id = ?");

  $sth->execute($self->id);
  my ($val) = $sth->fetchrow;
  $sth->finish;

  $self->{__pref_cache__}->{last_logged_in} = $val;
  return $val;
}

sub mark_log_in {
  my $self = shift;

  delete $self->{__pref_cache__}->{last_logged_in};
  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare("UPDATE rhnUserInfo SET last_logged_in = sysdate WHERE user_id = ?");
  $sth->execute($self->id);
  $dbh->commit;
}

sub get_pref {
  my $self = shift;
  my $pref = shift;

  if (exists $self->{__pref_cache__}->{$pref}) {
    return $self->{__pref_cache__}->{$pref};
  }

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare("SELECT $pref FROM rhnUserInfo WHERE user_id = ?");

  $sth->execute($self->id);
  my ($val) = $sth->fetchrow;
  $sth->finish;

  $self->{__pref_cache__}->{$pref} = $val;
  return $val;
}

sub get_server_pref {
  my $self = shift;
  my $server_id = shift;
  my $pref = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare("SELECT value FROM rhnUserServerPrefs WHERE user_id = ? AND server_id = ? AND name = ?");

  $sth->execute($self->id, $server_id, $pref);
  my ($val) = $sth->fetchrow;
  $sth->finish;

  return $val;
}

sub set_server_pref {
  my $self = shift;
  my $server_id = shift;
  my $pref = shift;
  my $new_val = shift;
  my $assumed_default = shift;

  my $dbh = RHN::DB->connect;
  my $query = <<EOS;
DELETE FROM rhnUserServerPrefs
 WHERE user_id = ?
   AND server_id = ?
   AND name = ?
EOS
  my $sth = $dbh->prepare($query);
  $sth->execute($self->id, $server_id, $pref);

  if ($new_val ne $assumed_default) {
    my $query = <<EOS;
INSERT INTO rhnUserServerPrefs
(user_id, server_id, name, value)
VALUES
(?, ?, ?, ?)
EOS
    my $sth = $dbh->prepare($query);
    $sth->execute($self->id, $server_id, $pref, $new_val);
  }

  $dbh->commit;
}

sub set_pref {
  my $self = shift;
  my $pref = shift;
  my $val = shift;

  delete $self->{__pref_cache__}->{$pref};

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare("SELECT 1 FROM rhnUserInfo WHERE user_id = ?");
  $sth->execute($self->id);

  my ($exists) = $sth->fetchrow;

  if (not $exists) {
    $sth = $dbh->prepare('INSERT INTO rhnUserInfo (user_id) VALUES (?)');
    $sth->execute($self->id);
  }

  $sth = $dbh->prepare("UPDATE rhnUserInfo SET $pref = ? WHERE user_id = ?");
  $sth->execute($val, $self->id);
  $dbh->commit;
}

# applicant info:
#   $sth = $dbh->prepare(<<EOS);
# SELECT UG.id,
#        (SELECT COUNT(*) FROM rhnUserGroupMembers WHERE user_group_id = UG.id)
#   FROM rhnUserGroupType UGT,
#        rhnUserGroup UG
#  WHERE UG.org_id = ?
#    AND UG.group_type = UGT.id
#    AND UGT.label = 'org_applicant'
# EOS
#   $sth->execute($self->org_id);
#   my ($applicant_group, $applicant_count) = $sth->fetchrow;
#   $sth->finish;

sub system_summary {
  my $self = shift;

  my $dbh = RHN::DB->connect;
  my $sth;

  $sth = $dbh->prepare(<<EOS);
SELECT COUNT(S.id)
  FROM rhnServer S
 WHERE S.org_id = ?
   AND EXISTS (SELECT 1 FROM rhnUserServerPerms USP WHERE USP.user_id = ? AND USP.server_id = S.id)
   AND NOT EXISTS (SELECT 1 FROM rhnEntitledServers ES where ES.id = S.id)
EOS
  $sth->execute($self->org_id, $self->id);
  my ($unentitled) = $sth->fetchrow;
  $sth->finish;

  $sth = $dbh->prepare(<<EOS);
SELECT COUNT(S.id)
  FROM rhnServer S
 WHERE S.org_id = ?
   AND EXISTS (SELECT 1 FROM rhnUserServerPerms USP WHERE USP.user_id = ? AND USP.server_id = S.id)
   AND NOT EXISTS (SELECT 1
                     FROM rhnServerGroup SG, rhnServerGroupMembers SGM
                    WHERE SGM.server_id = S.id
                      AND SG.id = SGM.server_group_id
                      AND SG.group_type IS NULL)
EOS
  $sth->execute($self->org_id, $self->id);
  my ($ungrouped) = $sth->fetchrow;
  $sth->finish;

  $sth = $dbh->prepare(<<EOS);
SELECT COUNT(USP.server_id)
  FROM rhnUserServerPerms USP
 WHERE USP.user_id = ?
EOS
  $sth->execute($self->id);
  my ($total_servers) = $sth->fetchrow;
  $sth->finish;

  $sth = $dbh->prepare(<<EOS);
SELECT COUNT(USP.server_id)
  FROM rhnUserServerPerms USP
 WHERE USP.user_id = ?
   AND EXISTS (SELECT 1 FROM rhnServerNeededPackageCache WHERE server_id = USP.server_id)
EOS
  $sth->execute($self->id);
  my ($servers_needing_attention) = $sth->fetchrow;
  $sth->finish;

  $sth = $dbh->prepare(<<EOS);
SELECT COUNT(USP.server_id)
  FROM rhnUserServerPerms USP
 WHERE USP.user_id = ?
   AND EXISTS (SELECT 1 FROM rhnServerInfo WHERE server_id = USP.server_id AND checkin < sysdate - ?)
EOS

  $sth->execute($self->id, PXT::Config->get('system_checkin_threshold'));
  my ($inactive_server_count) = $sth->fetchrow;
  $sth->finish;


  return [ $total_servers, $servers_needing_attention, $unentitled, $ungrouped, $inactive_server_count ];
}

sub action_summary {
  my $self = shift;
#  my $days = shift or die "No days argument to action_summary";

  my $dbh = RHN::DB->connect;
  my $sth;

  $sth = $dbh->prepare(<<EOS);
  SELECT count(distinct SA.action_id)
    FROM rhnAction A, rhnServerAction SA, rhnUserServerPerms USP
   WHERE USP.user_id = ?
     AND SA.server_id = USP.server_id
     AND SA.action_id = A.id
     AND SA.status = 3
     AND A.archived = 0
EOS
#     AND (sysdate - SA.completion_time) < $days
  $sth->execute($self->id);
  my ($failed) = $sth->fetchrow;
  $sth->finish;

  $sth = $dbh->prepare(<<EOS);
  SELECT count(distinct SA.action_id)
    FROM rhnAction A, rhnServerAction SA, rhnUserServerPerms USP
   WHERE USP.user_id = ?
     AND SA.server_id = USP.server_id
     AND SA.action_id = A.id
     AND SA.status IN (0, 1)
     AND A.archived = 0
EOS
#     AND ABS(A.earliest_action - sysdate) < $days
  $sth->execute($self->id);
  my ($pending) = $sth->fetchrow;
  $sth->finish;

  $sth = $dbh->prepare(<<EOS);
  SELECT count(distinct SA.action_id)
    FROM rhnAction A, rhnServerAction SA, rhnUserServerPerms USP
   WHERE USP.user_id = ?
     AND SA.server_id = USP.server_id
     AND SA.action_id = A.id
     AND SA.status = 2
     AND A.archived = 0
EOS
#     AND (sysdate - SA.completion_time) < $days
  $sth->execute($self->id);
  my ($completed) = $sth->fetchrow;
  $sth->finish;

  return [ $failed, $pending, $completed, $failed + $pending + $completed ];

}

sub server_group_count {
  my $self = shift;

  my $dbh = RHN::DB->connect;
  my $query =<<EOQ;
SELECT COUNT(server_group_id)
  FROM rhnUserServerGroupPerms
 WHERE user_id = ?
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute($self->id);

  my ($count) = $sth->fetchrow;

  $sth->finish;

  return $count;
}


sub errata_count {
  my $self = shift;

  my $dbh = RHN::DB->connect;
  my $query =<<EOQ;
SELECT COUNT(DISTINCT E.id)
  FROM rhnErrata E, rhnUserServerPerms USP, rhnServerNeededErrataCache SNEC
 WHERE E.id = SNEC.errata_id
   AND SNPC.server_id = USP.server_id
   AND USP.user_id = ?
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute($self->id);

  my ($count) = $sth->fetchrow;

  $sth->finish;

  return $count;
}


sub remove_from_group {
  my $self = shift;
  my $label = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
SELECT UG.id
  FROM rhnUserGroupType UGT,
       rhnUserGroup UG
 WHERE UG.org_id = ?
   AND UG.group_type = UGT.id
   AND UGT.label = ?
EOQ

  $sth->execute($self->org_id, $label);
  my ($ugid) = $sth->fetchrow;
  $sth->finish;

  $dbh->call_procedure("rhn_user.delete_from_usergroup", $self->id, $ugid);
  $dbh->commit;
}

sub has_incomplete_info {
  my $self = shift;

  my ($site) = $self->sites('M');

  if ($self->first_names eq 'Valued' or $self->last_name eq 'Customer') {
    return "details";
  }
  elsif ($site and ($site->site_city eq '.' or $site->site_address1 eq '.')) {
    return "address";
  }

  return 0;
}

sub orders_for_user {
  my $class = shift;
  my $uid = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOS);
SELECT CUSTOMER_NUMBER, WEB_ORDER_NUMBER, LINE_ID, PRODUCT_ITEM_CODE, PRODUCT_NAME, QUANTITY
  FROM user_orders
 WHERE customer_number = (SELECT oracle_customer_number FROM web_customer cu, web_contact co WHERE co.id = ? and co.org_id = cu.id)
EOS

  $sth->execute($uid);

  my @ret;
  while (my @row = $sth->fetchrow) {
    push @ret, [ @row ];
  }

  return @ret;
}

sub products_for_user {
  my $class = shift;
  my $uid = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOS);
SELECT REGISTRATION_USER_ID, REG_NUMBER, SERVICE_TAG, PRODUCT_DESCRIPTION, PRODUCT_ITEM_CODE,
       PRODUCT_START_DATE, PRODUCT_END_DATE, PRODUCT_ACTIVE_FLAG, PRODUCT_QUANTITY,
       SERVICE_DESCRIPTION, SERVICE_ITEM_CODE, SERVICE_START_DATE, SERVICE_END_DATE,
       SERVICE_ACTIVE_FLAG
  FROM user_products
 WHERE user_id = ?
EOS

  $sth->execute($uid);

  my @ret;
  while (my @row = $sth->fetchrow) {
    push @ret, [ @row ];
  }

  return @ret;
}

sub uids_by_login_prefix {
  my $class = shift;
  my $login = uc shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOS);
SELECT id, login
  FROM web_contact
 WHERE login_uc LIKE ?
EOS

  $sth->execute("$login%");

  my @ret;
  while (my @row = $sth->fetchrow) {
    push @ret, [ @row ];
  }

  return @ret;
}

sub banish {
  my $self = shift;

  my ($org_id) = RHN::Org->create_new_org(-org_name => "Rejection Org for " . $self->login,
					  -org_password => PXT::Utils->random_password(16),
					  -customer_type => 'P');

  $self->remove_from_group('org_applicant');

  $self->org_id($org_id);
  delete $self->{__orgobj__};
  $self->set_password(PXT::Utils->random_password(16));
  $self->login(substr($self->id . '-' . $self->login, 0, 63));

  $self->commit;
}

sub approve {
  my $self = shift;

  $self->set_password(PXT::Utils->random_password(10));
  $self->remove_from_group('org_applicant');

  $self->commit;

  return $self->password;
}

sub grant_servergroup_permission {
  my $self = shift;
  my $uid;
  if (ref $self) {
    $uid = $self->id;
  }
  else {
    $uid = shift;
  }

  my $sgid = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOS);
DECLARE
    cursor usgps is
        select  wc.id user_id,
                sg.id server_group_id
        from    rhnServerGroup sg,
                web_contact wc
        where   wc.id = :user_id
            and sg.id = :server_group_id
            and not exists (
                select  1
                from    rhnUserServerGroupPerms usgp
                where   usgp.user_id = :user_id
                    and usgp.server_group_id = :server_group_id
            );
BEGIN
    for usgp in usgps loop
        begin
            rhn_user.add_servergroup_perm(:user_id, :server_group_id);
        exception
            when others then null;
        end;
    end loop;
END;
EOS

  $sth->execute_h(user_id => $uid, server_group_id => $sgid);
  $dbh->commit;
}

sub revoke_servergroup_permission {
  my $self = shift;
  my $uid;
  if (ref $self) {
    $uid = $self->id;
  }
  else {
    $uid = shift;
  }

  my $sgid = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOS);
DECLARE
  cursor usgps is
    select  usgp.server_group_id, usgp.user_id
    from    rhnUserServerGroupPerms usgp
    where   usgp.server_group_id = :server_group_id
        and exists (
            select  1
            from    rhnServerGroup  sg,
                    web_contact     wc
            where   wc.id = :user_id
                and sg.id = :server_group_id
                and sg.org_id = wc.org_id
            );
BEGIN
    for usgp in usgps loop
        begin
            rhn_user.remove_servergroup_perm(:user_id, :server_group_id);
        exception
            when others then null;
        end;
    end loop;
END;
EOS

  $sth->execute_h(server_group_id => $sgid, user_id => $uid);
  $dbh->commit;
}

sub access_to_servergroup {
  my $self = shift;
  my $sgid = shift;

  my $dbh = RHN::DB->connect; 
  my $sth = $dbh->prepare(<<EOS);
SELECT DISTINCT SG.id 
  FROM rhnServerGroup SG, rhnUserManagedServerGroups UMSG
 WHERE UMSG.user_id = :user_id
   AND UMSG.server_group_id = :sg_id
   AND UMSG.server_group_id = SG.id
   AND SG.group_type IS NULL
EOS

  $sth->execute_h(user_id => $self->id, sg_id => $sgid);
  my ($count) = $sth->fetchrow;
  $sth->finish;

  #if we didn't get anything back, count will be undef and eval to false
  return $count;
}

sub satellite_has_users {
  my $self = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOS);
SELECT COUNT(*) FROM web_contact
EOS

  $sth->execute();
  my ($count) = $sth->fetchrow;
  $sth->finish;

  return $count;
}


sub systems_subscribed_to_channel {
  my $self = shift;
  my $cid = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
SELECT DISTINCT(SC.server_id)
  FROM rhnServerChannel SC, rhnUserServerPerms USP
 WHERE USP.user_id = ?
   AND SC.channel_id = ?
   AND SC.server_id = USP.server_id
EOQ

  $sth->execute($self->id, $cid);

  my @sids;

  while (my ($sid) = $sth->fetchrow) {
    push @sids, $sid;
  }

  return @sids;
}

sub email_addresses {
  my $self_or_class = shift;
  my $id;

  if (ref $self_or_class) {
    $id = $self_or_class->id;
  }
  else {
    $id = shift;
  }

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
SELECT id
  FROM rhnEmailAddress
 WHERE user_id = :user_id
ORDER BY MODIFIED DESC
EOQ

  $sth->execute_h(user_id => $id);

  my @ret;

  while (my ($id) = $sth->fetchrow) {
    push @ret, RHN::EmailAddress->lookup(-id => $id);
  }

  return @ret;
}

sub delete_nonverified_addresses {
  my $self = shift;
  my %params = validate(@_, {transaction => 0});
  my $dbh = $params{transaction} || RHN::DB->connect;

  my $query = <<EOQ;
DELETE
  FROM rhnEmailAddress
 WHERE user_id = :user_id
   AND state_id != (SELECT id FROM rhnEmailAddressState WHERE label = 'verified')
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute_h(user_id => $self->id);

  $dbh->commit unless $params{transaction};
}

#lock the user's row in web_contact -- $dbh must be committed or rolled back at some point
sub lock_web_contact {
  my $class = shift;
  my %params = validate(@_, {transaction => 0, uid => 1});
  my $dbh = $params{transaction} || RHN::DB->connect;

  my $sth = $dbh->prepare('SELECT * FROM web_contact WHERE id = :user_id FOR UPDATE');
  $sth->execute_h(user_id => $params{uid});

  my (@row) = $sth->fetchrow;

  return $sth;
}


sub can_delete_custominfokey {
  my $self = shift;
  my $key_id = shift;

  my $key = RHN::CustomInfoKey->lookup(-id => $key_id);

  throw 'no key' unless $key;

  return 1 if $self->is('org_admin');

#  unless (defined $key->creator_id) {
#    return 0;
#  }
#
#  unless ($key->creator_id == $self->id) {
#    return 0;
# }

  my $dbh = RHN::DB->connect();
  my $sth = $dbh->prepare(<<EOQ);
SELECT 1
  FROM rhnServerCustomDataValue SCDV,
       rhnServer S
 WHERE S.org_id = :org_id
   AND S.id = SCDV.server_id
   AND SCDV.key_id = :key_id
   AND NOT EXISTS (SELECT 1 FROM rhnUserServerPerms USP WHERE user_id = :user_id AND server_id = S.id)
EOQ

  $sth->execute_h(user_id => $self->id,
		  org_id => $self->org_id,
		  key_id => $key_id,
		 );

  my ($row) = $sth->fetchrow;
  $sth->finish;

  return 0 if defined $row;

  return 1;
}

# can this user modify the target user?
sub can_modify_user {
  my $self = shift;
  my $target = shift;

  die "'$target' is not a user object"
      unless (ref $target and $target->isa('RHN::DB::User'));

  if ($self->org_id != $target->org_id) {
    warn "Orgs for admin user edit mistatch (admin: @{[$self->org_id]} != @{[$target->org_id]}";
    return 0;
  }

  if ($target->id != $self->id and not $self->is('org_admin')) {
    warn "Non-orgadmin attempting to edit another's record";
    return 0;
  }

  return 1;
}

sub manages_a_channel {
  my $self = shift;

  my $dbh = RHN::DB->connect;

  my $query =<<EOQ;
SELECT 1
  FROM rhnUserChannel UC
 WHERE UC.user_id = :user_id
   AND UC.role = 'manage'
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute_h(user_id => $self->id);

  my ($truth) = $sth->fetchrow;
  $sth->finish;

  return $truth ? 1 : 0;
}

sub default_system_groups {
  my $self = shift;

  my $dbh = RHN::DB->connect;

  my $query =<<EOQ;
SELECT system_group_id
  FROM rhnUserDefaultSystemGroups
 WHERE user_id = :user_id
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute_h(user_id => $self->id);

  my @groups;

  while (my ($gid) = $sth->fetchrow) {
    push @groups, $gid;
  }

  return @groups;
}

sub set_default_system_groups {
  my $self = shift;
  my @sgids = grep { $_ } @_;

  my $dbh = RHN::DB->connect;

  $self->org->owns_server_groups(@sgids)
    or die "Attempt to set system groups (@sgids) for user '" . $self->id . "' without permission";

  my $query =<<EOQ;
DELETE
  FROM rhnUserDefaultSystemGroups
 WHERE user_id = :user_id
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute_h(user_id => $self->id);

  $query =<<EOQ;
INSERT
  INTO rhnUserDefaultSystemGroups
       (user_id, system_group_id)
VALUES (:user_id, :sgid)
EOQ

  $sth = $dbh->prepare($query);

  foreach my $sgid (@sgids) {
    $sth->execute_h(user_id => $self->id, sgid => $sgid);
  }

  $dbh->commit;

  return;
}

##
 # Sees if user exists in rhnWebContactDisabled view. 
 # If so, return true(1). Otherwise, the user is an active
 # user so return false(0).
##
sub is_disabled {
    #Get user... we should have been called like: $user->is_disabled()
    my $self = shift;

    #see if user is in rhnWebContactDisabled
    my $query = <<EOQ;
SELECT id as disabled_id
  FROM rhnWebContactDisabled
 WHERE id = :user_id
EOQ

    my $dbh = RHN::DB->connect;

    my $sth = $dbh->prepare($query);
    $sth->execute_h(user_id => $self->id);

    my ($userIsDisabled) = $sth->fetchrow();
    $sth->finish;

    #IF userIsDisabled is not null, then the user is disabled.
    return 1 if $userIsDisabled;

    return 0; #user is active
}

sub verify_file_access {
  my $self = shift;
  my $file_path = shift;

  my $dbh = RHN::DB->connect();
  my $sth = $dbh->prepare(<<EOQ);
SELECT 1
  FROM rhnUserChannelFamilyPerms UCFP, rhnDownloads D
 WHERE UCFP.user_id = :user_id
   AND D.channel_family_id = UCFP.channel_family_id
   AND D.file_id = (SELECT id FROM rhnFile WHERE path = :file_path)
EOQ
  $sth->execute_h(user_id => $self->id, file_path => $file_path);
  my ($file_access) = $sth->fetchrow;
  $sth->finish;

  return 1 if defined  $file_access;

  return 0;
}

1;

