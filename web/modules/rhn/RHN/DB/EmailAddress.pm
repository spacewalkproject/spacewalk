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

package RHN::DB::EmailAddress;

use RHN::DB;
use RHN::DB::TableClass;

use RHN::Exception qw/throw/;
use Params::Validate;
use Date::Parse;
use POSIX qw/strftime/;

my @ea_fields = qw/ID ADDRESS USER_ID STATE_ID NEXT_ACTION:longdate CREATED:longdate MODIFIED:longdate/;
my @eas_fields = qw/ID LABEL/;

my $ea_table = new RHN::DB::TableClass("rhnEmailAddress", "EA", "", @ea_fields);
my $eas_table = new RHN::DB::TableClass("rhnEmailAddressState", "EAS", "mail_state", @eas_fields);

my $j = $ea_table->create_join([$eas_table],
			       { rhnEmailAddress =>
				 { rhnEmailAddress => [ "ID", "ID" ],
				   rhnEmailAddressState => [ "STATE_ID", "ID" ],
				   } } );

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
   my %params = validate(@_, {-id => 1, -soft => 0});

   my $id = $params{-id};

   my @columns;

   my $dbh = RHN::DB->connect;
   my $query = $j->select_query("EA.ID = ?");

   my $sth = $dbh->prepare($query);
   $sth->execute($id);
   @columns = $sth->fetchrow;
   $sth->finish;

   my $ret;
   if ($columns[0]) {
     $ret = $class->_blank_address();
     foreach ($j->method_names) {
       $ret->{"__${_}__"} = shift @columns;
     }

     delete $ret->{":modified:"};
   }
   else {
     if ($params{-soft}) {
       return;
     }
     else {
       throw "No data found for email address '$id'\n";;
     }
   }

   return $ret;
}

sub _blank_address {
  my $class = shift;

  my $self = bless { }, $class;
  return $self;
}

sub create {
  my $class = shift;

  my $ea = $class->_blank_address;
  $ea->{__id__} = -1;

  return $ea;
}

sub commit {
  my $self = shift;
  my $dbh = shift || RHN::DB->connect;
  my $mode = 'update';

  if ($self->id == -1) {
    my $sth = $dbh->prepare("SELECT rhn_eaddress_id_seq.nextval FROM DUAL");
    $sth->execute;
    my ($id) = $sth->fetchrow;
    die "No new email address id from seq rhn_eaddress_id_seq (possible error: " . $sth->errstr . ")" unless $id;
    $sth->finish;

    $self->{":modified:"}->{id} = 1;
    $self->{__id__} = $id;
    $mode = 'insert';
  }

  die "$self->commit called on emailaddress without valid id" unless $self->id and $self->id > 0;

  my @modified = keys %{$self->{":modified:"}};
  my %modified = map { $_ => 1 } @modified;

  return unless @modified;

  my $query;
  if ($mode eq 'update') {
    $query = $ea_table->update_query($ea_table->methods_to_columns(@modified));
    $query .= "EA.ID = ?";
  }
  else {
    $query = $ea_table->insert_query($ea_table->methods_to_columns(@modified));
  }

  my $sth = $dbh->prepare($query);
  $sth->execute((map { $self->$_() } grep { $modified{$_} } $ea_table->method_names), ($mode eq 'update') ? ($self->id) : ());

  $dbh->commit;

  delete $self->{":modified:"};
}

sub next_action_seconds {
  my $self = shift;
  my $delay = shift;

  if (not defined $delay) {
    $self->next_action(undef);
  }
  else {
    my $when = time + $delay;
    $self->next_action(strftime("%Y-%m-%d %H:%M:%S", localtime $when));
  }
}

sub state {
  my $self = shift;
  return $self->mail_state_label if not @_;
  my $new_label = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare('SELECT id FROM rhnEmailAddressState WHERE label = :label');
  $sth->execute_h(label => $new_label);
  my ($id) = $sth->fetchrow;
  $sth->finish;

  die "no id for label $new_label" unless defined $id;
  $self->mail_state_label($new_label);
  delete $self->{":modified:"}->{mail_state_label};
  $self->state_id($id);
}

sub email_address_states {
  my $class = shift;

  my $dbh = RHN::DB->connect;

  my $query = <<EOQ;
SELECT label
  FROM rhnEmailAddressState
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute;

  my $labels = [ ];

  while (my ($label) = $sth->fetchrow) {
    push @{$labels}, $label;
  }

  return $labels;
}

sub delete_self {
  my $self = shift;
  my %params = validate(@_, {-transaction => 0});
  my $dbh = $params{-transaction} || RHN::DB->connect;

  my $query = <<EOQ;
DELETE
  FROM rhnEmailAddress
 WHERE id = :id
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute_h(id => $self->id);

  $dbh->commit unless $params{-transaction};
}

sub delete_other_addresses {
  my $self = shift;
  my %params = validate(@_, {-transaction => 0});
  my $dbh = $params{-transaction} || RHN::DB->connect;

  my $query = <<EOQ;
DELETE
  FROM rhnEmailAddress
 WHERE id <> :id
   AND user_id = :user_id
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute_h(id => $self->id, user_id => $self->user_id);

  $dbh->commit unless $params{-transaction};
}

sub reset_email {
  my $class = shift;
  my $user = shift;
  my $state = shift || 'unverified';

  throw "No user." unless (ref $user and $user->isa('RHN::DB::User'));

  my $new_address = $user->email;
  my @addresses = $user->email_addresses;
  $_->delete_self foreach (@addresses);
  my $email = $class->create;
  $email->address($new_address);
  $email->user_id($user->id);
  $email->state($state);
  $email->commit;

  return $email;
}

sub log_sent_email {
  my $class = shift;
  my %params = validate(@_, {-reason => 1, -address => 1, -user_id => 1});

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOS);
INSERT INTO rhnEmailAddressLog
  (user_id, address, reason, created)
VALUES
  (:user_id, :address, :reason, sysdate)
EOS
  $sth->execute_h(user_id => $params{-user_id}, address => $params{-address}, reason => $params{-reason});
  $dbh->commit;
}

1;
