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

package RHN::DB::TableClass;

use RHN::DB::JoinClass;

sub new {
  my $class = shift;
  my $table_name = shift;
  my $table_alias = shift;
  my $method_prefix = shift;

  my @columns;
  my %column_flags;
  foreach my $col (@_) {
    if ($col =~ /:/) {
      my ($name, $flag) = split /:/, $col;
      $column_flags{$name} = $flag;
      push @columns, $name;
    }
    else {
      push @columns, $col;
    }
  }

  my $self = bless { name => $table_name, alias => $table_alias,
		     columns => \@columns, prefix => $method_prefix,
		     column_flags => \%column_flags }, $class;

  my @meth = $self->method_names;
  my @cols = $self->column_names;
  my %m_to_c = map { $meth[$_] => $cols[$_] } 0..$#meth;
  my %c_to_m = map { $cols[$_] => $meth[$_] } 0..$#meth;

  die "method/column clash for $table_name" unless keys(%m_to_c) == keys(%c_to_m);

  $self->{m_to_c} = \%m_to_c;
  $self->{c_to_m} = \%c_to_m;

  return $self;
}

sub type_to_select {
  my $self = shift;
  my $type = shift;

  my $ret;

  if (exists RHN::DB::JoinClass->column_flags->{$self->column_flags($type)}) {
    $ret = "TO_CHAR($self->{alias}.$type, '" . RHN::DB::JoinClass->column_flags->{$self->column_flags($type)} . "')";
  }
  else {
    $ret = "$self->{alias}.$type";
  }

  return $ret;
}

sub type_to_placeholder {
  my $self = shift;
  my $type = shift;
  my $fieldname = shift;
  $fieldname ||= "?";

  my $ret;

  if ($self->column_flags($type) eq 'longdate') {
    $ret = "TO_DATE($fieldname, 'YYYY-MM-DD HH24:MI:SS')";
  }
  elsif ($self->column_flags($type) eq 'shortdate') {
    $ret = "TO_DATE($fieldname, 'YYYY-MM-DD')";
  }
  else {
    $ret = "$fieldname";
  }

  return $ret;
}

sub table_alias {
  my $self = shift;
  return $self->{alias};
}

sub table_name {
  my $self = shift;
  return $self->{name};
}

sub create_join {
  my $self = shift;
  my $friends = shift;
  my $columns = shift;

  my $joined = new RHN::DB::JoinClass [ $self, @{$friends} ], $columns, @_;

  return $joined;
}

sub select_query {
  my $self = shift;
  my $where = shift;

  my $ret = "SELECT ";
  $ret .= join(", ", map { $self->type_to_select($_) } @{$self->{columns}});
  $ret .= "\nFROM $self->{name} $self->{alias}\n";
  $ret .= "WHERE $where\n";

  return $ret;
}

sub update_query {
  my $self = shift;
  my %changed_fields = map { $_ => 1 } @_;

  return '' unless grep { exists $changed_fields{$_} } $self->column_names;

  my $ret;
  $ret .= "UPDATE $self->{name} $self->{alias}\nSET ";
  $ret .= join(", ", map { "$_ = " .  $self->type_to_placeholder($_) }
	       grep { exists $changed_fields{$_} } map { "$_" } $self->column_names);

  $ret .= "\nWHERE ";
  return $ret;
}

sub insert_query {
  my $self = shift;
  my %changed_fields = map { $_ => 1 } @_;

  return '' unless grep { exists $changed_fields{$_} } $self->column_names;

  my $ret;
  $ret .= "INSERT INTO $self->{name} $self->{alias}\n (";
  $ret .= join(", ", grep { exists $changed_fields{$_} } $self->column_names);
  $ret .= ") VALUES (";
  $ret .= join(", ", map { $self->type_to_placeholder($_) }
	       grep { exists $changed_fields{$_} } map { "$_" } $self->column_names);
  $ret .= ")";

  return $ret;
}

sub column_names {
  my $self = shift;

  return map { $self->{alias} . "." . $_ } @{$self->{columns}};
}

sub method_names {
  my $self = shift;
  my $prefix = shift || $self->{prefix} || '';

  $prefix .= "_" if $prefix;

  return map { lc "$prefix$_" } @{$self->{columns}};
}

sub methods_to_columns {
  my $self = shift;

  return map { $self->{m_to_c}->{$_} } @_;
}

sub column_to_methods {
  my $self = shift;

  return map { $self->{c_to_m}->{$_} } @_;
}

sub column_flags {
  my $self = shift;
  my $flag = shift;

  $flag =~ s/^[a-zA-Z]+\.//;

  return $self->{column_flags}->{$flag} || '';
}

1;
