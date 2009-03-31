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
package RHN::DB::Feedback;

use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

use RHN::DB::TableClass;

my @fb_fields = qw/ID RE_ID USER_ID SUBJECT MESSAGE ESCALATION_ID TYPE STATUS CREATED MODIFIED/;

my $fb = new RHN::DB::TableClass("rhnUserFeedback", "FB", "", @fb_fields);

sub blank_feedback {
  my $class = shift;

  my $self = bless { }, $class;

  return $self;
}

sub create {
  my $class = shift;

  my $fb = $class->blank_feedback;
  $fb->{__id__} = -1;

  return $fb;
}

# build some accessors
foreach my $field ($fb->method_names) {
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

  if ($@) {
    die $@;
  }
}

sub lookup {
  my $class = shift;
  my %params = validate(@_, {id => 1});
  my $id = $params{id};

  my $dbh = RHN::DB->connect;

  my $query;
  my $sth;

  $query = $fb->select_query("FB.ID = ?");

  $sth = $dbh->prepare($query);
  $sth->execute($id);

  my @columns = $sth->fetchrow;
  $sth->finish;

  my $ret;
  if ($columns[0]) {
    $ret = $class->blank_feedback;

    $ret->{__id__} = $columns[0];
    $ret->$_(shift @columns) foreach $fb->method_names;
    delete $ret->{":modified:"};
  }
  else {
    local $" = ", ";
    die "Error loading feedback $id; no ID? (@columns)";
  }

  return $ret;
}

sub commit {
  my $self = shift;
  my $mode = 'update';

  if ($self->id == -1) {
    my $dbh = RHN::DB->connect;

    my $sth = $dbh->prepare("SELECT rhn_user_feedback_id_seq.nextval FROM DUAL");
    $sth->execute;
    my ($id) = $sth->fetchrow;
    $sth->finish;

    $self->{":modified:"}->{id} = 1;
    $self->{__id__} = $id;
    $mode = 'insert';
  }

  die "$self->commit called on feedback without valid id" unless $self->id and $self->id > 0;

  my @modified = keys %{$self->{":modified:"}};
  my %modified = map { $_ => 1 } @modified;

  return unless @modified;

  my $dbh = RHN::DB->connect;

  my $query;
  if ($mode eq 'update') {
    $query = $fb->update_query($fb->methods_to_columns(@modified));
    $query .= "FB.ID = ?";
  }
  else {
    $query = $fb->insert_query($fb->methods_to_columns(@modified));
  }

  #warn "ins/upd query: $query";

  my $sth = $dbh->prepare($query);
  $sth->execute((map { $self->$_() } grep { $modified{$_} } $fb->method_names), ($mode eq 'update') ? ($self->id) : ());

  $dbh->commit;
  delete $self->{":modified:"};
}

sub set_type {
  my $self = shift;
  my $label = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare('SELECT id FROM rhnUserFeedbackType WHERE label = ?');
  $sth->execute($label);

  my ($id) = $sth->fetchrow;

  die "No feedback type of '$label' in database"
    unless defined $id;

  $self->type($id);
}

sub set_status {
  my $self = shift;
  my $label = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare('SELECT id FROM rhnUserFeedbackStatus WHERE label = ?');
  $sth->execute($label);

  my ($id) = $sth->fetchrow;

  die "No feedback status of '$label' in database"
    unless defined $id;

  $self->status($id);
}

sub get_status {
  my $self = shift;
  my $label = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare('SELECT label FROM rhnUserFeedbackStatus WHERE id = :id');
  $sth->execute_h(id => $self->status);

  my ($status) = $sth->fetchrow;
  $sth->finish;

  return $status;
}

sub feedback_overview {
  my $class = shift;
  my %params = @_;

  my ($org_id, $lower, $upper, $total_ref, $mode, $mode_params, $sort) =
    map { $params{"-" . $_} } qw/org_id lower upper total_rows mode mode_params sort/;

  $lower ||= 1;
  $upper ||= 100000;
  $sort ||= 'date';

  my $dbh = RHN::DB->connect;

  # note the odd sort for slots; basically we need a stable hueristic
  # for sorting so that the subsequent FB.created sort is meaningful.
  my %sort_options = ( login => 'U.login, FB.created DESC',
		       date => 'FB.created DESC',
		       subject => 'FB.subject, FB.created DESC',
		       entitlement => 'GREATEST(ENTERPRISE_SLOTS * 100, BASIC_SLOTS) DESC, FB.created DESC',
		     );

  my $where = '';
  if ($mode) {
    $where = "   AND FBS.label = ?";
  }

  my $query = <<EOQ;
SELECT FB.id, U.id, U.login, FB.subject, FB.escalation_id, FBS.label, FBT.label, FB.created,
       NVL((SELECT max_members
              FROM rhnServerGroup SG
             WHERE SG.org_id = U.org_id
               AND SG.group_type = (SELECT id FROM rhnServerGroupType WHERE label = 'sw_mgr_entitled')), 0) BASIC_SLOTS,
       NVL((SELECT max_members
              FROM rhnServerGroup SG
             WHERE SG.org_id = U.org_id
               AND SG.group_type = (SELECT id FROM rhnServerGroupType WHERE label = 'enterprise_entitled')), 0) ENTERPRISE_SLOTS
  FROM rhnUser U,
       rhnUserFeedbackType FBT,
       rhnUserFeedbackStatus FBS,
       rhnUserFeedback FB
 WHERE U.id = FB.user_id
   AND FBT.id = FB.type
   AND FBS.id = FB.status
$where
 ORDER BY $sort_options{$sort}
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute($mode ? $mode : ());

  $$total_ref = 0;

  my @result;
  my $i = 1;
  while (my @data = $sth->fetchrow) {
    $$total_ref = $i;
    my @altered_data = @data[0 .. 6];

    my $type = 'Free';
    if ($data[7] > 1) {
      $type = "Update Service ($data[7])";
    }
    if ($data[8] > 0) {
      $type = "Management Service ($data[8])";
    }
    push @altered_data, $type;

    if ($i >= $lower and $i <= $upper) {
      push @result, [ @altered_data ];
    }
    $i++;
  }
  $sth->finish;
  return @result;
}

sub faq_list {
  my $class = shift;
  my %params = @_;

  my ($lower, $upper, $total_ref, $private) =
    map { $params{"-" . $_} } qw/lower upper total_rows private/;

  $lower ||= 1;
  $upper ||= 100000;

  my $dbh = RHN::DB->connect;

  my $where = '';

  $where = 'WHERE FAQ.private != 1'
    unless $private;

  my $query = <<EOQ;
  SELECT FAQ.id, FAQ.subject, FAQ.modified, FAQ.details, FAQ.usage_count
    FROM rhnFAQ FAQ
$where
ORDER BY FAQ.id
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute();

  $$total_ref = 0;

  my @result;
  my $i = 1;

  while (my @data = $sth->fetchrow) {
    $$total_ref = $i;

    if ($i >= $lower and $i <= $upper) {
      push @result, [ @data ];
    }

    $i++;

  }

  $sth->finish;

  return @result;
}

#############################################################################
# method: 	faq_insert
# description:	
# date:         2002.02.19
# author:       pdevine
#
# fixme

sub faq_insert {
  my $class = shift;
  my %params = @_;

  my ($subject, $message, $private, $faq_class) =
    map { $params{"-" . $_} } qw/question answer private class/;

  $private = ($private ? 1 : 0 );

  $faq_class ||= 'general';
  ### Only allow 4000 characters to be inserted into the message field
  ### in the future, this should give a warning or display an error

  $message = substr $message, 0, 4000;

  my $dbh = RHN::DB->connect;

  my $query = <<EOQ;
INSERT INTO
  rhnFAQ
  (id, subject, details, private, class_id)
VALUES
  (rhn_faq_id_seq.nextval, :subject, :details, :private,
    (SELECT id FROM rhnFAQClass where label = :class) )
RETURNING id INTO :new_id
EOQ

  my $new_id;
  my $sth = $dbh->prepare($query);
  $sth->execute_h(subject => $subject, details => $message, private => $private, new_id => \$new_id, class => $faq_class);

  $dbh->commit;

  return $new_id;
}


#############################################################################
# method: 	faq_update
# description:	updates data in a canned autoresponse
# date:		2002.02.19
# author:	pdevine

sub faq_update {
  my $class = shift;
  my %params = @_;

  my ($id, $subject, $message, $private, $faq_class) =
    map { $params{"-" . $_} } qw/ id question answer private class/;

  $private = ($private ? 1 : 0 );

  my $dbh = RHN::DB->connect;

  my $query = <<EOQ;
UPDATE
  rhnFAQ
SET
  subject = :subject, details = :details, private = :private,
  class_id = (SELECT id FROM rhnFAQClass where label = :class)
WHERE
  id = :id
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute_h(subject => $subject, details => $message, private => $private, id => $id, class => $faq_class);

  $dbh->commit;

}

sub faq_increment_usage {
  my $class = shift;
  my $faq_id = shift;

  my $dbh = RHN::DB->connect;

  my $query = <<EOQ;
UPDATE rhnFAQ SET usage_count = usage_count + 1 WHERE id = ?
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute($faq_id);

  $dbh->commit;

}

#############################################################################
# method: 	faq_delete
# description:	deletes a faq entry
# date:		2002.02.22
# author:	pdevine

sub faq_delete {
  my $class = shift;
  my $id = shift;

  my $dbh = RHN::DB->connect;

  my $query = <<EOQ;
DELETE FROM
  rhnFAQ
WHERE
  id = ?
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute($id);

  $dbh->commit;

}


#############################################################################
# method: 	lookup_id
# description:	method for looking up an entry for a specific id
# date:		2002.02.22
# author:	pdevine

sub lookup_id {
  my $class = shift;
  my $id = shift;

  my $dbh = RHN::DB->connect;

  ###  LOOKUP ID

  my $query = <<EOQ;
SELECT
  UF.re_id, UF.subject 
FROM
  rhnUserFeedback UF
WHERE
  UF.id = ?
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute($id);

  my @data = $sth->fetchrow;

  $sth->finish;

  return @data;

}

#############################################################################
# method: 	_lookup_re_id
# description:	private function for looking up entries of re_id's
# date:		2002.02.22
# author:	pdevine

sub _lookup_re_id {
  my $dbh = shift;
  my $re_id = shift;

#  ###  LOOKUP RE_ID
#
#  my $query = <<EOQ;
#SELECT
#  UF.id, UF.subject 
#FROM
#  rhnUserFeedback UF
#WHERE
#  UF.re_id = ?
#EOQ
#
#  my $sth = $dbh->prepare($query);
#  $sth->execute($id);
#
#  my @result;
#  my $i = 1;
#
#  while(my @data = $sth->fetchrow) {
#    push @result, [ @data ];
#    $i++;
#  }
#
#  $sth->finish;
#
#  return @result;

}


sub feedback_types {
  my $class = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare('SELECT id, label, name FROM rhnUserFeedbackType ORDER BY id');
  $sth->execute;

  my @ret;
  while (my @row = $sth->fetchrow) {
    push @ret, [ @row ];
  }

  return @ret;
}

sub feedback_statuses {
  my $class = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare('SELECT id, label, name FROM rhnUserFeedbackStatus ORDER BY name, label');
  $sth->execute;

  my @ret;
  while (my @row = $sth->fetchrow) {
    push @ret, [ @row ];
  }

  return @ret;
}

1;
