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

package RHN::DB::SatCluster;

use strict;
use Carp;

use RHN::DB;
use RHN::DB::TableClass;
use RHN::DataSource;

use RHN::DataSource::Simple ();
use RHN::SatCluster ();

use Digest::MD5 qw/md5_hex/;

use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

our $VERSION = (split(/s+/, q$Id$, 4))[2];

# Hash of default values for instance construction
use constant INSTANCE_DEFAULTS => (
);

# 
# Notes:
#   - TARGET_TYPE should always be 'CLUSTER'.
#   - PHYSICAL_LOCATION_ID should always be 1.
#   - DEPLOYED should always be 1.
#   - The lookup method (and similar) should fetch both the cluster and
#     node records (the latter stored in the 'node' field).
#   - The create method should create both the cluster and node records.
#   - RECID should be an RHN server ID (RHNSERVER.ID); CUSTOMER_ID should
#     be that server's ORG_ID.  (Note that RECID must be provided, not
#     created.)
#     

# Development notes:
#  - I'm thinking we don't need a SatNode.pm.  This module will
#    be the only one dealing directly with the DB records, so it
#    can do the separate records behind the scenes.


# Generated getter/setter methods (per Chip)
  my @s_fields = qw(
    recid customer_id description public_key vip pem_public_key
    pem_public_key_hash last_update_user last_update_date
  );
  my @other_fields = qw(
    mac_address server_id
  );

  my $s = new RHN::DB::TableClass('rhn_sat_cluster', 'SC', '', @s_fields);

  my $tmpl = q|
    sub [[field]] {
      my $self = shift;
      if (@_) {
	if ("[[field]]" ne "recid") {
	  $self->{":modified:"}->{[[field]]} = 1;
	}
        $self->{__[[field]]__} = shift;
      }
      return $self->{__[[field]]__};
    };
  |;

  foreach my $field (@s_fields, @other_fields) {

    (my $sub = $tmpl) =~ s/\[\[field\]\]/$field/g;

    eval $sub;

    croak $@ if($@);
  }



#########
sub new {
#########
  my $class = shift;
  my %args  = @_;
  my $self  = {};
  bless($self, $class);

  foreach my $arg (keys %args) {
    $self->$arg($args{$arg});
  }

  # Set defaults for values that weren't supplied to the constructor
  my %defaults = (INSTANCE_DEFAULTS);
  foreach my $field (keys %defaults) {
    $self->$field($defaults{$field}) unless(defined($self->$field()));
  }

  return $self;
}



# Create a blank SAT_CLUSTER object
############
sub create {
############
  my $class = shift;
  my $self = bless { }, $class;
  return $self;
}


################
sub create_new {
################
  my $self = shift;
  my $dbh  = RHN::DB->connect;
  my($sql, $data, $sth);

  # We'll need to create four records:
  #   1. An RHN_COMMAND_TARGET record for the scout cluster;
  #   2. An RHN_SAT_CLUSTER record for the scout cluster;
  #   3. An RHN_COMMAND_TARGET record for the scout node;
  #   4. An RHN_SAT_NODE record for the scout node.

  # Make sure required values are set
  my @required = qw(
    customer_id description last_update_user
  );

  foreach my $field (@required) {
    unless ($self->$field() =~ /\S/) {
      die "Required field '$field' is not set\n";
    }
  }

  # Fetch two IDs from RHN_COMMAND_TARGET_RECID_SEQ to act 
  # as the sat_cluster recid and sat_node recid
  $sql = q{
    SELECT sequence_nextval('RHN_COMMAND_TARGET_RECID_SEQ')
    FROM   dual
  };

  $sth = $dbh->prepare($sql);

  my %recid;
  foreach my $type (qw(cluster node)) {
    $sth->execute();
    $recid{$type} = $sth->fetchrow;
  }

  # Next, create RHN_COMMAND_TARGET records
  $sql = q{
    INSERT INTO rhn_command_target (recid, target_type, customer_id)
    VALUES (?, ?, ?)
  };
  $sth = $dbh->prepare($sql);

  foreach my $type (keys %recid) {
    $sth->execute($recid{$type}, $type, $self->customer_id);
  }


  # Then create the RHN_SAT_CLUSTER record
  $sql = q{
    INSERT INTO rhn_sat_cluster (
      RECID,
      TARGET_TYPE,
      CUSTOMER_ID,
      DESCRIPTION,
      LAST_UPDATE_USER,
      LAST_UPDATE_DATE,
      PHYSICAL_LOCATION_ID,
      VIP,
      DEPLOYED
    )
    VALUES (
      :recid,
      'cluster',
      :customer_id,
      :description,
      :last_update_user,
      CURRENT_TIMESTAMP,
      1,
      :vip,
      1
    )
  };

  $dbh->do_h($sql,
    recid            => $recid{'cluster'},
    customer_id      => $self->customer_id,
    description      => $self->description,
    last_update_user => $self->last_update_user,
    vip              => $self->vip,
  );

  my $scout_shared_key = generate_shared_key();

  # Finally, create the RHN_SAT_NODE record.
  $sql = q{
    INSERT INTO rhn_sat_node (
      RECID,
      TARGET_TYPE,
      LAST_UPDATE_USER,
      LAST_UPDATE_DATE,
      MAC_ADDRESS,
      MAX_CONCURRENT_CHECKS,
      SAT_CLUSTER_ID,
      IP,
      SCHED_LOG_LEVEL,
      SPUT_LOG_LEVEL,
      DQ_LOG_LEVEL,
      SCOUT_SHARED_KEY,
      SERVER_ID
    )
    VALUES (
      :recid,
      'node',
      :last_update_user,
      CURRENT_TIMESTAMP,
      :mac_address,
      10,
      :sat_cluster_id,
      :ip,
      1,
      1,
      1,
      :scout_shared_key,
      :server_id
    )
  };

  $dbh->do_h($sql,
    recid            => $recid{'node'},
    last_update_user => $self->last_update_user,
    mac_address      => 'not set',
    sat_cluster_id   => $recid{'cluster'},
    scout_shared_key => $scout_shared_key,
    server_id        => $self->server_id,
    ip               => $self->vip,
  );


  # Commit changes
  $dbh->commit();

  # Record my ID
  $self->recid($recid{'cluster'});



}

############
sub commit {
############

 # <<INSERT CODE HERE>>

}


# Look up sat cluster by ID
############
sub lookup {
############
  my $class = shift;
  my %params = Params::Validate::validate(@_, { recid => { optional => 0}});
  my $recid = $params{recid};

  my $dbh;
  my $sqlstmt;
  my $sth;
  my $instance;
  my @columns;

  $dbh = RHN::DB->connect;
  $sqlstmt = $s->select_query("SC.recid = ?");
  $sth = $dbh->prepare($sqlstmt);
  $sth->execute($recid);
  @columns = $sth->fetchrow;
  $sth->finish;

  if ($columns[0]) {
    $instance = $class->create;
    $instance->recid($columns[0]);
    foreach ($s->method_names) {
      $instance->$_(shift @columns);
    }
    delete $instance->{":modified:"};
  }
  else {
    local $" =", ";
    die "error loading sat_cluster $recid (@columns)";
  }

  return $instance;

}


#################
sub push_config {
#################
  my $class = shift;
  my $org_id = shift;
  my $scout_id = shift;
  my $user_id = shift;

  my $dbh = RHN::DB->connect;
  my $sth;

  my $scout = RHN::SatCluster->lookup(-recid => $scout_id);

  $dbh->call_procedure('rhn_install_org_satellites', $scout->customer_id, $scout_id, $user_id);

  $dbh->commit;
}

#########################
sub generate_shared_key {
#########################
  open(RANDOM, '/dev/urandom') or die 'could not open /dev/urandom for reading!';
  binmode(RANDOM);
  my $rand_data;
  my $result = read(RANDOM, $rand_data, 128);
  close(RANDOM);

  unless (defined $result) {
    die 'could not read from /dev/urandom!';
  }

  my $digest = md5_hex($rand_data);
  my $ssk = substr($digest, 0, 12);

  return $ssk;
}

###############
sub fetch_key {
###############
  my $class = shift;
  my $sat_cluster_id = shift;


  my $ds = new RHN::DataSource::Simple(-querybase => 'scout_queries',
				       -mode => 'fetch_key');

  my $data = $ds->execute_query(-sat_cluster_id => $sat_cluster_id);

  unless (@$data) {
    return undef;
  }

  my $key = $data->[0]->{SCOUT_SHARED_KEY};

  return $key;
}

1;

__END__
=head1 NAME

RHN::DB::SatCluster - Monitoring scout clusters ("sat clusters")

=head1 SYNOPSIS

  use RHN::DB::SatCluster;
  
  <<INSERT SAMPLE CODE HERE>>

=head1 DESCRIPTION

RHN::DB::SatCluster provides access to RHN monitoring "satellite clusters"
(a.k.a. scouts) (the RHN_SAT_CLUSTER and RHN_SAT_NODE tables).

=head1 CLASS METHODS

=over 8

=item new()

Creates a new RHN::DB::SatCluster object.


=item lookup()

Look up sat cluster by ID


=item push_config(org_id, scout_id, user_id)

Call the rhn_install_org_satellites stored procedure to add the
needed records to make the desired scouts want to request a new
config file

=item generate_shared_key()

Generates a hex md5sum random scout_shared_key that will be instered into the
sat_node record when a new scout is create via a web-based install.
This key will be use as a replacemtn for the easily guessable sat_cluster_id
in scout to MOC communications

=item fetch_key(sat_cluster_id)

Method to simply grab the scout_shared_key for a given sat_cluster_id

=back

=head1 COPYRIGHT

Copyright (c) 2004-2010, Red Hat, Inc.  All rights reserved

=cut


