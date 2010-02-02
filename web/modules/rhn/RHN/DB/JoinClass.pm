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

package RHN::DB::JoinClass;

use Data::Dumper;

sub new {
  my $class = shift;
  my $tables = shift;
  my $column_association = shift;
  my $outer = shift;

  my $self = bless { tables => $tables, assoc => $column_association, outer => $outer}, $class;

  my @meth = $self->method_names;
  my @cols = $self->column_names;
  my %m_to_c = map { $meth[$_] => $cols[$_] } 0..$#meth;
  my %c_to_m = map { $cols[$_] => $meth[$_] } 0..$#meth;

  die "method/column clash" unless keys(%m_to_c) == keys(%c_to_m);

  $self->{m_to_c} = \%m_to_c;
  $self->{c_to_m} = \%c_to_m;

  return $self;
}

sub update_queries {
  my $self = shift;
  my %changed_fields = map { $_ => 1 } @_;

  my @ret;

  foreach my $table (@{$self->{tables}}) {
    next unless grep { exists $changed_fields{$_} } $table->column_names;

    my $ret;

    $ret .= "UPDATE $table->{name} $table->{alias}\nSET ";
    $ret .= join(", ", map { "$_ = ?" }
		 grep { exists $changed_fields{$_} } $table->column_names);

    $ret .= "\nWHERE " .
      $table->{alias} . "." .
	$self->{assoc}->{$self->{tables}->[0]->{name}}->{$table->{name}}->[1] .
	  " = ?";

    push @ret, [ $ret,  [ $table->method_names ] ];
  }

  return @ret;
}

sub insert_queries {
  my $self = shift;
  my %changed_fields = map { $_ => 1 } @_;

  my @ret;

  foreach my $table (@{$self->{tables}}) {
    next unless grep { exists $changed_fields{$_} } $table->column_names;

    my $ret;

    $ret .= "INSERT INTO $table->{name} $table->{alias}\n(";
    $ret .= join(", ", map { "$_" }
		 grep { exists $changed_fields{$_} } $table->column_names);

    $ret .= ")\nVALUES\n(";

    $ret .= join(", ", map { "?" }
		 grep { exists $changed_fields{$_} } $table->column_names);

    $ret .= ")";

    push @ret, [ $ret,  [ $table->method_names ] ];
  }

  return @ret;
}


my %column_flags = (longdate => "YYYY-MM-DD HH24:MI:SS",
                    shortdate => "YYYY-MM-DD",
		    dayofyear => "YYYY-MM-DD");

sub column_flags {
  return \%column_flags;
}

sub select_query {
  my $self = shift;
  my $where = shift;

  my $ret = "SELECT ";

  my @clauses;
  foreach my $table (@{$self->{tables}}) {
    push @clauses, join(", ", map {
      (exists $column_flags{$table->column_flags($_)}? "TO_CHAR($table->{alias}.$_ , '" . $column_flags{$table->column_flags($_)} . "')" : "$table->{alias}.$_")
    } @{$table->{columns}});
  }
  $ret .= join(", ", @clauses) . "\nFROM ";

  $ret .= join(", ", map { "$_->{name} $_->{alias}" } @{$self->{tables}});

  $ret .= "\nWHERE ";

  $ret .= join(" AND ",
	       (map { "$self->{tables}->[0]->{alias}.$self->{assoc}->{$self->{tables}->[0]->{name}}->{$_->{name}}->[0] =" .
		       " $_->{alias}.$self->{assoc}->{$self->{tables}->[0]->{name}}->{$_->{name}}->[1]" . ($self->{outer}->{$_->{name}} || '')}
	       @{$self->{tables}}[1..$#{$self->{tables}}]),
	       $where);

  return $ret;
}

sub column_names {
  my $self = shift;

  my @ret;
  foreach my $table (@{$self->{tables}}) {
    push @ret, map { "$table->{alias}.$_" } @{$table->{columns}};
  }

  return @ret;
}

sub method_names {
  my $self = shift;
  my %prefixes = @_;

  my @ret;
  foreach my $table (@{$self->{tables}}) {
    push @ret, $table->method_names($prefixes{$table->{alias}} || $prefixes{$table->{name}} || '');
  }

  return @ret;
}

sub methods_to_columns {
  my $self = shift;

  return map { $self->{m_to_c}->{$_} } @_;
}

1;
