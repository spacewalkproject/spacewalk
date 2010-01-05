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

package RHN::DB::Probe;

use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => '-');

use strict;
use Carp;
use Data::Dumper;

use RHN::DB;
use RHN::DB::TableClass;
use RHN::DataSource::Simple;

our $VERSION = (split(/s+/, q$Id$, 4))[2];

# Hash of default values for instance construction
use constant INSTANCE_DEFAULTS => (
  check_interval_minutes => 5,
);

#
# NOTE:  For limited Triumph functionality:
#   1. NOTIFY_{CRITICAL,WARNING,UNKNOWN,RECOVERY} DB fields should
#      equal the 'notify' field;
#   2. RETRY_INTERVAL_MINUTES should equal the 'check_interval_minutes' field;
#   3. MAX_ATTEMPTS should be 1;
#   4. PROBE_TYPE should be 'check'.
#


# Setup class data and generated setter and getter methods
{

  #Setup vars that are common to all Probe objects
  my $_readable_type = "probe"; #used for human readable messages about this type of object
  my $_table_name = "rhn_probe";
  my $_table_alias = "P";
  my $_method_prefix = "";
  my $_sequence = "rhn_probes_recid_seq"; #sequence for fetching the next probe recid
  my $_primary_key_field = "recid";

  my %_valid_spec = (recid => { default => 0 },
		     probe_type => { default => "check" },
		     description => { optional => 0 },
		     customer_id => { optional => 0 },
		     command_id => { optional => 0 },
		     contact_group_id => { optional => 1 },
		     max_attempts => { default => 1 },
		     last_update_user => { optional => 0 }		    );
	
  my @p_fields = qw /recid probe_type description customer_id command_id
		     contact_group_id notify_critical notify_warning notify_unknown notify_recovery
		     notification_interval_minutes check_interval_minutes retry_interval_minutes
		     max_attempts last_update_user last_update_date/;

  my $p_table = new RHN::DB::TableClass($_table_name, $_table_alias, $_method_prefix, @p_fields);

  my @cp_fields = qw /probe_id host_id sat_cluster_id/;
  my $cp_table = new RHN::DB::TableClass("rhn_check_probe", "CP", "check_probe", @cp_fields);

  #accessor methods to the class data
  sub get_readable_type { $_readable_type }
  sub get_sequence { $_sequence }
  sub get_table_alias {$_table_alias }
  sub get_primary_key_field { $_primary_key_field }
  sub get_table { $p_table }
  sub get_validation_spec { \%_valid_spec }

# Generated getter/setter methods (per Chip)
# put all the fields for both rhn_probe and rhn_check_probe into @fields
  my @fields;
  push @fields, @p_fields;
  push @fields, @cp_fields;

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


##################
sub validate_obj {
##################
  my $self = shift;
  my $class = ref($self) || $self;

  my $spec = $class->get_validation_spec;

  # Build the list of fields to be validated against the spec
  # and their values
  my %validate;
  foreach my $field (keys %$spec) {
    my $value = $self->$field;
    if (defined $value) {
      $validate{$field} = qq/$value/;
    }
  }

  my %params = Params::Validate::validate_with( params => \%validate,
						spec => $spec);

  #set the validated/defaulted name/value pairs on the instance
  foreach my $param (keys %params) {
    $self->$param($params{$param});
  }
  return $self;
}

#########
sub new {
#########
  my $class = shift;
  my %args  = @_;
  my $self  = {};
  bless($self, $class);

  foreach my $arg (keys %args) {
    $self->$arg($args{$arg});
  }

  # Set defaults for values that weren't supplied to the constructor
  my %defaults = (INSTANCE_DEFAULTS);
  foreach my $field (keys %defaults) {
    $self->$field($defaults{$field}) unless(defined($self->$field()));
  }

  return $self;
}

# Create a "blank" instance
# Make sure to call validate prior to commit to set sensible defaults
# where needed
############
sub create {
############
  my $class = shift;
  my $self = bless { }, $class;
  return $self;
}


# Look up probe by probe ID
############
sub lookup {
############
  my $class = shift;

  my $type = $class->get_readable_type;
  my $pk = $class->get_primary_key_field;
  my $pk_upper = uc $pk;

  my %params = Params::Validate::validate(@_, { recid => { optional => 0 }});
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
    local $" =", ";
    die "error loading $type $pk_value (@columns)";
  }

  return $instance;
}

############
sub commit {
############
  my $self = shift;
  my $mode = 'update';
  my $type = $self->get_readable_type;

  #make updating the name of the primary key field easier
  my $pk = $self->get_primary_key_field;
  my $pk_upper = uc $pk;
  my $table_alias = $self->get_table_alias;

  #if this is a new instance, change mode to insert
  if (not $self->$pk) {
    my $dbh = RHN::DB->connect;

    #get the next probe recid to use for a new probe
    my ($pk_value) = $dbh->sequence_nextval(get_sequence);

    #mark recid as dirty since the accessor for the recid field doesn't
    $self->{":modified:"}->{$pk} = 1;
    $self->$pk($pk_value);
    $mode = 'insert';
  }
  #validate the object we're about to presist
  $self->validate_obj;

  #make sure recid is valid
  die "$self->commit called on $type without a valid $pk" unless ($self->$pk > 0);

  #Create an array of modified fields
  my @modified = keys %{$self->{":modified:"}};
  my %modified = map { $_ => 1} @modified;
  return unless @modified;

  my $dbh = RHN::DB->connect;

  my $query;

  if ($mode eq 'update') {
    $query = get_table->update_query(get_table->methods_to_columns(@modified));
    $query .= get_table_alias .".$pk_upper = ?";
    # adjust the query to update the last_update_date
    $query =~ s/SET (.*)/SET $table_alias\.last_update_date = SYSDATE, $1/;
  }
  else {
    $query = get_table->insert_query(get_table->methods_to_columns(@modified));
    # adjust query to update last_update_date
    $query =~ s/\((.*)\) VALUES \((.*)\)/\($1, $table_alias\.last_update_date\) VALUES \($2, SYSDATE\)/;
  }

  my $sth = $dbh->prepare($query);

  # build a list of method named for the modified fields
  my @mod_accessors = grep { $modified{$_} } get_table->method_names;

  # build a list of value associated with modified fields
  my @bindvals = map { $self->$_() } @mod_accessors;

  #execute the statement
  $sth->execute( @bindvals, ($mode eq 'update') ? ($self->$pk) : ());

  $dbh->commit;

  delete $self->{":modified:"};
}

#################
sub list_scouts {
#################
  my $class = shift;
  my $customer_id = shift;

  my $ds = new RHN::DataSource::Simple(-querybase => "probe_queries",
				       -mode => "clusters_for_customer");

  return $ds->execute_query(-customer_id => $customer_id);
}


1;

__END__
=head1 NAME

RHN::DB::Probe - Monitoring probes

=head1 SYNOPSIS

  use RHN::DB::Probe;
  
  <<INSERT SAMPLE CODE HERE>>

=head1 DESCRIPTION

<<INSERT LONG DESCRIPTION HERE>>

=head1 METHODS

=over 8

=item new()

<<CONSTRUCTOR DOCUMENTATION HERE>>

=item create()

Create a probe record


=item lookup()

Look up probe by probe ID



=back

=head1 SEE ALSO

L<OTHER_MODULE>, L<ANOTHER_MODULE>

=head1 COPYRIGHT

Copyright (c) 2004-2005, Red Hat, Inc.  All rights reserved

=cut


