#!/usr/bin/perl -w
use strict;

$|++;

use lib '/var/www/lib';

use RHN::DB;
use RHN::Server;
use RHN::SatelliteCert;
use XML::Writer;
use IO;
use Date::Parse;
use Symbol;

use Frontier::RPC2;

my $dbh = RHN::DB->connect("webdev");
$dbh->do("alter session set nls_date_format = 'YYYY-MM-DD HH24:MI:SS'");
my $sth;

my %modes = (packages => 0,
	     channels => 0,
	     errata => 0,
	     packages_short => 0,
	     dist_map => 0);

my %methods = (channels => \&channel_dump,
	       channel_families => \&channel_family_dump,
	       packages => \&package_dump,
	       packages_short => \&short_package_dump,
	       errata => \&errata_dump,
	       dist_map => \&dist_map_dump);

my $s = Frontier::RPC2->new;

my $request;

my $size = $ENV{CONTENT_LENGTH};

read STDIN, $request, $size
  or die "can't read $size from stdin: $!";

print "Content-Type: application/octet-stream\n\n";

my $writer = new XML::Writer;
$writer->xmlDecl;
$writer->startTag("rhn-satellite", "version" => "0.1");

eval {
  my $s = $s->serve($request, \%methods, 1);
  die "Request result did not return 'dummy return': $s" unless $s =~ /dummy return/;
};

if ($@) {
  warn "Err: $@";
  $writer->startTag("rhn-error");
  $writer->characters("Error: \n$@\n");
  $writer->endTag("rhn-error");
}

$writer->endTag("rhn-satellite");
$writer->end();

exit;



sub short_package_dump {
  $modes{short_package} = 1;

  package_dump(@_);
}

sub errata_dump {
  my $sysid = shift;
  my @eids = map { s/\D//g; $_  } @{+shift};

  my $system = validate_server_credentials($sysid);

  $writer->startTag("rhn-errata");

  my @errata_columns = qw/ID ADVISORY ADVISORY_TYPE PRODUCT
    DESCRIPTION SYNOPSIS TOPIC SOLUTION ISSUE_DATE UPDATE_DATE CREATED
    MODIFIED NOTES ORG_ID REFERS_TO ADVISORY_NAME ADVISORY_REL/;

  my $cert = RHN::SatelliteCert->parse_cert($system->satellite_cert);
  my %allowed_by_id = cert_channels($cert);
  my @cert_channel_ids = keys %allowed_by_id;

  my $where = '';
  $where = sprintf("E.id = EC.errata_id AND EC.channel_id IN (%s)", join(", ", ("?") x @cert_channel_ids));

  if (@eids) {
    $where .= ' AND id IN (' . join(", ", ("?") x @eids) . ")";
  }

  my $errata_columns = join(", ", map { "E.$_" } @errata_columns);
  my $query = "SELECT DISTINCT $errata_columns FROM rhnErrata E, rhnChannelErrata EC WHERE $where ORDER BY E.id";

  $sth = $dbh->prepare($query);
  $sth->execute(@cert_channel_ids ? @cert_channel_ids : (), @eids ? @eids : ());

  $where = '';
  my $and_where = '';
  if (@eids) {
    $where = 'WHERE errata_id IN (' . join(", ", ("?") x @eids) . ")";
    $and_where = 'AND errata_id IN (' . join(", ", ("?") x @eids) . ")";
  }

  my $ep_sth = $dbh->prepare(sprintf(<<EOS, join(", ", ("?") x @cert_channel_ids)));
SELECT DISTINCT EP.errata_id, EP.package_id
  FROM rhnErrataPackage EP, rhnChannelPackage CP
 WHERE CP.channel_id IN (%s)
   AND CP.package_id = EP.package_id $and_where
EOS
  $ep_sth->execute(@cert_channel_ids ? @cert_channel_ids : (), @eids ? @eids : ());

  my $ek_sth = $dbh->prepare("SELECT errata_id, keyword FROM rhnErrataKeyword $where");
  $ek_sth->execute(@eids ? @eids : ());

  my $ecve_sth = $dbh->prepare("SELECT errata_id, CVE.name FROM rhnErrataCVE, rhnCVE CVE WHERE cve_id = CVE.id $and_where");
  $ecve_sth->execute(@eids ? @eids : ());

  my $eb_sth = $dbh->prepare("SELECT errata_id, bug_id, summary FROM rhnErrataBugList $where");
  $eb_sth->execute(@eids ? @eids : ());

  my $ec_sth = $dbh->prepare("SELECT errata_id, md5sum, filename FROM rhnErrataFile $where");
  $ec_sth->execute(@eids ? @eids : ());

  $where = '';
  if (@eids) {
    $where = "AND CE.errata_id IN (" . join(", ", ("?") x @eids) . ") ";
  }

  my $echan_sth = $dbh->prepare(sprintf(<<EOS, join(", ", ("?") x @cert_channel_ids)));
SELECT  CE.errata_id, C.label
  FROM  rhnChannel C, rhnChannelErrata CE
 WHERE  CE.channel_id = C.id
   AND  CE.channel_id IN (%s)
   $where
EOS
  $echan_sth->execute(@cert_channel_ids ? @cert_channel_ids : (), @eids ? @eids : ());

  my %errata_packages;
  my %errata_bugs;
  my %errata_keywords;
  my %errata_cves;
  my %errata_checksums;
  my %errata_channels;

  while (my ($eid, $pid) = $ep_sth->fetchrow) {
    push @{$errata_packages{$eid}}, $pid;
  }

  while (my ($eid, $keyword) = $ek_sth->fetchrow) {
    push @{$errata_keywords{$eid}}, $keyword;
  }

  while (my ($eid, $cve) = $ecve_sth->fetchrow) {
    push @{$errata_cves{$eid}}, $cve;
  }

  while (my ($eid, $bug, $summary) = $eb_sth->fetchrow) {
    push @{$errata_bugs{$eid}}, [ $bug, $summary ];
  }

  while (my ($eid, $md5sum, $filename) = $ec_sth->fetchrow) {
    push @{$errata_checksums{$eid}}, [ $md5sum, $filename ];
  }

  while (my ($eid, $label) = $echan_sth->fetchrow) {
    push @{$errata_channels{$eid}}, $label
  }

  while (my @row = $sth->fetchrow) {

    $row[$_] = db_to_unixtime($row[$_])
      for (8, 9, 10, 11);

    my $pids = join(" ", map { "rhn-package-$_" } @{$errata_packages{$row[0]} || []}) || '';
    my $channels = join(" ", @{$errata_channels{$row[0]} || []}) || '';
    $writer->startTag("rhn-erratum", advisory => $row[1], packages => $pids, id => 'rhn-erratum-' . $row[0], channels => $channels);

    $writer->startTag("rhn-erratum-keywords");
    foreach my $keyword (@{$errata_keywords{$row[0]} || []}) {
      $writer->startTag("rhn-erratum-keyword");
      $writer->characters($keyword);
      $writer->endTag("rhn-erratum-keyword");
    }
    $writer->endTag("rhn-erratum-keywords");

    $writer->emptyTag("rhn-erratum-cves", "cves", join(" ", @{$errata_cves{$row[0]} || []}));

    $writer->startTag("rhn-erratum-bugs");
    foreach my $bug (@{$errata_bugs{$row[0]} || []}) {
      $writer->startTag("rhn-erratum-bug");
      $writer->startTag("rhn-erratum-bug-id");
      $writer->characters($bug->[0]);
      $writer->endTag("rhn-erratum-bug-id");
      $writer->startTag("rhn-erratum-bug-summary");
      $writer->characters($bug->[1]);
      $writer->endTag("rhn-erratum-bug-summary");
      $writer->endTag("rhn-erratum-bug");
    }
    $writer->endTag("rhn-erratum-bugs");

    $writer->startTag("rhn-erratum-checksums");
    foreach my $checksum (@{$errata_checksums{$row[0]} || []}) {
      $writer->emptyTag("rhn-erratum-checksum", md5sum => $checksum->[0], filename => $checksum->[1]);
    }
    $writer->endTag("rhn-erratum-checksums");

    foreach my $i (2..$#errata_columns) {
      my $field = $errata_columns[$i];
      $field =~ s/_/-/g;

      $writer->startTag("rhn-erratum-" . lc($field));
      if (defined $row[$i]) {
	$writer->characters($row[$i]);
      }
      else {
	$writer->emptyTag("rhn-null");
      }
      $writer->endTag("rhn-erratum-" . lc($field));
    }

    $writer->endTag("rhn-erratum");
  }

  $writer->endTag("rhn-errata");

  return 'dummy return';
}

sub package_dump {
  my $sysid = shift;
  my @all_pids = map { s/\D//g; $_ } @{+shift};

  my $system = validate_server_credentials($sysid);

  if ($modes{short_package}) {
    $writer->startTag("rhn-packages-short");
  }
  else {
    $writer->startTag("rhn-packages");
  }

  #warn "incoming pids:  @all_pids";

  while (@all_pids) {
    # deal w/ large #'s of arbitrary package id's
    my @pids = @all_pids[0..($#all_pids > 999 ? 999 : $#all_pids)];
    @all_pids = ($#all_pids > 999 ? @all_pids[1000..$#all_pids] : ());

    #warn "current pid batch:  @pids";
    #warn "all_pids dump:  " . Data::Dumper->Dump([(@all_pids)]);
    #warn "remaining pids:  @all_pids";
    #$writer->endTag("rhn-packages");
    #return;

    my $where = '';

    if (@pids) {
      $where = 'AND P.id IN (' . join(", ", ("?") x @pids) . ")";
    }

    my @package_columns = qw/ID ORG_ID NAME EPOCH VERSION RELEASE PACKAGE_ARCH_ID PACKAGE_SIZE/;
    push @package_columns, qw/MD5SUM PACKAGE_GROUP RPM_VERSION DESCRIPTION
SUMMARY PAYLOAD_SIZE BUILD_HOST BUILD_TIME SOURCE_RPM
VENDOR PAYLOAD_FORMAT COMPAT PATH HEADER_SIG COPYRIGHT COOKIE
CREATED MODIFIED/
  if not $modes{short_package};

    my $long_clause = <<EOS;
,       PG.name package_group, P.rpm_version, P.description, P.summary,
       P.payload_size, P.build_host, P.build_time,
       SR.name source_rpm, P.vendor, P.payload_format,
       P.compat, P.path, P.header_sig, P.copyright, P.cookie,
       P.created, P.modified
EOS

    $long_clause = '' if $modes{short_package};

    my $cert = RHN::SatelliteCert->parse_cert($system->satellite_cert);
    my %allowed_by_id = cert_channels($cert);

    my @cert_channel_ids = keys %allowed_by_id;

    my $package_columns = join(", ", @package_columns);
    $sth = $dbh->prepare(sprintf(<<EOS, join(", ", ("?") x @cert_channel_ids)));
SELECT P.id, P.org_id, PN.name, PE.epoch, PE.version, PE.release, PA.label, P.package_size,
       P.md5sum
$long_clause
  FROM rhnPackageName PN,
       rhnPackageEvr PE,
       rhnPackageArch PA,
       rhnPackageGroup PG,
       rhnPackage P,
       rhnSourceRpm SR,
       rhnChannelPackage CP
 WHERE P.name_id = PN.id
   AND P.evr_id = PE.id
   AND P.package_arch_id = PA.id
   AND P.package_group = PG.id
   AND P.source_rpm_id = SR.id
   AND P.id = CP.package_id
   AND CP.channel_id IN (%s)
$where
ORDER BY P.id
EOS

    $sth->execute(@cert_channel_ids, @pids ? @pids : ());

    my $i = 0;
    my $pkg_changelog_sth = $dbh->prepare("SELECT name, text, time, created, modified FROM rhnPackageChangelog WHERE package_id = ? ORDER BY time");

    my $pkg_conf_sth = $dbh->prepare(<<EOS);
SELECT PC.name, PC.version, PCONF.sense
  FROM rhnPackageCapability PC,
       rhnPackageConflicts PCONF
 WHERE PCONF.package_id = ?
   AND PCONF.capability_id = PC.id
EOS

    my $pkg_obs_sth = $dbh->prepare(<<EOS);
SELECT PC.name, PC.version, PO.sense
  FROM rhnPackageCapability PC,
       rhnPackageObsoletes PO
 WHERE PO.package_id = ?
   AND PO.capability_id = PC.id
EOS

    my $pkg_prov_sth = $dbh->prepare(<<EOS);
SELECT PC.name, PC.version, PP.sense
  FROM rhnPackageCapability PC,
       rhnPackageProvides PP
 WHERE PP.package_id = ?
   AND PP.capability_id = PC.id
EOS

    my $pkg_req_sth = $dbh->prepare(<<EOS);
SELECT PC.name, PC.version, PR.sense
  FROM rhnPackageCapability PC,
       rhnPackageRequires PR
 WHERE PR.package_id = ?
   AND PR.capability_id = PC.id
EOS

    my $pkg_file_sth = $dbh->prepare(<<EOS);
SELECT PC.name, PF.device, PF.inode, PF.file_mode, PF.username,
       PF.groupname, PF.rdev, PF.file_size, PF.mtime, PF.md5,
       PF.linkto, PF.flags, PF.verifyflags, PF.lang
  FROM rhnPackageCapability PC,
       rhnPackageFile PF
 WHERE PF.package_id = ?
   AND PF.capability_id = PC.id
EOS

    while (my @row = $sth->fetchrow) {

# From taw:
#
# Let's filter out any attributes with "" as their data for:
#     name, version, release, md5sum, arch, channels, id
# These *can* be an empty string:
#     epoch, org_id
#      next if ($row[0] eq undef or $row[2] eq '' or $row[4] eq '' or $row[5] eq '' or $row[6] eq '' or $row[7] eq '');
      next unless defined $row[0] and defined $row[2] and defined $row[4] and defined $row[5] and defined $row[6] and defined $row[8];

      if ($modes{short_package}) {
	$writer->emptyTag("rhn-package-short",
			  id => "rhn-package-$row[0]",
			  org_id => ($row[1] || ''),
			  name => $row[2],
			  version => $row[4],
			  release => $row[5],
			  epoch => ($row[3] || ''),
			  arch => $row[6],
			  package_size => $row[7],
			  md5sum => $row[8],
			  );
      }
      else {
	$row[$_] = db_to_unixtime($row[$_])
	  for (15, 25, 26);
	$row[$_] = clean_text($row[$_])
	  for (11, 12, 22, 23);

	$writer->startTag("rhn-package",
			  id => "rhn-package-$row[0]",
			  org_id => ($row[1] || ''),
			  name => $row[2],
			  version => $row[4],
			  release => $row[5],
			  epoch => ($row[3] || ''),
			  arch => $row[6],
			  package_size => $row[7],
			  md5sum => $row[8],
			  );
	foreach my $i (8..$#package_columns) {
	  my $field = $package_columns[$i];
	  $field =~ s/_/-/g;

	  $writer->startTag("rhn-package-" . lc($field));
	  if (defined $row[$i]) {
	    $writer->characters($row[$i]);
	  }
	  else {
	    $writer->emptyTag("rhn-null");
	  }
	  $writer->endTag("rhn-package-" . lc($field));
	}

	$writer->startTag('rhn-package-changelog');

	$pkg_changelog_sth->execute($row[0]);

	while (my @row = $pkg_changelog_sth->fetchrow) {
	  my @labels = qw/name text time created modified/;

	  $writer->startTag("rhn-package-changelog-entry");
	  foreach my $i (0..$#labels) {
	    my $l = lc $labels[$i];

	    $writer->startTag("rhn-package-changelog-entry-$l");
	    $writer->characters(clean_text($row[$i] || ''));
	    $writer->endTag("rhn-package-changelog-entry-$l");
	  }
	  $writer->endTag("rhn-package-changelog-entry");
	}
	$writer->endTag('rhn-package-changelog');

	foreach my $s (qw/provides requires obsoletes conflicts/) {
	  $writer->startTag("rhn-package-$s");
	  my %handles = (provides => $pkg_prov_sth,
			 requires => $pkg_req_sth,
			 obsoletes => $pkg_obs_sth,
			 conflicts => $pkg_conf_sth);

	  my $sth = $handles{$s};
	  $sth->execute($row[0]);

	  while (my @row = $sth->fetchrow) {
	    my @labels = qw/name version sense/;

	    $writer->emptyTag("rhn-package-$s-entry", name => $row[0], version => $row[1] || '', sense => $row[2]);
	  }
	  $writer->endTag("rhn-package-$s");
	}

	$writer->startTag("rhn-package-files");

	$pkg_file_sth->execute($row[0]);

	while (my @row = $pkg_file_sth->fetchrow) {
	  my @labels = qw/name device inode file_mode username groupname rdev file_size mtime md5 linkto flags verifyflags lang/;

	  $row[0] = clean_text($row[0]);
	  do { $_ = '' unless defined $_ } foreach @row;
	  my %h;
	  @h{@labels} = @row;
	  $writer->emptyTag("rhn-package-file", %h);
	}
	$writer->endTag("rhn-package-files");

	$writer->endTag("rhn-package");
      }
    }
  }
  if ($modes{short_package}) {
    $writer->endTag("rhn-packages-short");
  }
  else {
    $writer->endTag("rhn-packages");
  }
  return 'dummy return';
}

sub channel_family_dump {
  my $sysid = shift;

  my $system = validate_server_credentials($sysid);


  my $cert;
  eval {
    $cert = RHN::SatelliteCert->parse_cert($system->satellite_cert);
  };

  if ($@) {
    die "Error parsing cert: \n" . $system->satellite_cert . "\nError: $@";
  }

  die "no cert!" unless $cert;

  my %paid_families = map { @$_ } $cert->get_channel_families();
  my $num_families = keys %paid_families;
  $num_families++;

  #warn "allowed families:  " . join(", ", (keys %paid_families, 'rh-public'));

  my @cfam_columns = qw/ID NAME LABEL CREATED MODIFIED PRODUCT_URL/;
  my $sth = $dbh->prepare(sprintf <<EOS, join(", ", ("?") x $num_families));
SELECT CF.ID, CF.NAME, CF.LABEL, CF.CREATED, CF.MODIFIED, CF.PRODUCT_URL
  FROM rhnChannelFamily CF
 WHERE CF.label in (%s)
ORDER BY CF.id
EOS

  $sth->execute(keys %paid_families, 'rh-public');

  $writer->startTag("rhn-channel-families");


  while (my @row = $sth->fetchrow) {
    $row[$_] = db_to_unixtime($row[$_])
      for (3, 4);


    my @quantity;
    @quantity = ('maxmembers' => $paid_families{$row[2]}) if exists $paid_families{$row[2]};

    $writer->startTag("rhn-channel-family", 'id' => "rhn-channel-family-$row[0]", label => $row[2], @quantity);

    $writer->startTag("rhn-channel-family-purchasable");
    $writer->characters(0);
    $writer->endTag("rhn-channel-family-purchasable");

    foreach my $i (1..$#cfam_columns) {
      my $field = $cfam_columns[$i];
      $field =~ s/_/-/g;

      next if lc $field eq 'label';

      $writer->startTag("rhn-channel-family-" . lc($field));
      if (defined $row[$i]) {
	$writer->characters($row[$i]);
      }
      else {
	$writer->emptyTag("rhn-null");
      }
      $writer->endTag("rhn-channel-family-" . lc($field));
    }

    $writer->endTag("rhn-channel-family");
  }

  $writer->endTag("rhn-channel-families");

  return 'dummy return';
}


sub channel_dump {
  my $sysid = shift;
  my @labels = @{+shift};

  my $system = validate_server_credentials($sysid);

  my $cert = RHN::SatelliteCert->parse_cert($system->satellite_cert);
  my %allowed_channels_by_id = cert_channels($cert);

  my %allowed_channels_by_label = map { $allowed_channels_by_id{$_} => $_ } keys %allowed_channels_by_id;

  my @good_ids;

  if (@labels) {
    foreach my $label (@labels) {
      push @good_ids, $allowed_channels_by_label{$label} if ($allowed_channels_by_label{$label});
    }
    die "No valid channels found in channel list (@labels)"
      unless (@good_ids);
  }
  else {
    @good_ids = keys %allowed_channels_by_id;
    die "No valid channels found"
      unless (@good_ids);
  }

  $writer->startTag("rhn-channels");

  my @channel_columns = qw/ID PARENT_CHANNEL ORG_ID ARCH LABEL BASEDIR
    NAME SUMMARY DESCRIPTION LAST_MODIFIED CREATED MODIFIED/;

#   my $where = '';
#   if (@labels) {
#     $where = "AND C.label IN (" . join(", ", ("?") x @labels) . ")";
#   }

  my $channel_columns = join(", ", @channel_columns);
  $sth = $dbh->prepare(sprintf(<<EOS, join(", ", ("?") x @good_ids)));
SELECT C.ID, C2.LABEL, C.ORG_ID, CA.LABEL, C.LABEL, C.BASEDIR, C.NAME,
       C.SUMMARY, C.DESCRIPTION, C.LAST_MODIFIED, C.CREATED, C.MODIFIED
  FROM rhnChannelArch CA,
       rhnChannel C2,
       rhnChannel C
 WHERE C.id IN (%s)
   AND C.channel_arch_id = CA.id
   AND CA.label IN ('channel-ia32', 'channel-ia64')
   AND C.parent_channel = C2.id(+)
ORDER BY id
EOS
  $sth->execute(@good_ids);

  my $sth2 = $dbh->prepare(<<EOS);
SELECT package_id FROM rhnChannelPackage WHERE channel_id = ?
EOS

  my @cfam_columns = qw/ID LABEL/;
  my $sth3 = $dbh->prepare(<<EOS);
SELECT CF.ID, CF.LABEL
  FROM rhnChannelFamily CF, rhnChannelFamilyMembers CFM
 WHERE CFM.channel_id = ?
   AND CFM.channel_family_id = CF.id
ORDER BY CF.id
EOS

  my $sth4 = $dbh->prepare(<<EOS);
SELECT CE.errata_id FROM rhnChannelErrata CE where CE.channel_id = ?
EOS

  my $sth5 = $dbh->prepare(<<EOS);
SELECT dcm.os, dcm.release, ca.label
  FROM rhnDistChannelMap dcm, rhnChannelArch ca
 WHERE dcm.channel_id = ?
   AND dcm.channel_arch_id = ca.id
   AND CA.label IN ('channel-ia32', 'channel-ia64')
ORDER BY dcm.os, dcm.release, ca.label
EOS


  while (my @row = $sth->fetchrow) {
    $row[$_] = db_to_unixtime($row[$_])
      for (9, 10, 11);

    next unless $allowed_channels_by_id{$row[0]};

    my @pids;

    $sth2->execute($row[0]);
    while (my ($pid) = $sth2->fetchrow) {
      push @pids, $pid;
    }
    my $package_string = join(" ", map { "rhn-package-$_" } @pids);

    my @cerrata;
    $sth4->execute($row[0]);
    while (my ($ce) = $sth4->fetchrow) {
        push @cerrata, $ce;
    }
    my $cerr_string = join(" ", map { "rhn-erratum-$_" } @cerrata);

    $writer->startTag("rhn-channel", 
        'channel-id' => "rhn-channel-$row[0]", 
        label => $row[4], 
        packages => $package_string, 
        "channel-errata" => $cerr_string);

    foreach my $i (1..$#channel_columns) {
      my $field = $channel_columns[$i];
      $field =~ s/_/-/g;

      next if lc $field eq 'label';
      if (lc $field eq 'arch') {
	$row[$i] = channel_arch_to_old_arch($row[$i]);
      }

      $writer->startTag("rhn-channel-" . lc($field));
      if (defined $row[$i]) {
	$writer->characters($row[$i]);
      }
      else {
	$writer->emptyTag("rhn-null");
      }
      $writer->endTag("rhn-channel-" . lc($field));
    }

    # Channel families

    $writer->startTag("rhn-channel-families");

    $sth3->execute($row[0]);

    while (my @fam = $sth3->fetchrow) {
      $writer->emptyTag("rhn-channel-family", 
        'id' => "rhn-channel-family-$fam[0]", 
        label => $fam[1],
        );
    }

    $writer->endTag("rhn-channel-families");

    # Dists
    $writer->startTag("rhn-dists");

    $sth5->execute($row[0]);

    while (my @dist = $sth5->fetchrow) {
      $writer->emptyTag( "rhn-dist",
        'os' => $dist[0],
        'release' => $dist[1],
        'arch' => channel_arch_to_old_arch($dist[2]));
    }

    $writer->endTag("rhn-dists");

    $writer->endTag("rhn-channel");
  }

  $writer->endTag("rhn-channels");

  return 'dummy return';
}

sub dist_map_dump {
  my $sysid = shift;
  my @labels = @{+shift};

  my $system = validate_server_credentials($sysid);

  my $cert = RHN::SatelliteCert->parse_cert($system->satellite_cert);
  my %allowed_channels_by_id = cert_channels($cert);

  my %allowed_channels_by_label = map { $allowed_channels_by_id{$_} => $_ } keys %allowed_channels_by_id;


  my @good_ids;

  if (@labels) {
    foreach my $label (@labels) {
      push @good_ids, $allowed_channels_by_label{$label} if ($allowed_channels_by_label{$label});
    }
  }
  else {
    @good_ids = keys %allowed_channels_by_id;
  }

  $writer->startTag("rhn-dist-channel-map");


  my $sth = $dbh->prepare(sprintf(<<EOS, join(", ", ("?") x @good_ids)));
SELECT dcm.os, dcm.release, ca.label, c.label
  FROM rhnDistChannelMap dcm, rhnChannel c, rhnChannelArch Ca
 WHERE dcm.channel_id = c.id
   AND dcm.channel_arch_id = ca.id
   AND c.id IN (%s)
   AND CA.label IN ('channel-ia32', 'channel-ia64')
ORDER BY dcm.os, dcm.release, ca.label, dcm.channel_id
EOS

  $sth->execute(@good_ids);

  while (my @row = $sth->fetchrow) {
    $writer->emptyTag("rhn-dist", 'os' => $row[0], 'release' => $row[1], 'arch' => channel_arch_to_old_arch($row[2]), 'channel' => $row[3]);
  }

  $writer->endTag("rhn-dist-channel-map");

  return 'dummy return';
}

sub validate_server_credentials {
  my $sysid = shift;

  my $server = RHN::Server->lookup_by_cert($sysid);

  # TODO: Validate the server is a satellite box, too

  my $cert = $server->satellite_cert;
  die "no cert, not a satellite?" unless $cert;

  return $server;
}

sub cert_channels { #all channels provided by the cert, plus all public channels
  my $cert = shift;

  my @paid_families = map { $_->[0] } $cert->get_channel_families;

  push @paid_families, 'rh-public';

  my $sth = $dbh->prepare(<<EOQ);
SELECT C.id, C.label
  FROM rhnChannel C, rhnChannelFamilyMembers CFM, rhnChannelFamily CF
 WHERE CF.label = ?
   AND CFM.channel_family_id = CF.id
   AND CFM.channel_id = C.id
EOQ

  my %channels;

  foreach my $fam (@paid_families) {
    $sth->execute($fam);
    while (my ($cid, $clabel) = $sth->fetchrow) {
      $channels{$cid} = $clabel;
    }
  }

  return %channels;
}

sub db_to_unixtime {
  my $time = shift;

  return str2time($time, "EST");
}

sub clean_text {
  my $t = shift;

  $t =~ s/\xa9/(C)/g;
  $t =~ tr/\x09\x0a\x0d[\x20-\x7F]/?/cs;

  return $t;
}

sub channel_arch_to_old_arch {
  my $channel_arch = shift;

  my %mapping = ('channel-ia32' => 'i386',
		 'channel-ia64' => 'ia64',
		 'channel-sparc' => 'sparc',
		 'channel-alpha' => 'alpha',
		 'channel-s390' => 's390',
		 'channel-s390x' => 's390x',
		 'channel-iSeries' => 'iSeries',
		 'channel-pSeries' => 'pSeries');

  if (exists $mapping{$channel_arch}) {
    return $mapping{$channel_arch};
  }
  else {
    die "Invalid channel arch mapping: $channel_arch";
  }
}
