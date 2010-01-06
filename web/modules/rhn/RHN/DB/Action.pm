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

package RHN::DB::Action;

use strict;
use Data::Dumper;
use Carp;
use Params::Validate qw/validate/;
Params::Validate::validation_options(strip_leading => "-");

use RHN::DB;
use RHN::DB::TableClass;
use RHN::Exception qw/throw/;

use RHN::DataSource::Action;

my @action_fields = qw { id org_id action_type scheduler earliest_action:longdate version name prerequisite};
my @action_overview_fields = qw { action_id scheduler_login total_count successful_count failed_count in_progress_count };
my @action_type_fields = qw { id name label };
my @action_script_fields = qw { id action_id script username groupname timeout};

my $a = new RHN::DB::TableClass("rhnAction","A","",@action_fields); 
my $ao = new RHN::DB::TableClass("rhnActionOverview","AO","action",@action_overview_fields);
my $at = new RHN::DB::TableClass("rhnActionType", "AT", "action_type", @action_type_fields);
my $as = new RHN::DB::TableClass("rhnActionScript", "A_S", "script", @action_script_fields);

my $tc = $a->create_join([ $ao, $at, $as ],{ "rhnAction" => { "rhnAction" => [ "ID", "ID" ],
						    "rhnActionOverview" => ["ID", "ACTION_ID" ],
						    "rhnActionType" => ["ACTION_TYPE", "ID"],
						    "rhnActionScript" => ["ID", "ACTION_ID" ],
							    }
					   },
			 { rhnActionScript => "(+)" }
			);

sub script_server_results {
  my $self = shift;
  my $server_id = shift;

  my $dbh = RHN::DB->connect;
  my $query;
  my $sth;

  $query = <<EOQ;
SELECT ASR.output,
       TO_CHAR(ASR.start_date, 'YYYY-MM-DD HH24:MI:SS') AS START_DATE,
       TO_CHAR(ASR.stop_date, 'YYYY-MM-DD HH24:MI:SS') AS STOP_DATE,
       ASR.return_code
  FROM rhnServerActionScriptResult ASR,
       rhnActionScript ASCRIPT
 WHERE ASCRIPT.action_id = :action_id
   AND ASCRIPT.id = ASR.action_script_id
   AND ASR.server_id = :server_id
EOQ
  $sth = $dbh->prepare($query);
  $sth->execute_h(action_id => $self->id,
		  server_id => $server_id,
		 );

  my $results = $sth->fetchrow_hashref_copy;
  $sth->finish;

  return $results;
}

sub is_type_of {
  my $self = shift;
  my $generic_type = shift;

  my $dbh = RHN::DB->connect;

  my $query;
  my $sth;

  $query = <<EOQ;
SELECT 1
  FROM DUAL
 WHERE EXISTS (
  SELECT arch_type_id
    FROM rhnArchTypeActions
   WHERE action_type_id = :action_type_id
     AND action_style = :generic_type
)
EOQ
  $sth = $dbh->prepare($query);
  $sth->execute_h(action_type_id => $self->action_type_id,
		  generic_type => $generic_type,
		 );

  my $is_type = $sth->fetchrow;
  $sth->finish;

  return 1 if $is_type;

  return 0;
}

sub get_server_status {
  my $self = shift;
  my $server_id = shift;

  my $dbh = RHN::DB->connect;

  my $query;
  my $sth;

  $query = <<EOQ;
SELECT  AST.name
  FROM  rhnActionStatus AST, rhnServerAction SA
 WHERE  SA.action_id = ?
   AND  SA.server_id = ?
   AND  SA.status = AST.id
EOQ
  $sth = $dbh->prepare($query);
  $sth->execute($self->id, $server_id);

  my $server_status = $sth->fetchrow;
  $sth->finish;

  if (!$server_status) {
    die "asked for status for server not tied to action " . $self->id;
  }

  return $server_status;
}

# Like get_server_status, but returns a hash for the server's row in
# rhnActionStatus, or an arrayref of all servers for that action if no
# server id is specified.
sub get_full_server_status {
  my $self = shift;
  my $server_id = shift;

  my $ds = new RHN::DataSource::Action (-mode => 'server_status');
  my $data = $ds->execute_full(-aid => $self->id);

  if ($server_id) {
    # There should never be more than one matching row.
    my ($row) = grep { $_->{ID} == $server_id } @{$data};

    throw "(no_status_for_server) No status found for system '$server_id', action '" . $self->id . "'"
      unless $row;

    return $row;
  }

  return $data;

}


sub cancel_pending_for_system {
  my $class = shift;
  my %params = validate(@_, {server_id => 1, transaction => 0});

  my $dbh = $params{transaction} || RHN::DB->connect;

  my $sth = $dbh->prepare(<<EOQ);
DECLARE

cursor pending_actions is
SELECT A.id
  FROM rhnAction A,
       rhnServerAction SA
 WHERE SA.server_id = :server_id
   AND SA.status = 0
   AND SA.action_id = A.id
   AND A.prerequisite IS NULL
ORDER BY A.id;

BEGIN

for action in pending_actions loop
  rhn_server.remove_action(:server_id, action.id);
end loop;
END;
EOQ

  $sth->execute_h(server_id => $params{server_id});

  if (defined $params{transaction}) {
    return $params{transaction};
  }
  else {
    $dbh->commit;
  }
}


sub delete_set_from_action {
  my $class = shift;
  my $aid = shift;
  my $uid = shift;
  my $set_name = shift;

  my $dbh = RHN::DB->connect;



  my $query = <<EOQ;
DECLARE

cursor selected_servers is
SELECT SA.server_id
  FROM rhnServerAction SA, rhnSet ST
 WHERE ST.user_id = :user_id
   AND ST.label = :label
   AND ST.element = SA.server_id
   AND SA.action_id = :action_id
   AND SA.status = 0;

BEGIN
for server in selected_servers loop
  rhn_server.remove_action(server.server_id, :action_id);
end loop;
END;
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute_h(action_id => $aid, user_id => $uid, label => $set_name);
  $dbh->commit;
}

sub delete_system_from_action_set {
  my $class = shift;
  my $sid = shift;
  my $uid = shift;
  my $set_name = shift;

  my $dbh = RHN::DB->connect;

  my $query = <<EOQ;
DECLARE

cursor selected_actions is
SELECT SA.action_id
  FROM rhnSet ST, rhnServerAction SA
 WHERE ST.user_id = :user_id
   AND ST.label = :label
   AND SA.server_id = :server_id
   AND ST.element = SA.action_id
   AND SA.status = 0;

BEGIN
for action in selected_actions loop
  rhn_server.remove_action(:server_id, action.action_id);
end loop;
END;
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute_h(server_id => $sid, user_id => $uid, label => $set_name);
  $dbh->commit;

}

sub archive_actions {
  my $class = shift;
  my $user = shift;
  my $set = shift;

  die "in RHN::Action::archive_actions.  User = '$user', set = '" . $set->label . "'\n" unless ($user && $set);

  $user->verify_action_access($set->contents)
    or die "Attempt to archive actions by '" . $user->id . "' without proper permissions.  Actions: " . join(", ", $set->contents);

  my $dbh = RHN::DB->connect;
  my $sth;

  my $query =<<EOQ;
UPDATE rhnAction
   SET archived = 1
 WHERE id IN (SELECT element FROM rhnSet WHERE user_id = ? AND label = ?)
   AND org_id = ?
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute($user->id, $set->label, $user->org->id);
  $dbh->commit;

  return;
}

sub lookup {
  my $class = shift;
  my %params = validate(@_, {id => 1});
  my $id = $params{id};

  my $dbh = RHN::DB->connect;

  my $query;
  my $sth;

  $query = $tc->select_query("A.ID = ? AND AO.ACTION_ID = ?");

  $sth = $dbh->prepare($query);
  $sth->execute($id, $id);

  my @columns = $sth->fetchrow;
  $sth->finish;

  my $ret;
  if ($columns[0]) {
    $ret = $class->blank_action;

    $ret->{__id__} = $columns[0];
    $ret->$_(shift @columns) foreach $tc->method_names;
    delete $ret->{":modified:"};
  }

  return $ret;
}

sub blank_action {
  bless { }, shift;
}

sub commit {
  my $self = shift;

  if ($self->id == -1) {
    croak "${self}->commit called on attempt to create a new action " .
          "(Action creation not allowed)";
  }

  croak "$self->commit called on action without valid id" unless $self->id and $self->id > 0;

  my @modified = keys %{$self->{":modified:"}};
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

sub prerequisite_action {
  my $self = shift;

  return unless $self->prerequisite;

  my $aid = $self->prerequisite;
  my $class = ref $self;
  my $new_action = $class->lookup(-id => $aid);

  return $new_action;
}

sub get_top_of_action_chain {
  my $self = shift;

  my $current_action = $self;

  while ($current_action->prerequisite()) {
    $current_action = $current_action->prerequisite_action;
  }

  return $current_action;
}

sub next_action_in_chain {
  my $self = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
SELECT A.id
  FROM rhnAction A
 WHERE A.prerequisite = :current_aid
EOQ

  $sth->execute_h(current_aid => $self->id);
  my ($next_aid) = $sth->fetchrow();
  $sth->finish;

  return unless $next_aid;

  my $class = ref $self;
  my $new_action = $class->lookup(-id => $next_aid);

  return $new_action;
}

sub action_is_for_server {
  my $class = shift;
  my $action_id = shift;
  my $server_id = shift;

  my $dbh = RHN::DB->connect;

  my $query;
  my $sth;

  $query = <<EOQ;
SELECT  1
  FROM  rhnServerAction SA
 WHERE  SA.action_id = :aid
   AND  SA.server_id = :sid
EOQ
  $sth = $dbh->prepare($query);
  $sth->execute_h(aid => $action_id, sid => $server_id);

  my ($yes) = $sth->fetchrow;

  $sth->finish;

  return $yes ? 1 : 0;
}



1;
