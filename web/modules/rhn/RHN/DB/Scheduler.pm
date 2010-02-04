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

package RHN::DB::Scheduler;
use strict;

use Data::Dumper ();

use RHN::DB;
use RHN::Exception qw/throw/;
use RHN::DataSource::Simple;
use RHN::DataSource::System;

use RHN::DataSource::Errata ();
use RHN::DB::Set ();
use RHN::Errata ();
use RHN::Package ();
use RHN::Server ();

use Params::Validate;
Params::Validate::validation_options(strip_leading => "-");

# XXX FIXME:  cull these in the future depending upon the fate of _horrible_tickle
use PXT::Config;
use IO::Socket::INET;

# XXX FIXME:  this will be replaced once we have some more interesting schema underneath :/
sub _horrible_tickle {
  unless (PXT::Config->get('osa_tickle_enabled')) {
    return;
  }

  warn "horrible tickle starting...";

  my $ds = new RHN::DataSource::Simple(-querybase => 'push_queries',
				       -mode => 'superclients');
  my $data = $ds->execute_query();

  foreach my $row (@{$data}) {
    my $sock = new IO::Socket::INET (PeerAddr => $row->{HOSTNAME},
				     PeerPort => $row->{PORT},
				     Proto => 'tcp');

    if ($sock) {
      warn "SOCKET!!!";
      close($sock);
      last;
    }
  }
}

sub osa_wakeup_tickle {
  # XXX FIXME:  replace this w/ something far more useful...
  _horrible_tickle();
}

sub make_base_action {
  my $class = shift;
  my %params = validate(@_, { org_id => 1,
			      user_id => 0,
			      type_label => 1,
			      earliest => 1,
			      action_name => 0,
			      prerequisite => 0,
			      transaction => 0,
			    });

  my $org_id = $params{org_id};
  my $user_id = $params{user_id};
  my $type_label = $params{type_label};
  my $earliest = $params{earliest};
  my $action_name = $params{action_name};
  my $prerequisite = $params{prerequisite};
  my $transaction = $params{transaction};

  if ($action_name and length($action_name) > 128) {
    warn "action name too long, will truncate:  $action_name";
    $action_name = substr($action_name, 0, 128);
  }

  my $dbh = $transaction || RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
SELECT rhn_event_id_seq.nextval,
       rAT.id,
       rAS.id
  FROM rhnActionType rAT,
       rhnActionStatus rAS
 WHERE rAT.label = ?
   AND rAS.name = ?
EOQ

  $sth->execute($type_label, 'Queued');
  my ($id, $type_id, $stat_id) = $sth->fetchrow();
  $sth->finish;

  # TODO:  fix sys_date => reasonable value later...
  my $query = <<EOQ;
INSERT INTO rhnAction (id, org_id, action_type, scheduler, earliest_action, version, name, prerequisite)
VALUES (?, ?, ?, ?, TO_DATE(?, 'YYYY-MM-DD HH24:MI:SS'), 2, ?, ?)
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute($id, $org_id, $type_id, $user_id, $earliest, $action_name, $prerequisite);
  #$sth->execute($id, $org_id, $type_id, $user_id);
  $dbh->commit unless $transaction;

  return ($id, $stat_id, $transaction);
}

sub add_servers_to_action {
  my $class = shift;
  my $action_id = shift;
  my $status_id = shift;
  my $user_id = shift;
  my $server_set = shift;
  my $server_id = shift;
  my $transaction = shift;
  my $sid_arrayref = shift;

  my $dbh = $transaction || RHN::DB->connect;
  my $query;
  my $sth;

  if ($server_set) {
    $query = <<EOQ;
INSERT INTO rhnServerAction (server_id, action_id, status)
(SELECT element, ?, ?
   FROM rhnSet
  WHERE user_id = ?
    AND label = ?
    AND EXISTS (SELECT 1 FROM rhnEntitledServers ES WHERE ES.id = element)
)
EOQ
    $sth = $dbh->prepare($query);
    $sth->execute($action_id, $status_id, $user_id, $server_set->label);
  }
  elsif ($server_id) {
    $query = <<EOQ;
INSERT INTO rhnServerAction (server_id, action_id, status) VALUES (?, ?, ?)
EOQ
    $sth = $dbh->prepare($query);
    $sth->execute($server_id, $action_id, $status_id);
  }
  elsif ($sid_arrayref) {
    $query = <<EOQ;
INSERT INTO rhnServerAction (server_id, action_id, status) VALUES (?, ?, ?)
EOQ
    $sth = $dbh->prepare($query);

    foreach my $sid (@{$sid_arrayref}) {
      $sth->execute($sid, $action_id, $status_id);
    }
  }
  else {
    throw "neither server_set nor server_id provided";
  }

  if (defined $transaction) {
    return $transaction;
  }
  else {
    $dbh->commit;
  }
}


sub schedule_reboot {
  my $class = shift;
  my %params = @_;

  my ($org_id, $user_id, $server_set, $server_id, $earliest, $prerequisite, $transaction) =
    map { $params{"-" . $_} } qw/org_id user_id server_set server_id earliest prerequisite transaction/;

  my ($action_id, $stat_id) = $class->make_base_action(-org_id => $org_id,
						       -user_id => $user_id,
						       -type_label => 'reboot.reboot',
						       -earliest => $earliest,
						       -prerequisite => $prerequisite,
						       -transaction => $transaction);

  $class->add_servers_to_action($action_id, $stat_id, $user_id, $server_set, $server_id);

  osa_wakeup_tickle();

  return $action_id;
}

sub sscd_schedule_reboot {
  my $class = shift;
  my %params = @_;

  my ($earliest, $org_id, $user_id, $server_set) =
    map { $params{"-" . $_} } qw/earliest org_id user_id server_set/;

  my $ds = RHN::DataSource::System->new;
  $ds->mode('system_set_supports_reboot');

  my $ids_ref = $ds->execute_query(-user_id => $user_id, -set_label => $server_set->label);

  my $action_name;

  my ($action_id, $action_stat_id) = $class->make_base_action(-org_id => $org_id,
							      -user_id => $user_id,
							      -type_label => 'reboot.reboot',
							      -earliest => $earliest,
							      -action_name => $action_name);

  my $query;
  my $dbh = RHN::DB->connect;
  $query = 'INSERT INTO rhnServerAction (server_id, action_id, status) VALUES (?, ?, ?)';

  my $sth = $dbh->prepare($query);

  foreach my $server (@{$ids_ref}) {
    warn "rebooting $server->{ID}...";
    $sth->execute($server->{ID}, $action_id, $action_stat_id);
  }

  osa_wakeup_tickle();

  return $action_id;
}

sub sscd_schedule_package_refresh {
  my $class = shift;
  my %params = @_;

  my ($org_id, $user_id, $server_set, $earliest, $transaction) =
    map { $params{"-" . $_} } qw/org_id user_id server_set earliest transaction/;


  my %servers_by_action_type;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
SELECT S.id, AT.label
  FROM rhnActionType AT,
       rhnArchTypeActions ATA,
       rhnServerArch SA,
       rhnServer S,
       rhnSet ST
 WHERE ST.label = :set_label
   AND ST.user_id = :user_id
   AND ST.element = S.id
   AND SA.id = S.server_arch_id
   AND ATA.arch_type_id = SA.arch_type_id
   AND ATA.action_style = 'refresh_list'
   AND AT.id = ATA.action_type_id
EOQ

  $sth->execute_h(set_label => $server_set->label, user_id => $user_id);

  while (my $row = $sth->fetchrow_hashref) {
    push @{$servers_by_action_type{$row->{LABEL}}}, $row->{ID};
  }

  my @action_ids;

  foreach my $action_label (keys %servers_by_action_type) {
    my ($action_id, $stat_id) = $class->make_base_action(-org_id => $org_id,
							 -user_id => $user_id,
							 -type_label => $action_label,
							 -earliest => $earliest,
							 -transaction => $transaction,
							);

    $class->add_servers_to_action($action_id, $stat_id, $user_id, undef, undef, undef, $servers_by_action_type{$action_label});

    push @action_ids, $action_id;
  }

  osa_wakeup_tickle();

  return @action_ids;
}

sub schedule_hardware_refresh {
  my $class = shift;
  my %params = @_;

  my ($org_id, $user_id, $server_set, $package_set, $server_id, $earliest) =
    map { $params{"-" . $_} } qw/org_id user_id server_set package_set server_id earliest/;

  my ($id, $stat_id) = $class->make_base_action(-org_id => $org_id,
						-user_id => $user_id,
						-type_label => 'hardware.refresh_list',
						-earliest => $earliest
					       );

  my $dbh = RHN::DB->connect;
  my $query;
  my $sth;

  if ($server_set) {
    $query = <<EOQ;
INSERT INTO rhnServerAction (server_id, action_id, status)
(SELECT element, ?, ? FROM rhnSet WHERE user_id = ? AND label = ? AND EXISTS (SELECT 1 FROM rhnEntitledServers ES WHERE ES.id = element))
EOQ
    $sth = $dbh->prepare($query);
    $sth->execute($id, $stat_id, $user_id, $server_set->label);
  }
  elsif ($server_id) {
    $query = <<EOQ;
INSERT INTO rhnServerAction (server_id, action_id, status) VALUES (?, ?, ?)
EOQ
    $sth = $dbh->prepare($query);
    $sth->execute($server_id, $id, $stat_id);
  }
  else {
    die "no servers provided!";
  }

  $dbh->commit;

  osa_wakeup_tickle();

  return $id;
}

sub sscd_schedule_package_upgrade {
  my $class = shift;
  my %params = @_;

  my ($earliest, $org_id, $user_id) =
    map { $params{"-" . $_} } qw/earliest org_id user_id/;

  my $dbh = RHN::DB->connect;
  my $sth;
  my $query;

  my $ds = new RHN::DataSource::System;
  $ds->mode('ssm_package_upgrades_conf');

  my $servers_data = $ds->execute_query(-user_id => $user_id);


  my %actions;
  foreach my $row (@{$servers_data}) {

    my $server_name = $row->{SERVER_NAME};
    my $server_id = $row->{ID};
    my $action_type = $row->{ACTION_TYPE_LABEL};
    my $action_type_name = $row->{ACTION_TYPE_NAME};

    my $action_name = $action_type_name . " for " . $server_name;

    my ($action_id, $action_stat_id) = $class->make_base_action(-org_id => $org_id,
								-user_id => $user_id,
								-type_label => $action_type,
								-earliest => $earliest,
								-action_name => $action_name);

    $actions{$server_id}->{$action_type}->{action_id} = $action_id;
    $actions{$server_id}->{$action_type}->{status_id} = $action_stat_id;
  }

  foreach my $server_id (keys %actions) {
    foreach my $action_type (keys %{$actions{$server_id}}) {
      $query = <<EOQ;
INSERT INTO rhnServerAction (server_id, action_id, status) VALUES (:server_id, :action_id, :status_id)
EOQ
      $sth = $dbh->prepare($query);
      $sth->execute_h(server_id => $server_id,
		      action_id => $actions{$server_id}->{$action_type}->{action_id},
		      status_id => $actions{$server_id}->{$action_type}->{status_id},
		     );

      $query = <<EOQ;
INSERT INTO rhnActionPackage (id, action_id, name_id, evr_id)
SELECT  rhn_act_p_id_seq.nextval,
        :action_id,
        P.name_id,
        P.evr_id
  FROM  rhnActionType ActionT,
        rhnArchTypeActions ATA,
        rhnPackageArch PA,
        rhnPackage P,
        rhnServerNeededPackageCache SNPC,
        rhnSet ST
 WHERE  ST.user_id = :user_id
   AND  ST.label = 'package_upgradable_list'
   AND  ST.element = P.id
   AND  P.package_arch_id = PA.id
   AND  PA.arch_type_id = ATA.arch_type_id
   AND  ATA.action_style = 'install'
   AND  ActionT.id = ATA.action_type_id
   AND  ActionT.label = :scheduled_action_type
   AND  SNPC.server_id = :server_id
   AND  SNPC.package_id = P.id
EOQ
      $sth = $dbh->prepare($query);
      $sth->execute_h(server_id => $server_id,
		      user_id => $user_id,
		      action_id => $actions{$server_id}->{$action_type}->{action_id},
		      scheduled_action_type => $action_type,
		     );
    }
  }

  $dbh->commit;

  osa_wakeup_tickle();

  return \%actions;
}

# one or more package install or remove for a single system

sub sscd_schedule_package_removal {
  my $class = shift;
  my %params = @_;

  my ($earliest, $org_id, $user_id, $label) =
    map { $params{"-" . $_} } qw/earliest org_id user_id label/;

  $label ||= 'sscd_removable_package_list';

  my $dbh = RHN::DB->connect;
  my $query = <<EOQ;
SELECT  DISTINCT S.id, S.name
  FROM  rhnServer S,
        rhnServerPackage SP,
        rhnSet SYSTEM_SET
 WHERE  SYSTEM_SET.user_id = ?
   AND  SYSTEM_SET.label = 'system_list'
   AND  SYSTEM_SET.element = SP.server_id
   AND  SP.name_id IN (SELECT element FROM rhnSet WHERE user_id = SYSTEM_SET.user_id AND label = '$label')
   AND  SP.server_id = S.id
ORDER BY UPPER(S.name)
EOQ



  my $sth = $dbh->prepare($query);

  $sth->execute($user_id);

  my @actions;
  while (my ($server_id, $server_name) = $sth->fetchrow) {
    my $action_name = "Package Removals for " . $server_name;
    my $action_lbl = "packages.remove";

    if ( $label eq 'sscd_removable_patch_list') {
      $action_name = "Patch Removals for " . $server_name;
      $action_lbl = "solarispkgs.patchRemove";
    }

    my ($action_id, $action_stat_id) = $class->make_base_action(-org_id => $org_id,
								-user_id => $user_id,
								-type_label => $action_lbl,
								-earliest => $earliest,
								-action_name => $action_name,
							       );

    push @actions, { action_id => $action_id, status_id => $action_stat_id, server_id => $server_id };
  }

  foreach my $action (@actions) {
    $query = <<EOQ;
INSERT INTO rhnServerAction (server_id, action_id, status) VALUES (?, ?, ?)
EOQ
    $sth = $dbh->prepare($query);
    $sth->execute($action->{server_id}, $action->{action_id}, $action->{status_id});

    $query = <<EOQ;
INSERT INTO rhnActionPackage (id, action_id, name_id, evr_id)
(
SELECT  rhn_act_p_id_seq.nextval, ?, SP.name_id, SP.evr_id
  FROM  rhnServerPackage SP, rhnSet PACKAGE_LIST
 WHERE  PACKAGE_LIST.user_id = ?
   AND  PACKAGE_LIST.label = '$label'
   AND  SP.server_id = ?
   AND  SP.name_id = PACKAGE_LIST.element
   AND  SP.evr_id = PACKAGE_LIST.element_two
)
EOQ
    $sth = $dbh->prepare($query);
    $sth->execute($action->{action_id}, $user_id, $action->{server_id});
  }

  $dbh->commit();

  osa_wakeup_tickle();

  return \@actions;
}

my $packaging_type_action_map =
  { 'rpm' => { remove => 'packages.remove',
	       install => 'packages.update',
	       verify => 'packages.verify' },
    'sysv-solaris' => { remove => 'solarispkgs.remove',
			install => 'solarispkgs.install' },
  };

# one or more package install or remove for a single system
sub schedule_system_package_action {
  my $class = shift;
  my %params = validate(@_, {org_id => 1, user_id => 1, earliest => 1, sid => 1, id_combos => 1, action_type => 1});
  my $action_type = $params{action_type};

  die "Need package_ids or id combos" unless ($params{package_ids} or $params{id_combos});

  my $packages_by_action_type;
  my %packages_for_action;
  my $server_packaging_type = RHN::Server->packaging_type($params{sid});

  foreach my $id_combo (@{$params{id_combos}}) {
    my ($name_id, $evr_id) = @{$id_combo};

    my $pid = RHN::Package->guestimate_package_id(-server_id => $params{sid},
						  -name_id => $name_id, -evr_id => $evr_id);

    my $action_type_label;

    if ($pid) {
      $action_type_label = RHN::Package->package_arch_type_action($pid, $action_type);
    }
    else {
      $action_type_label = $packaging_type_action_map->{$server_packaging_type}->{$action_type}
    }

    throw "Unknown server packaging type/action combination = '$server_packaging_type'/'$action_type'"
      unless $action_type_label;

    push @{$packages_by_action_type->{$action_type_label}}, {pid => $pid, name_id => $name_id, evr_id => $evr_id};

  }

  my $dbh = RHN::DB->connect;

  foreach my $action_type_label (keys %{$packages_by_action_type}) {
    my @packages = @{$packages_by_action_type->{$action_type_label}};

    my $action_name;
    my %action_verbs = (install => 'Install', remove => 'Removal', verify => 'Verification');
    throw "Invalid action type: '$action_type'."
      unless exists $action_verbs{$action_type};

    if (scalar @packages == 1) {
      $action_name = "Package $action_verbs{$action_type}";
    }
    else {
      $action_name = "Package $action_verbs{$action_type}s";
    }

    my ($action_id, $status_id) = $class->make_base_action(-org_id => $params{org_id},
							   -user_id => $params{user_id},
							   -type_label => $action_type_label,
							   -earliest => $params{earliest},
							   -action_name => $action_name,
							  );

    $packages_for_action{$action_id} = [ map { ( $_->{pid} || $_->{name_id} . '|' . $_->{evr_id} ) } @packages ];

    my $sth = $dbh->prepare(<<EOQ);
INSERT INTO rhnServerAction (server_id, action_id, status)
VALUES  (:sid, :aid, :status_id)
EOQ

    $sth->execute_h(sid => $params{sid}, aid => $action_id, status_id => $status_id);

    $sth = $dbh->prepare(<<EOQ);
INSERT
  INTO rhnActionPackage (id, action_id, name_id, evr_id)
VALUES (rhn_act_p_id_seq.nextval, :aid, :name_id, :evr_id)
EOQ

    foreach my $package (@packages) {
      $sth->execute_h(aid => $action_id, name_id => $package->{name_id}, evr_id => $package->{evr_id});
    }
  }

  $dbh->commit;

  osa_wakeup_tickle();

  return \%packages_for_action;
}

sub schedule_package_install {
  my $class = shift;
  my %params = validate(@_, { org_id => 1,
			      user_id => 0,
			      earliest => 1,
			      action_name => 0,
			      prerequisite => 0,
			      transaction => 0,
			      server_set => 0,
			      package_set => 0,
			      server_id => 0,
			      package_id => 0,
			      package_ids => 0,
			      transaction => 0,
			    });

  my ($org_id, $user_id, $server_set, $package_set, $server_id, $package_id, $package_ids, $earliest, $trans) =
    map { $params{$_} } qw/org_id user_id server_set package_set server_id package_id package_ids earliest transaction/;

  my $action_name = $params{action_name} || "Package Installs";
  my $type_label = 'packages.update';

  if ($package_id) {
    my $package = RHN::Package->lookup(-id => $package_id);

    die "package lookup failed!" if !$package;

    $type_label = RHN::Package->package_arch_type_action($package_id, 'install');

    $action_name = "Package Install:  " . $package->nvre;
  }

  my ($id, $stat_id) = $class->make_base_action(-org_id => $org_id,
						-user_id => $user_id,
						-type_label => $type_label,
						-earliest => $earliest,
						-action_name => $action_name,
						-prerequisite => $params{prerequisite},
					       );

  my $dbh = $trans || RHN::DB->connect;
  my $query;
  my $sth;

  my $rhn_class = '';

  if ($package_id and $server_set) {
    $query = <<EOQ;
INSERT INTO rhnServerAction (server_id, action_id, status)
(
SELECT  ST.element, ?, ?
  FROM  web_contact WC, rhnSet ST
 WHERE  ST.user_id = ?
   AND  ST.label = ?
   AND  ST.user_id = WC.id
   AND  ST.element IN (
SELECT	S.id
  FROM  rhnArchType AT, rhnPackageArch PA, rhnPackage P, rhnChannelPackage CP, rhnServerChannel SC, rhnServer S
 WHERE  S.org_id = WC.org_id
   AND  EXISTS (SELECT 1 FROM rhnEntitledServers ES WHERE ES.id = S.id)
   AND  SC.server_id = S.id
   AND  SC.channel_id = CP.channel_id
   AND  CP.package_id = ?
   AND  CP.package_id = P.id
   AND  PA.id = P.package_arch_id
   AND  AT.id = PA.arch_type_id
   AND  (   (NVL((SELECT MAX(PE.evr)
                    FROM rhnServerPackage SP, rhnPackageEvr PE
                   WHERE SP.name_id = P.name_id
                     AND SP.server_id = S.id
                     AND SP.evr_id = PE.id), ${rhn_class}EVR_T(NULL, 0, 0))
             <
             (SELECT EVR FROM rhnPackageEVR PE WHERE PE.id = P.evr_id)
            )
         OR AT.label = 'solaris-patch'
         OR AT.label = 'solaris-patch-cluster'
        )
)
   AND  EXISTS (SELECT 1 FROM rhnEntitledServers ES WHERE ES.id = element)
)
EOQ
    $sth = $dbh->prepare($query);
    #  warn "ins query:  $query\n$id, $stat_id, $user_id, ".$servers->label;
    $sth->execute($id, $stat_id, $user_id, $server_set->label, $package_id);
  }
  elsif ($server_set) {
    $query = <<EOQ;
INSERT INTO rhnServerAction (server_id, action_id, status)
(SELECT element, ?, ? FROM rhnSet WHERE user_id = ? AND label = ? AND EXISTS (SELECT 1 FROM rhnEntitledServers ES WHERE ES.id = element))
EOQ
    $sth = $dbh->prepare($query);
    #  warn "ins query:  $query\n$id, $stat_id, $user_id, ".$servers->label;
    $sth->execute($id, $stat_id, $user_id, $server_set->label);
  }
  elsif ($server_id) {
        $query = <<EOQ;
INSERT INTO rhnServerAction (server_id, action_id, status)
VALUES  (?, ?, ?)
EOQ
    $sth = $dbh->prepare($query);
    #  warn "ins query:  $query\n$id, $stat_id, $user_id, ".$servers->label;
    $sth->execute($server_id, $id, $stat_id);
  }
  else {
    die "no servers!";
  }

  if ($package_set) {
    $query = <<EOQ;
INSERT INTO rhnActionPackage (id, action_id, name_id, evr_id)
(SELECT rhn_act_p_id_seq.nextval, ?, element, element_two FROM rhnSet WHERE user_id = ? AND label = ?)
EOQ
    $sth = $dbh->prepare($query);
    #  warn "ins query:  $query\n$id, $user_id, ".$packages->label;
    $sth->execute($id, $user_id, $package_set->label);
  }
  elsif ($package_id) {
    $query = <<EOQ;
INSERT INTO rhnActionPackage (id, action_id, name_id, evr_id)
(SELECT rhn_act_p_id_seq.nextval, ?, P.name_id, P.evr_id FROM rhnPackage P WHERE P.id = ?)
EOQ
    $sth = $dbh->prepare($query);
    #  warn "ins query:  $query\n$id, $user_id, ".$packages->label;
    $sth->execute($id, $package_id);
  }
  elsif ($package_ids) {
    $query =<<EOQ;
INSERT INTO rhnActionPackage (id, action_id, name_id, evr_id)
(SELECT rhn_act_p_id_seq.nextval, ?, P.name_id, P.evr_id FROM rhnPackage P WHERE P.id = ?)
EOQ
    $sth = $dbh->prepare($query);

    foreach my $pid (@{$package_ids}) {
      $sth->execute($id, $pid);
    }
  }
  else {
    die "no packages provided!";
  }
  $dbh->commit
    unless $trans;

  osa_wakeup_tickle();

  return $id;
}

sub sscd_schedule_package_installations {
  my $class = shift;
  my %params = @_;

  my ($earliest, $org_id, $user_id, $channel_id, $label) = map { $params{"-" . $_} } qw/earliest org_id user_id  channel_id label/;
  $label ||=  'package_installable_list';

  my $dbh = RHN::DB->connect;
  my $query;
  my $sth;

  my %actions;

  # figure out what all the different actions we're going to need to create are...
  if (($label eq 'patch_installable_list') or 
      ($label eq 'patchset_installable_list')) {
	# for patch and package we get in rhnSet.element rhnPackage.name_id
        # and in element_two is evr
	$query = <<EOQ;
SELECT DISTINCT ActionT.label, ActionT.name
  FROM rhnActionType ActionT,
       rhnArchTypeActions ATA,
       rhnPackageArch PA,
       rhnPackage P,
       rhnSet ST,
       rhnChannelPackage CP
 WHERE ST.user_id = :user_id
   AND ST.label = :set_label
   AND ST.element = P.name_id
   AND ST.element_two = P.evr_id
   AND CP.package_id = P.id
   AND CP.channel_id = :cid
   AND P.package_arch_id = PA.id
   AND PA.arch_type_id = ATA.arch_type_id
   AND ATA.action_style = :action_style
   AND ActionT.id = ATA.action_type_id
EOQ
  } else {
    # for everything else we get in rhnSet.element rhnPackage.id
    $query = <<EOQ;
SELECT DISTINCT ActionT.label, ActionT.name
  FROM rhnActionType ActionT,
       rhnArchTypeActions ATA,
       rhnPackageArch PA,
       rhnPackage P,
       rhnSet ST,
       rhnChannelPackage CP
 WHERE ST.user_id = :user_id
   AND ST.label = :set_label
   AND ST.element = P.id
   AND CP.package_id = P.id
   AND CP.channel_id = :cid
   AND P.package_arch_id = PA.id
   AND PA.arch_type_id = ATA.arch_type_id
   AND ATA.action_style = :action_style
   AND ActionT.id = ATA.action_type_id
EOQ
  }

  $sth = $dbh->prepare($query);

  $sth->execute_h(user_id => $user_id,
		  set_label => $label,
		  action_style => 'install',
		  cid => $channel_id);

  while (my ($action_type, $action_type_name) = $sth->fetchrow) {

    my @action = $class->make_base_action(-org_id => $org_id,
					  -user_id => $user_id,
					  -type_label => $action_type,
					  -earliest => $earliest,
					  -action_name => $action_type_name . "(s)",
					 );

    $actions{$action_type}->{action_id} = $action[0];
    $actions{$action_type}->{stat_id} = $action[1];
  }

  $query = <<EOQ;
INSERT INTO rhnServerAction (server_id, action_id, status)
(
SELECT  element, :action_id, :status_id
  FROM  rhnServerChannel SC, rhnSet ST
 WHERE  ST.user_id = :user_id
   AND  ST.label = 'system_list'
   AND  ST.element = SC.server_id
   AND  SC.channel_id = :channel_id
)
EOQ

  $sth = $dbh->prepare($query);

  foreach my $action_type (keys %actions) {
	my $a=$actions{$action_type}->{action_id};
	my $b=$actions{$action_type}->{stat_id};
    $sth->execute_h(action_id => $actions{$action_type}->{action_id},
		    status_id => $actions{$action_type}->{stat_id},
		    user_id => $user_id,
		    channel_id => $channel_id);
  }

  if (($label eq 'patch_installable_list') or
      ($label eq 'patchset_installable_list')) {
    $query = <<EOQ;
INSERT INTO rhnActionPackage (id, action_id, name_id, evr_id, package_arch_id)
SELECT rhn_act_p_id_seq.nextval,
       :action_id,
       P.name_id,
       P.evr_id,
       P.package_arch_id
  FROM rhnActionType ActionT,
       rhnArchTypeActions ATA,
       rhnPackageArch PA,
       rhnPackage P,
       rhnChannelPackage CP,
       rhnSet S
 WHERE S.user_id = :user_id
   AND S.label = :set_label
   AND S.element = P.name_id
   AND S.element_two = P.evr_id
   AND CP.channel_id = :cid
   AND CP.package_id = P.id
   AND P.package_arch_id = PA.id
   AND PA.arch_type_id = ATA.arch_type_id
   AND ATA.action_style = 'install'
   AND ActionT.id = ATA.action_type_id
   AND ActionT.label = :action_type
EOQ
  } else {
    $query = <<EOQ;
INSERT INTO rhnActionPackage (id, action_id, name_id, evr_id, package_arch_id)
SELECT rhn_act_p_id_seq.nextval,
       :action_id,
       P.name_id,
       P.evr_id,
       P.package_arch_id
  FROM rhnActionType ActionT,
       rhnArchTypeActions ATA,
       rhnPackageArch PA,
       rhnPackage P,
       rhnChannelPackage CP,
       rhnSet S
 WHERE S.user_id = :user_id
   AND S.label = :set_label
   AND P.id = S.element
   AND CP.channel_id = :cid
   AND CP.package_id = P.id
   AND P.package_arch_id = PA.id
   AND PA.arch_type_id = ATA.arch_type_id
   AND ATA.action_style = 'install'
   AND ActionT.id = ATA.action_type_id
   AND ActionT.label = :action_type
EOQ
  }

  $sth = $dbh->prepare($query);

  foreach my $action_type (keys %actions) {
    $sth->execute_h(action_id => $actions{$action_type}->{action_id},
		    user_id => $user_id,
		    set_label => $label,
		    action_type => $action_type,
		    cid => $channel_id);
  }


  $dbh->commit;

  osa_wakeup_tickle();

  return \%actions;
}


sub schedule_package_remove {
  my $class = shift;
  my %params = @_;

  my ($org_id, $user_id, $server_set, $package_set, $server_id, $package_id, $package_id_combos, $earliest) =
    map { $params{"-" . $_} } qw/org_id user_id server_set package_set server_id package_id package_id_combos earliest/;


  my ($id, $stat_id) = $class->make_base_action(-org_id => $org_id,
						-user_id => $user_id,
						-type_label => 'packages.remove',
						-earliest => $earliest,
					       );

  my $dbh = RHN::DB->connect;
  my $sth;

  if ($server_set) {

    $sth = $dbh->prepare(<<EOQ);
INSERT INTO rhnServerAction (server_id, action_id, status)
(SELECT element, ?, ? FROM rhnSet WHERE user_id = ? AND label = ? AND EXISTS (SELECT 1 FROM rhnEntitledServers ES WHERE ES.id = element))
EOQ
    $sth->execute($id, $stat_id, $user_id, $server_set->label);
  }
  elsif ($server_id) {

    $sth = $dbh->prepare(<<EOQ);
INSERT INTO rhnServerAction (server_id, action_id, status)
(SELECT ES.id, ?, ? FROM rhnEntitledServers ES WHERE ES.id = ?)
EOQ
    $sth->execute($id, $stat_id, $server_id);
  }
  else {
    die "impossible condition reached";
  }


  if ($package_set) {
    $sth = $dbh->prepare(<<EOQ);
INSERT INTO rhnActionPackage (id, action_id, name_id, evr_id)
(SELECT rhn_act_p_id_seq.nextval, ?, element, element_two FROM rhnSet WHERE user_id = ? AND label = ?)
EOQ
    $sth->execute($id, $user_id, $package_set->label);
  }
  elsif ($package_id) {
    die "not yet implemented...";
  }
  elsif ($package_id_combos) {
    throw "package_id_combos param must be an arrayref" unless (ref $package_id_combos eq 'ARRAY');
    $sth = $dbh->prepare(<<EOQ);
INSERT
  INTO rhnActionPackage
       (id, action_id, name_id, evr_id)
VALUES (rhn_act_p_id_seq.nextval, ?, ?, ?)
EOQ

    foreach my $pid_combo (@{$package_id_combos}) {
      my ($name_id, $evr_id) = split(/\|/, $pid_combo);
      throw "Format of $pid_combo is not name_id|evr_id" unless ($name_id and $evr_id);

      $sth->execute($id, $name_id, $evr_id);
    }
  }
  else {
    die "impossible condition reached";
  }

  $dbh->commit;

  osa_wakeup_tickle();

  return $id;
}

# n systems
sub schedule_all_errata_for_systems {
  my $class = shift;
  my %params = @_;

  my ($org_id, $user_id, $earliest, $server_set) =
    map { $params{"-" . $_} } qw/org_id user_id earliest server_set/;

  die "no servers!" unless $server_set;

  my $ds = new RHN::DataSource::Errata (-mode => 'unscheduled_relevant_to_system_set');
  my $data = $ds->execute_query(-user_id => $user_id, -set_label => 'system_list');
  my @errata_ids = map { $_->{ID} } @{$data};

  my $errata_set = new RHN::DB::Set "sscd_temp_errata_list", $user_id;

  $errata_set->add(@errata_ids);
  $errata_set->commit;

  RHN::DB::Scheduler->schedule_errata_updates_for_systems(-org_id => $org_id,
							  -user_id => $user_id,
							  -earliest => $earliest,
							  -server_set => $server_set,
							  -errata_set => $errata_set,
							 );

  $errata_set->empty;
  $errata_set->commit;

  osa_wakeup_tickle();
}

# n errata, n systems
sub schedule_errata_updates_for_systems {
  my $class = shift;
  my %params = @_;

  my ($org_id, $user_id, $earliest, $server_set, $errata_set) =
    map { $params{"-" . $_} } qw/org_id user_id earliest server_set errata_set/;

  die "no servers!" unless $server_set;
  die "no errata!" unless $errata_set;

  my $dbh = RHN::DB->connect;
  my $sth;

  # this is potentially a very expensive way of doing this.  i'm breaking each errata
  # into its own action, and also *only* giving it the servers that are relevant to it...
  my $errata_counter = 1;
  my @errata_ids = $errata_set->contents;
  my $errata_total = @errata_ids;

  my @action_ids;

  foreach my $errata_id (@errata_ids) {
    my $errata = RHN::Errata->lookup(-id => $errata_id);

    die "errata lookup failed!" if !$errata;

#    my $action_name = "Errata Update: " . $errata->advisory . ($errata_total > 1 ? " ($errata_counter of $errata_total)" : "");
    my $action_name = "Errata Update: " . $errata->advisory . ' - ' . $errata->synopsis;

    my ($action_id, $stat_id) = $class->make_base_action(-org_id => $org_id,
							 -user_id => $user_id,
							 -type_label => 'errata.update',
							 -earliest => $earliest,
							 -action_name => $action_name,
							);

    $sth = $dbh->prepare(<<EOQ);
INSERT INTO rhnServerAction (server_id, action_id, status)
(
SELECT  element, ?, ?
  FROM  rhnSet ST
 WHERE  ST.user_id = ?
   AND  ST.label = ?
   AND  EXISTS (SELECT 1 FROM rhnUserServerPerms USP WHERE USP.user_id = ST.user_id AND USP.server_id = ST.element)
   AND  EXISTS (SELECT 1 FROM rhnEntitledServers ES WHERE ES.id = ST.element)
   AND  EXISTS (SELECT 1 FROM rhnServerNeededErrataCache SNEC WHERE SNEC.server_id = element AND SNEC.errata_id = ?)
)
EOQ
    $sth->execute($action_id, $stat_id, $user_id, $server_set->label, $errata_id);

    $sth = $dbh->prepare(<<EOQ);
INSERT INTO rhnActionErrataUpdate (action_id, errata_id) VALUES (?, ?)
EOQ
    $sth->execute($action_id, $errata_id);

    $dbh->commit;
    push @action_ids, $action_id;
    $errata_counter++;
  }

  osa_wakeup_tickle();

  return @action_ids;
}

# 1 system
sub schedule_all_errata_updates_for_system {
  my $class = shift;
  my %params = @_;
  my ($org_id, $user_id, $earliest, $server_id) =
    map { $params{"-" . $_} } qw/org_id user_id earliest server_id/;

  throw "no system" unless $server_id;
  my $server = RHN::Server->lookup(-id => $server_id);
  throw "system '$server_id' is not entitled" unless $server->is_entitled;

  my $ds = new RHN::DataSource::Errata (-mode => 'unscheduled_relevant_to_system');
  my $data = $ds->execute_query(-user_id => $user_id, -sid => $server_id);
  my @errata_ids = map { $_->{ID} } @{$data};

  my $dbh = RHN::DB->connect;

  foreach my $errata_id (@errata_ids) {
    my $errata = RHN::Errata->lookup(-id => $errata_id);

    throw "errata '$errata_id' lookup failed" unless $errata;

    my $action_name = "Errata Update: " . $errata->advisory . ' - ' . $errata->synopsis;

    my ($action_id, $stat_id) = $class->make_base_action(-org_id => $org_id,
							 -user_id => $user_id,
							 -type_label => 'errata.update',
							 -earliest => $earliest,
							 -action_name => $action_name,
							);

    my $sth = $dbh->prepare(<<EOQ);
INSERT
  INTO rhnServerAction
       (server_id, action_id, status)
VALUES (:sid, :action_id, :stat_id)
EOQ
    $sth->execute_h(action_id => $action_id, stat_id => $stat_id, sid => $server_id);

    $sth = $dbh->prepare(<<EOQ);
INSERT
  INTO rhnActionErrataUpdate
       (action_id, errata_id)
VALUES (:action_id, :eid)
EOQ
    $sth->execute_h(action_id => $action_id, eid => $errata_id);

  }

  $dbh->commit;

  osa_wakeup_tickle();

  return scalar @errata_ids;
}

# n errata, 1 system
sub schedule_errata_updates_for_system {
  my $class = shift;
  my %params = @_;

  my ($org_id, $user_id, $earliest, $server_id, $errata_set, $errata_ids) =
    map { $params{"-" . $_} } qw/org_id user_id earliest server_id errata_set errata_ids/;


  die "no server!" unless $server_id;
  die "no errata!" unless $errata_set or $errata_ids;

  my $dbh = RHN::DB->connect;
  my $sth;

  my @errata_ids;
  if ($errata_ids) {
    @errata_ids = @$errata_ids;
  }
  else {
    @errata_ids = $errata_set->contents;
  }

  my $errata_counter = 1;
  my $errata_total = @errata_ids;

  my @action_ids;
  foreach my $errata_id (@errata_ids) {

    my $errata = RHN::Errata->lookup(-id => $errata_id);

    die "errata lookup failed!" if !$errata;

#    my $action_name = "Errata Update: " . $errata->advisory . ($errata_total > 1 ? " ($errata_counter of $errata_total)" : "");
    my $action_name = "Errata Update: " . $errata->advisory . ' - ' . $errata->synopsis;

    my ($action_id, $stat_id) = $class->make_base_action(-org_id => $org_id,
							 -user_id => $user_id,
							 -type_label => 'errata.update',
							 -earliest => $earliest,
							 -action_name => $action_name,
							);

#    warn "action id == $action_id, stat id == $stat_id";

    $sth = $dbh->prepare(<<EOQ);
INSERT INTO rhnServerAction (server_id, action_id, status)
(
SELECT    S.ID, ?, ?
  FROM    rhnServer S
 WHERE    S.ID = ?
AND EXISTS (SELECT 1 FROM rhnEntitledServers ES WHERE ES.id = S.ID)
)
EOQ

    $sth->execute($action_id, $stat_id, $server_id);

    $sth = $dbh->prepare(<<EOQ);
INSERT INTO rhnActionErrataUpdate (action_id, errata_id) VALUES (?, ?)
EOQ
    $sth->execute($action_id, $errata_id);

    $dbh->commit;
    $errata_counter++;

    push @action_ids, $action_id;
  }

  osa_wakeup_tickle();

  return @action_ids;
}

sub schedule_package_sync {
  my $class = shift;
  my %params = validate(@_, { org_id => 1,
			      user_id => 1,
			      server_id => 1,
			      earliest => 1,
			      comparison => 1,
			      action_name => 0,
			      transaction => 0,
			      prerequisite => 0,
			    });

  my $dbh = $params{transaction} || RHN::DB->connect;

  my ($action_id, $stat_id) = $class->make_base_action(-org_id => $params{org_id},
						       -user_id => $params{user_id},
						       -type_label => 'packages.runTransaction',
						       -earliest => $params{earliest},
						       -action_name => $params{action_name},
						       -prerequisite => $params{prerequisite},
						       -transaction => $params{transaction},
						      );

  $dbh = $class->add_servers_to_action($action_id, $stat_id, $params{user_id}, undef, $params{server_id}, $dbh);

  my $sth;
  $sth = $dbh->prepare(<<EOS);
SELECT rhn_packagedelta_id_seq.nextval FROM DUAL
EOS
  $sth->execute_h();
  my ($delta_id) = $sth->fetchrow;
  $sth->finish;

  $sth = $dbh->prepare(<<EOS);
INSERT INTO rhnPackageDelta
  (id, label)
VALUES
  (:id, 'delta-' || :id)
EOS
  $sth->execute_h(id => $delta_id);

  $sth = $dbh->prepare(<<EOS);
INSERT INTO rhnPackageDeltaElement
  (package_delta_id, transaction_package_id)
VALUES
  (:delta_id,
   lookup_transaction_package(:operation, :n, :e, :v, :r, :a))
EOS

  for my $compline (@{$params{comparison}}) {

    my @delta;

    # "upgrade" or "downgrade" are just insert then remove
    if ($compline->{S1} and not $compline->{S2}) {
      push @delta, [ "insert", $compline->{S1} ];
    }
    elsif ($compline->{S2} and not $compline->{S1}) {
      push @delta, [ "delete", $compline->{S2} ];
    }
    elsif ($compline->{S1} and $compline->{S2}) {
      if ($compline->{COMPARISON}) {
	push @delta, [ "insert", $compline->{S1} ];
	push @delta, [ "delete", $compline->{S2} ];
      }
      else {
	next;
      }
    }
    else {
      die "neither S1 or S2?";
    }


    $sth->execute_h(delta_id => $delta_id,
		    n => $_->[1]->name,
		    v => $_->[1]->version,
		    r => $_->[1]->release,
		    e => $_->[1]->epoch,
		    a => $_->[1]->arch,
		    operation => $_->[0]) for @delta;
  }

  $dbh->do("INSERT INTO rhnActionPackageDelta (action_id, package_delta_id) VALUES (?, ?)", {}, $action_id, $delta_id);


  if ($params{transaction}) {
    # XX FIXME: hunt this down and percolate the osa_wakeup up the stack a bit
    osa_wakeup_tickle();
    return ($action_id, $params{transaction});
  }
  else {
    $dbh->commit;
    osa_wakeup_tickle();

    return $action_id;
  }
}

sub reschedule_action {
  my $class = shift;
  my %params = @_;

  my $remaining_tries = 5; # arbitrary decision for now...

  my ($action_id, $org_id, $user_id, $server_set, $server_id) =
    map { $params{"-" . $_} } qw/action_id org_id user_id server_set server_id/;

  die "no action id!" unless $action_id;

  my $dbh = RHN::DB->connect;
  my $query;
  my $sth;

  if (!$server_id and !$server_set) {

    $query = <<EOQ;
UPDATE rhnServerAction
   SET status = 0,
       remaining_tries = :remaining_tries
 WHERE action_id = :action_id
   AND status = 3
EOQ

    $sth = $dbh->prepare($query);
    $sth->execute_h(action_id => $action_id, remaining_tries => $remaining_tries);
  }
  elsif ($server_id) {

    $query = <<EOQ;
UPDATE rhnServerAction
   SET status = 0,
       remaining_tries = :remaining_tries
 WHERE action_id = :action_id
   AND status = 3
   AND server_id = :server_id
EOQ

    $sth = $dbh->prepare($query);
    $sth->execute_h(action_id => $action_id, remaining_tries => $remaining_tries,
		    server_id => $server_id);
  }
  else {
    $query = <<EOQ;
UPDATE rhnServerAction
   SET status = 0,
       remaining_tries = :remaining_tries
 WHERE action_id = :action_id
   AND status = 3
   AND server_id IN (SELECT element FROM rhnSet WHERE user_id = :user_id AND label = :label)
EOQ

    $sth = $dbh->prepare($query);
    $sth->execute(action_id => $action_id,
		  user_id => $user_id,
		  label => $server_set->label,
		  remaining_tries => $remaining_tries);
  }

  $dbh->commit;

  osa_wakeup_tickle();
}

sub schedule_config_action {
  my $class = shift;
  my %params = validate(@_, { org_id => 1,
			      user_id => 1,
			      server_id => 1,
			      earliest => 1,
			      action_type => 1,
			      action_name => 1,
			      transaction => 0,
			      prerequisite => 0,
			      revision_ids => 1
			    });

  my $dbh = $params{transaction} || RHN::DB->connect;

  my ($action_id, $stat_id) = $class->make_base_action(-org_id => $params{org_id},
						       -user_id => $params{user_id},
						       -type_label => $params{action_type},
						       -earliest => $params{earliest},
						       -action_name => $params{action_name},
						       -prerequisite => $params{prerequisite},
						       -transaction => $dbh,
						      );

  $class->add_servers_to_action($action_id, $stat_id, $params{user_id}, undef, $params{server_id});

  my $query;
  my $sth;

  if (grep { $params{action_type} eq $_ } qw/configfiles.deploy configfiles.verify configfiles.diff/) {
    $query =<<EOQ;
INSERT
  INTO rhnActionConfigRevision
       (id, action_id, server_id, config_revision_id)
VALUES (rhn_actioncr_id_seq.nextval, :aid, :server_id, :revision_id)
EOQ

    $sth = $dbh->prepare($query);

    foreach my $revision_id (@{$params{revision_ids}}) {
      $sth->execute_h(aid => $action_id,
		      server_id => $params{server_id},
		      revision_id => $revision_id,
		     );
    }
  }
  elsif ($params{action_type} eq 'configfiles.upload') {
    die 'invalid option; you should be using scheduled_config_upload instead';
  }
  else {
    die "unknown config file action!";
  }

  $dbh->commit unless $params{transaction};

  # XXX FIXME:  trace and percolate up
  osa_wakeup_tickle();

  return ($action_id, $dbh);
}


sub associate_answer_files_with_action {
  my $class = shift;
  my $action_id = shift;
  my $package_answer_files = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
INSERT
  INTO rhnActionPackageAnswerFile
       (action_package_id, answerfile)
       (SELECT AP.id, :answerfile
          FROM rhnActionPackage AP
         WHERE AP.action_id = :aid
           AND AP.name_id = :name_id
           AND AP.evr_id = :evr_id)
EOQ

  foreach my $id_combo (keys %{$package_answer_files}) {
    my ($name_id, $evr_id) = split(/\|/, $id_combo);

    unless ($name_id and $evr_id) {
      die "package_answer_files hash '" . Data::Dumper->Dump([($package_answer_files)])
	. "' for action id '$action_id' did not provide name_id and evr_id";
    }

    $sth->execute_h(aid => $action_id, name_id => $name_id, evr_id => $evr_id,
		    answerfile => $dbh->encode_blob($package_answer_files->{$id_combo}, 'answerfile'));
  }

  $dbh->commit;

  osa_wakeup_tickle();

  return;
}

sub schedule_remote_command {
  my $class = shift;
  my %params = validate(@_, { org_id => 1,
			      user_id => 1,
			      earliest => 1,
			      server_id => 0,
			      server_ids => 0,
			      server_set => 0,
			      prerequisite => 0,
			      action_name => 0,
			      script => 1,
			      username => 1,
			      group => 1,
			      timeout => 0,
			    });

  # /bin/sh doesn't like \r\n's (at least on lovely solaris
  $params{script} =~ s{\r\n}{\n}gism;

  my ($action_id, $stat_id) = $class->make_base_action(-org_id => $params{org_id},
						       -user_id => $params{user_id},
						       -type_label => 'script.run',
						       -earliest => $params{earliest},
						       -action_name => $params{action_name},
						       -prerequisite => $params{prerequisite},
						      );

  my $dbh = RHN::DB->connect;
  my $sth;

  if ($params{server_set}) {

    # can't use the normal add_systems for the set...
    $sth = $dbh->prepare(<<EOQ);
INSERT INTO rhnServerAction (server_id, action_id, status)
SELECT DISTINCT S.id, :action_id, :status
  FROM rhnServer S,
       rhnClientCapabilityName CCN,
       rhnClientCapability CC,
       rhnSet ST,
       rhnUserServerPerms USP
 WHERE USP.user_id = :user_id
   AND ST.user_id = :user_id
   AND ST.label = :set_label
   AND USP.server_id = ST.element
   AND rhn_server.system_service_level(USP.server_id, 'provisioning') > 0
   AND USP.server_id = CC.server_id
   AND CC.capability_name_id = CCN.id
--   AND CCN.name = 'script.run'
   AND USP.server_id = S.id
EOQ
    $sth->execute_h(user_id => $params{user_id},
		    action_id => $action_id,
		    status => $stat_id,
		    set_label => $params{server_set}->label
		   );
  }
  elsif ($params{server_id}) {
    $class->add_servers_to_action($action_id,
				  $stat_id,
				  $params{user_id},
				  undef,
				  $params{server_id});
  }
  elsif ($params{server_ids}) {
    $class->add_servers_to_action($action_id,
				  $stat_id,
				  $params{user_id},
				  undef,
				  undef,
				  undef,
				  $params{server_ids});
  }
  else {
    throw "(invalid_params) Need a server_id, server_ids, or a server_set when scheduling remote command";
  }

  $dbh = RHN::DB->connect;
  $sth = $dbh->prepare(<<EOQ);
INSERT
  INTO rhnActionScript
       (id, action_id, script, username, groupname, timeout)
VALUES (rhn_actscript_id_seq.nextval, :aid, :script, :username, :groupname, :timeout)
EOQ

  $sth->execute_h(aid => $action_id,
		  script => $dbh->encode_blob($params{script}, 'script'),
		  username => $params{username},
		  groupname => $params{group},
		  timeout => $params{timeout},
		 );

  $dbh->commit;

  osa_wakeup_tickle();

  return $action_id;
}

1;
