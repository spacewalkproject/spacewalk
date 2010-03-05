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

use strict;

package RHN::DB::ChannelEditor;

use RHN::DB;
use RHN::DataSource::Errata;

use RHN::Channel;
use Date::Parse;

use RHN::ErrataTmp;
use RHN::ErrataEditor;
use RHN::ChannelEditor;

use RHN::Date ();

use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

sub packages_in_channel {
  my $class = shift;
  my $cid = shift;

  die "No channel id!" unless $cid;

  my $dbh = RHN::DB->connect;
  my $query;
  my $sth;

  $query = <<EOS;
  SELECT DISTINCT CP.package_id
    FROM rhnChannelPackage CP
   WHERE CP.channel_id = ?
EOS

  $sth = $dbh->prepare($query);

  $sth->execute($cid);

  my @result;

  while (my ($pid) = $sth->fetchrow) {
    push @result, $pid;
  }

  return @result;

}

sub channel_base_arch_map {
  my $self = shift;

  my $dbh = RHN::DB->connect;

  my $query;
  my $sth;

  $query = <<EOQ;
SELECT CA.id, CA.label, CA.name
  FROM rhnChannelArch CA
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute();

  my @archs;

  while (my $row = $sth->fetchrow_hashref) {
    push @archs, $row;
  }

  my %archmap;
  foreach my $arch (@archs) {
    $archmap{$arch->{ID}} = {LABEL => $arch->{LABEL},
			      NAME  => $arch->{NAME},
			      };
  }

  return \%archmap;
}

sub default_arch_id {
  my $class = shift;

  my $dbh = RHN::DB->connect;

  my $query;
  my $sth;

  $query = <<EOQ;
SELECT id FROM rhnChannelArch WHERE label = 'channel-ia32'
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute();

  my ($id) = $sth->fetchrow;

  $sth->finish;

  return $id;
}


sub channels_visible_to_org_with_parent {
  my $self = shift;
  my $org_id = shift;

  my $dbh = RHN::DB->connect;

  my $query;
  my $sth;
#Only display if there is a parent channel available See Bug 432650
  $query = <<EOQ;
SELECT  ACh.channel_name NAME, ACh.channel_id ID, ACh.channel_depth DEPTH, C.org_id CHANNEL_ORG_ID
  FROM  rhnAvailableChannels ACh inner join 
  	rhnChannel C on C.id = ACh.channel_id  left outer join
  	rhnAvailableChannels ACh2 on C.parent_channel = ACh2.channel_id
  where ACh.org_id = :org_id AND (C.parent_channel is NULL or ACH2.org_id = :org_id)
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute_h(org_id => $org_id);

  my @channels;

  while (my $row = $sth->fetchrow_hashref) {
    push @channels, $row;
  }

  return @channels;
}


sub channels_visible_to_org {
  my $self = shift;
  my $org_id = shift;

  my $dbh = RHN::DB->connect;

  my $query;
  my $sth;

  $query = <<EOQ;
SELECT  ACh.channel_name NAME, ACh.channel_id ID, ACh.channel_depth DEPTH, C.org_id CHANNEL_ORG_ID
  FROM  rhnAvailableChannels ACh, rhnChannel C
 WHERE  ACh.org_id = :org_id
   AND  C.id = ACh.channel_id
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute_h(org_id => $org_id);

  my @channels;

  while (my $row = $sth->fetchrow_hashref) {
    push @channels, $row;
  }

  return @channels;
}

sub add_channel_packages {
  my $class = shift;
  my $cid = shift;
  my @pids = @_;

  die "No channel id" unless $cid;

  my $query = <<EOQ;
DELETE
  FROM rhnChannelPackage
 WHERE package_id = :pid
   AND channel_id = :cid
EOQ

  my $dbh = RHN::DB->connect();
  my $sth = $dbh->prepare($query);

  foreach my $pid (@pids) {
    $sth->execute_h(pid => $pid, cid => $cid);
  }

  $query = <<EOQ;
INSERT
  INTO rhnChannelPackage
       (channel_id, package_id)
VALUES (:cid, :pid)
EOQ

  $sth = $dbh->prepare($query);

  foreach my $pid (@pids) {
    $sth->execute_h(cid => $cid, pid => $pid);
  }

  $sth = $dbh->prepare(<<EOQ);
INSERT 
  INTO rhnRepoRegenQueue
        (id, channel_label, client, reason, force, bypass_filters, next_action, created, modified)
VALUES (rhn_repo_regen_queue_id_seq.nextval,
        :label, 'perl-web::add_channel_packages', NULL, 'N', 'N', sysdate, sysdate, sysdate)
EOQ

  my $channel = RHN::Channel->lookup(-id => $cid); 
  $sth->execute_h(label => $channel->label);

  $dbh->call_procedure('rhn_channel.update_channel', $cid);

  $dbh->commit;

  return 1;
}

sub remove_channel_packages {
  my $class = shift;
  my $cid = shift;
  my @pids = @_;

  die "No channel id" unless $cid;

  my $query = <<EOQ;
DELETE
  FROM rhnChannelPackage
 WHERE package_id = :pid
   AND channel_id = :cid
EOQ

  my $dbh = RHN::DB->connect();
  my $sth = $dbh->prepare($query);

  foreach my $pid (@pids) {
    $sth->execute_h(pid => $pid, cid => $cid);
  }

  $sth = $dbh->prepare(<<EOQ);
INSERT 
  INTO rhnRepoRegenQueue
        (id, channel_label, client, reason, force, bypass_filters, next_action, created, modified)
VALUES (rhn_repo_regen_queue_id_seq.nextval,
        :label, 'perl-web::remove_channel_packages', NULL, 'N', 'N', sysdate, sysdate, sysdate)
EOQ

  my $channel = RHN::Channel->lookup(-id => $cid); 
  $sth->execute_h(label => $channel->label);

  $dbh->call_procedure('rhn_channel.update_channel', $cid);

  $dbh->commit;

  return 1;
}

sub clone_channel_packages {
  my $class = shift;
  my $from_cid = shift;
  my $to_cid = shift;

  my $dbh = RHN::DB->connect();
  my $sth = $dbh->prepare(<<EOQ);
INSERT INTO rhnChannelPackage
(channel_id, package_id)
(SELECT :to_cid, CP.package_id
   FROM rhnChannelPackage CP,
        rhnPackage P,
        rhnChannelPackageArchCompat CPAC,
        rhnChannel C
  WHERE CP.channel_id = :from_cid
    AND C.id = :to_cid
    AND P.id = CP.package_id
    AND CPAC.channel_arch_id = C.channel_arch_id
    AND CPAC.package_arch_id = P.package_arch_id)
EOQ

  $sth->execute_h(to_cid => $to_cid, from_cid => $from_cid);

  $sth = $dbh->prepare(<<EOQ);
INSERT 
  INTO rhnRepoRegenQueue
        (id, channel_label, client, reason, force, bypass_filters, next_action, created, modified)
VALUES (rhn_repo_regen_queue_id_seq.nextval,
        :label, 'perl-web::clone_channel_packages', NULL, 'N', 'N', sysdate, sysdate, sysdate)
EOQ

  my $channel = RHN::Channel->lookup(-id => $to_cid); 
  $sth->execute_h(label => $channel->label);

  $dbh->call_procedure('rhn_channel.update_channel', $to_cid);

  $dbh->commit;
}

sub clone_original_channel_packages {
  my $class = shift;
  my $from_cid = shift;
  my $to_cid = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
INSERT INTO rhnChannelPackage
(channel_id, package_id)
(SELECT :to_cid, OLDEST.package_id
  FROM  (SELECT P.id package_id,
                RANK() OVER (PARTITION BY P.name_id, P.package_arch_id ORDER BY PE.evr ASC) AS DEPTH
          FROM rhnPackageEVR PE,
               rhnPackage P,
               rhnChannelPackage CP
         WHERE CP.channel_id = :from_cid
           AND P.id = CP.package_id
           AND PE.id = P.evr_id
        ) OLDEST
  WHERE OLDEST.DEPTH = 1
    AND NOT EXISTS (SELECT 1
                      FROM rhnChannelErrata CE, rhnErrataPackage EP
                     WHERE CE.channel_id = :from_cid
                       AND CE.errata_id = EP.errata_id
                       AND EP.package_id = OLDEST.package_id)
)
EOQ

  $sth->execute_h(to_cid => $to_cid, from_cid => $from_cid);

  $sth = $dbh->prepare(<<EOQ);
INSERT 
  INTO rhnRepoRegenQueue
        (id, channel_label, client, reason, force, bypass_filters, next_action, created, modified)
VALUES (rhn_repo_regen_queue_id_seq.nextval,
        :label, 'perl-web::clone_original_channel_packages', NULL, 'N', 'N', sysdate, sysdate, sysdate)
EOQ

  my $channel = RHN::Channel->lookup(-id => $to_cid); 
  $sth->execute_h(label => $channel->label);

  $dbh->call_procedure('rhn_channel.update_channel', $to_cid);

  $dbh->commit;
}

sub clone_all_errata {
  my $class = shift;
  my %attr = validate(@_, {from_cid => 1, to_cid => 1, org_id => 1});

  my $data = $class->errata_migration_provider(-from_cid => $attr{from_cid}, -to_cid => $attr{to_cid}, -org_id => $attr{org_id});

  my $special_handling;

  foreach my $e_data (@{$data}) {
    my $eid = $e_data->{ID};
    my $owned_errata = $e_data->{OWNED_ERRATA};


	#if there are no errata that have been cloned from this one, let's clone it
    if (not defined $owned_errata) {
      RHN::ChannelEditor->clone_errata_into_channel(%attr, -eid => $eid);
    }
    #if there has only been one errata cloned from it, and it isn't modified or published
    elsif ( (scalar @{$owned_errata} == 1)
	    and not $owned_errata->[0]->{LOCALLY_MODIFIED}
	    and $owned_errata->[0]->{PUBLISHED} ) {
      RHN::ChannelEditor->add_cloned_errata_to_channel(-eids => [ $owned_errata->[0]->{ID} ], -to_cid => $attr{to_cid}, -from_cid => $attr{from_cid});
    }
    #else there are more than 1 errata (or none that are unmodified and published), so we need to figure out how to handle it
    else {
    	my $found = 0;
		foreach my $tmp_errata (@{$owned_errata}) {
			if ( not $tmp_errata->{LOCALLY_MODIFIED} and $tmp_errata->{PUBLISHED}) {
				RHN::ChannelEditor->add_cloned_errata_to_channel(-eids => [ $tmp_errata->{ID} ], -to_cid => $attr{to_cid}, -from_cid => $attr{from_cid});
				$found = 1;
				last;
			}
		}
		#none of the multiple errata aren't modified or they are not published, so lets use the original errata
		if (not $found) {
			RHN::ChannelEditor->clone_errata_into_channel(%attr, -eid => $eid);
		}
       $special_handling++;
    }
  }

  return $data;
}

sub errata_migration_provider {
  my $class = shift;
  my %attr = validate(@_, {from_cid => 1, to_cid => 1, org_id => 1});

  my $ds = new RHN::DataSource::Errata(-mode => 'relevant_to_one_channel_but_not_another');
  my $errata_data = $ds->execute_query(-cid => $attr{from_cid}, -cid_2 => $attr{to_cid});

  $ds = new RHN::DataSource::Errata(-mode => 'published_owned_errata');
  my $published_owned_errata = $ds->execute_full(-org_id => $attr{org_id});

  $ds = new RHN::DataSource::Errata(-mode => 'unpublished_owned_errata');
  my $unpublished_owned_errata = $ds->execute_full(-org_id => $attr{org_id});

  my %tcache; #cache timestamps

  my @owned_errata =
    sort { ( ($tcache{$b->{CREATED}} ||= str2time($b->{CREATED}))     # order by timestamp, cached, newest
	     <=>                                                      # first, so the oldest cloned errata
	     ($tcache{$a->{CREATED}} ||= str2time($a->{CREATED})) )   # is the one used.  If two errata share
	   || ( $a->{ADVISORY_NAME} cmp $b->{ADVISORY_NAME} ) }                 # a timestamp, order alphabetically
      grep { exists $_->{RELATIONSHIP} and $_->{RELATIONSHIP} eq 'cloned_from' } # filter out non-cloned errata
	(@{$published_owned_errata}, @{$unpublished_owned_errata});

  my %clone_map;   # need a map to find the appropriate pre-existing errata for each Red Hat errata.

  foreach my $owned_errata (@owned_errata) {
    #push the original id
    push @{$clone_map{$owned_errata->{FROM_ERRATA_ID}}}, $owned_errata;
    #also push the clone's id (in case we clone a cloned channel)
    push @{$clone_map{$owned_errata->{ID}}}, $owned_errata;
  }

  foreach my $e_data (@{$errata_data}) {
    my $eid = $e_data->{ID};
    $e_data->{OWNED_ERRATA} = $clone_map{$eid};
  }

  return $errata_data;
}

sub clone_errata_into_channel {
  my $class = shift;
  my %attr = validate(@_, {from_cid => 0, to_cid => 1, eid => 1, org_id => 1, include_packages => 0});

  my $new_eid = RHN::ErrataEditor->clone_into_org($attr{eid}, $attr{org_id});
  my $new_errata = RHN::ErrataTmp->lookup_managed_errata(-id => $new_eid);
  $new_eid = RHN::ErrataEditor->publish_errata($new_errata);
  RHN::ChannelEditor->add_cloned_errata_to_channel(-eids => [ $new_eid ], -to_cid => $attr{to_cid}, -from_cid => $attr{from_cid});

  return $new_eid;
}

sub schedule_errata_cache_update {
  my $class = shift;

  my $org_id = shift;
  my $cid = shift;
  my $delay = shift || 0;

  die "Org id and Channel id required"
    unless ($org_id && $cid);

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
SELECT task_data
  FROM rhnTaskQueue
 WHERE task_data = ?
EOQ

  $sth->execute($cid);

  my $now = RHN::Date->now->long_date;

  $delay = $delay / (24*60*60);

  if ($sth->fetchrow) {
    $sth->finish;

    $sth = $dbh->prepare(<<EOQ);
UPDATE rhnTaskQueue
   SET earliest = TO_DATE(?, 'YYYY-MM-DD HH24:MI:SS') + ?
 WHERE task_data = ?
EOQ

    $sth->execute($now, $delay, $cid);
  }
  else {
    $sth->finish;

    $sth = $dbh->prepare(<<EOQ);
INSERT INTO rhnTaskQueue
       (org_id, task_name, task_data, priority, earliest)
VALUES (?, 'update_errata_cache_by_channel', ?, 0, TO_DATE(?, 'YYYY-MM-DD HH24:MI:SS') + ?)
EOQ

    $sth->execute($org_id, $cid, $now, $delay);
  }

  $dbh->commit;
}

#pick the 'most likely' parent for a cloned channel by:
#  1) See if the org owns a clone of the original channel's parent
#  2) Otherwise, pick the actual parent of the original channel
sub likely_parent {
  my $class = shift;
  my $org_id = shift;
  my $orig_cid = shift;

  my $target_cid;

  my $dbh = RHN::DB->connect;
  my $query =<<EOQ;
  SELECT CC.id as to_channel_id
    FROM rhnChannelCloned CC, rhnChannel C
   WHERE CC.original_id = C.parent_channel
     AND C.id = :orig_cid
     AND EXISTS (SELECT 1 FROM rhnChannelPermissions CP WHERE CP.channel_id = CC.id AND CP.org_id = :org_id)
ORDER BY CC.modified DESC
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute_h(orig_cid => $orig_cid, org_id => $org_id);

  ($target_cid) = $sth->fetchrow;
  $sth->finish;

  return $target_cid if $target_cid;

  $query =<<EOQ;
SELECT C.parent_channel
  FROM rhnChannel C
 WHERE C.id = :orig_cid
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute_h(orig_cid => $orig_cid);

  ($target_cid) = $sth->fetchrow;
  $sth->finish;

  return $target_cid;
}

sub remove_errata_from_channel {
  my $class = shift;
  my %attr = validate_with( params => \@_,
			    spec => {cid => { type => SCALAR },
				     eids => { type => ARRAYREF },
				     include_packages => { type => SCALAR },
				    },
			  );

  my $dbh = RHN::DB->connect;
  my $query =<<EOQ;
DELETE
  FROM rhnChannelErrata CE
 WHERE CE.channel_id = :cid
   AND CE.errata_id = :eid
EOQ

  my $sth = $dbh->prepare($query);

  foreach my $eid (@{ $attr{eids} }) {
    $sth->execute_h(cid => $attr{cid}, eid => $eid);
  }

  $query =<<EOQ;
DELETE
  FROM rhnChannelPackage CP
 WHERE CP.channel_id = :cid
   AND CP.package_id IN(SELECT EP.package_id FROM rhnErrataPackage EP WHERE EP.errata_id = :eid)
EOQ

  $sth = $dbh->prepare($query);

  foreach my $eid (@{$attr{eids}}) {
    $sth->execute_h(cid => $attr{cid}, eid => $eid);
    my $errata = RHN::ErrataTmp->lookup_managed_errata(-id => $eid);
    $errata->refresh_erratafiles();


  }

  $sth = $dbh->prepare(<<EOQ);
INSERT 
  INTO rhnRepoRegenQueue
        (id, channel_label, client, reason, force, bypass_filters, next_action, created, modified)
VALUES (rhn_repo_regen_queue_id_seq.nextval,
        :label, 'perl-web::remove_errata_from_channel', NULL, 'N', 'N', sysdate, sysdate, sysdate)
EOQ

  my $channel = RHN::Channel->lookup(-id => $attr{cid}); 
  $sth->execute_h(label => $channel->label);

  $dbh->call_procedure('rhn_channel.update_channel', $attr{cid});

  $dbh->commit;

  return;
}

sub add_errata_to_channel {
  my $class = shift;
  my %attr = validate_with( params => \@_,
			    spec => {cid => { type => SCALAR },
				     eids => { type => ARRAYREF },
				     include_packages => { type => SCALAR,
							   optional => 1},
				    },
			  );

  my $dbh = RHN::DB->connect();

  my $query = <<EOQ;
INSERT INTO rhnChannelErrata
       (errata_id, channel_id)
VALUES (:eid, :cid)
EOQ

  my $sth = $dbh->prepare($query);

  foreach my $eid (@{$attr{eids}}) {
    $sth->execute_h(eid => $eid, cid =>$attr{cid});
  }

  $sth->finish;

  $query = <<EOQ;
INSERT
  INTO rhnChannelPackage
       (channel_id, package_id)
       (SELECT :cid, EP.package_id
          FROM rhnErrataPackage EP
         WHERE EP.errata_id = :eid
           AND NOT EXISTS (SELECT 1
                             FROM rhnChannelPackage CP
                            WHERE CP.channel_id = :cid
                              AND CP.package_id = EP.package_id
                          )
       )
EOQ

  $sth = $dbh->prepare($query);

  foreach my $eid (@{$attr{eids}}) {
    $sth->execute_h(cid => $attr{cid}, eid => $eid);
    my $errata = RHN::ErrataTmp->lookup_managed_errata(-id => $eid);
    $errata->refresh_erratafiles();
  }

  $sth->finish;

  $sth = $dbh->prepare(<<EOQ);
INSERT 
  INTO rhnRepoRegenQueue
        (id, channel_label, client, reason, force, bypass_filters, next_action, created, modified)
VALUES (rhn_repo_regen_queue_id_seq.nextval,
        :label, 'perl-web::add_errata_to_channel', NULL, 'N', 'N', sysdate, sysdate, sysdate)
EOQ

  my $channel = RHN::Channel->lookup(-id => $attr{cid}); 
  $sth->execute_h(label => $channel->label);

  $dbh->call_procedure('rhn_channel.update_channel', $attr{cid});

  $dbh->commit;

  return 1;
}

sub add_cloned_errata_to_channel {
  my $class = shift;
  my %attr = validate_with( params => \@_,
			    spec => {to_cid => { type => SCALAR },
				     from_cid => { type => SCALAR },
				     eids => { type => ARRAYREF },
				    },
			  );

  my $dbh = RHN::DB->connect();

  my $query = <<EOQ;
INSERT INTO rhnChannelErrata
       (errata_id, channel_id)
VALUES (:eid, :cid)
EOQ

  my $sth = $dbh->prepare($query);

  foreach my $eid (@{$attr{eids}}) {
    $sth->execute_h(eid => $eid, cid =>$attr{to_cid});
  }

  $sth->finish;

  $query = <<EOQ;
INSERT
  INTO rhnChannelPackage
       (channel_id, package_id)
       (SELECT :to_cid, EP.package_id
          FROM rhnPackage P, rhnChannel C, rhnChannelPackageArchCompat CPAC, rhnChannelPackage SOURCE_CP, rhnErrataPackage EP
         WHERE 1=1
           AND SOURCE_CP.channel_id = :from_cid
           AND EP.errata_id = :eid
           AND EP.package_id = SOURCE_CP.package_id
           AND P.id = EP.package_id
           AND C.id = :to_cid
           AND CPAC.channel_arch_id = C.channel_arch_id
           AND CPAC.package_arch_id = P.package_arch_id
           AND NOT EXISTS (SELECT 1
                             FROM rhnChannelPackage TARGET_CP
                            WHERE TARGET_CP.channel_id = :to_cid
                              AND TARGET_CP.package_id = EP.package_id
                          )
       )
EOQ

  $sth = $dbh->prepare($query);

  foreach my $eid (@{$attr{eids}}) {
    $sth->execute_h(to_cid => $attr{to_cid}, from_cid => $attr{from_cid}, eid => $eid);

    my $errata = RHN::ErrataTmp->lookup_managed_errata(-id => $eid);
    $errata->refresh_erratafiles();
  }

  $sth->finish;

  $sth = $dbh->prepare(<<EOQ);
INSERT 
  INTO rhnRepoRegenQueue
        (id, channel_label, client, reason, force, bypass_filters, next_action, created, modified)
VALUES (rhn_repo_regen_queue_id_seq.nextval,
        :label, 'perl-web::add_cloned_errata_to_channel', NULL, 'N', 'N', sysdate, sysdate, sysdate)
EOQ

  my $channel = RHN::Channel->lookup(-id => $attr{to_cid}); 
  $sth->execute_h(label => $channel->label);

  $dbh->call_procedure('rhn_channel.update_channel', $attr{to_cid});

  $dbh->commit;

  return 1;
}

sub label_exists { #does channel name already exist??
  my $class = shift;
  my $label = shift;

  my $dbh = RHN::DB->connect;

  my $query =<<EOQ;
SELECT 1
  FROM rhnChannel C
 WHERE C.label = :label
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute_h(label => $label);

  my ($exists) = $sth->fetchrow;
  $sth->finish;

  return $exists;
}

1;

