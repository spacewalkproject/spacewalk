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

# errata - DB layer
use strict;

package RHN::DB::Errata;

use Carp;
use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

use RHN::DB;
use RHN::Exception;

use RHN::DB::TableClass;
use Data::Dumper;

my @errata_fields = qw/ID ADVISORY ADVISORY_TYPE PRODUCT DESCRIPTION SYNOPSIS TOPIC SOLUTION ISSUE_DATE:shortdate REFERS_TO CREATED:shortdate MODIFIED:longdate UPDATE_DATE:shortdate NOTES ORG_ID ADVISORY_NAME ADVISORY_REL LOCALLY_MODIFIED LAST_MODIFIED:longdate/;

my $e = new RHN::DB::TableClass("rhnErrata", "E", "", @errata_fields);

sub oval_file_count {
  my $self_or_id = shift;
  my $id;
  my $retval;
  my @row;

  if (ref $self_or_id) {
    $id = $self_or_id->id;
  }
  else {
    $id = shift;
  }

  my $dbh = RHN::DB->connect;

  my $query;
  my $sth;

  $query = <<EOQ;
SELECT COUNT(*)
FROM rhnErrataFile EF,
     rhnErrataFileType EFT
WHERE EF.type = EFT.id
      AND EFT.label = 'OVAL'
      AND EF.errata_id = ?
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute($id);
  @row = $sth->fetchrow_array();
  $retval = $row[0];
  $sth->finish;
  return $retval;
}
sub affected_product_lines {
  my $self_or_id = shift;
  my $id;

  if (ref $self_or_id) {
    $id = $self_or_id->id;
  }
  else {
    $id = shift;
  }

  my $dbh = RHN::DB->connect;

  my $query;
  my $sth;

  $query = <<EOQ;
SELECT DISTINCT PL.name
  FROM rhnProductLine PL,
       rhnProduct P,
       rhnProductChannel PC,
       rhnErrataFileChannel EFC,
       rhnErrataFile EF
 WHERE EF.errata_id = ?
   AND EF.id = EFC.errata_file_id
   AND EFC.channel_id = PC.channel_id
   AND PC.product_id = P.id
   AND P.product_line_id = PL.id
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute($id);

  my @ret;

  while (my ($row) = $sth->fetchrow) {
    push @ret, $row;
  }
  $sth->finish;

  return @ret;
}

sub affected_products {
  my $self = shift;

  my $dbh = RHN::DB->connect;

  my $query;
  my $sth;

  $query = <<EOQ;
SELECT DISTINCT P.name
  FROM rhnProduct P,
       rhnProductChannel PC,
       rhnErrataFileChannel EFC,
       rhnErrataFile EF
 WHERE EF.errata_id = ?
   AND EF.id = EFC.errata_file_id
   AND EFC.channel_id = PC.channel_id
   AND PC.product_id = P.id
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute($self->id);

  my @ret;

  while (my ($row) = $sth->fetchrow) {
    push @ret, $row;
  }
  $sth->finish;

  return @ret;
}


# returns all the files associated with an errata,
# plus xtra info (like per-file obsoletion by other errata ...)
# NOTE:  gotta figure out the obsoletion of the srpm's based from the binary ones (in perl)...
sub files {
  my $self = shift;

  die "not a red hat errata!" unless not $self->org_id;

  my $dbh = RHN::DB->connect;

  my $query;
  my $sth;

  $query = <<EOQ;
SELECT  DISTINCT
        EF.id AS ID,
        Csum.checksum AS MD5SUM,
        EF.filename AS FILENAME,
	EFP.package_id AS PACKAGE_ID,
        P1.path AS RHN_PACKAGE_PATH,
        PA.name AS PACKAGE_ARCH,
        PS1.source_rpm_id AS PACKAGE_SOURCE_RPM_ID,
        PS2.path AS RHN_PACKAGE_SOURCE_PATH,
        EFPS.package_id AS PACKAGE_SOURCE_ID,
        PS2.source_rpm_id AS PACKAGE_SOURCE_SOURCE_RPM_ID,
        EFT.label AS FILE_TYPE,
        CA.name AS CHANNEL_ARCH_NAME,
        CA.label AS CHANNEL_ARCH_LABEL,
        SA.name AS SERVER_ARCH_NAME,
        SA.label AS SERVER_ARCH_LABEL,
        Prod.name AS PRODUCT,
        (
SELECT MAX(E.advisory_name)
  FROM rhnErrata E,
       rhnErrataPackage EP,
       rhnChannelErrata CE,
       rhnChannelNewestPackage CNP,
       rhnPackage P
 WHERE P.id = EFP.package_id
   AND CNP.channel_id = EFC.channel_id
   AND CNP.name_id = P.name_id
   AND CNP.package_arch_id = P.package_arch_id
   AND CNP.package_id != P.id
   AND CNP.channel_id = CE.channel_id
   AND CE.errata_id = EP.errata_id
   AND EP.package_id = CNP.package_id
   AND EP.errata_id = E.id
   AND E.org_id IS NULL
        ) AS PACKAGE_OUTDATED_BY
  FROM  rhnPackageSource PS2,
        rhnPackageSource PS1,
        rhnPackageArch PA,
        rhnPackage P1,
        rhnErrataFilePackageSource EFPS,
        rhnErrataFilePackage EFP,
        rhnProduct Prod,
        rhnProductChannel PC,
        rhnServerArch SA,
        rhnServerChannelArchCompat SCAC,
        rhnChannelArch CA,
        rhnChannel C,
        rhnErrataFileChannel EFC,
        rhnErrataFileType EFT,
        rhnErrataFile EF,
        rhnChecksum Csum
 WHERE  EF.errata_id = ?
   AND  EF.type = EFT.id
   AND  EF.id = EFC.errata_file_id (+)
   AND  EFC.channel_id = PC.channel_id (+)
   AND  EFC.channel_id = C.id (+)
   AND  C.channel_arch_id = CA.id (+)
   AND  CA.id = SCAC.channel_arch_id (+)
   AND  SCAC.server_arch_id = SA.id (+)
   AND  PC.product_id = Prod.id (+)
   AND  EF.id = EFP.errata_file_id (+)
   AND  EF.id = EFPS.errata_file_id (+)
   AND  EFP.package_id = P1.id (+)
   AND  P1.source_rpm_id = PS1.source_rpm_id (+)
   AND  P1.package_arch_id = PA.id (+)
   AND  EFPS.package_id = PS2.id (+)
   AND  EF.checksum_id = Csum.id
ORDER BY UPPER(Prod.name), UPPER(PA.name), UPPER(EF.filename)
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute($self->id);

  my @ret;

  while (my $row = $sth->fetchrow_hashref) {
    push @ret, $row;
  }
  $sth->finish;

  return @ret;
}

sub related_cves {
  my $self_or_id = shift;
  my $id;

  if (ref $self_or_id) {
    $id = $self_or_id->id;
  }
  else {
    $id = shift;
  }

  my $dbh = RHN::DB->connect;

  my $query;
  my $sth;

  $query = <<EOQ;
SELECT  CVE.name
  FROM  rhnCVE CVE, rhnErrataCVE ECVE
 WHERE  ECVE.errata_id = ?
   AND  ECVE.cve_id = CVE.id
ORDER BY UPPER(CVE.name)
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute($id);

  my @ret;

  while (my ($cve) = $sth->fetchrow) {
    push @ret, $cve;
  }
  $sth->finish;

  return @ret;
}


# should we show this erratum at all?
sub is_public {
    my $self = shift;

    # if it's not owned by RH, it ain't public...
    if (defined $self->org_id) {
	return undef;
    }

    my $dbh = RHN::DB->connect;

    my $query;
    my $sth;

    # if any channels are tied to it that are not in the product list,
    # it ain't public...
    $query = <<EOQ;
SELECT  1
  FROM  rhnChannelErrata CE
 WHERE  CE.errata_id = ?
   AND  NOT EXISTS (
  SELECT 1
    FROM rhnProductChannel PC
   WHERE PC.channel_id = CE.channel_id
)
EOQ

    $sth = $dbh->prepare($query);
    $sth->execute($self->id);

    my $hidden_channel;

    ($hidden_channel) = $sth->fetchrow;
    $sth->finish;

    return if ($hidden_channel);

    return 1;
}

# protected means is a red hat errata and has private packages.
sub is_protected {
  my $self = shift;

  my $dbh = RHN::DB->connect;

  my $query;
  my $sth;

  $query = <<EOQ;
SELECT  1
  FROM  rhnPrivateChannelFamily PCF, rhnChannelFamilyMembers CFM, rhnChannelErrata CE
 WHERE  CE.errata_id = ?
   AND  CE.channel_id = CFM.channel_id
   AND  CFM.channel_family_id = PCF.channel_family_id
   AND  ROWNUM = 1
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute($self->id);

  my $has_priv_perms;

  ($has_priv_perms) = $sth->fetchrow;
  $sth->finish;

  return if (!$has_priv_perms);

  return (defined $self->org_id ? undef : 1);
}

sub lookup {
  my $class = shift;
  my %params = validate(@_, {id => 0, advisory_name => 0, transaction => 0});
  my $transaction = $params{transaction};


  my $dbh = $transaction || RHN::DB->connect;

  my $tc = $class->table_class;

  my $query;
  my $sth;

  if (defined $params{id}) {
    $query = $tc->select_query("E.ID = ?");
    $sth = $dbh->prepare($query);
    $sth->execute($params{id});
  }
  elsif (defined $params{advisory_name}) {
    $query = $tc->select_query("E.advisory_name = ?");
    $sth = $dbh->prepare($query);
    $sth->execute($params{advisory_name});
  }
  else {
    throw "no info to perform lookup on";
  }
  my @columns = $sth->fetchrow;
  $sth->finish;

  my $ret;
  my $tmp_col;
  $ret = $class->blank_errata;
  if ($columns[0]) {
    $ret->{__id__} = $columns[0];
    foreach ($tc->method_names) {
      $tmp_col = shift @columns;
      if ($_ eq "severity_id") {
        $tmp_col = -1 unless defined($tmp_col);
      }
      $ret->$_($tmp_col);
    }
    #$ret->$_(shift @columns) foreach $tc->method_names;
    delete $ret->{":modified:"};
  }
  else {
    local $" = ", ";
    throw "Error loading errata; no ID? (@columns)";
  }

  return $ret;
}

sub bugs_fixed {
  my $self = shift;
  my $dbh = RHN::DB->connect;

  my $bl_table = $self->table_map('rhnErrataBugList');
  my $query;
  my $sth;

  $query = <<EOQ;
SELECT  EBL.bug_id, EBL.summary
  FROM  $bl_table EBL
 WHERE  EBL.errata_id = ?
ORDER BY UPPER(EBL.bug_id)
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute($self->id);

  my @ret;

  while (my @row = $sth->fetchrow) {
    push @ret, [ @row ];
  }
  $sth->finish;

  return @ret;
}

sub add_bug {
  my $self = shift;
  my ($id, $summary) = @_;

  my $dbh = RHN::DB->connect;

  my $bl_table = $self->table_map('rhnErrataBugList');

  my $query = <<EOQ;
INSERT INTO $bl_table
       (errata_id, bug_id, summary)
VALUES (?, ?, ?)
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute($self->id, $id, $summary);

  $dbh->commit;

  return;
}

sub update_bug {
  my $self = shift;
  my ($old_id, $new_id, $summary) = @_;

  my $dbh = RHN::DB->connect;

  my $bl_table = $self->table_map('rhnErrataBugList');

  my $query = <<EOQ;
UPDATE $bl_table
   SET bug_id = ?,
       summary = ?
 WHERE errata_id = ?
   AND bug_id = ?
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute($new_id, $summary, $self->id, $old_id);

  $dbh->commit;

  return;
}

sub keywords {
  my $self = shift;
  my $dbh = RHN::DB->connect;

  my $kw_table = $self->table_map('rhnErrataKeyword');

  my $query;
  my $sth;

  $query = <<EOQ;
SELECT  EK.keyword
  FROM  $kw_table EK
 WHERE  EK.errata_id = ?
ORDER BY UPPER(EK.keyword)
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute($self->id);

  my @ret;

  while (my @row = $sth->fetchrow) {
    push @ret, @row;
  }
  $sth->finish;

  return @ret;
}

sub set_keywords {
  my $self = shift;
  my @words = @_;

  my $dbh = RHN::DB->connect;

  my $kw_table = $self->table_map('rhnErrataKeyword');

  my $query;
  my $sth;

  $query = <<EOQ;
DELETE FROM  $kw_table EK
      WHERE  EK.errata_id = ?
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute($self->id);

  $query = <<EOQ;
INSERT INTO  $kw_table EK
(errata_id, keyword)
VALUES
(?, ?)
EOQ

  $sth = $dbh->prepare($query);

  foreach my $word (@words) {
    $sth->execute($self->id, $word);
  }

  $sth->finish;
  $dbh->commit;

  return;
}

#all channels affected by errata, pulled from rhnChannelErrata
sub channels {
  my $class = shift;
  my $eid = shift;

  my $dbh = RHN::DB->connect;

  my $query = <<EOQ;
SELECT CE.channel_id
  FROM rhnChannelErrata CE
 WHERE CE.errata_id = ?
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute($eid);

  my @ret;

  while (my ($cid) = $sth->fetchrow) {
    push @ret, $cid;
  }

  return @ret;
}

# show only affected channels that have servers subscribing to them
sub affected_channels {
  my $self = shift;
  my $org_id = shift;

  my $dbh = RHN::DB->connect;

  my $query;
  my $sth;

#   $query = <<EOQ;
# SELECT  DISTINCT C.id, C.name
#   FROM  rhnChannel C, rhnChannelPackage CP, rhnErrataPackage EP
#  WHERE  EP.errata_id = ?
#    AND  EP.package_id = CP.package_id
#    AND  CP.channel_id = C.id
# ORDER BY UPPER(C.name)
# EOQ

  $query = <<EOQ;
SELECT DISTINCT C.id, C.name
  FROM rhnAvailableChannels AC, rhnChannel C, rhnChannelErrata CE
 WHERE CE.errata_id = ?
   AND CE.channel_id = C.id
   AND AC.org_id = ?
   AND C.id = AC.channel_id
 ORDER BY UPPER(C.name)
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute($self->id, $org_id);

  my @ret;

  while (my @row = $sth->fetchrow) {
    push @ret, [ @row ];
  }
  $sth->finish;

  return @ret;

}

# differs from the above in that this one only shows redhat channels affected by an errata...
sub affected_redhat_channels {
  my $self = shift;

  my $dbh = RHN::DB->connect;

  my $query;
  my $sth;

  $query = <<EOQ;
SELECT  DISTINCT C.id, C.name
  FROM  rhnChannelFamilyMembers CFM, rhnChannelFamily CF, rhnChannel C, rhnChannelErrata CE
 WHERE  CE.errata_id = ?
   AND  CE.channel_id = C.id
   AND  C.org_id IS NULL
   AND  CF.label = 'rh-public'
   AND  CF.id = CFM.channel_family_id
   AND  CFM.channel_id = C.id
ORDER BY UPPER(C.name)
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute($self->id);

  my @ret;

  while (my @row = $sth->fetchrow) {
    push @ret, [ @row ];
  }
  $sth->finish;

  return @ret;

}

# show channels which own packages referred to by this errata
sub related_channels_owned_by_org {
  my $class = shift;
  my $eid = shift;
  my $org_id = shift;

  my $ep_table = $class->table_map('rhnErrataPackage');

  my $dbh = RHN::DB->connect;

  my $query;
  my $sth;

   $query = <<EOQ;
  SELECT DISTINCT C.id
    FROM rhnChannel C,
         rhnChannelPackage CP,
         rhnPackage P2,
         rhnPackage P1,
         $ep_table EP
   WHERE EP.errata_id = :eid
     AND EP.package_id = P1.id
     AND P1.name_id = P2.name_id
     AND P1.package_arch_id = P2.package_arch_id
     AND CP.package_id = P2.id
     AND C.id = CP.channel_id
     AND C.org_id = :org_id
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute_h(eid => $eid, org_id => $org_id);

  my @ret;

  while (my ($id) = $sth->fetchrow) {
    push @ret, $id;
  }
  $sth->finish;

  return @ret;
}

sub channel_packages_in_errata {
  my $self = shift;
  my $cid = shift;

  die "No channel id!" unless $cid;

  my $ep_table = $self->table_map('rhnErrataPackage');

  my $dbh = RHN::DB->connect;
  my $query;
  my $sth;

  $query = <<EOS;
  SELECT DISTINCT P1.name_id
    FROM rhnChannel C,
         rhnChannelPackage CP,
         rhnPackage P2,
         rhnPackage P1,
         $ep_table EP
   WHERE EP.errata_id = :eid
     AND EP.package_id = P1.id
     AND P1.name_id = P2.name_id
     AND P1.package_arch_id = P2.package_arch_id
     AND CP.package_id = P2.id
     AND C.id = CP.channel_id
     AND C.id = :cid
EOS

  $sth = $dbh->prepare($query);

  $sth->execute_h(eid => $self->id, cid => $cid);

  my @result;

  while (my ($pid) = $sth->fetchrow) {
    push @result, $pid;
  }

  return @result;
}

sub packages_in_errata {
  my $class = shift;
  my $eid = shift;

  die "No errata id!" unless $eid;

  my $dbh = RHN::DB->connect;
  my $query;
  my $sth;

  $query = <<EOS;
  SELECT EP.package_id,
         P.name_id,
         PN.name,
         C.label,
         PA.name,
         P.path,
         PE.evr.version,
         PE.evr.release,
         C.name,
         Csum.checksum md5sum,
         P.path,
         PE.evr.epoch,
         PA.label,
         TO_CHAR(P.last_modified, 'YYYY-MM-DD HH24:MI:SS') AS PACKAGE_LAST_MODIFIED
    FROM rhnPackageArch PA,
         rhnPackageEVR PE,
         rhnPackageName PN,
         rhnPackage P,
         rhnChannel C,
         rhnChannelErrata CE,
         rhnChannelPackage CP,
         rhnErrataPackage EP,
         rhnChecksum Csum
 WHERE  EP.errata_id = ?
     AND CE.errata_id = ?
     AND EP.package_id = CP.package_id
     AND CE.channel_id = CP.channel_id
     AND CE.channel_id = C.id
   AND  EP.package_id = P.id
   AND  P.name_id = PN.id
   AND  P.evr_id = PE.id
     AND P.package_arch_id = PA.id
     AND P.checksum_id = Csum.id
EOS

  $sth = $dbh->prepare($query);

  $sth->execute($eid, $eid);

  my @result;

  while (my @row = $sth->fetchrow) {
    push @result, [ @row ];
  }

  return @result;
}

# return the srpms for the binary rpms entered in rhnPackage that
# are associated w/ this errata
# output is in same format as with packages_overview
sub source_rpms {
  my $self = shift;

  my $dbh = RHN::DB->connect;

  my $query;
  my $sth;

  $query = <<EOS;
  SELECT PS.id, P.id, PS.id, C.label, 'src', PS.path, NULL, NULL, 'SRPMs',
         CPsum.checksum md5sum, CPSsum.checksum md5sum
    FROM rhnChannel C,
         rhnPackageSource PS,
         rhnPackage P,
         rhnChannelPackage CP,
         rhnChannelErrata CE,
         rhnErrataPackage EP
         rhnChecksum CPsum,
         rhnChecksum CPSsum
   WHERE EP.errata_id = ?
     AND CE.errata_id = ?
     AND EP.package_id = CP.package_id
     AND CE.channel_id = CP.channel_id
     AND CE.channel_id = C.id
     AND EP.package_id = P.id
     AND P.source_rpm_id = PS.source_rpm_id
     AND P.checksum_id = CPsum.id
     AND PS.checksum_id = CPSsum.id
EOS


  $sth = $dbh->prepare($query);
  $sth->execute($self->id, $self->id);

  my @ret;

  while (my @row = $sth->fetchrow) {
    push @ret, [ @row ];
  }
  $sth->finish;

  return @ret;
}

# for an errata, give binary packages RHN knows about...
sub public_packages_overview {
  my $self = shift;

  my $dbh = RHN::DB->connect;

  my $query;
  my $sth;

  $query = <<EOQ;
SELECT  P2.id, Csum.checksum md5sum, C.name, PN.name, PE.evr.version, PE.evr.release, PE.evr.epoch, P2.path, PA.name, C.label, CFM.channel_family_id,
        (
           SELECT  CFP2.channel_family_id
             FROM  rhnChannelFamilyPermissions CFP2
            WHERE  CFP2.org_id IS NULL
              AND  CFP2.channel_family_id = CFM.channel_family_id
        ) PUBLIC_PACKAGE
  FROM  rhnChannelFamily CF, rhnChannelFamilyMembers CFM, rhnPackageArch PA, rhnPackageName PN, rhnPackageEVR PE, rhnPackage P2, rhnPackage P, rhnChannel C, rhnChannelPackage CP, rhnChannelErrata CE, rhnErrataPackage EP, rhnChecksum Csum
 WHERE  EP.errata_id = ?
   AND  CE.errata_id = ?
   AND  EP.package_id = CP.package_id
   AND  CE.channel_id = CP.channel_id
   AND  CP.channel_id = C.id
   AND  CP.package_id = P.id
   AND  P.name_id = P2.name_id
   AND  EXISTS (SELECT CP2.package_id FROM rhnChannelPackage CP2 WHERE CP2.channel_id = C.id AND CP2.package_id = P2.id)
   AND  P2.name_id = PN.id
   AND  P2.evr_id = PE.id
   AND  P2.package_arch_id = PA.id
   AND  C.id = CFM.channel_id
   AND  CFM.channel_family_id = CF.id
   AND  CF.org_id IS NULL
   AND  P2.checksum_id = Csum.id
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute($self->id, $self->id);

  my @ret;

  while (my @row = $sth->fetchrow) {
    push @ret, [ @row ];
  }
  $sth->finish;

  return @ret;
}

# shows the packages corresponding to the subscribed channels of your org.
sub rhn_files_overview {
  my $self = shift;
  my $org_id = shift;

  my $dbh = RHN::DB->connect;

  my $query;
  my $sth;

  $query = <<EOQ;
SELECT  DISTINCT EFP.package_id,
                 Csum.checksum md5sum,
                 EF.filename AS FILENAME,
                 C.name AS CHANNEL_NAME
  FROM  rhnChannel C,
        rhnErrataFilePackage EFP,
        rhnErrataFileChannel EFC,
        rhnErrataFile EF,
        rhnChecksum Csum
 WHERE  EF.errata_id = :errata_id
   AND  EF.id = EFC.errata_file_id (+)
   AND  EF.id = EFP.errata_file_id (+)
   AND  EFC.channel_id IN (SELECT AC.channel_id FROM rhnAvailableChannels AC WHERE AC.org_id = :org_id)
   AND  EFC.channel_id = C.id
   AND  EF.checksum_id = Csum.id
ORDER BY C.name, EF.filename DESC
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute_h(errata_id => $self->id,
		  org_id => $org_id,
		 );

  my @ret;

  while (my $row = $sth->fetchrow_hashref) {
    push @ret, $row;
  }
  $sth->finish;

  return @ret;
}

sub blank_errata {
  my $class = shift;

  my $self = bless { }, $class;
  return $self;
}

sub create_errata {
  my $class = shift;

  my $err = $class->blank_errata;
  $err->{__id__} = -1;

  return $err;
}


# build some accessors
foreach my $field ($e->method_names) {
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

  if ($@) {
    die $@;
  }
}

sub commit {
  my $self = shift;
  my $mode = 'update';

  my $id = shift || 0;
  my $transaction = shift;
  my $dbh = $transaction || RHN::DB->connect;

  my $tc = $self->table_class;

  if ($self->id == -1) {

    unless ($id) {
      my $sth = $dbh->prepare("SELECT rhn_errata_id_seq.nextval FROM DUAL");
      $sth->execute;
      ($id) = $sth->fetchrow;
      die "No new errata id from seq rhn_errata_id_seq (possible error: " . $sth->errstr . ")" unless $id;
      $sth->finish;
    }

    $self->{":modified:"}->{id} = 1;
    $self->{__id__} = $id;

    $mode = 'insert';
  }

  die "$self->commit called on errata without valid id" unless $self->id and $self->id > 0;

  my @modified = keys %{$self->{":modified:"}};
  my %modified = map { $_ => 1 } @modified;

  return unless @modified;

  my $query;

  if ($mode eq 'update') {
      $query = $tc->update_query($tc->methods_to_columns(@modified));
      $query .= "E.ID = ?";
    }
  elsif ($mode eq 'insert') {
    $query = $tc->insert_query($tc->methods_to_columns(@modified));
    }
  else {
    die "Invalid mode - '$mode'";
  }

  my $sth = $dbh->prepare($query);
  my @list = map { $self->$_() } (grep { $modified{$_} } $tc->method_names), ($mode eq 'update') ? ('id') : ();

  $sth->execute(@list);

  unless ($transaction) {
    $dbh->commit;
  }
  delete $self->{":modified:"};

  return $transaction;
}

sub recent_errata_summary {
  my $class = shift;
  my $user = shift;
  my $count = shift;

  my $e_table = $class->table_map('rhnErrata');

  my $query = <<EOQ;
  SELECT  id, advisory, advisory_type, synopsis, issue_date, update_date
    FROM  $e_table
ORDER BY  update_date DESC, id
EOQ

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare($query);
  $sth->execute;

  my @ret;
  while (my @row = $sth->fetchrow) {
    push @ret, [ @row, "n/a" ];
    last if @ret > $count;
  }
  $sth->finish;

  return @ret;
}

sub get_product_types {
  my $dbh = RHN::DB->connect;
  my $query = "SELECT DISTINCT(product) FROM rhnErrata";

  my $sth = $dbh->prepare($query);
  $sth->execute(); 
  my @res;
  my @row;

  push @res, [ @row ] while(@row = $sth->fetchrow); 

  return @res; 
}

sub get_errata_packages {
  my $class = shift;
  my $id = shift;
  my $pcols = shift;
  my $acols = shift || [];

  my $ep_table = $class->table_map('rhnErrataPackage');

  my $dbh = RHN::DB->connect;

  my $query = sprintf <<EOQ, join(", ",(map { "RP.$_"} @{$pcols}),(map { "RA.$_" } @{$acols}));
SELECT %s
FROM rhnPackage RP, rhnPackageArch RPA, $ep_table REP
WHERE REP.errata_id = ? AND REP.package_id = RP.id AND RP.package_arch_id = RA.id
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute($id);

  my @res;
  my @row;

  push @res, [ @row ] while(@row = $sth->fetchrow);

  return @res;
}

sub add_errata_package {
  my $class = shift;
  my $errata_id = shift;
  my $pkg_id = shift;

  if(!$errata_id or !$pkg_id) {
    croak "${class}->add_errata_package called without both package_id and errata_id";
  }

  my $ep_table = $class->table_map('rhnErrataPackage');

  my $query = <<EOQ;
INSERT INTO $ep_table (errata_id,package_id) VALUES (?,?)
EOQ

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare($query);
  $sth->execute($errata_id,$pkg_id); 
  $dbh->commit;
}

sub remove_errata_package {
  my $class = shift;
  my $errata_id = shift;
  my $pkg_id = shift;

  if(!$errata_id or !$pkg_id) {
    croak "${class}->remove_errata_package called without both package_id and errata_id";
  }

  my $ep_table = $class->table_map('rhnErrataPackage');

  my $query = <<EOQ;
DELETE FROM $ep_table WHERE errata_id = ? AND package_id = ?
EOQ

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare($query);
  $sth->execute($errata_id,$pkg_id); 
  $dbh->commit;
}


sub errata_list_by_product {
  my $class = shift;
  my $product = shift;
  my $errata_type = shift;
  my $order_by = shift;

  my $errata_type_clause = '';
  my $order_by_clause = '';

  $order_by = 'update_date' unless $order_by;
  $order_by = 'update_date' if ($order_by eq 'date');

  if ($errata_type) {
    $errata_type_clause = " AND E.advisory_type = ?"
  }


  if ($order_by eq 'synopsis') {
    $order_by_clause = "\n ORDER BY UPPER($order_by)";
  }
  elsif ($order_by eq 'advisory') {
    $order_by_clause = "\n ORDER BY IMPORTANCE, UPPER(E.advisory_name)";
  }
  elsif ($order_by eq 'severity') {
    $order_by_clause = "\n ORDER BY RANK";
  }
  else {
    $order_by_clause = "\n ORDER BY $order_by DESC";
  }

  my $query = <<EOQ;
SELECT DISTINCT E.id, E.advisory_name advisory, E.synopsis synopsis, TO_CHAR(E.update_date, 'YYYY-MM-DD') update_date,
                E.advisory_type, E.description,
                DECODE(E.advisory_type, 'Security Advisory', 1, 'Bug Fix Advisory', 2, 'Product Enhancement Advisory', 3) IMPORTANCE, 
                DECODE (E.severity_id, 0, 'Critical', 1, 'Important', 2, 'Moderate', 3, 'Low', ' ') SEVERITY, SEV.rank RANK
  FROM  rhnErrata E,
        rhnChannelErrata CE,
        rhnProductChannel PC,
        rhnProduct P,
        rhnErrataSeverity SEV
 WHERE  P.label = ?
   AND  E.severity_id = SEV.id (+)
   AND  P.id = PC.product_id
   AND  PC.channel_id = CE.channel_id 
   AND  CE.errata_id = E.id $errata_type_clause $order_by_clause
EOQ

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare($query);

  $sth->execute($product, $errata_type_clause ? ($errata_type) : ());

  my @ret;
  while (my @row = $sth->fetchrow) {
      push @ret, [ @row ];
  }

  return @ret;
}

# Returns a list of errata for a given CVE
sub find_by_cve {
    my $class = shift;
    my $cve = shift;

    my $query = <<EOQ;
SELECT product, advisory
  FROM rhnErrata e, rhnCVE c, rhnErrataCVE ec
  WHERE c.name LIKE ? AND
  c.id = ec.cve_id AND
  ec.errata_id = e.id
ORDER BY product ASC
EOQ

    my $dbh = RHN::DB->connect;
    my $sth = $dbh->prepare($query);

    #$sth->bind_param( 1, $cve );
    $sth->execute("%" . $cve);
    my @ret;
    while (my ($prod, $adv) = $sth->fetchrow ) {
        push @ret, [$prod, $adv];
    }

    return @ret;
}

sub find_by_advisory {
  my $class = shift;
  my %params = @_;

  my ($type, $version, $release) =
    map { $params{"-" . $_} } qw/type version release/;

  my $release_str = '';

  if ($release) {
    $release_str = 'AND advisory_rel = ?'
  }

  my $query = <<EOQ;
SELECT id, advisory
  FROM rhnErrata
-- WHERE advisory LIKE ?
 WHERE advisory_name = ? $release_str
ORDER BY UPDATE_DATE DESC
EOQ

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare($query);

  $sth->execute($type . "-" . $version, ($release ? $release : ()));

  my @ret;
  while (my ($id, $adv) = $sth->fetchrow) {
      push @ret, [ $id, $adv ];
  }

  return @ret;
}

sub rss_recent_errata {
  my $class = shift;
  my $n = shift;

  my $dbh = RHN::DB->connect;
  my $sth;

  my $query = <<EOQ;
SELECT DISTINCT E.id, E.advisory, E.synopsis, E.description, E.topic, E.update_date
  FROM rhnErrata E,
       rhnChannelErrata CE,
       rhnProductChannel PC
 WHERE PC.channel_id = CE.channel_id
   AND CE.errata_id = E.id
ORDER BY E.UPDATE_DATE DESC
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute();

  my @ret;
  while (my @row = $sth->fetchrow) {
    last unless --$n;

    my $h;

    for my $n (qw/id advisory synopsis description topic/) {
      $h->{$n} = shift @row || '';
    }

    push @ret, $h;
  }

  return @ret;
}

sub method_names {
  return $e->method_names;
}

sub errata_fields {
  return @errata_fields;
}

sub table_class {
  return $e;
}

sub table_map {
  my $class = shift;

  return $_[0];
}

sub packages {
  my $self = shift;
  my $eid = $self->id;

  my $ep_table = $self->table_map('rhnErrataPackage');

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
SELECT package_id FROM $ep_table WHERE errata_id = :eid
EOQ

  $sth->execute_h(eid => $eid);
  my @ret;

  while (my ($pid) = $sth->fetchrow) {
    push @ret, $pid;
  }

  return @ret;
}

# used by errata search to find the package names in an errata that
# match a given string
sub matching_packages_in_errata {
  my $class = shift;
  my $eid = shift;
  my $string = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
SELECT DISTINCT PN.name
  FROM rhnPackageName PN,
       rhnPackageEVR PE,
       rhnPackageArch PA,
       rhnPackage P,
       rhnErrataPackage EP
 WHERE EP.errata_id = :eid
   AND P.id = EP.package_id
   AND PN.id = P.name_id
   AND PE.id = P.evr_id
   AND PA.id = P.package_arch_id
   AND UPPER(PN.name) LIKE UPPER('%' || :search_string || '%')
EOQ

  $sth->execute_h(eid => $eid, search_string => $string);
  my @ret;

  while (my ($pid) = $sth->fetchrow) {
    push @ret, $pid;
  }

  return @ret;
}

sub remove_packages_in_set {
  my $self = shift;
  my %attr = validate(@_, { set_label => 1, user_id => 1 });

  my $ep_table = $self->table_map('rhnErrataPackage');

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
DELETE
  FROM $ep_table EP
 WHERE EP.errata_id = :eid
   AND EP.package_id IN (SELECT S.element FROM rhnSet S WHERE S.user_id = :user_id AND S.label = :set_label)
EOQ

  $sth->execute_h(%attr, eid => $self->id);
  $dbh->commit;

  return;
}

sub add_packages_in_set {
  my $self = shift;
  my %attr = validate(@_, { set_label => 1, user_id => 1 });

  my $ep_table = $self->table_map('rhnErrataPackage');

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
INSERT
  INTO $ep_table
       (errata_id, package_id)
       SELECT :eid, S.element
         FROM rhnSet S
        WHERE S.user_id = :user_id
          AND S.label = :set_label
          AND NOT EXISTS (SELECT 1 FROM $ep_table EP2 WHERE EP2.errata_id = :eid AND EP2.package_id = S.element)
EOQ

  $sth->execute_h(%attr, eid => $self->id);
  $dbh->commit;

  return;
}

sub is_locally_modified {
  my $class = shift;
  my $eid = shift;

  my $e_table = $class->table_map('rhnErrata');

  my $dbh = RHN::DB->connect;
  my $query =<<EOQ;
SELECT E.locally_modified
  FROM $e_table E
 WHERE E.id = :eid
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute_h(eid => $eid);

  my ($mod) = $sth->fetchrow;

  return (defined $mod) ? ($mod eq 'Y' ? 1 : 0)
                        : undef;
}

sub cloned_from {
  my $self = shift;

  my $er_table = $self->table_map('rhnErrataCloned');

  die "No eid" unless $self->id;

  my $dbh = RHN::DB->connect;

  my $query = <<EOQ;
SELECT EC.original_id as from_errata_id
  FROM $er_table EC
 WHERE EC.id = :eid
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute_h(eid => $self->id);

  my ($progenitor) = $sth->fetchrow;
  $sth->finish;

  return $progenitor;
}

sub refresh_erratafiles {
  my $self = shift;

  my $dbh = RHN::DB->connect;

  my $ef_table = $self->table_map('rhnErrataFile');
  my $query = <<EOQ;
DELETE
  FROM $ef_table EF
 WHERE EF.errata_id = :eid
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute_h(eid => $self->id);

  my $ep_table = $self->table_map('rhnErrataPackage');
  $query = <<EOQ;
SELECT rhn_erratafile_id_seq.nextval AS ID, EFT.id AS TYPE_ID, Csum.checksum md5sum, P.path, P.id AS PACKAGE_ID,
       PN.name || '-' || PE.evr.as_vre_simple() || '.' || PA.label AS NVREA
  FROM rhnErrataFileType EFT, rhnPackage P, $ep_table EP, rhnPackageName PN, rhnPackageEVR PE, rhnPackageArch PA, rhnChecksum Csum
 WHERE EFT.label = 'RPM'
   AND P.id = EP.package_id
   AND EP.errata_id = :eid
   AND P.evr_id = PE.id
   AND P.name_id = PN.id
   AND P.package_arch_id = PA.id
   AND P.checksum_id = Csum.id
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute_h(eid => $self->id);

  my $ef_insert_query = <<EOQ;
INSERT
  INTO $ef_table
       (id, errata_id, type, checksum_id, filename)
VALUES (:id, :eid, :type, lookup_checksum('md5', :md5sum), :filename)
EOQ

  my $ef_insert_sth = $dbh->prepare($ef_insert_query);

  my $efp_table = $self->table_map('rhnErrataFilePackage');
  my $efp_insert_query = <<EOQ;
INSERT
  INTO $efp_table EFP
       (errata_file_id, package_id)
VALUES (:ef_id, :pid)
EOQ

  my $efp_insert_sth = $dbh->prepare($efp_insert_query);

  my $efc_channel = $self->table_map('rhnErrataFileChannel');
  my $efc_insert_query = <<EOQ;
INSERT
  INTO $efc_channel
       (errata_file_id, channel_id)
VALUES (:ef_id, :cid)
EOQ

  my $efc_insert_sth = $dbh->prepare($efc_insert_query);

  my $channel_select_query = <<EOQ;
SELECT CP.channel_id AS ID
  FROM rhnChannelPackage CP, $ep_table EP
 WHERE CP.package_id = :pid
   AND EP.errata_id = :eid
   AND EP.package_id = CP.package_id
EOQ
  my $channel_select_sth = $dbh->prepare($channel_select_query);
  while (my $row = $sth->fetchrow_hashref) {
    $row->{PATH} ||= '/tmp/' . $row->{NVREA};
    $row->{PATH} =~ s|^redhat/linux/||;
    $row->{PATH} = substr($row->{PATH}, 0, 128);

    $ef_insert_sth->execute_h(id => $row->{ID},
			      eid => $self->id,
			      type => $row->{TYPE_ID},
			      md5sum => $row->{MD5SUM},
			      filename => $row->{PATH});

    $efp_insert_sth->execute_h(ef_id => $row->{ID},
			       pid => $row->{PACKAGE_ID});

    $channel_select_sth->execute_h(pid => $row->{PACKAGE_ID},
				   eid => $self->id);

    while (my $channel = $channel_select_sth->fetchrow_hashref) {
      $efc_insert_sth->execute_h(ef_id => $row->{ID},
				 cid => $channel->{ID});
    }
  }

  $dbh->commit;

  return;
}

1;
