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
package RHN::Task::PushedUsers;

use RHN::TaskMaster;
use RHN::DB;
use RHN::SessionSwap;
use RHN::Postal;
use RHN::User;

our @ISA = qw/RHN::Task/;

sub delay_interval { 60 }

# This task is the web side of the entitlement pushing code from Bala.
# Basically customers (not contacts) are created in CRM and pushed to
# our side, along with an entry in web_customer_notification.  We send
# emails to the entries in this table with links that let them create
# an account into the org in question.  This way users get to pick
# their own username, password, etc.

sub run {
  my $self = shift;
  my $center = shift;
  
  my $dbh = RHN::DB->connect();
  
  my $sth = $dbh->prepare(<<EOS);
SELECT WCN.id, WCN.org_id, WCN.contact_email_address, WC.name, WC.oracle_customer_number
  FROM web_customer WC, web_customer_notification WCN
 WHERE WC.id = WCN.org_id
EOS
  my $delete_sth = $dbh->prepare("DELETE FROM web_customer_notification WHERE id = ?");
  
  $sth->execute;

  while (my ($id, $org_id, $email, $name, $number) = $sth->fetchrow) {
  	# Once there is an entry, check whether he is an admin or normal user by getting the admin ids for that org
  	my $contact_sth = $dbh->prepare(<<EOQ);
  SELECT user_id
    FROM rhnusergroupmembers ugm
   WHERE user_group_id = (SELECT id
                            FROM rhnusergroup
                           WHERE org_id = ? 
	                         AND group_type = (SELECT id FROM rhnUserGroupType WHERE label = 'org_admin')
	                     )
     AND EXISTS (SELECT wc.id FROM rhnwebcontactenabled wc WHERE wc.id = ugm.user_id)
ORDER BY ugm.user_id
EOQ
    
	$contact_sth->execute($org_id);
	my @admin_emails = ();
	my $user;
	while (my ($id) = $contact_sth->fetchrow) {
		# admin already exists for this org, get the email address(s).
		$user = RHN::User->lookup(-id => $id);
		my $admin_email = $user->find_mailable_address();
		if ($admin_email) { push @admin_emails, $admin_email->address;}
	}
	$contact_sth->finish();
	  	
    my $letter = new RHN::Postal;

    $center->info("processing org_id $org_id, email $email");
    $letter->subject("Red Hat login creation request");
    $letter->template('new_user_notification.xml');

    my $checksum = RHN::SessionSwap->encode_data($org_id);
    $letter->set_tag(create_url => "https://rhn.redhat.com/rhn/newlogin/CreatePersonal.do?checksum=$checksum");
    $letter->set_tag(customer_name => $name);
    $letter->set_tag(customer_number => $number);

    $letter->render;
    $letter->to($email);
    
    #send a copy to the admins of an org if exists
    $letter->cc(@admin_emails);

    $letter->bcc(join(", ", PXT::Config->get("pushed_users_bcc")));

    $letter->from('Red Hat Customer Service <customerservice@redhat.com>');
    $letter->set_header("X-RHN-Info" => "backend_pushed_user");
    $letter->send;

    $delete_sth->execute($id);
    $dbh->commit;
  }

  $self->log_daemon_state($dbh, 'pushed_users');
  $dbh->commit;
}

1;
