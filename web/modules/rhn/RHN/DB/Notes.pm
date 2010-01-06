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

package RHN::DB::Notes;

use strict;
use Data::Dumper;
use Carp;
use RHN::DB;
use RHN::DB::TableClass;

use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

# fields common to all notes tables
my @common_fields = qw { id creator subject note created modified };

# fields specific to ServerNotes table
my @sn_fields = qw { server_id };

# fields specific to ServerGroupNotes table
my @sgn_fields = qw { server_group_id };

# Structure used to generate packages:
# [0] package name
# [1] table name
# [2] sequence name
# [3] additional column(s) not found in @oommon_fields
my @pkgs =( 
           [ 
             "RHN::DB::ServerGroupNotes", 
             "rhnServerGroupNotes",
             "rhn_servergrp_note_id_seq", 
             [ @sgn_fields ]
           ],   
           [ 
             "RHN::DB::ServerNotes",
             "rhnServerNotes", 
             "rhn_server_note_id_seq", 
             [ @sn_fields ]
           ] 
	       );

sub blank_note {
   bless { }, shift;
}

sub create_note {
   my $note = shift->blank_note;
   $note->{__id__} = -1;
   return $note;
}

sub lookup {
  my $class = shift;
  my %params = validate(@_, {id => 1});
  my $id = $params{id};

  my $dbh = RHN::DB->connect;
  my $ret = $class->blank_note;

  my $query = sprintf "SELECT %s FROM %s N WHERE N.id = ?",
    join(", ",map{ "N.$_" } @common_fields,$ret->columns),
      $ret->table;

  my $sth = $dbh->prepare($query);
  $sth->execute($id);
  my @cols = $sth->fetchrow;
  $sth->finish;

  if ($cols[0]) {
    $ret->{__id__} = $cols[0];
    $ret->$_(shift @cols) foreach (@common_fields,$ret->columns);
    delete $ret->{":modified:"};
  }
  else {
    local $" = ", ";
    croak "Error loading note $id; no ID? (@cols)";
  }

  return $ret;
}

sub commit {
   my $self = shift;
   my $dbh = RHN::DB->connect;
   my $mode = '';
   my $sth;
   my $query;

   my @modified;
   my %modified;


   if ($self->{__delete__}) {
   # hack alert
      $query = "DELETE FROM ";
      $query .= $self->table;
      $query .= " WHERE ID = ";
      $query .= $self->id;
   }

   else {
      if ($self->id == -1)
      {
         $mode = 'insert';
         $query = "SELECT ". $self->sequence . ".nextval FROM DUAL";

         $sth = $dbh->prepare($query);
         $sth->execute;
         my ($id) = $sth->fetchrow;
         croak "No new note id from sequence (possible error: " . $sth->errstr . ")" unless $id;
         $sth->finish;

         $self->{":modified:"}->{id} = 1;
         $self->{__id__} = $id;
         $mode = 'insert';
      }
      else {
         $mode = 'update';
      }
      croak "$self->commit called on org without valid id" unless $self->id and $self->id > 0;

      @modified = keys %{$self->{":modified:"}};
      %modified = map { $_ => 1 } @modified;
      return unless @modified;
   }

   $dbh = RHN::DB->connect;

   my $o = new RHN::DB::TableClass($self->table,"T","",@common_fields,$self->columns);
   if ($mode eq 'update') {
      $query = $o->update_query($o->methods_to_columns(@modified));
      $query .= "T.ID = ?";
   }
   elsif ($mode eq 'insert') {
      $query = $o->insert_query($o->methods_to_columns(@modified));
   }

   $sth = $dbh->prepare($query);
   $sth->execute((map { $self->$_() } grep { $modified{$_} } $o->method_names), ($mode eq 'update') ? ($self->id) : ());

   $dbh->commit;
   delete $self->{":modified:"};
}

#
# Generate getter/setters 
#
foreach my $field (@common_fields) {
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

  croak $@ if($@);
}

#
# Generate packages
#
foreach my $p (@pkgs) {

   my $pkg = q {
      package [[package]];
      @[[package]]::ISA = ( "RHN::DB::Notes" );

      sub columns {
         return qw{ [[columns]] };
      }

      sub table {
         return "[[table]]";
      }

      sub sequence {
         return "[[sequence]]";
      }

      1;
   };

   $pkg =~ s/\[\[package\]\]/$p->[0]/g;
   $pkg =~ s/\[\[table\]\]/$p->[1]/g;
   $pkg =~ s/\[\[sequence\]\]/$p->[2]/g;
   $pkg =~ s/\[\[columns\]\]/@{$p->[3]}/g;

   eval $pkg;

   croak $@ if($@);

   # Generate accessors unique to this package
   foreach my $field (@{$p->[3]}) {
      my $sub = q {
         sub [[package]]::[[field]] {
            my $self = shift;
            if (@_ and "[[field]]" ne "id") {
               $self->{":modified:"}->{[[field]]} = 1;
               $self->{__[[field]]__} = shift;
            }
            return $self->{__[[field]]__};
         }
      };

      $sub =~ s/\[\[field\]\]/$field/g;
      $sub =~ s/\[\[package\]\]/$p->[0]/g;

      eval $sub;

      croak $@ if ($@);
   }
}

1;
