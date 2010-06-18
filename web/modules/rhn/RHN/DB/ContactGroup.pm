#
# Copyright (c) 2004--2010 Red Hat, Inc.
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

package RHN::DB::ContactGroup;

use strict;
use Carp;
use RHN::DB;
use RHN::DB::TableClass;
use RHN::DataSource::Simple;

use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

our $VERSION = (split(/s+/, q$Id$, 4))[2];


# Setup class data and generated getter and setter methods
{
  # setup things that are fairly common to all DB objects.
  my $_readable_type = "contact group";  # used for human readable messages referring to this type of object.
  my $_table_name = "rhn_contact_groups";
  my $_table_alias = "CG";  # table alias to be used in all sql calls to reference this table.
  my $_method_prefix = "";  # prefix for the names of the accessor methods for the fields of a table
  my $_sequence = "rhn_contact_groups_recid_seq";  # the sequence for fetching the next recid.
  my $_primary_key_field = "recid";

  my @fields = qw/recid contact_group_name customer_id strategy_id ack_wait rotate_first
                  last_update_user last_update_date notification_format_id/;

  # Note that we could add one or more callbacks to perform stronger
  # verification as appropriate (i.e. string lengths, etc.).
  my %_valid_spec = (recid => { default => 0 },
                     contact_group_name => { optional => 0 },
                     customer_id => { optional => 0 },
                     strategy_id => { optional => 0 },
                     ack_wait => { default => 0 },
                     rotate_first => { default => 0 },
                     last_update_user => { optional => 0 },
                     notification_format_id => { optional => 0 }
                );

  my $_table = new RHN::DB::TableClass($_table_name, $_table_alias, $_method_prefix, @fields);

  # add accessor methods to the class data for this class.
  sub get_readable_type { $_readable_type }
  sub get_sequence { $_sequence }
  sub get_table_alias { $_table_alias }
  sub get_primary_key_field { $_primary_key_field }
  sub get_validation_spec { \%_valid_spec }
  sub get_table { $_table }

  # create templatized accessor methods for each field.
  my $tmpl = q|
    sub [[field]] {
      my $self = shift;
      if (@_) {
        if ("[[field]]" ne $self->get_primary_key_field) {
          $self->{":modified:"}->{[[field]]} = 1;
        }
        $self->{__[[field]]__} = shift;
      }
      return $self->{__[[field]]__};
    };
  |;

  foreach my $field (@fields) {

    (my $sub = $tmpl) =~ s/\[\[field\]\]/$field/g;

    eval $sub;

    croak $@ if($@);
  }
}


# Validate this object against the validation spec setting
# any default values that might be required.
##################
sub validate_obj {
##################
  my $self = shift;
  my $class = ref($self) || $self;

  my $spec = $class->get_validation_spec;

  # Build a list of the fields to be validated against the spec
  # and their values
  my %validate;
  foreach my $field (keys %$spec) {
    my $value = $self->$field;
    if (defined $value) {
      # double quoted to work around taint issues.
      $validate{$field} = qq/$value/;
    }
  }

  my %params = Params::Validate::validate_with( params => \%validate,
                                                spec => $spec);

  # set the validated/defaulted name/value pairs on this instance.
  foreach my $param (keys %params) {
    $param = lc $param;
    $self->$param($params{$param});
  }
  return $self;
}


# Constructor
#########
sub new {
#########
  my $class = shift;
  my $self = bless { }, $class;

  # make sure that any required parameters have been passed
  # and get default values.
  my %params = Params::Validate::validate_with( params => \@_,
                                                spec => $class->get_validation_spec,
                                                allow_extra => 1,
                                                ignore_case => 1);

  # populate this instance with the and validated/defaulted
  # name value pairs.
  foreach my $param (keys %params) {
    $self->$param($params{$param});
  }

  return $self;
}


# Create a "blank" instance without regard for defaults.
# Make sure to call validate prior to commit to set sensible defaults
# where appropriate.
############
sub create {
############
  my $class = shift;
  my $self = bless { }, $class;
  return $self;
}


# commit changed values to the database inserting the record if appropriate.
# Note: there's a bunch of stuff going on here that could probably be factored
# out into a base class.
############
sub commit {
############
  my $self = shift;
  my $mode = 'update';
  my $type = $self->get_readable_type;

  # make it a bit easier to update the name of the primary key field.
  my $pk = $self->get_primary_key_field;
  my $pk_upper = uc $pk;
  my $table_alias = $self->get_table_alias;

  # if this is a "new" (not yet persisted) instance then switch to insert mode.
  if (not $self->$pk ) {
    my $dbh = RHN::DB->connect;

    # Get the next recid from the sequence and set it as the id for this instance.
    my $sth = $dbh->prepare("SELECT " . $self->get_sequence . ".nextval FROM DUAL");
    $sth->execute;
    my ($pk_value) = $sth->fetchrow;
    die "No new $type $pk from seq " . $self->get_sequence . " (possible error: " . $sth->errstr . ")" unless $pk_value;
    $sth->finish;

    #mark recid dirty since the accessor for the recid field doesn't.
    $self->{":modified:"}->{$pk} = 1;
    $self->$pk($pk_value);
    $mode = 'insert';
  }

  # make sure that the thing we are about to persist is valid.
  $self->validate_obj;

  # make sure that we have a valid recid.
  die "$self->commit called on $type without valid $pk" unless ($self->$pk > 0);

  # Create an array of modified field names
  my @modified = keys %{$self->{":modified:"}};
  return unless @modified;

  my %modified = map { $_ => 1 } @modified;

  my $dbh = RHN::DB->connect;

  my $query;
  if ($mode eq 'update') {
    $query = get_table->update_query(get_table->methods_to_columns(@modified));
    $query .= get_table_alias . ".$pk_upper = ?";
    # adjust the query to update last_update_date
    $query =~ s/SET (.*) WHERE/SET $1, $table_alias\.last_update_date = SYSDATE WHERE/;
  }
  else {
    $query = get_table->insert_query(get_table->methods_to_columns(@modified));
    # adjust the query to update last_update_date
    $query =~ s/\((.*)\) VALUES \((.*)\)/\($1, $table_alias\.last_update_date\) VALUES \($2, SYSDATE\)/;
  }
  
  my $sth = $dbh->prepare($query);

  # build a list of method names for the modified fields
  my @mod_accessors =  grep { $modified{$_} } get_table->method_names;

  # build a list of the values associated with the modified fields
  my @bindvals = map { $self->$_() } @mod_accessors;

  #execute the statement
  $sth->execute( @bindvals, ($mode eq 'update') ? ($self->$pk) : ());

  $dbh->commit;

  delete $self->{":modified:"};
}


# Look up contact group object by id.
############
sub lookup {
############
  my $class = shift;

  my $type = $class->get_readable_type;
  my $pk = $class->get_primary_key_field;
  my $pk_upper = uc $pk;

  my %params = Params::Validate::validate(@_, {recid => { optional => 0 }});
  my $pk_value = $params{recid};

  my $dbh;
  my $sqlstmt;
  my $sth;
  my $instance;
  my @columns;

  $dbh = RHN::DB->connect;
  $sqlstmt = get_table->select_query(get_table_alias . ".$pk_upper = ?");
  $sth = $dbh->prepare($sqlstmt);
  $sth->execute($pk_value);
  @columns = $sth->fetchrow;
  $sth->finish;

  if ($columns[0]) {
    $instance = $class->create;
    $instance->$pk($columns[0]);
    foreach (get_table->method_names) {
      $instance->$_(shift @columns);
    }
    delete $instance->{":modified:"};
  }
  else {
    local $" = ", ";
    die "Error loading $type $pk_value (@columns)";
  }

  return $instance;
}


# add a contact method to this group.
#
# rhn_contact_group_members has the following fields:
#
# contact_group_id - the redid of the associatd rhn_contact_group record
# order_number - zero based ordinal
# member_contact_method_id - the recid of the associated rhn_contact_method record
# member_contact_group_id - to allow groups of groups (always null)
# last_updat_user - uid of the last person to update this record.
# last_update_date - SYSDATE at the last update.

#########################
sub set_groups_methods {
#########################
  my $self = shift;
  my ($user_id, @method_ids) = @_;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
DELETE from rhn_contact_group_members
 WHERE contact_group_id = :group_id
EOQ

  $sth->execute_h(group_id => $self->recid);

  foreach my $method_id (@method_ids) {
    $self->add_method_to_group($user_id, $method_id);
  }
  $dbh->commit;
  return;
}

#########################
sub add_method_to_group {
#########################
  my $self = shift;
  my ($user_id, $method_id) = @_;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
INSERT INTO rhn_contact_group_members
  (contact_group_id, order_number, member_contact_method_id,
   member_contact_group_id, last_update_user, last_update_date)
VALUES
  (:group_id, 
   (SELECT NVL(MAX(order_number)+1,0) FROM contact_group_members WHERE contact_group_id = :group_id),
   :method_id, NULL, :user_id, SYSDATE)
EOQ

  $sth->execute_h(group_id => $self->recid, method_id => $method_id, user_id => $user_id);
  $dbh->commit;
  return;
}


############
sub delete {
############
  my $self = shift;
  my $pk = $self->get_primary_key_field;

  my $dbh = RHN::DB->connect;
  my ($sth, $query);

  $query = <<EOQ;
DELETE FROM rhn_contact_groups
      WHERE recid = :group_id
EOQ

$sth = $dbh->prepare($query);
    $sth->execute_h(group_id => $self->$pk);
    $dbh->commit;
}

        
1;


__END__
=head1 NAME

RHN::DB::ContactGroup - Notification Groups for alerts from monitoring

=head1 SYNOPSIS

  use RHN::DB::ContactGroup;
  
  <<INSERT SAMPLE CODE HERE>>

=head1 DESCRIPTION

<<INSERT LONG DESCRIPTION HERE>>

=head1 REQUIRES

Params::Validate, RHN::DB, RHN::DB::TableClass, Carp,
RHN::DataSource::Simple.

=head1 INSTANCE VARIABLES

=over 8

=item recid 

 the primary key for the contact group

=item contact_group_name

an arbitary description for the contact group

=item customer_id

the org_id of the customer this contact group is associated wtih.

=item ack_wait

amount of time to wait for alert acknowledgement before escalating
the aler to the next method in the escalation chain.  Defaults to 0
Per bug #94543 since we're only using Broadcast strategy.  A
sensible default for Escalation strategies would be 5 minutes.

=item rotate_first

Boolean value indicating whether the notification system should send
to the destinations comprising the group in rotation: A-B-C the
first time, B-C-A the second, and C-A-B the third. This ensures that
the first destination listed is not always the first destination to
which the alerting software sends the message when you direct a
message to the group.  Default value is 0 (false).

=item last_update_user

The uid of the user that last updated this contact group.

=item last_update_date

The date that this contact group was last updated.

=item notification_format_id

=back

=head1 CLASS METHODS

=over 8

=back

=head1 INSTANCE METHODS

=over 8

=item new()

Create a new RHN::DB::ContactGroup object.

=item lookup()

Look up contact group by ID


=back

=head1 SEE ALSO

L<OTHER_MODULE>, L<ANOTHER_MODULE>

=head1 COPYRIGHT

Copyright (c) 2004--2010 Red Hat, Inc.  All rights reserved

=cut
