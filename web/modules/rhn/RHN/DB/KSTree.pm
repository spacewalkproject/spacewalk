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

package RHN::DB::KSTree;

use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

use RHN::DB;
use RHN::SimpleStruct;
our @ISA = qw/RHN::SimpleStruct/;
our @simple_struct_fields = qw/id label base_path channel_id files boot_image org_id tree_type tree_type_name tree_type_label install_type install_type_name install_type_label channel_arch_id channel_arch_label channel_arch_name/;

use RHN::DataSource::General;
use RHN::Server;
use RHN::Channel;
use RHN::Exception qw/throw/;

sub helper_pick_field {
  my ($id, $label, $cid) = @_;

  my ($clause, @params);

  if ($id) {
    $clause = "KT.id = :kstree_id";
    @params = (kstree_id => $id);
  }
  elsif ($label) {
    $clause = "KT.label = :label";
    @params = (label => $label);
  }
  else {
    throw "need id or label";
  }

  return ($clause, \@params)
}

sub lookup {
  my $class = shift;
  my %params = validate(@_, { id => 0, label => 0 });

  my $id = $params{id};
  my $label = $params{label};

  my ($clause, $query_params) = helper_pick_field($id, $label);

  my $dbh = RHN::DB->connect;

  my $query = <<EOQ;
SELECT KT.id, KT.label, KT.base_path, KT.channel_id, KT.boot_image,
       KT.org_id, KTT.id AS TREE_TYPE, KTT.label AS TREE_TYPE_LABEL, KTT.name AS TREE_TYPE_NAME,
       KIT.id AS install_type, KIT.label AS install_type_label, KIT.name AS install_type_name,
       C.channel_arch_id, CA.label AS CHANNEL_ARCH_LABEL, CA.name AS CHANNEL_ARCH_NAME
  FROM rhnKSTreeType KTT,
       rhnKickstartableTree KT,
       rhnKSInstallType KIT,
       rhnChannel C,
       rhnChannelArch CA
 WHERE $clause
   AND KTT.id = KT.kstree_type
   AND KIT.id = KT.install_type
   AND C.id = KT.channel_id
   AND CA.id = C.channel_arch_id
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute_h(@$query_params);

  my $row = $sth->fetchrow_hashref;
  $sth->finish;

  my $self = $class->new;

  return unless ($row);
  $self->$_($row->{uc $_}) for qw/id label base_path channel_id boot_image org_id tree_type tree_type_name tree_type_label install_type install_type_label install_type_name channel_arch_id channel_arch_label channel_arch_name/;

  $sth = $dbh->prepare("SELECT relative_filename, file_size, Csum.checksum md5sum, TO_CHAR(last_modified, 'YYYY-MM-DD HH24:MI:SS') AS LAST_MODIFIED FROM rhnKSTreeFile, rhnChecksum Csum WHERE kstree_id = :tree_id AND checksum_id = Csum.id");
  $sth->execute_h(tree_id => $self->id);
  $self->files( [ $sth->fullfetch_hashref ] );

  return $self;
}

sub create_tree {
  my $class = shift;
  my %params = validate(@_, { org_id => 0, tree_type => 0, boot_image => 0,
			      label => 1, path => 1, channel_id => 1, install_type_label => 1 });

  $params{boot_image} ||= $params{label};
  $params{tree_type} ||= 'rhn-managed';

  my $dbh = RHN::DB->connect;

  my $sth = $dbh->prepare(<<EOS);
INSERT INTO rhnKickstartableTree
  (id, label, base_path, channel_id, boot_image, org_id, kstree_type, install_type)
VALUES
  (rhn_kstree_id_seq.nextval, :label, :path, :channel_id, :boot_image, :org_id,
   (SELECT id FROM rhnKSTreeType WHERE label = :tree_type),
   (SELECT id FROM rhnKSInstallType WHERE label = :install_type_label)
  )
RETURNING id INTO :tree_id
EOS

  my $tree_id;
  $sth->execute_h(tree_id => \$tree_id, map { $_ => $params{$_} } qw/label path channel_id boot_image org_id tree_type install_type_label/);

  $dbh->call_procedure('rhn_channel.update_channel', $params{channel_id});

  return $class->lookup(-id => $tree_id);
}

sub delete_tree {
  my $class = shift;
  my $id = shift;

  my $dbh = RHN::DB->connect;

  my $sth = $dbh->prepare("SELECT channel_id FROM rhnKickstartableTree WHERE id = :kstid");
  $sth->execute_h(kstid => $id);

  my ($channel_id) = $sth->fetchrow();

  unless (defined $channel_id) {
    die "no channel id for given kickstart tree id $id";
  }

  $sth = $dbh->prepare("DELETE FROM rhnKickstartableTree WHERE id = :kstid");
  $sth->execute_h(kstid => $id);
  $dbh->call_procedure('rhn_channel.update_channel', $channel_id);
}

sub has_file {
  my $self = shift;
  my $infile = shift;

  for my $file (@{$self->files}) {
    return 1 if $file->{RELATIVE_FILENAME} eq $infile;
  }

  return 0;
}

sub add_file {
  my $self = shift;

  my $files = $self->files;
  push @$files, @_;
}

sub commit {
  my $self = shift;

  my $dbh = RHN::DB->connect;

  my $sth = $dbh->prepare(<<EOQ);
UPDATE rhnKickstartableTree
   SET label = :label,
       base_path = :base_path,
       channel_id = :channel_id,
       boot_image = :boot_image
 WHERE id = :tree_id
EOQ

  $sth->execute_h(tree_id => $self->id, map { $_ => $self->$_() } qw/label base_path channel_id boot_image/);
  $dbh->call_procedure('rhn_channel.update_channel', $self->channel_id());

  $dbh->commit;
}

sub commit_files {
  my $self = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare("DELETE FROM rhnKSTreeFile WHERE kstree_id = ?");
  $sth->execute($self->id);

  my %seen;
  for my $file (@{$self->files}) {
    $sth = $dbh->prepare(<<EOQ);
INSERT INTO rhnKSTreeFile
  (kstree_id, relative_filename, checksum_id, last_modified, file_size)
VALUES
  (:tree_id, :relative_filename, lookup_checksum('md5', :md5sum), TO_DATE(:last_modified, 'YYYY-MM-DD HH24:MI:SS'), :file_size)
EOQ

    $sth->execute_h(tree_id => $self->id, map { $_ => $file->{+uc $_} } qw/relative_filename md5sum last_modified file_size/)
  }

  $dbh->call_procedure('rhn_channel.update_channel', $self->channel_id());

  $dbh->commit;
}

sub best_kstree_for_server {
  my $class = shift;
  my $user = shift;
  my $server = shift;

  my $base_channel = RHN::Server->base_channel_id($server->id);
  my $base_channel_cloned_from = RHN::Channel->channel_cloned_from($base_channel) || 0;

  my $ds = new RHN::DataSource::General(-mode => 'kstrees_for_user');
  my $forest = $ds->execute_query(-user_id => $user->id);

  my $id;
  for my $tree (@$forest) {
    if ($tree->{CHANNEL_ID} == $base_channel or
        $tree->{CHANNEL_ID} == $base_channel_cloned_from) {
      $id = $tree->{ID};
      last;
    }
  }

  if ($id) {
    return $class->lookup(-id => $id);
  }
  else {
    return;
  }
}

sub kstrees_for_user {
  my $class = shift;
  my $uid = shift;

  my $ds = new RHN::DataSource::General(-mode => 'kstrees_for_user');
  return $ds->execute_query(-user_id => $uid);
}

sub name {
  my $self = shift;

  my $channel = RHN::Channel->lookup(-id => $self->channel_id);

  return sprintf('%s (%s)', $channel->name, $self->label);
}

sub compatible_tree {
  my $self = shift;
  my $kstid = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
SELECT 1
  FROM rhnKickstartableTree KST1, rhnKickstartableTree KST2,
       rhnChannel C1, rhnChannel C2
 WHERE KST1.id = :kstid1
   AND KST2.id = :kstid2
   AND C1.id = KST1.channel_id
   AND C2.id = KST2.channel_id
   AND KST1.install_type = KST2.install_type
   AND C1.channel_arch_id = C2.channel_arch_id
EOQ

  $sth->execute_h(kstid1 => $self->id, kstid2 => $kstid);
  my ($truth) = $sth->fetchrow;
  $sth->finish;

  return $truth;
}

# If org_id is NULL, then the KSTree is an RHN kstree, hosted on the
# satellite.  Otherwise it is user-hosted.
sub is_rhn_tree {
  my $self = shift;

  return ($self->org_id ? 0 : 1);
}

# If we add more is_{foo}_capable functions, we should probably move the
# data to the database.
sub is_selinux_capable {
  my $self = shift;

  if ($self->install_type_label eq 'rhel_4') {
    return 1;
  }

  return 0;
}

1;

