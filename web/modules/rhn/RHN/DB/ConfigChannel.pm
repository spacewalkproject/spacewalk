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

package RHN::DB::ConfigChannel;

use RHN::DB;
use RHN::DB::TableClass;

use RHN::DataSource::General;

use RHN::ConfigRevision;
use RHN::Server;

use RHN::Exception qw/throw/;
use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

my @ns_fields = qw/ID ORG_ID NAME LABEL DESCRIPTION CONFCHAN_TYPE_ID CREATED:longdate MODIFIED:longdate/;
my @ns_type_fields = qw/ID LABEL NAME/;

my $ns_table = new RHN::DB::TableClass("rhnConfigChannel", "CC", "", @ns_fields);
my $ns_type_table = new RHN::DB::TableClass("rhnConfigChannelType", "CCT", "type", @ns_type_fields);

my $j = $ns_table->create_join(
   [$ns_type_table],
   {
      "rhnConfigChannel" =>
         {
            "rhnConfigChannel" => ["ID","ID"],
            "rhnConfigChannelType" => ["CONFCHAN_TYPE_ID","ID"],
	  }
    });


# build some accessors
foreach my $field ($j->method_names) {

  my $sub = q{
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

sub lookup {
   my $class = shift;
   my %attr = validate(@_, { id => 0, org_id => 0, name => 0, label => 0, cfid => 0 });

   my $id = $attr{id} || 0;


   my @columns;

   my $query;
   my @exec_params;
   if ($attr{id}) {
     $query = $j->select_query("CC.ID = ?");
     push @exec_params, $attr{id};
   }
   elsif ($attr{org_id} and $attr{name}) {
     $query = $j->select_query("CC.ORG_ID = ? AND CC.name = ?");
     push @exec_params, $attr{org_id}, $attr{name};
   }
   elsif ($attr{org_id} and $attr{label}) {
     $query = $j->select_query("CC.ORG_ID = ? AND CC.label = ?");
     push @exec_params, $attr{org_id}, $attr{label};
   }
   elsif ($attr{cfid}) {
     $query = $j->select_query("CC.id = (SELECT CF.config_channel_id FROM rhnConfigFile CF WHERE CF.id = ?)");
     push @exec_params, $attr{cfid};
   }
   else {
     my @params = @_ || '';
     throw "Invalid params @params to RHN::ConfigChannel->lookup";
   }

   my $dbh = RHN::DB->connect;
   my $sth = $dbh->prepare($query);
   $sth->execute(@exec_params);
   @columns = $sth->fetchrow;
   $sth->finish;

   my $ret;
   if ($columns[0]) {
     $ret = $class->_blank_config_channel();
     foreach ($j->method_names) {
       $ret->{"__${_}__"} = shift @columns;
     }

     delete $ret->{":modified:"};
   }
   else {
     throw "No config_channel with id '$id' found\n";
   }

   return $ret;
}

sub create_config_channel {
  my $class = shift;

  my $config_channel = $class->_blank_config_channel();
  $config_channel->{__id__} = -1;

  return $config_channel;
}

sub _blank_config_channel {
  my $class = shift;

  my $self = bless { }, $class;
  return $self;
}

sub set_type {
  my $self = shift;
  my $type = shift || '';

  my $dbh = RHN::DB->connect;

  my $query = <<EOQ;
SELECT CCT.id, CCT.label, CCT.name
  FROM rhnConfigChannelType CCT
 WHERE CCT.label = :label
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute_h(label => $type);

  my $row = $sth->fetchrow_hashref;
  $sth->finish;

  unless ($row) {
    throw "(invalid_configchannel_type) Could not find config channel type '$type'";
  }

  foreach my $attr (qw/id name label/) {
    my $meth = 'type_' . $attr;
    $self->{"__${meth}__"} = $row->{uc($attr)};
  }
  $self->confchan_type_id($row->{ID});

  return;
}

sub commit {
  my $self = shift;
  my $transaction = shift;
  my $dbh = $transaction || RHN::DB->connect;
  my $mode = 'update';

  if ($self->id == -1) {
    $mode = 'insert';
  }

  die "$self->commit called without valid id" unless $self->id;

  my @modified = keys %{$self->{":modified:"}};
  my %modified = map { $_ => 1 } @modified;

  return unless @modified;
  my $id;

  if ($mode eq 'update') {
    my @queries = $j->update_queries($j->methods_to_columns(@modified));

    foreach my $query (@queries) {
      local $" = ":";
      my $sth = $dbh->prepare($query->[0]);
      my @vals = map { $self->$_() } grep { exists $modified{$_} } @{$query->[1]};
      $sth->execute(@vals, $modified{id} ? () : $self->id);
    }
  }
  else {
    $id = $dbh->call_function('rhn_config.insert_channel', $self->org_id, $self->type_label, $self->name, $self->label, $self->description);
    $self->{__id__} = $id;
  }

  $dbh->commit unless $transaction;

  delete $self->{":modified:"};

  return $dbh if $transaction;
}

sub vivify_server_config_channel {
  my $class = shift;
  my $server_id = shift;
  my $type = shift;

  my $ret = $class->find_server_config_channel($server_id, $type) || $class->add_server_config_channel($server_id, $type);

  return $ret;
}

sub find_server_config_channel {
  my $class = shift;
  my $server_id = shift;
  my $type = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
SELECT CC.id
  FROM rhnServerConfigChannel SCC, rhnConfigChannel CC, rhnConfigChannelType CCT
 WHERE SCC.server_id = :server_id
   AND CC.id = SCC.config_channel_id
   AND CCT.id = CC.confchan_type_id
   AND CCT.label = :type
EOQ

  $sth->execute_h(server_id => $server_id, type => $type);

  my ($ccid) = $sth->fetchrow;
  $sth->finish;

  return $ccid;
}

sub add_server_config_channel {
  my $class = shift;
  my $server_id = shift;
  my $type_label = shift;

  my $server = RHN::Server->lookup(-id => $server_id);

  # non-db call
  my $cc = $class->create_config_channel();

  my $dbh = RHN::DB->connect;

  eval {
    $cc->name(sprintf('%s Config Channel for system %d', $type_label, $server->id));
    $cc->label(sprintf('%s-%d', $type_label, $server->id));
    $cc->description(sprintf('%s Config Channel for %s (%d)', $type_label, $server->name, $server->id));
    $cc->confchan_type_id($class->lookup_channel_type($type_label));
    $cc->type_label($type_label);
    $cc->org_id($server->org_id);
    $dbh = $cc->commit($dbh);

    my $sth = $dbh->prepare(<<EOQ);
INSERT
  INTO rhnServerConfigChannel
       (server_id, config_channel_id, position)
VALUES (:sid, :ccid, NULL)
EOQ

    $sth->execute_h(sid => $server_id, ccid => $cc->id);
  };

  if ($@) {
    $dbh->rollback();
    throw $@;
  }
  else {
    $dbh->commit;
    return $cc->id;
  }
}

sub lookup_channel_type {
  my $class = shift;
  my $label = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
SELECT id
  FROM rhnConfigChannelType
 WHERE label = :label
EOQ
  $sth->execute_h(label => $label);
  my ($ret) = $sth->fetchrow;
  $sth->finish;

  die "Unknown config channel type '$label'" unless defined $label;

  return $ret;
}


sub find_file_existence {
  my $self = shift;
  my $path = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
SELECT CF.id
  FROM rhnConfigFile CF
 WHERE CF.config_channel_id = :ccid
   AND CF.config_file_name_id = lookup_config_filename(:path)
EOQ
  $sth->execute_h(ccid => $self->id, path => $path);

  my ($cfid) = $sth->fetchrow;
  $sth->finish;

  return $cfid;
}

sub add_file_existence {
  my $self = shift;
  my $path = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
DECLARE
BEGIN
  :cfid := rhn_config.insert_file(:ccid, :path);
END;
EOQ
  my $cfid;
  $sth->execute_h(cfid => \$cfid, ccid => $self->id, path => $path);

  die "no cfid" unless $cfid;

  $dbh->commit;

  return $cfid;
}

sub vivify_file_existence {
  my $self = shift;
  my $path = shift;

  my $ret = $self->find_file_existence($path) || $self->add_file_existence($path);

  # TODO: if find_file_existence returned a 'dead' file, revive it

  return $ret;
}

sub lookup_latest_in_channel {
  my $class = shift;
  my %params = validate(@_, { channel_id => 1,
			      file_id => 0,
			      file_path => 0,
			    });

  unless ($params{file_id} or $params{file_path}) {
    throw "(missing_param) Need file_id or file_path";
  }

  if ($params{file_id} and $params{file_path}) {
    throw "(too_many_params) Please give a file_id or a file_path, not both";
  }

  my $dbh = RHN::DB->connect;
  my $query;
  my %query_params;

  if ($params{file_id}) {
    $query = <<EOQ;
SELECT CF.latest_config_revision_id
  FROM rhnConfigFile CF
   AND CF.id = :file_id
   AND CF.config_channel_id = :channel_id
EOQ
  }
  elsif ($params{file_path}) {
    $query = <<EOQ;
SELECT CF.latest_config_revision_id
  FROM rhnConfigFile CF,
       rhnConfigFileName CFN
 WHERE CFN.path = :file_path
   AND CF.config_file_name_id = CFN.id
   AND CF.config_channel_id = :channel_id
EOQ
  }

  my $sth = $dbh->prepare($query);
  $sth->execute_h(%params);

  my ($cr_id) = $sth->fetchrow;
  $sth->finish;

  return unless $cr_id;

  return RHN::ConfigRevision->lookup(-id => $cr_id);
}

1;
