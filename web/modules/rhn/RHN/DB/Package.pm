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

package RHN::DB::Package;


use strict;
use Data::Dumper;
use Carp;
use RHN::DB;
use RHN::DB::TableClass;
use RPM2;
use RHN::Exception qw/throw/;
use Params::Validate;
Params::Validate::validation_options(strip_leading => "-");

use RHN::Package::SolarisPackage;
use RHN::Package::SolarisPatch;
use RHN::Package::SolarisPatchSet;

my @pkg_fields = qw/
		    id org_id name_id evr_id package_arch_id package_group rpm_version description
		    summary package_size payload_size build_host build_time:longdate source_rpm_id
		    vendor payload_format compat path header_sig copyright cookie last_modified:longdate
		    /;
my @arch_fields = qw { id name label arch_type_id};
my @name_fields = qw { id name };
my @evr_fields = qw { id epoch version release };
my @group_fields = qw { id name };
my @srpm_fields = qw { id name };
my @csum_fields = qw { id checksum };

my $p = new RHN::DB::TableClass("rhnPackage","P","",@pkg_fields);
my $a = new RHN::DB::TableClass("rhnPackageArch","PA","arch",@arch_fields);
my $n = new RHN::DB::TableClass("rhnPackageName", "PN", "package_name", @name_fields);
my $evr = new RHN::DB::TableClass("rhnPackageEVR", "PEVR", "package_evr", @evr_fields);
my $pg = new RHN::DB::TableClass("rhnPackageGroup", "PG", "package_group", @group_fields);
my $srpm = new RHN::DB::TableClass("rhnSourceRPM", "SRPM", "s_rpm", @srpm_fields);
my $csum = new RHN::DB::TableClass("rhnChecksum", "Csum", "checksum", @csum_fields);

my $tc = $p->create_join([ $a, $n, $evr, $pg, $srpm, $csum ],{ "rhnPackage" => {
									 "rhnPackage" => [ "ID", "ID" ],
									 "rhnPackageArch" => ["PACKAGE_ARCH_ID", "ID" ],
									 "rhnPackageName" => ["NAME_ID", "ID"],
									 "rhnPackageEVR" => ["EVR_ID", "ID"],
									 "rhnPackageGroup" => ["PACKAGE_GROUP", "ID"],
									 "rhnSourceRPM" => ["SOURCE_RPM_ID", "ID"],
									 "rhnChecksum" => ["CHECKSUM_ID", "ID"],
									}
						      },
			 { rhnSourceRPM => "(+)",
			   rhnPackageGroup => "(+)" }
			);

# read only fields
my %ro = map { $_ => 1 } $tc->column_names;


sub other_archs_available {
  my $self = shift;
  my $org_id = shift;

  my $dbh = RHN::DB->connect;
  my $query;
  my $sth;

  $query = <<EOQ;
SELECT P.id, PA.name
  FROM rhnPackageArch PA, rhnChannelPackage CP, rhnPackage P
 WHERE 1=1
   AND P.name_id = ?
   AND P.id != ?
   AND P.evr_id = ?
   AND CP.package_id = P.id
   AND EXISTS (
       SELECT 1
         FROM rhnChannelPermissions
        WHERE org_id = ?
          AND channel_id = cp.channel_id
       )
   AND P.package_arch_id = PA.id
EOQ

#  warn "other archs query:\n$query\n$org_id, ".$self->name_id.", ".$self->evr_id.", ".$self->id;

  $sth = $dbh->prepare($query);
  $sth->execute($self->name_id, $self->id, $self->evr_id, $org_id);

  my @columns;
  my @ret;
  while(@columns = $sth->fetchrow) {
#    warn "x: @columns";
    push @ret, [ @columns ];
  }

  $sth->finish;
  return @ret;
}


# list channels providing this package
sub channels {
  my $self = shift;
  my $pid = (ref $self) ? $self->id : shift; #class or object method
  my $org_id = shift;

  my $dbh = RHN::DB->connect;
  my $query;
  my $sth;

  $query = <<EOQ;
SELECT  C.id, C.name
  FROM  rhnAvailableChannels AC, rhnChannel C, rhnChannelPackage CP
 WHERE  CP.package_id = ?
   AND  CP.channel_id = C.id
   AND  AC.org_id = ?
   AND  C.id = AC.channel_id
ORDER BY UPPER(C.name)
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute($pid, $org_id);

  my @columns;
  my @ret;
  while(@columns = $sth->fetchrow) {
    push @ret, [ @columns ];
  }

  $sth->finish;
  return @ret;
}

sub package_names_by_provide {
  my $class = shift;
  my %params = validate(@_, {org_id => 1, cap_name => 1});

  my $ds = new RHN::DataSource::Package(-mode => 'name_by_provide');

  return $ds->execute_query(-org_id => $params{org_id}, -cap_name => $params{cap_name});
}

sub package_set_channels {
  my $class = shift;
  my $set_label = shift;
  my $uid = shift;
  my $org_id = shift;

  my $dbh = RHN::DB->connect;
  my $query = <<EOQ;
SELECT  DISTINCT CP.channel_id
  FROM  rhnAvailableChannels AC, rhnChannelPackage CP, rhnSet S
 WHERE  S.label = :set_label
   AND  S.user_id = :user_id
   AND  CP.package_id = S.element
   AND  AC.org_id = :org_id
   AND  CP.channel_id = AC.channel_id
EOQ

  my $sth = $dbh->prepare($query);

  $sth->execute_h(set_label => $set_label, user_id => $uid, org_id => $org_id);

  my @ret;

  while (my ($id) = $sth->fetchrow) {
    push @ret, $id;
  }

  return @ret;
}

#grab channel names for package id.
sub package_channel_names {
  my $class = shift;
  my $pid = shift;
  my $org_id = shift;

  return unless $pid;

  my $dbh = RHN::DB->connect;

  my $query = <<EOQ;
  SELECT AC.channel_name
    FROM rhnChannelPackage CP, rhnAvailableChannels AC
   WHERE AC.org_id = ?
     AND CP.package_id = ?
     AND AC.channel_id = CP.channel_id
ORDER BY UPPER(AC.channel_name)
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute($org_id, $pid);

  my @ret;

  while (my ($data) = $sth->fetchrow) {
    push @ret, $data;
  }

  unless (@ret) {
    @ret = ('&nbsp');
  }

  return @ret;

}

sub source_rpm {
  my $self = shift;

  my $dbh = RHN::DB->connect;
  my $query;
  my $sth;

  $query = <<EOQ;
SELECT  SR.name
  FROM  rhnSourceRPM SR
 WHERE  SR.id = ?
EOQ

#  warn "source rpm query:\n$query\n".$self->source_rpm_id;

  $sth = $dbh->prepare($query);
  $sth->execute($self->source_rpm_id);

  my @columns;
  my $ret;
  if(@columns = $sth->fetchrow) {
    $ret = $columns[0];
  }
  $sth->finish;
  return $ret;
}

sub change_log {
  my $self = shift;

  my $dbh = RHN::DB->connect;
  my $query;
  my $sth;

  $query = <<EOQ;
SELECT  PCL.name, PCL.text, TO_CHAR(PCL.time, 'YYYY-MM-DD HH24:MI:SS') as TIME
  FROM  rhnPackageChangeLog PCL
 WHERE  PCL.package_id = :pid
ORDER BY  PCL.time DESC
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute_h(pid => $self->id);

  my @ret;
  while(my $row = $sth->fetchrow_hashref) {
    push @ret, $row;
  }
  $sth->finish;
  return @ret;
}

sub nvre {
  my $self = shift;

  my $nvre = $self->nvre_epochless;
  $nvre .= defined $self->package_evr_epoch ? ":".$self->package_evr_epoch : "";
  return $nvre;
}

sub nvre_epochless {
  my $self = shift;

  my $nvre = join('-', ($self->package_name_name, $self->package_evr_version, $self->package_evr_release));
  return $nvre;
}

sub lookup_nvre {
  my $class = shift;
  my $name_id = shift;
  my $evr_id = shift;

  my $dbh = RHN::DB->connect;
  my $query;
  my $sth;

  $query = <<EOQ;
SELECT  PN.name || '-' || PE.evr.as_vre_simple()
  FROM  rhnPackageName PN, rhnPackageEVR PE
 WHERE  PN.id = ?
   AND  PE.id = ?
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute($name_id, $evr_id);

  my @columns;
  my $ret;
  if(@columns = $sth->fetchrow) {
    $ret = $columns[0];
  }
  $sth->finish;
  return $ret;
}

sub license {
  return "FIXME";
}

sub file_list {
  my $self = shift;
  my %params = @_;

  my ($lower, $upper, $total_ref) = map { $params{"-" . $_} } qw/lower upper total_rows/;

  $lower ||= 1;
  $upper ||= 100000;


  my $dbh = RHN::DB->connect;
  my $query;
  my $sth;

  $query = <<EOQ;
SELECT C.name, F.file_size, Csum.checksum md5, F.file_mode
  FROM rhnPackageFile F, rhnPackageCapability C, rhnChecksum Csum
 WHERE F.package_id = ?
   AND F.capability_id = C.id
   AND F.checksum_id = Csum.id
ORDER BY UPPER(C.name)
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute($self->id);

  my @columns;
  my @ret;
  my $i = 1;
  $$total_ref = 0;
  while(@columns = $sth->fetchrow) {
    $$total_ref = $i;
    if ($i >= $lower and $i <= $upper) {
      push @ret, [ @columns ];
    }
    $i++;
  }
  $sth->finish;

  return @ret;
}

sub provides {
  my $self = shift;

  my @ret;
  my $dbh = RHN::DB->connect;
  my $query;
  my $sth;

  $query = <<EOQ;
SELECT  DISTINCT C.name, C.version, P.sense
  FROM  rhnPackageCapability C, rhnPackageProvides P
 WHERE  P.package_id = ?
   AND  P.capability_id = C.id
ORDER BY UPPER(C.name), C.version
EOQ


  $sth = $dbh->prepare($query);
  $sth->execute($self->id);

  my @columns;
  while(@columns = $sth->fetchrow) {
    push @ret, [ @columns ];
  }
  use Data::Dumper;
  return @ret;
}

sub requires {
  my $self = shift;

  my @ret;
  my $dbh = RHN::DB->connect;
  my $query;
  my $sth;

  $query = <<EOQ;
SELECT  DISTINCT C.name, C.version, P.sense 
  FROM  rhnPackageCapability C, rhnPackageRequires P
 WHERE  P.package_id = ?
   AND  P.capability_id = C.id
ORDER BY UPPER(C.name), C.version
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute($self->id);

  my @columns;
  while(@columns = $sth->fetchrow) {
    push @ret, [ @columns ];
  }

  return @ret;
}

# don't know what tables these next 2 will need to talk to...
sub obsoletes {
  my $self = shift;

  my @ret;
  my $dbh = RHN::DB->connect;
  my $query;
  my $sth;

  $query = <<EOQ;
SELECT  DISTINCT C.name, C.version, P.sense 
  FROM  rhnPackageCapability C, rhnPackageObsoletes P
 WHERE  P.package_id = ?
   AND  P.capability_id = C.id
ORDER BY UPPER(C.name), C.version
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute($self->id);

  my @columns;
  while(@columns = $sth->fetchrow) {
    push @ret, [ @columns ];
  }

  return @ret;
}

sub conflicts {
  my $self = shift;

  my @ret;
  my $dbh = RHN::DB->connect;
  my $query;
  my $sth;

  $query = <<EOQ;
SELECT  DISTINCT C.name, C.version, P.sense
  FROM  rhnPackageCapability C, rhnPackageConflicts P
 WHERE  P.package_id = ?
   AND  P.capability_id = C.id
ORDER BY UPPER(C.name), C.version
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute($self->id);

  my @columns;
  while(@columns = $sth->fetchrow) {
    push @ret, [ @columns ];
  }

  return @ret;
}

# given varying data, try to figure what freakin' package to load.
# NOTE:  Might I say, this sucketh much donkey wong.  Awaiting a better answer :(
sub guestimate_package_id {
  my $class = shift;
  my %params = @_;

  my ($channel_id, $name_id, $evr_id, $server_id) =
    map {$params{'-'.$_}} qw/channel_id name_id evr_id server_id/;

  my $dbh = RHN::DB->connect;
  my $query;
  my $sth;

  if (defined $channel_id and defined $name_id and defined $evr_id) {
    # Dunno if this can be done faster...
    $query = <<EOQ;
SELECT P.id, P.package_arch_id P_ARCH
  FROM rhnPackage P,
       rhnChannelPackage CP
 WHERE CP.channel_id = ?
   AND P.id = CP.package_id
   AND P.name_id = ?
   AND P.evr_id = ?
ORDER BY P.package_arch_id
EOQ

    $sth = $dbh->prepare($query);
    $sth->execute($channel_id, $name_id, $evr_id);

    my @columns = $sth->fetchrow;
    $sth->finish;

    return $columns[0];
  }
  elsif (defined $server_id and defined $name_id and defined $evr_id) {
    $query = <<EOQ;
SELECT P.id, P.package_arch_id P_ARCH
  FROM
       rhnServerPackageArchCompat SPAC,
       rhnServer S,
       rhnServerChannel SC,
       rhnChannelPackage CP,
       rhnPackage P
 WHERE S.id = :server_id
   AND P.name_id = :name_id
   AND P.evr_id = :evr_id
   AND p.id = cp.package_id
   and cp.channel_id = sc.channel_id
   AND SC.server_id = S.id
   AND S.server_arch_id = SPAC.server_arch_id
   AND SPAC.package_arch_id = P.package_arch_id
ORDER BY P.package_arch_id DESC
EOQ

    $sth = $dbh->prepare($query);
    $sth->execute_h(server_id => $server_id, name_id => $name_id, evr_id => $evr_id);

    my @columns = $sth->fetchrow;
    $sth->finish;

    return $columns[0];
  } else {
    croak "not enough information to make a guess about what package you're looking for!";
  }
}

sub lookup {
  my $class = shift;
  my %params = validate(@_, {id => 1});
  my $id = $params{id};

  my $dbh = RHN::DB->connect;

  my $query;
  my $sth;

  $query = $tc->select_query("P.ID = ?");

  $sth = $dbh->prepare($query);
  $sth->execute($id);

  my @columns = $sth->fetchrow;
  $sth->finish;

  my $ret;
  if ($columns[0]) {
    $ret = $class->blank_package;

    $ret->{__id__} = $columns[0];
    $ret->$_(shift @columns) foreach $tc->method_names;
    delete $ret->{":modified:"};
  }
  else {
    local $" = ", ";
    die "Error loading package; no ID? (@columns)";
  }

  return assign_correct_subclass($ret);
}


sub assign_correct_subclass {
  my $obj = shift;

  my $packaging_type = $obj->packaging_type;

  if ($packaging_type eq 'sysv-solaris') {
    bless $obj, 'RHN::Package::SolarisPackage';
  }
  elsif ($packaging_type eq 'solaris-patch') {
    bless $obj, 'RHN::Package::SolarisPatch';
  }
  elsif ($packaging_type eq 'solaris-patch-cluster') {
    bless $obj, 'RHN::Package::SolarisPatchSet';
  }

  return $obj->_init;
}

sub _init {
  my $self = shift;

  return $self;
}

sub blank_package {
  bless { }, shift;
}

sub create_package {
  my $class = shift;
  my $package = $class->blank_package;
  $package->{__id__} = -1;
  return $package;
}

sub package_fields {
  return @pkg_fields;
}

sub arch_fields {
  return @arch_fields;
}

sub commit {
  my $self = shift;

  if ($self->id == -1) {
    croak "${self}->commit called on attempt to create a new package " .
          "(Package creation not allowed)";
  }

  croak "$self->commit called on package without valid id" unless $self->id and $self->id > 0;

  my @modified = keys %{$self->{":modified:"}};
  # check modified against ro fields
  my @violations = grep { exists $ro{$_} } $tc->methods_to_columns(@modified);
  croak "${self}->commit attempt to modify read only fields " . join(" ",@violations) if(@violations);
  my %modified = map { $_ => 1 } @modified;

  return unless @modified;

  my $dbh = RHN::DB->connect;

  my @queries = $tc->update_queries($tc->methods_to_columns(@modified));

  foreach my $query (@queries) {
    local $" = ":";
    my $sth = $dbh->prepare($query->[0]);
    $sth->execute((map { $self->$_() } grep { exists $modified{$_} } @{$query->[1]}), $self->id);
    $dbh->commit;
  }

  delete $self->{":modified:"};
}

#
# Generate getter/setters
#
foreach my $field ($tc->method_names) {
  my $sub = q {
    sub [[field]] {
      my $self = shift;
      if (@_ and "[[field]]" ne "id") {
        $self->{":modified:"}->{[[field]]} = 1;
        $self->{__[[field]]__} = shift;
      }
      return $self->{__[[field]]__};
    }
  };

  $sub =~ s/\[\[field\]\]/$field/g;

  eval $sub;

  croak $@ if($@);
}

sub package_list_overview {
  my $class = shift;
  my %params = @_;

  my ($user_id, $lower, $upper, $total_rows, $view_mode, $mode_params, $like, $alphabar) =
    map {$params{'-'.$_}} qw/user_id lower upper total_rows view_mode mode_params like alphabar/;
  my $query;
  my @res;
  my @row;

  my $i = 1;
  $$total_rows = 0;

  my $dbh = RHN::DB->connect;

  if ($view_mode eq 'set') {
    $query = <<EOQ;
SELECT
	  PN.name, PE.evr.as_vre_simple(), PN.id || '|' || PE.id
FROM
	  rhnPackageName PN,
          rhnPackageEVR PE,
          rhnSet S
WHERE	  S.label = ?
AND       S.user_id = ?
AND	  S.element = PN.id
AND	  S.element_two = PE.id
ORDER BY  UPPER(PN.name)
EOQ
  }
  elsif ($view_mode eq 'channel') {
    $query = <<EOQ;
SELECT
          PN.name, CPO.evr.as_vre_simple(), PN.id || '|' || LOOKUP_EVR(CPO.evr.epoch, CPO.evr.version, CPO.evr.release)
FROM
          rhnPackageName PN,
          rhnChannelPackageOverview CPO
WHERE
          CPO.channel_id = ?
      AND PN.id = CPO.name_id
ORDER BY  UPPER(PN.name)
EOQ
  }
  elsif ($view_mode eq 'channel_name_search') {
    $query = <<EOQ;
SELECT
          PN.name, CPO.evr.as_vre_simple(), PN.id || '|' || LOOKUP_EVR(CPO.evr.epoch, CPO.evr.version, CPO.evr.release)
FROM
          rhnPackageName PN,
          rhnChannelPackageOverview CPO
WHERE
          CPO.channel_id = ?
      AND PN.id = CPO.name_id
      AND UPPER(PN.name) LIKE UPPER(?)
ORDER BY  UPPER(PN.name)
EOQ
  }
  elsif ($view_mode eq 'name_search') {
    $query = <<EOQ;
SELECT
          PN.name, CPO.evr.as_vre_simple(), PN.id || '|' || LOOKUP_EVR(CPO.evr.epoch, CPO.evr.version, CPO.evr.release)
FROM
          rhnPackageName PN,
          rhnChannelPackageOverview CPO
WHERE
          CPO.channel_id = ?
      AND PN.id = CPO.name_id
      AND UPPER(name) LIKE UPPER(?)
ORDER BY  UPPER(name)
EOQ
  }
  elsif ($view_mode eq 'install_action') {
    $query = <<EOQ;
SELECT
          PN.name, PE.evr.as_vre_simple(), PN.id || '|' || PE.id
FROM
          rhnPackageName PN,
          rhnPackageEVR PE,
          rhnActionPackage AP
WHERE
          AP.action_id = ?
      AND PN.id = AP.name_id
      AND PE.id = AP.evr_id
ORDER BY  UPPER(name)
EOQ
  }
  elsif ($view_mode eq 'removal_action') {
    $query = <<EOQ;
SELECT
          PN.name, PE.evr.as_vre_simple(), PN.id || '|' || PE.id
FROM
          rhnPackageName PN,
          rhnPackageEVR PE,
          rhnActionPackage AP
WHERE
          AP.action_id = ?
      AND PN.id = AP.name_id
      AND PE.id = AP.evr_id
ORDER BY  UPPER(name)
EOQ
  }
  elsif ($view_mode eq 'any_channel') {
    $query = <<EOQ;
  SELECT PN.name, PE.evr.as_vre_simple(), P.id
    FROM rhnPackageName PN, rhnPackageEVR PE, rhnPackage P
   WHERE P.org_id = ?
     AND PN.id = P.name_id
     AND PE.id = P.evr_id
ORDER BY UPPER(PN.name)
EOQ
  }
  elsif ($view_mode eq 'no_channels') {
    $query = <<EOQ;
  SELECT PN.name, PE.evr.as_vre_simple(), P.id
    FROM rhnPackageName PN, rhnPackageEVR PE, rhnPackage P
   WHERE P.org_id = ?
     AND PN.id = P.name_id
     AND PE.id = P.evr_id
     AND NOT EXISTS (SELECT 1
                       FROM rhnChannelPackage CP
		      WHERE P.id = CP.package_id)
ORDER BY UPPER(PN.name)
EOQ
  }
  elsif ($view_mode eq 'view_channel') {
    $query = <<EOQ;
  SELECT PN.name, PE.evr.as_vre_simple(), P.id
    FROM rhnPackageName PN, rhnPackageEVR PE, rhnPackage P, rhnChannelPackage CP
   WHERE CP.channel_id = ?
     AND P.id = CP.package_id
     AND PN.id = P.name_id
     AND PE.id = P.evr_id
ORDER BY UPPER(PN.name)
EOQ
  }
  else {
    croak "No supported view_mode specified, view_mode == $view_mode";
  }

  my $sth = $dbh->prepare($query);
  $sth->execute(@$mode_params, $like ? "%$like%" : ());

  my $lastalpha = '';
  while (@row = $sth->fetchrow) {
    my $alpha = lc(substr $row[0], 0, 1);
    if ($alpha ne $lastalpha) {
      $alphabar->{$alpha} = $i;
      $lastalpha = $alpha;
    }

    if ($i <= $upper and $i >= $lower) {
      push @res, [ @row ];
    }
    $$total_rows++;
    $i++;
  }

  return @res;
}

sub packages_available_to_server {
  my $class = shift;
  my $sid = shift;
  my $like = shift;

  my $query;
  my @res;
  my @row;

# TODO:  convert the hideous formatting of these queries

  if (defined $like and $like ne '') {
    $query = <<EOQ;
select
        pn.name,
        full_list.evr.version || '-' || full_list.evr.release || DECODE(full_list.evr.epoch, NULL, '', ':' || full_list.evr.epoch),
        pn.id || '|' || lookup_evr(full_list.evr.epoch, full_list.evr.version, full_list.evr.release)
from (
    select
        p.name_id name_id,
        max(pe.evr) evr
    from
        rhnPackageEVR PE,
        rhnPackage P,
        rhnChannelPackage CP,
        rhnServerChannel SC
    where
        sc.server_id = ?
    and sc.channel_id = cp.channel_id
    and cp.package_id = p.id
    and p.evr_id = pe.id
    group by
        p.name_id
    ) full_list,
   rhnPackageName pn
where
    full_list.name_id = pn.id
    and full_list.name_id NOT IN (SELECT SP.name_id
                                    FROM rhnServerPackage SP
                                   WHERE SP.server_id = ? )
    and UPPER(PN.name) like UPPER(?)
order by
   UPPER(pn.name)
EOQ
  }
  else {
    $query = <<EOQ;
select
        pn.name,
        full_list.evr.version || '-' || full_list.evr.release || DECODE(full_list.evr.epoch, NULL, '', ':' || full_list.evr.epoch),
        pn.id || '|' || lookup_evr(full_list.evr.epoch, full_list.evr.version, full_list.evr.release)
from (
    select
        p.name_id name_id,
        max(pe.evr) evr
    from
        rhnPackageEVR PE,
        rhnPackage P,
        rhnChannelPackage CP,
        rhnServerChannel SC
    where
        sc.server_id = ?
    and sc.channel_id = cp.channel_id
    and cp.package_id = p.id
    and p.evr_id = pe.id
    group by
        p.name_id
    ) full_list,
   rhnPackageName pn
where
    full_list.name_id = pn.id
    and full_list.name_id NOT IN (SELECT SP.name_id
                                    FROM rhnServerPackage SP
                                   WHERE SP.server_id = ? )
order by
   UPPER(pn.name)
EOQ
  }

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare($query);
  $sth->execute($sid, $sid, $like ? "%$like%" : ());

  while (my @row = $sth->fetchrow) {
    push @res, [ @row ];
  }

  return @res;
}

sub source_rpm_path {
  my $self = shift;

  my $dbh = RHN::DB->connect;
  my $sth;

  if (defined $self->org_id) {
    $sth = $dbh->prepare("SELECT PS.path, PS.package_size FROM rhnPackageSource PS WHERE PS.org_id = ? AND PS.source_rpm_id = ?");
    $sth->execute($self->org_id, $self->source_rpm_id);
  }
  else {
    $sth = $dbh->prepare("SELECT PS.path, PS.package_size FROM rhnPackageSource PS WHERE PS.org_id IS NULL AND PS.source_rpm_id = ?");
    $sth->execute($self->source_rpm_id);
  }

  my ($path, $size) = $sth->fetchrow;
  $sth->finish;

  return ($path, $size);
}

sub obsoleting_packages {
  my $class = shift;
  my $package_id = shift;
  my $org_id = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOS);
SELECT P2.id, PN.name || '-' || PE.evr.as_vre_simple() || '-' || PA.name, AC.channel_id, AC.channel_name, EP.errata_id, E.advisory
  FROM rhnPackage P1,
       rhnPackage P2,
       rhnPackageArch PA,
       rhnChannelPackage CP1,
       rhnChannelPackage CP2,
       rhnAvailableChannels AC,
       rhnPackageName PN,
       rhnPackageEVR PE,
       rhnPackageEVR PE2,
       rhnErrata E,
       rhnErrataPackage EP
 WHERE P1.id = ?
   AND CP1.package_id = P1.id
   AND P2.id = CP2.package_id
   AND P1.name_id = P2.name_id
   AND CP1.channel_id = CP2.channel_id
   AND CP2.channel_id = AC.channel_id
   AND AC.org_id = ?
   AND P2.id = EP.package_id(+)
   AND PE.id = P2.evr_id
   AND PE2.id = P1.evr_id
   AND PN.id = P2.name_id
   AND E.id(+) = EP.errata_id
   AND PE.evr >= PE2.evr
   AND PA.id = P2.package_arch_id
ORDER BY PE.evr DESC, AC.channel_name, E.issue_date
EOS

  $sth->execute($package_id, $org_id);

  my @ret;
  while (my @row = $sth->fetchrow) {
    push @ret, [ @row ];
  }

  return @ret;
}

sub system_set_server_package_names {
  my $class = shift;
  my %params = @_;

  my ($user_id, $lower, $upper, $total_rows, $all_ids) =
    map {$params{'-'.$_}} qw/user_id lower upper total_rows all_ids/;

  my @res;
  my $row;

  my $i = 1;
  $$total_rows = 0;


  my $dbh = RHN::DB->connect;

  # the 1 just makes life easier come pagination time, since we do a bit of post processing...
  my $query = <<EOQ;
SELECT PN.id id, PN.name name, COUNT(SP.server_id) num_systems
  FROM  rhnPackageName PN, rhnServerPackage SP, rhnSet S
 WHERE  S.user_id = ?
   AND  S.label = 'system_list'
   AND  S.element = SP.server_id
   AND  SP.name_id = PN.id
GROUP BY PN.id, PN.name
ORDER BY UPPER(PN.name)
EOQ
  my $sth = $dbh->prepare($query);

  $sth->execute($user_id);

  my @ret;
  my @ids;
  while ($row = $sth->fetchrow_hashref) {
    if ($all_ids) {
      push @ids, $row->{ID};
    }

    if ($i <= $upper and $i >= $lower) {
      push @ret, $row;
    }
    $$total_rows++;
    $i++;
  }

  return (data => \@ret, ids =>\@ids);
}


sub delta_canonical_lists {
  my $class = shift;
  my $s1 = shift;
  my $s2 = shift;

  my %s1_names;
  my %s2_names;

  foreach my $pkg (@$s1) {
    $s1_names{$pkg->[0]} = $pkg;
  }

  foreach my $pkg (@$s2) {
    $s2_names{$pkg->[0]} = $pkg;
  }

  my @names;
  @names = keys %s1_names;

  foreach my $name (keys %s2_names) {
    push @names, $name
      unless exists $s1_names{$name};
  }

  my @data = map { 
    ({ name_id => $_,
       name => $s1_names{$_}->[1] || $s2_names{$_}->[1],
       s1 => { evr_id  => $s1_names{$_}->[2],
	       evr     => $s1_names{$_}->[3],
	       epoch   => $s1_names{$_}->[4],
	       version => $s1_names{$_}->[5],
	       release => $s1_names{$_}->[6]
	     },
       s2 => { evr_id  => $s2_names{$_}->[2],
	       evr     => $s2_names{$_}->[3],
	       epoch   => $s2_names{$_}->[4],
	       version => $s2_names{$_}->[5],
	       release => $s2_names{$_}->[6]
	     },
       comparison => 0
     }) } @names;

  my @ret;
  foreach my $row (@data) {
    my $p1 = $s1_names{$row->{name_id}};
    my $p2 = $s2_names{$row->{name_id}};

    push @ret, $row
      unless $p1->[2] and $p2->[2] and
	$p1->[2] == $p2->[2];

    $row->{comparison} = $class->vercmp($row->{s1}->{epoch}, $row->{s1}->{version}, $row->{s1}->{release},
					$row->{s2}->{epoch}, $row->{s2}->{version}, $row->{s2}->{release})
      if $row->{s1}->{evr} and $row->{s2}->{evr};
  }

  return \@ret;
}

sub delta_canonical_lists_hashref {
  my $class = shift;
  my $s1 = shift;
  my $s2 = shift;

  my %s1_names;
  my %s2_names;

  foreach my $pkg (@$s1) {
    $s1_names{$pkg->{NAME_ID}} = $pkg;
  }

  foreach my $pkg (@$s2) {
    $s2_names{$pkg->{NAME_ID}} = $pkg;
  }

  my @names;
  @names = keys %s1_names;

  foreach my $name (keys %s2_names) {
    push @names, $name
      unless exists $s1_names{$name};
  }

  my @data = map { 
    ({ NAME_ID => $_,
       NAME => $s1_names{$_}->{NAME} || $s2_names{$_}->{NAME},
       S1 => { EVR_ID  => $s1_names{$_}->{EVR_ID},
	       EVR     => $s1_names{$_}->{EVR},
	       EPOCH   => $s1_names{$_}->{EPOCH},
	       ERRATA  => $s1_names{$_}->{ERRATA},
	       VERSION => $s1_names{$_}->{VERSION},
	       RELEASE => $s1_names{$_}->{RELEASE}
	     },
       S2 => { EVR_ID  => $s2_names{$_}->{EVR_ID},
	       EVR     => $s2_names{$_}->{EVR},
	       EPOCH   => $s2_names{$_}->{EPOCH},
	       ERRATA  => $s2_names{$_}->{ERRATA},
	       VERSION => $s2_names{$_}->{VERSION},
	       RELEASE => $s2_names{$_}->{RELEASE}
	     },
       COMPARISON => 0
     }) } @names;

  my @ret;
  foreach my $row (@data) {
    my $p1 = $s1_names{$row->{NAME_ID}};
    my $p2 = $s2_names{$row->{NAME_ID}};

    push @ret, $row
      unless $p1->{EVR_ID} and $p2->{EVR_ID} and
	$p1->{EVR_ID} == $p2->{EVR_ID};

    $row->{COMPARISON} = $class->vercmp($row->{S1}->{EPOCH}, $row->{S1}->{VERSION}, $row->{S1}->{RELEASE},
					$row->{S2}->{EPOCH}, $row->{S2}->{VERSION}, $row->{S2}->{RELEASE})
      if $row->{S1}->{EVR_ID} and $row->{S2}->{EVR_ID};
  }

  return \@ret;
}

sub vercmp {
  my $class = shift;
  my ($e1, $v1, $r1, $e2, $v2, $r2) = @_;

  if (not $e1) {
    $e1 = 0;
  }

  if (not $e2) {
    $e2 = 0;
  }

  return 1 if $e1 and not $e2;
  return -1 if not $e1 and $e2;

  if ($e1 and $e2) {
    $e1 = int $e1;
    $e2 = int $e2;

    return -1 if $e1 < $e2;
    return 1 if $e1 > $e2;
  }

  unless (defined $v1 and defined $v2) {
    throw "v1($v1) or v2($v2) undefined";
  }

  my $c = RPM2::rpmvercmp($v1, $v2);

  return $c if $c;

  return RPM2::rpmvercmp($r1, $r2);
}


sub target_systems_in_set {
  my $self = shift;
  my %params = @_;

  my ($org_id, $user_id) =
    map { $params{"-" . $_} } qw/org_id user_id/;


  my $rhn_class = '';
  $rhn_class = 'RHN.' unless PXT::Config->get('satellite');

  my $query = <<EOQ;
SELECT	S.id
  FROM  rhnPackage P, rhnChannelPackage CP, rhnServerChannel SC, rhnServer S
 WHERE  S.org_id = ?
   AND  S.id IN (SELECT element FROM rhnSet WHERE user_id = ? AND label = 'system_list')
   AND  EXISTS (SELECT 1 FROM rhnUserServerPerms USP WHERE USP.user_id = ? AND USP.server_id = S.id)
   AND  EXISTS (SELECT 1 FROM rhnEntitledServers ES WHERE ES.id = S.id)
   AND  SC.server_id = S.id
   AND  SC.channel_id = CP.channel_id
   AND  CP.package_id = ?
   AND  CP.package_id = P.id
   AND  NVL((SELECT MAX(PE.evr)
           FROM rhnServerPackage SP, rhnPackageEvr PE
          WHERE SP.name_id = P.name_id
            AND SP.server_id = S.id
            AND SP.evr_id = PE.id), ${rhn_class}EVR_T(NULL, 0, 0))
        <
        (SELECT EVR FROM rhnPackageEVR PE WHERE PE.id = P.evr_id)
EOQ

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare($query);
  $sth->execute($org_id, $user_id, $user_id, $self->id);

  my @ret;
  while (my $row = $sth->fetchrow) {
      push @ret,  $row ;
  }

  return @ret;
}

sub org_permission_check {
  my $class = shift;
  my $pid = shift;
  my $org_id = shift;

    my $query = <<EOQ;
SELECT 1
  FROM rhnPackage P
 WHERE p.id = :pid
   AND (   P.org_id = :org_id
        OR EXISTS (SELECT 1
                     FROM rhnChannelPackage CP,
                          rhnAvailableChannels AC
                    WHERE AC.org_id = :org_id
                      AND AC.channel_id = CP.channel_id
                      AND CP.package_id = :pid)
       )
EOQ

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare($query);
  $sth->execute_h(org_id => $org_id, pid => $pid);

  my ($has_permission) = $sth->fetchrow();
  $sth->finish();
  warn "HAS PERM is $has_permission";
  return $has_permission;
}

sub delete_packages_from_set {
  my $class = shift;
  my $set_label = shift;
  my $user_id = shift;

  my $dbh = RHN::DB->connect;
  my $lock_sth = RHN::User->lock_web_contact(-transaction => $dbh, -uid => $user_id);
  my $sth;

  if (PXT::Config->get('satellite')) {
    $sth = $dbh->prepare(<<EOQ);
SELECT P.path
  FROM rhnPackage P
 WHERE P.id IN(SELECT S.element FROM rhnSet S WHERE S.user_id = :user_id and S.label = :label)
   AND NOT EXISTS(SELECT 1 FROM rhnPackageFileDeleteQueue PFDQ WHERE PFDQ.path = P.path)
EOQ

    $sth->execute_h(user_id => $user_id, label => $set_label);

    my @paths;

    while (my ($path) = $sth->fetchrow) {
      push @paths, $path;
    }

    $sth = $dbh->prepare(<<EOQ);
INSERT
  INTO rhnPackageFileDeleteQueue (path)
VALUES (:path)
EOQ

    foreach my $path (@paths) {
      $sth->execute_h(path => $path);
    }

  }

  my $query = 'delete from %s where package_id IN(SELECT S.element FROM rhnSet S WHERE S.user_id = :user_id AND S.label = :label)';

  my @tables = qw/rhnChannelPackage rhnErrataPackage rhnErrataPackageTmp rhnPackageChangelog rhnServerNeededPackageCache rhnPackageFile rhnPackageProvides rhnPackageRequires rhnPackageConflicts rhnPackageObsoletes/;

  foreach my $table (@tables) {
    my $query = sprintf($query, $table);
    $sth = $dbh->prepare($query);

    $sth->execute_h(user_id => $user_id, label => $set_label);
  }

  $query =<<EOQ;
DELETE
  FROM rhnPackageSource PS
 WHERE id IN(SELECT P.source_rpm_id
               FROM rhnPackage P
              WHERE id IN(SELECT S.element
                            FROM rhnSet S
                           WHERE S.user_id = :user_id
                             AND S.label = :label))
EOQ

  my $srpm_id_sth = $dbh->prepare($query);

  $query =<<EOQ;
DELETE
  FROM rhnPackage
 WHERE id IN(SELECT S.element FROM rhnSet S WHERE S.user_id = :user_id AND S.label = :label)
EOQ
  my $del_sth = $dbh->prepare($query);

  $srpm_id_sth->execute_h(user_id => $user_id, label => $set_label);
  $srpm_id_sth->finish;

  $del_sth->execute_h(user_id => $user_id, label => $set_label);
  $del_sth->finish;

  $lock_sth->finish;
  $dbh->commit;

  return;
}

sub installed_package_nvre {
  my $class = shift;
  my $sid = shift;
  my $name_id = shift;
  my $evr_id = shift;

    my $query = <<EOQ;
SELECT SPN.name || '-' || SPE.evr.as_vre_simple()
  FROM rhnPackageName SPN,
       rhnPackageEVR SPE,
       rhnPackageEVR PE,
       rhnServerPackage SP
 WHERE SP.server_id = :sid
   AND SP.name_id = :name_id
   AND PE.id = :evr_id
   AND SPE.id = SP.evr_id
   AND SPN.id = SP.name_id
   AND SP.evr_id != PE.id
   AND SPE.evr < PE.evr
ORDER BY UPPER(SPN.name), SPE.evr DESC
EOQ

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare($query);
  $sth->execute_h(sid => $sid, name_id => $name_id, evr_id => $evr_id);

  my @nvres;

  while (my ($nvre) = $sth->fetchrow()) {
    push @nvres, $nvre;
  }

  return @nvres;
}

sub valid_package_archs { #return all archs recognized by our server

  my $class = shift;

  my $query =<<EOQ;
SELECT  DISTINCT PA.name
  FROM  rhnPackageArch PA
EOQ

  my $dbh = RHN::DB->connect();

  my $sth = $dbh->prepare($query);
  $sth->execute();

  my @archs;

  while (my ($data) = $sth->fetchrow) {

    push @archs, $data;
  }

  return @archs;

}

sub lookup_package_name_id {
  my $class = shift;
  my $name = shift;

  my $dbh = RHN::DB->connect;
  return $dbh->call_function('lookup_package_name', $name);
}

sub is_package_in_channel {
  my $class = shift;
  my %params = validate(@_, { evr_id => 0, name_id => 0, id => 0, cid => 1 });

  throw "Need id or evr_id and name_id" unless ($params{id} or ($params{evr_id} and $params{name_id}));

  my $query;
  my %query_params;

  if ($params{id}) {
    $query =<<EOQ;
SELECT 1
  FROM rhnChannelPackage CP
 WHERE CP.channel_id = :cid
   AND CP.package_id = :pid
EOQ

    %query_params = ( cid => $params{cid},
		      pid => $params{id} );
  }
  else {
    $query =<<EOQ;
SELECT 1
  FROM rhnChannelPackage CP, rhnPackage P
 WHERE CP.channel_id = :cid
   AND CP.package_id = P.id
   AND P.evr_id = :evr_id
   AND P.name_id = :name_id
EOQ

    %query_params = %params;
  }

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare($query);

  $sth->execute_h(%query_params);

  my ($ret) = $sth->fetchrow;

  $sth->finish;

  return $ret;
}

sub latest_packages_in_channel_tree {
  my $class = shift;
  my %params = validate(@_, { uid => 1, packages => 1, base_cid => 1 });

  my $user_id = $params{uid};
  my $base_cid = $params{base_cid};

  my @pids;

  foreach my $name (@{$params{packages}}) {
    my $ds = new RHN::DataSource::Simple(-querybase => "Package_queries", -mode => "latest_package_in_channel_tree");
    my ($package) = @{$ds->execute_query(-user_id => $user_id, -cid => $base_cid, -package_name => $name )};

    next unless $package;

    push @pids, $package->{ID};
  }

  return (@pids);
}

sub packaging_type {
  my $class_or_self = shift;

  my $pid;

  if (ref $class_or_self) {
    $pid = $class_or_self->id;
  }
  else {
    $pid = shift;
  }

  throw "RHN::Package::packaging_type called without a pid param" unless $pid;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
SELECT AT.label, AT.name
  FROM rhnArchType AT, rhnPackageArch PA, rhnPackage P
 WHERE P.id = :pid
   AND P.package_arch_id = PA.id
   AND PA.arch_type_id = AT.id
EOQ

  $sth->execute_h(pid => $pid);

  my ($label, $name) = $sth->fetchrow;
  $sth->finish;

  throw "Could not determine packaging type for package ($pid)" unless $label;

  return $label;
}

sub channel_package_intersection_from_set {
  my $self = shift;
  my %params = validate(@_, { user_id => 1, channel_set_label => 1, package_set_label => 1 });

  my $dbh = RHN::DB->connect;

  my $sth = $dbh->prepare(<<EOQ);
SELECT up.name_id || '|' || up.evr_id AS id,
       C.name AS channel_name,
       C.id AS channel_id
  FROM
       rhnChannel C,
       rhnPackage p,
       rhnChannelPackage cp,
       ( select element name_id,
                element_two evr_id
           from rhnSet
          where user_id = :user_id
            and label = :package_set_label
       ) up,
       ( select element channel_id
           from rhnSet
          where user_id = :user_id
            and label = :channel_set_label
       ) uc
 WHERE 1 = 1
   and uc.channel_id = cp.channel_id
   and cp.package_id = p.id
   and up.name_id = p.name_id
   and up.evr_id = p.evr_id
   and cp.channel_id = c.id
ORDER BY up.name_id || '|' || up.evr_id, C.name
EOQ

  $sth->execute_h(user_id => $params{user_id},
		  channel_set_label => $params{channel_set_label},
		  package_set_label => $params{package_set_label});

  my @data;

  while (my $row = $sth->fetchrow_hashref) {
    push @data, $row;
  }

  my %ret;

  foreach my $row (@data) {
    push @{$ret{$row->{ID}}}, { CHANNEL_ID => $row->{CHANNEL_ID},
				CHANNEL_NAME => $row->{CHANNEL_NAME},
			      };
  }

  return \%ret;
}

sub arch_type_label {
  my $self = shift;

  my $dbh = RHN::DB->connect;

  my $sth = $dbh->prepare(<<EOQ);
SELECT AT.label
  FROM rhnArchType AT
 WHERE AT.id = :atid
EOQ

  $sth->execute_h(atid => $self->arch_arch_type_id);
  my ($label) = $sth->fetchrow;
  $sth->finish;

  return $label;
}

sub arch_type_name {
  my $self = shift;

  my $dbh = RHN::DB->connect;

  my $sth = $dbh->prepare(<<EOQ);
SELECT AT.name
  FROM rhnArchType AT
 WHERE AT.id = :atid
EOQ

  $sth->execute_h(atid => $self->arch_arch_type_id);
  my ($name) = $sth->fetchrow;
  $sth->finish;

  return $name;
}

sub download_link_type {
  my $self = shift;

  my $arch_type_label = $self->arch_type_label();

  my %download_type_map = ( rpm => 'Package',
			    'sysv-solaris' => 'Package',
			    'tar' => 'Tar file',
			    'solaris-patch' => 'Patch',
			    'solaris-patch-cluster' => 'Patch Cluster',
			  );

  my $ret = $download_type_map{$arch_type_label} || 'File';

  return $ret;
}

sub package_type_capable {
  my $class_or_self = shift;

  my $pid;

  if (ref $class_or_self) {
    $pid = $class_or_self->id;
  }
  else {
    $pid = shift;
  }

  throw "RHN::Package::package_type_capable called without a pid param" unless $pid;

  my $caps = shift;
  throw "RHN::Package::package_type_capable called without any capabilites" unless $caps;

  my $packaging_type = RHN::Package->packaging_type($pid);
  my @caps = split(/,\s*/, $caps);

  foreach my $cap (@caps) {
    if ($cap eq 'dependencies') {
      return unless (grep { $packaging_type eq $_ } qw/rpm solaris-patch/);
    }
    elsif ($cap eq 'change_log') {
      return unless ($packaging_type eq 'rpm');
    }
    elsif ($cap eq 'file_list') {
      return unless ($packaging_type eq 'rpm');
    }
    elsif ($cap eq 'deploy_answer_file') {
      return unless ($packaging_type eq 'sysv-solaris');
    }
    elsif ($cap eq 'errata') {
      return unless ($packaging_type eq 'rpm');
    }
    elsif ($cap eq 'remove') {
      return unless (grep { $packaging_type eq $_ } qw/rpm sysv-solaris solaris-patch/);
    }
    elsif ($cap eq 'package_map') {
      return unless ($packaging_type eq 'sysv-solaris');
    }
    elsif ($cap eq 'solaris_patchable') {
      return unless ($packaging_type eq 'sysv-solaris');
    }
    elsif ($cap eq 'solaris_patch') {
      return unless ($packaging_type eq 'solaris-patch');
    }
    elsif ($cap eq 'solaris_patchset') {
      return unless ($packaging_type eq 'solaris-patch-cluster');
    }
    else {
      throw "unknown capability ($cap)";
    }
  }

  return 1;
}

# get the name of the package install action for this type of package
sub package_arch_type_action {
  my $class = shift;
  my $id = shift;
  my $action_style = shift;

  throw "action style must be 'install' or 'remove' or 'verify'"
    unless ($action_style and ($action_style eq 'install' or $action_style eq 'remove' or $action_style eq 'verify'));

  throw "No package id." unless $id;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
SELECT ActionT.label
  FROM rhnActionType ActionT, rhnArchTypeActions ATA, rhnPackageArch PA, rhnPackage P
 WHERE ActionT.id = ATA.action_type_id
   AND ATA.arch_type_id = PA.arch_type_id
   AND ATA.action_style = :action_style
   AND PA.id = P.package_arch_id
   AND P.id = :pid
EOQ

  $sth->execute_h(pid => $id, action_style => $action_style);

  my ($label) = $sth->fetchrow;

  throw "No '$action_style' action label found for package '$id'"
    unless $label;

  return $label;
}

# Return list of blacklisted packages not to be included in Manifests and
# UI lists.  org_id is optional.
sub package_blacklist {
  my $self = shift;
  my $org_id = shift;
  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);

SELECT pn.name 
  FROM rhnPackageSyncBlacklist BL,
       rhnPackageName PN
  WHERE PN.id = BL.package_name_id
    AND (BL.org_id = :org_id or BL.org_id is null)

EOQ

  $sth->execute_h(org_id => $org_id);

  my @blacklist;

  while (my ($pname) = $sth->fetchrow()) {
    push @blacklist, $pname;
  }

  return @blacklist;
}



1;
