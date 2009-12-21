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

package RHN::DB::Command;

use strict;

use Carp;
use Params::Validate;
Params::Validate::validation_options(strip_leading => "-");

use RHN::Exception;
use RHN::DB::TableClass;
use RHN::DataSource::Simple;

our $VERSION = (split(/s+/, q$Id$, 4))[2];

# Hash of default values for instance construction
use constant INSTANCE_DEFAULTS => (
);


# list_groups should dip into RHN_COMMAND_GROUPS table.


my @c_fields = qw(
    recid name description group_name command_class enabled
    system_requirements version_support help_url
  );
my $c_table = new RHN::DB::TableClass("rhn_command", "C", "", @c_fields);

my @cg_fields = qw/group_name description/;
my $cg_table = new RHN::DB::TableClass("rhn_command_groups", "CG", "command_group", @cg_fields);

my @cr_fields = qw/description/;
my $cr_table = new RHN::DB::TableClass("rhn_command_requirements", "CR", "requirements", @cr_fields);

my $j = $c_table->create_join(
   [$cg_table, $cr_table],
   {
      "rhn_command" =>
         {
            "rhn_command" => ["RECID","RECID"],
            "rhn_command_groups" => ["GROUP_NAME","GROUP_NAME"],
	    "rhn_command_requirements" => ["SYSTEM_REQUIREMENTS", "NAME"],
         }
   },
   { rhn_command_groups => "(+)",
     rhn_command_requirements => "(+)",
   });


# Generated getter/setter methods (per Chip)
{

  my $tmpl = q|
    sub [[field]] {
      my $self = shift;
      if (@_) {
        $self->{__[[field]]__} = shift;
      }
      return $self->{__[[field]]__};
    };
  |;

  foreach my $field ($j->method_names) {

    (my $sub = $tmpl) =~ s/\[\[field\]\]/$field/g;

    eval $sub;

    croak $@ if($@);
  }

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



# Look up command by ID
############
sub lookup {
############
  my $class = shift;
  #my %params = validate(@_, {id => 1});
  my %params = @_;
  throw "no command id given" unless defined $params{id};

  my $id = $params{id};

  my @columns;

  my $dbh = RHN::DB->connect;
  my $sqlstmt;

  # digital server id's contain non-digits
  $sqlstmt = $j->select_query("C.RECID = ?");

  my $sth = $dbh->prepare($sqlstmt);
  $sth->execute($id);
  @columns = $sth->fetchrow;
  $sth->finish;

  my $ret;
  if ($columns[0]) {
    $ret = $class->new();
    foreach ($j->method_names) {
      $ret->{"__".$_."__"} = shift @columns;
    }

    delete $ret->{":modified:"};
  }
  else {
    croak "no such command";
  }

  return $ret;
}


# Get a list of available command groups
#################
sub list_groups {
#################
  my $class = shift;

  my $ds = new RHN::DataSource::Simple(-querybase => "probe_queries",
				       -mode => "command_groups");

  return $ds->execute_query();
}




1;

__END__
=head1 NAME

RHN::DB::Command - Monitoring commands

=head1 SYNOPSIS

  use RHN::DB::Command;
  
  my $groups   = RHN::DB::Command->list_groups();
  my $cmd_obj  = RHN::DB::Command->lookup(id => $command_id);


=head1 DESCRIPTION

RHN::DB::Command provides access to RHN monitoring commands 
(the RHN_COMMANDS table).

=head1 CLASS METHODS

=over 8

=item new()

Construct a new RHN::DB::Command object.

=item list_groups()

Get a list of available command groups.

=item lookup(id => $command_id)

Look up command by ID.  Returns an RHN::DB::Command object.

=back

=head1 INSTANCE VARIABLES

=over 8

=item recid()

Record ID (a.k.a. command ID).

=item name()

Command name.

=item description()

Command description.

=item group_name()

Group name of the command.

=item command_class()

Perl class that implements the command.

=item enabled()

Whether or not the command is enabled.

=item system_requirements()

System requirements that must be satisfied for the command to run.

=item version_support()

Supported versions of monitored software.

=back

=head1 COPYRIGHT

Copyright (c) 2004-2005, Red Hat, Inc.  All rights reserved

=cut


