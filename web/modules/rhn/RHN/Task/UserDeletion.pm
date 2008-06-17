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
package RHN::Task::UserDeletion;

use Sys::Hostname;
use Params::Validate;

use PXT::Config;
use RHN::User;
use RHN::Postal;
use RHN::Exception qw/throw/;

our @ISA = qw/RHN::Task/;

# looks for user deactivation requests and does them


# perl -I /var/www/lib/ /home/bretm/rhn/tools/taskomatic/taskomatic --pid /tmp/task.pid --debug --task RHN::Task::UserDeletion

sub crontab {
  return PXT::Config->get('user_deletion_crontab');
}



sub get_deletion_batch {
    my $query = 'SELECT user_id FROM rhnUserDeletionQueue ORDER BY created';
    my $dbh = RHN::DB->connect();
    my $sth = $dbh->prepare($query);
    $sth->execute();

    my @ret;
    while (my ($user_id) = $sth->fetchrow) {
      push @ret, $user_id;
    }

    return @ret;
}

sub mail_deactivation_confirmation {
  my %params = validate(@_, {-login => 1, -email => 1});

  my $notice = new RHN::Postal;

  my $filename = "account_deactivation_notice.xml";
  $notice->template($filename);

  $notice->set_tag("login", $params{-login});
  $notice->set_tag("email-address", $params{-email});
  $notice->subject("RHN Account Deactivation");
  $notice->to($params{-email});
  $notice->render();

  $notice->send;
}


sub run {
  my $class = shift;
  my $center = shift;

  my @batch = get_deletion_batch();

  my $start_ts = time();
  my $dbh = RHN::DB->connect;

  $center->info("starting user deletion batch run...");
  while (@batch and (time() < ($start_ts + PXT::Config->get('user_deletion_batch_time')))) {

    my $user_id = pop @batch;
    $center->info("deactivating user:  $user_id");

    my $user = RHN::User->lookup(-id => $user_id);
    my $login = $user->login;

    # remove the email address from cheetah mailer and save for 
    # sending the confirmation email
    my $email_addy = $user->queue_for_cheetah(-transaction => $dbh);

    # temporary hack, there should be a cascade delete for this table...
    my $sth = $dbh->prepare("DELETE FROM rhnUserDeletionQueue WHERE user_id = ?");
    $sth->execute($user_id);

    eval {
      RHN::User->delete_user($user_id);
      $user = undef;
      $dbh->commit;
      $center->info("user $login deleted");
    };

    if ($@) {
      my $E = $@;

      if (ref $E and $E->is_rhn_exception('cannot_delete_user')) {
	# with the new changes to the webpage, only non-paying customers
	# should have gotten into the db, so it's safe to disable them from here...
	$user->disable_user(undef, $dbh);
	$user->commit;
	$center->info("user $login disabled");
      }
      else {
	$dbh->rollback();
	$center->info("critical error deleting user $user_id:  " . $E);

	if (PXT::Config->get('traceback_mail')) {
	  my $date = scalar localtime time;
	  my $to = PXT::Config->get('traceback_mail');

	  my $hostname = Sys::Hostname::hostname;
	  my $username = $user->login;

	  my $subject = "User Deletion traceback from $hostname";

	  my $severity;
	  if ($E->isa("RHN::Exception")) {
	    $severity = $E->{-severity};
	  }
	  else {
	    $severity = "unhandled"
	  }

	  my $body = <<EOB;
The following exception occurred while attempting to delete a user:

Date:
  $date

User Information:
  $username ($user_id)

Error message:
  $E
EOB

	  RHN::Mail->send(to => $to, subject => $subject, body => $body,
			  headers => {"X-RHN-Traceback-Severity" => $severity});
	  $center->info("Traceback sent to $to");
	}
      }
    }

    # mail the confirmation letter
    if ($email_addy) {
      $center->info("emailing deactivation confirmation to $email_addy");
      mail_deactivation_confirmation(-login => $login, -email => $email_addy);
    }
  }

  if (@batch) {
    $center->info("batch not fully completed...");
  }

  $dbh = RHN::DB->connect();
  $class->log_daemon_state($dbh, 'user_deleter');
  $dbh->commit;
}

1;
