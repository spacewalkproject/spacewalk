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

package RHN::DB::Kickstart::Session;

use RHN::DB;
use RHN::DB::TableClass;

use RHN::Exception qw/throw/;
use RHN::Action;
use RHN::Token;
use RHN::DataSource::Simple;

use PXT::Config ();
use RHN::DataSource::General ();
use RHN::KSTree ();
use RHN::SessionSwap ();

use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

use Date::Parse;
use POSIX qw/strftime/;
use URI::URL;

my @kss_fields = qw/ID KICKSTART_ID KICKSTART_MODE  VIRTUALIZATION_TYPE KSTREE_ID ORG_ID SCHEDULER OLD_SERVER_ID NEW_SERVER_ID STATE_ID SERVER_PROFILE_ID ACTION_ID LAST_FILE_REQUEST PACKAGE_FETCH_COUNT SYSTEM_RHN_HOST DEPLOY_CONFIGS CREATED:longdate MODIFIED:longdate/;
my @ksss_fields = qw/ID NAME LABEL DESCRIPTION/;
my @kickstart_fields = qw/ID LABEL ACTIVE/;

my $kss_table = new RHN::DB::TableClass("rhnKickstartSession", "KSS", "", @kss_fields);
my $ksss_table = new RHN::DB::TableClass("rhnKickstartSessionState", "KSSS", "session_state", @ksss_fields);
my $kstable = new RHN::DB::TableClass("rhnKSData", "KS", "ks", @kickstart_fields);

my $j = $kss_table->create_join([$ksss_table, $kstable],
			       { rhnKickstartSession =>
				 { rhnKickstartSession => [ "ID", "ID" ],
				   rhnKickstartSessionState => [ "STATE_ID", "ID" ],
				   rhnKSData => [ "KICKSTART_ID", "ID" ],
				 }
			       },
 			       { rhnKSData => "(+)",
			       } );

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

sub lookup_null_virt_type_id {
   my $dbh = shift;
   my $query = "select id from rhnKickstartVirtualizationType where label='none'";
   my $sth = $dbh->prepare($query);
   $sth->execute_h();
   my @columns = $sth->fetchrow;
   $sth->finish;
   return $columns[0];
}


sub new {
  my $class = shift;
  my $self = $class->create;
  my %params = validate(@_, {kickstart_id => 0, kickstart_mode => 0, kstree_id => 0, org_id => 1, old_server_id => 0,
			     new_server_id => 0, server_profile_id => 0, action_id => 0, scheduler => 0 
                 });

  foreach my $attr (keys %params) {
    $self->$attr($params{$attr});
  }

  $self->update_state('created');

  return $self;
}




sub lookup {
   my $class = shift;

   my %params = validate(@_, {id => 0, org_id => 0, sid => 0, soft => 0, expired => 0});

   my $id = $params{id};
   my $sid = $params{sid};
   my $org_id = $params{org_id};

   my $query_preamble;
   my %query_params;

   if ($id) {
     $query_preamble = "KSS.id = :id";
     %query_params = (id => $id);
   }
   elsif ($org_id and $sid) {
     $query_preamble = "KSS.org_id = :org_id AND (KSS.old_server_id = :sid OR KSS.new_server_id = :sid)";
     unless ($params{expired}) {
       $query_preamble .= " AND NOT EXISTS (SELECT 1 FROM rhnKickstartSessionState KSSS WHERE KSSS.id = KSS.state_id AND (KSSS.label = 'failed' or KSSS.label = 'complete'))";
     }
     %query_params = (org_id => $org_id, sid => $sid);
   }
   else {
     die "Need either an ID or org_id and sid";
   }

   my @columns;

   my $dbh = RHN::DB->connect;
   my $query = $j->select_query($query_preamble);
   $query .= "\nORDER BY KSS.created DESC";

   my $sth = $dbh->prepare($query);
   $sth->execute_h(%query_params);
   @columns = $sth->fetchrow;
   $sth->finish;

   my $ret;
   if ($columns[0]) {
     $ret = $class->_blank_session();
     foreach ($j->method_names) {
       $ret->{"__${_}__"} = shift @columns;
     }

     delete $ret->{":modified:"};
   }
   else {
     if ($params{soft}) {
       return;
     }
     else {
       throw "No data found for kickstart session '$id'\n";;
     }
   }

   return $ret;
}

sub _blank_session {
  my $class = shift;

  my $self = bless { }, $class;
  return $self;
}

sub create {
  my $class = shift;

  my $kss = $class->_blank_session;
  $kss->{__id__} = -1;

  return $kss;
}

sub commit {
  my $self = shift;
  my $transaction = shift;
  my $dbh = $transaction || RHN::DB->connect;
  my $mode = 'update';

  if ($self->id == -1) {
    my $sth = $dbh->prepare("SELECT rhn_ks_session_id_seq.nextval FROM DUAL");
    $sth->execute;
    my ($id) = $sth->fetchrow;
    die "No new kickstart session id from seq rhn_ks_session_id_seq (possible error: " . $sth->errstr . ")" unless $id;
    $sth->finish;

    $self->{":modified:"}->{id} = 1;
    $self->{__id__} = $id;
	$self->virtualization_type(lookup_null_virt_type_id($dbh));
    $mode = 'insert';
  }

  die "$self->commit called on kickstart session without valid id" unless $self->id and $self->id > 0;

  # only update rhnKickstartSession.state_id, do not insert or update into rhnKickstartSessionState
  delete $self->{":modified:"}->{$_}
    foreach qw/session_state_id session_state_label session_state_name session_state_description/;

  my @modified = keys %{$self->{":modified:"}};
  my %modified = map { $_ => 1 } @modified;
  return unless @modified;

  my @queries;
  if ($mode eq 'update') {
    @queries = $j->update_queries($j->methods_to_columns(@modified));
  }
  else {
    @queries = $j->insert_queries($j->methods_to_columns(@modified));
  }

  foreach my $query (@queries) {
    my $sth = $dbh->prepare($query->[0]);
    my @vals = map { $self->$_() } grep { exists $modified{$_} } @{$query->[1]};
    $sth->execute(@vals, $modified{id} ? () : $self->id);
  }

  $dbh->commit
    unless $transaction;

  delete $self->{":modified:"};
}

sub update_state {
  my $self = shift;
  my $state = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare('SELECT KSSS.id, KSSS.name, KSSS.description FROM rhnKickstartSessionState KSSS WHERE KSSS.label = :label');

  $sth->execute_h(label => $state);
  my ($id, $name, $description) = $sth->fetchrow;
  $sth->finish;

  return unless $id;

  # update fields for object in memory
  $self->state_id($id);
  $self->session_state_id($id);
  $self->session_state_label($state);
  $self->session_state_name($name);
  $self->session_state_description($description);

  return;
}

sub get_url {
  my $self = shift;

  die "url called on a session without an id" unless ($self->id > 0);
  my %url_data;

  $url_data{session} = RHN::SessionSwap->encode_data($self->id);

  my $url = new URI::URL;
  $url->scheme('http');

  my $host = $self->system_rhn_host || PXT::Config->get('base_domain');
  $url->host($host);

  $url->path('/kickstart/ks/' . join('/', %url_data));

  return $url;
}

sub action {
  my $self = shift;

  return unless ($self->action_id);

  return RHN::Action->lookup(-id => $self->action_id);
}

# last_action was once just a column, but now it actually is based on
# the session history log, so act accordingly

sub last_action {
  my $self = shift;
  die "rewritten last_action is read only" if @_;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
SELECT TO_CHAR(MAX(time), 'YYYY-MM-DD HH24:MI:SS')
  FROM rhnKickstartSessionHistory KSH
 WHERE KSH.kickstart_session_id = :ksid
EOQ
  $sth->execute_h(ksid => $self->id);

  my ($time) = $sth->fetchrow;
  $sth->finish;

  return $time;
}

# The activation key that is associated with this session
sub activation_keys {
  my $self = shift;

  my $ds = new RHN::DataSource::General(-mode => 'regtokens_for_kickstart_session');
  my $data = $ds->execute_full(-kssid => $self->id);

  my @tokens = map { RHN::Token->lookup(-id => $_->{ID}) } @{$data};

  return @tokens;
}

sub kstree {
  my $self = shift;

  return unless $self->kstree_id;

  return RHN::KSTree->lookup(-id => $self->kstree_id);
}

1;
