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

package RHN::DailySummaryEngine;
use strict;

use Params::Validate qw/validate/;
use Time::HiRes;

use PXT::Config;

use RHN::Mail;
use RHN::Utils;
use RHN::User;
use RHN::Postal;
use RHN::DataSource::Task;


my $SPACER = 2;
my $INDENT = 2;

my $ACTIONS_MESSAGE = <<EOT;
Scheduled Actions Summary:
---------------------------
Some of your systems registered scheduled event activity today.
Here are the system counts per action type:

%s

To see a full listing of upcoming events for your systems:
https://%s/rhn/schedule/PendingActions.do

EOT

my $AWOL_MESSAGE = <<EOT;
Systems Not Checking In:
-------------------------
The following systems recently stopped checking in with Spacewalk:

%s


Please note that inactive systems cannot receive any updates.

Follow this url to see the full list of inactive systems:
https://%s/network/systems/system_list/inactive.pxt

EOT

# by default, turn off emailing :)
sub new {
  my $class = shift;
  my %params = validate(@_, { -email => 0, -debug => 0, -log_fn => 0});

  my $self = bless { orgs => {} }, $class;
  $self->{email} = $params{-email};
  $self->{debug} = $params{-debug};
  $self->{log_fn} = $params{-log_fn};

  return $self;
}

sub run_user {
  my $self = shift;
  my %params = validate(@_, {-user_id => 1, -verified_email_address => 1});
  my $user_id = $params{-user_id};
  my $verified_email_address = $params{-verified_email_address};

  my $report;

  my $pre;
  my $post;

  my $user = RHN::User->lookup(-id => $user_id);

  my @awol_servers = get_awol_servers($user_id);
  my %action_info = get_action_info($user_id);

  # don't do anything unless we have interesting info to report...
  return unless (@awol_servers or keys %{$action_info{-action_counts}});

  my $awol_message;
  my $action_counts_message = '';

  my $hostname = RHN::TemplateString->get_string(-label => 'hostname') || 'rhn.redhat.com';

  if (@awol_servers) {

    $awol_message = render_awol_servers_message(-user => $user,
						-servers => \@awol_servers,
						-hostname => $hostname);
  }
  else {
    $awol_message = '';
  }

  $action_info{-hostname} = $hostname;

  $action_counts_message = render_actions_message(\%action_info);


  $report = prepare_email(-user_id => $user_id,
			  -awol_mesg => $awol_message,
			  -actions_mesg => $action_counts_message,
			  -user => $user,
			  -verified_email => $verified_email_address,
			  -hostname => $hostname);

  if ($self->{email} and $verified_email_address) {
    $self->log("emailing report to $verified_email_address ...");
    $report->to($verified_email_address);

    # queue it up for sending...
    push @{$self->{__emails__}}, $report;
  }

  return $report;
}


sub debug {
  my $self = shift;
  my $debug = shift;

  if ($debug) {
    $self->{debug} = $debug;
  }
  else {
    return $self->{debug};
  }
}


sub log {
  my $self = shift;

  if ($self->{debug}) {
    if (ref $self->{log_fn} eq 'CODE') {
      # we've been passed a debugging function...
      $self->{log_fn}->(@_);
    }
    else {
      warn "ref:  " . ref $self->{log_fn};
      warn ('***', @_, '***');
    }
  }
}

# gets a bunch of potential orgs from the queue...
sub get_org_batch {
  my $self = shift;

  my $batch_ds = new RHN::DataSource::Task(-mode => 'daily_summary_queue_batch');
  my $batch = $batch_ds->execute_query();

  return @$batch;
}


# iterate through the org, build emails where appropriate, and queue them for sending...
sub queue_org_emails {
  my $self = shift;
  my $org_id = shift;

  my $pre;
  my $post;

  my @users = $self->users_in_org_wanting_reports($org_id);

  $pre = Time::HiRes::time();
  foreach my $user (@users) {
    $self->log("dealing with user $user->[0] ...");
    $self->run_user(-user_id => $user->[0], -verified_email_address => $user->[1]);
  }
  $post = Time::HiRes::time();

  $self->log("queued emails of org of " . scalar @users . " users in " . ($post - $pre) . "s ...");
}

sub mail_queued_emails {
  my $self = shift;

  while ($self->{__emails__} and @{$self->{__emails__}}) {
    my $email = pop @{$self->{__emails__}};
    $email->send;
  }
}

sub enqueue_org {
  my $self = shift;
  my $org_id = shift;
  my $transaction = shift;

  my $dbh;

  if ($transaction) {
    $dbh = $transaction;
  }
  else {
    $dbh = RHN::DB->connect();
  }

  $dbh->do("INSERT INTO rhnDailySummaryQueue (org_id) VALUES (?)", {}, $org_id);

  $dbh->commit() unless $transaction;
}

# shoves potential orgs into the queue...
sub enqueue_orgs {
  my $self = shift;
  my $transaction = shift;

  die "no transaction handle" unless $transaction;

  $self->log("finding awol server orgs...");
  $self->awol_server_orgs();
  $self->log("done.");

  $self->log("finding orgs w/ recent action activity ...");
  $self->orgs_with_recent_actions();
  $self->log("done.");

  # enqueue all the orgs in one transaction ...
  $self->log("enqueing orgs...");
  foreach my $org_id (keys %{$self->{orgs}}) {
    $self->enqueue_org($org_id, $transaction);
  }
  $self->log("done.");

  return $transaction;
}

# blows away a single org from the
sub dequeue_org {
  my $self = shift;
  my $org_id = shift;

  my $dbh = RHN::DB->connect();
  $dbh->do("DELETE FROM rhnDailySummaryQueue WHERE org_id = ?", {}, $org_id);
  $dbh->commit; # get these committed as soon as possible...
}

# find all the orgs that have "recently-awol" systems
sub awol_server_orgs {
  my $self = shift;

  my $dbh = RHN::DB->connect();

  # on rdu (1):  ~21.33s
  #    rdu (2):  ~20.18s
  my $query = <<EOQ;
SELECT DISTINCT S.org_id
  FROM rhnServer S,
       rhnServerInfo SI,
       rhnServerGroup SG,
       rhnServerGroupType SGT
 WHERE SGT.label IN ('enterprise_entitled', 'provisioning_entitled')
   AND SGT.id = SG.group_type
   AND SG.max_members > 0
   AND SG.org_id = S.org_id
   AND S.id = SI.server_id
   AND (sysdate - SI.checkin) BETWEEN 1 AND (1 + :checkin_threshold)
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute_h(checkin_threshold => PXT::Config->get('system_checkin_threshold'));

  while (my ($org_id) = $sth->fetchrow) {
    $self->{orgs}->{$org_id} = 1;
  }
}


sub orgs_with_recent_actions {
  my $self = shift;

  my $dbh = RHN::DB->connect();

  # on rdu (1):  ~6m 09.80s
  #    rdu (2):  ~1m 22.6s
  #    rdu (3):  ~0m 57.16s
  my $query = <<EOQ;
SELECT DISTINCT S.org_id
  FROM rhnServer S,
       rhnServerAction SA,
       rhnServerGroup SG,
       rhnServerGroupType SGT
 WHERE SGT.label IN ('enterprise_entitled', 'provisioning_entitled')
   AND SGT.id = SG.group_type
   AND SG.max_members > 0
   AND SG.org_id = S.org_id
   AND  S.id = SA.server_id
   AND (sysdate - SA.modified) BETWEEN 0 AND 1
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute_h();

  while (my ($org_id) = $sth->fetchrow) {
    $self->{orgs}->{$org_id} = 1;
  }
}

sub users_in_org_wanting_reports {
  my $self = shift;
  my $org_id = shift;

  my $dbh = RHN::DB->connect();

  my $query = <<EOQ;
SELECT WC.id, EA.address
  FROM rhnEmailAddressState EAS,
       rhnEmailAddress EA,
       rhnUserInfo UI,
       rhnWebContactEnabled WC
 WHERE WC.org_id = ?
   AND WC.id = UI.user_id
   AND UI.email_notify = 1
   AND WC.id = EA.user_id
   AND EA.state_id = EAS.id
   AND EAS.label = 'verified'
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute($org_id);

  my @ret;
  while (my @row = $sth->fetchrow) {
    push @ret, [@row];
  }

  return @ret;
}

sub render_awol_servers_message {
  my %params = validate(@_, { -user => 1, -servers => 1, -hostname => 1});
  my $user = $params{-user};
  my @servers = @{$params{-servers}};

  my $ret = sprintf("  %-15s %-25.25s  %-25s", 'System Id', 'System Name', 'Last Checkin') . "\n";
  foreach my $server (@servers) {
    $ret .= sprintf("  %-15s %-25.25s  %-25s\n", $server->[0], $server->[1], $user->convert_time($server->[2]));
  }

  return sprintf($AWOL_MESSAGE, $ret, $params{-hostname});
}

# render the scheduled action summary table... lots of funky indentation here...
sub render_actions_message {
  my %action_info = validate(@_, {-action_counts => 1,
				  -action_states => 1,
				  -max_entity_length => 1,
				  -hostname => 1,
				  -legend => 0});

  my $action_counts = $action_info{-action_counts};
  my $action_states = $action_info{-action_states};
  my $max_entity_len = $action_info{-max_entity_length};

  my $ret = '';
  if (keys %{$action_counts}){

    my @sorted_actions = sort { length($a) <=> length($b) } keys %{$action_counts};
    my @sorted_states = sort keys %{$action_states};
    my %action_lengths = map { $_ => length($_) } keys %{$action_counts};
    my %state_lengths = map { $_ => length($_) } keys %{$action_states};

    #warn "max entity length:  $max_entity_len";
    #warn "sorted actions:  " .join(", ", @sorted_actions);
    my $max_action_len = length($sorted_actions[-1]);
    #warn "max action length:  $max_action_len";
    $max_entity_len = $max_entity_len < $max_action_len ? $max_action_len : $max_entity_len;

    # _______Errata_Update:
    # Package List Refresh:
    #                      ^
    my $marker_1 = $max_entity_len + 1;

    $ret .= " " x ($INDENT + $marker_1 + $SPACER) . join(" " x $SPACER, @sorted_states) . "\n";

    foreach my $action_type (@sorted_actions) {

      $ret .= sprintf("%${INDENT}s%-${marker_1}.${marker_1}s", "", $action_type . ':');

      # see if there are any entities for the action
      if (exists $action_counts->{$action_type}->{-entities}) {

	$ret .= "\n";
	my $entities = $action_counts->{$action_type}->{-entities};

	foreach my $entity (sort {$b cmp $a} keys %{$entities}) {
	  $ret .= sprintf("%${INDENT}s% ${marker_1}.${marker_1}s", '', $entity);
	  foreach my $status (@sorted_states) {
	    my $count =  exists $entities->{$entity}->{$status} ? $entities->{$entity}->{$status} : 0;
	    my $fields = ($SPACER + ($state_lengths{$status}));
	    $ret .= sprintf("%${fields}s", $count);
	  }

	  $ret .= "\n";
	}
      }
      else {
	foreach my $status (@sorted_states) {
	  my $count =  exists $action_counts->{$action_type}->{$status} ? $action_counts->{$action_type}->{$status} : 0;
	  my $fields = ($SPACER + ($state_lengths{$status}));
	  $ret .= sprintf("%${fields}s", $count);
	}
      }

      $ret .= "\n";
    }

    if (exists $action_info{-legend}) {

      $ret .= sprintf("\n\n%s\n\n", 'Errata Synopses:');

      foreach my $legend_entity (sort {$b cmp $a} keys %{$action_info{-legend}}) {

	$ret .= sprintf("%${INDENT}s%s  %s\n", '', $legend_entity, $action_info{-legend}->{$legend_entity});
      }
    }

    $ret = sprintf($ACTIONS_MESSAGE, $ret, $action_info{-hostname});
  }

  return $ret;
}

sub prepare_email {
  my %params = validate(@_, { -user_id => 1,
			      -awol_mesg => 1,
			      -actions_mesg => 1,
			      -user => 1,
			      -verified_email => 1,
			      -hostname => 1,
			    });
  my $user = $params{-user};
  my $report = new RHN::Postal;
  my $filename = "daily_summary.xml";
  $report->template($filename);

  $report->set_tag("awol-systems-message", $params{-awol_mesg});
  $report->set_tag("action-counts-message", $params{-actions_mesg});

  # might be a bit much to load the entire user just for this time conversion...
  my $now = RHN::Date->new(now => 1, user => $user);
  $report->subject("RHN Daily Status Report for " . $now->short_date);

  $report->set_tag("calculation-date-time", $now->long_date_with_zone($user));
  $report->set_tag("login", $user->login());
  $report->set_tag('email-address', $params{-verified_email});
  $report->set_tag('hostname', $params{-hostname});
  $report->set_header("X-RHN-Info" => "rhn-daily-status-report");

  $report->wrap_body();
  $report->render();

  return $report;
}

sub get_awol_servers {
  my $user_id = shift;

  my $dbh = RHN::DB->connect();

  # see if there are any awol servers this guy needs to know about...
  my $query = <<EOQ;
SELECT DISTINCT S.id, S.name, TO_CHAR(SI.checkin, 'YYYY-MM-DD HH24:MI:SS') AS CHECKIN
  FROM rhnServer S,
       rhnServerInfo SI,
       rhnUserServerPerms USP
 WHERE USP.user_id = :user_id
   AND USP.server_id = SI.server_id
   AND (sysdate - SI.checkin) BETWEEN 1 AND (1 + :checkin_threshold)
   AND SI.server_id = S.id
   AND NOT EXISTS (
  SELECT *
    FROM rhnUserServerPrefs
   WHERE user_id = :user_id
     AND server_id = S.id
     AND name = 'include_in_daily_summary'
     AND value = 0
)
   AND EXISTS (SELECT 1 FROM rhnServerFeaturesView SFV WHERE SFV.server_id = S.id AND SFV.label = 'ftr_daily_summary')
ORDER BY CHECKIN DESC
EOQ

  my $sth = $dbh->prepare($query);

  $sth->execute_h(user_id => $user_id, checkin_threshold => PXT::Config->get('system_checkin_threshold'));

  my @ret;
  while (my @row = $sth->fetchrow) {
    push @ret, [@row];
  }

  return @ret;
}

sub get_action_info {
  my $user_id = shift;

  my $dbh = RHN::DB->connect();

  # summarize server actions that happened today for servers he has access to...
  my $query = <<EOQ;
SELECT AT.name,
        AStat.name,
        COUNT(SA.server_id),
        E.advisory_name AS ADVISORY,
        E.synopsis AS SYNOPSIS
   FROM rhnErrata E,
        rhnActionErrataUpdate AEU,
        rhnActionStatus AStat,
        rhnActionType AT,
        rhnAction A,
        rhnServerAction SA,
        rhnUserServerPerms USP
  WHERE USP.user_id = :user_id
    AND NOT EXISTS (
  SELECT *
    FROM rhnUserServerPrefs
   WHERE user_id = :user_id
     AND server_id = USP.server_id
     AND name = 'include_in_daily_summary'
     AND value = 0
)
    AND EXISTS ( select 1 from rhnServerFeaturesView sfv
                 where sfv.server_id = usp.server_id
                   and sfv.label = 'ftr_daily_summary')
    AND USP.server_id = SA.server_id
    AND sysdate - SA.modified > 0
    AND sysdate - SA.modified < 1
    AND SA.status = AStat.id
    AND SA.action_id = A.id
    AND A.action_type = AT.id
    AND A.id = AEU.action_id (+)
    AND AEU.errata_id = E.id (+)
GROUP BY AT.name, AStat.name, E.advisory_name, E.synopsis
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute_h(user_id => $user_id);

  my %action_counts;
  my %action_states;
  my %legend;

  my $max_entity_length = 0;

  while (my @row = $sth->fetchrow) {

    # type -> status -> entity -> count
    my $entity;

    # if errata, like RHxA-yyyy-zzz, or if package action, a package name...
    if ($row[0] =~ m/^Errata/) {
      $entity = sprintf("%${INDENT}s%s", '', $row[3]);
    }
#    elsif ($row[0] =~ m/^Package/) {
#      $entity = $row[4];
#      $entity .= "-$row[5]" if $row[5];
#      $entity .= "-$row[6]" if $row[6];
#    }

    if ($entity) {
      $action_counts{$row[0]}->{-entities}->{$entity}->{$row[1]} = $row[2];

      # gotta explain what RHSA-0000:000 is...
      $legend{$entity} = $row[4];

      my $len = length($entity);
      $max_entity_length = $max_entity_length < $len ? $len : $max_entity_length;
    }
    else {
      $action_counts{$row[0]}->{$row[1]} = $row[2];
    }

    $action_states{$row[1]} = 1;
  }

  return (-action_counts => \%action_counts,
	  -action_states => \%action_states,
	  -max_entity_length => $max_entity_length,
	  -legend => \%legend,
	 );
}

1;
