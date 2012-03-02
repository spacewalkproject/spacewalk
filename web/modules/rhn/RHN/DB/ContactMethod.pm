#
# Copyright (c) 2008--2012 Red Hat, Inc.
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

package RHN::DB::ContactMethod;

use strict;
use Carp;
use RHN::DB;
use RHN::DB::TableClass;
use RHN::DataSource::ContactMethod;
use RHN::ContactGroup;

use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

our $VERSION = (split(/s+/, q$Id$, 4))[2];

# Setup class data and generated getter and setter methods
{
  # setup things that are fairly common to all DB objects.
  my $_readable_type = "contact method";  # used for human readable messages referring to this type of object.
  my $_table_name = "rhn_contact_methods";
  my $_table_alias = "CM";  # table alias to be used in all sql calls to reference this table.
  my $_method_prefix = "";  # prefix for the names of the accessor methods for the fields of a table
  my $_sequence = "rhn_contact_methods_recid_seq";  # the sequence for fetching the next recid.
  my $_primary_key_field = "recid";

  # see pod documentation for descriptions of the fields
  my @fields = qw/recid method_name contact_id schedule_id method_type_id
                  pager_email pager_max_message_length pager_split_long_messages email_address
                  last_update_user last_update_date notification_format_id/;

  # Note that we could add one or more callbacks to perform stronger
  # verification as appropriate (i.e. string lengths, etc.).
  my %_valid_spec = (recid => { default => 0 },
                     method_name => { optional => 0 },
                     contact_id => { optional => 0 },
                     schedule_id => { default => 1 },
                     method_type_id => { optional => 0 },
                     pager_split_long_messages => { default => 0 },
                     notification_format_id => { optional => 0 },
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
                                                allow_extra => 1);

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
  if (not $self->$pk) {
    my $dbh = RHN::DB->connect;

    # Get the next recid from the sequence and set it as the id for this instance.
    my $sth = $dbh->prepare("SELECT sequence_nextval('" . $self->get_sequence . "') FROM DUAL");
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
  my %modified = map { $_ => 1 } @modified;
  return unless @modified;

  my $dbh = RHN::DB->connect;

  my $query;
  if ($mode eq 'update') {
    $query = get_table->update_query(get_table->methods_to_columns(@modified));
    $query .= get_table_alias . ".$pk_upper = ?";
    # adjust the query to update last_update_date
    $query =~ s/SET (.*) WHERE/SET $1, $table_alias\.last_update_date = CURRENT_TIMESTAMP WHERE/;
  }
  else {
    $query = get_table->insert_query(get_table->methods_to_columns(@modified));
    # adjust the query to update last_update_date
    $query =~ s/\((.*)\) VALUES \((.*)\)/\($1, last_update_date\) VALUES \($2, CURRENT_TIMESTAMP\)/;
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


# Look up instance by id.
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


# get the list of contact groups this contact method is associated with.
####################
sub contact_groups {
####################
  my $self = shift;
  my @groups;
  my $pk = $self->get_primary_key_field;

  my $ds = new RHN::DataSource::ContactMethod(-mode => "contact_groups");
  my $groups_data = $ds->execute_query(-method_id => $self->$pk);

  foreach my $group (@$groups_data) {
#      warn "group: $group\n";
      push @groups, new RHN::ContactGroup(%$group);
  }

  return \@groups;
}

############
sub delete {
############
  my $self = shift;
  my $pk = $self->get_primary_key_field;

  my $dbh = RHN::DB->connect;
  my ($sth, $query);

  $query = <<EOQ;
DELETE FROM rhn_contact_methods
      WHERE recid = :method_id
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute_h(method_id => $self->$pk);
  $dbh->commit;
}


# check to see if any probes notify a contact group
# that the specified contact method is in.
############################
sub has_probe_dependencies {
############################
  my $class = shift;

  my %params = Params::Validate::validate(@_, {method_id => { optional => 0 }});
  my $method_id = $params{method_id};

  my $dbh = RHN::DB->connect;
  my ($sth, $query);

  $query = <<EOQ;
SELECT CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END
  FROM     rhn_probe P, rhn_contact_group_members CGM
  WHERE    P.contact_group_id = CGM.contact_group_id
  AND      CGM.member_contact_method_id = :method_id
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute_h(method_id => $method_id);
  my ($ret) = $sth->fetchrow;
  $sth->finish;

  return $ret;
}



##########################
sub get_method_type_info {
##########################

  my $self = shift;
  my $class = ref($self) || $self;

  my $method_type = shift;
  my $default_strategy = "Broadcast";
  my $default_group_type = "Email";
  my $default_ack_completed = "No";

  my %query_params = (method_type => $method_type,
                      strategy => $default_strategy,
                      group_type => $default_group_type,
                      ack_completed => $default_ack_completed
                      );

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
SELECT recid as method_type_id, 
       notification_format_id as method_format_id, 
       (
SELECT notification_format_id 
  FROM rhn_method_types
  WHERE method_type_name = :group_type
       ) AS group_format_id,
       (
SELECT recid
  FROM rhn_strategies
 WHERE contact_strategy = :strategy
   AND ack_completed = :ack_completed
       ) AS strategy_id
  FROM rhn_method_types
 WHERE method_type_name = :method_type              
EOQ

  $sth->execute_h(%query_params);
  my ($method_type_id, $method_format_id, $group_format_id, $strategy_id) = $sth->fetchrow;
  $sth->finish;

  return { method_type_id => $method_type_id,
           method_format_id => $method_format_id,
           group_format_id => $group_format_id,
           strategy_id => $strategy_id };
}

        
1;


__END__
=head1 NAME

RHN::DB::ContactMethod - Notification Methods for alerts from monitoring

=head1 SYNOPSIS

  use RHN::DB::ContactMethod;
  
  <<INSERT SAMPLE CODE HERE>>

=head1 DESCRIPTION

<<INSERT LONG DESCRIPTION HERE>>

=head1 REQUIRES

Params::Validate, RHN::DB, RHN::DB::TableClass, Carp

=head1 INSTANCE VARIABLES

=over 8

=item recid - the primary key for the contact method

=item method_name - an arbitary description for the contact method

=item contact_id - establishes the relationship to a WEB_CONTACT via WEB_CONTACT.ID

=item schedule_id - schedule for the notification method.  There is currently only
one schedule (24x7) so this value is defaulted to "1" for expediency
TODO: Implement proper objects for the schedules - kdykeman (6/23/2004)

=item last_update_user - the uid of the person who last changed the method

=item last_update_date - the date the method was last changed.

=item method_type_id - represents the mechanism for deliver of notifications on this
method.  The method type has implications for which fields are used by the notification
system as well as the format of the notiification message.
Currently valid values are Pager|Email|Group|SNMP (references RHN_METHOD_TYPES.ID)

=item email_address - the email address to use when delivering notifications to
method that have an Email method type.

=item pager_email - the email address to use when delivering notifications to
methods have a Pager method type.

=item pager_max_message_length - Not required.  Limits the length of the notification
message sent.

=item pager_split_long_messages - Not required.  Boolean value indicating whether to
deliver long notifications as multiple messages.
Note: There is a trigger that verifies this field is not null if it is a pager
method type, so this field is defaulted to 0 for all methods.

=item notification_format_id - copied value of notification_format_id from the
selected RHN_METHOD_TYPES instance.


=back

=head1 CLASS METHODS

=over 8

=back

=head1 INSTANCE METHODS

=over 8

=item new()

<<CONSTRUCTOR DOCUMENTATION HERE>>

=item lookup()

Look up contact method by ID

=item set_type_info

=back

=head1 SEE ALSO

L<OTHER_MODULE>, L<ANOTHER_MODULE>

=head1 COPYRIGHT

Copyright (c) 2004--2012 Red Hat, Inc.  All rights reserved

=cut
