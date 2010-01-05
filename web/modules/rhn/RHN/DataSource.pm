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

package RHN::DataSource;

use strict;
use RHN::Utils;
use RHN::DB::DataSource;
use RHN::Exception qw/throw/;
use Data::Dumper;

our @ISA = qw/RHN::DB::DataSource/;

sub valid_fields {
  return qw/mode dsn/;
}

sub new {
  my $class = shift;
  my %attr = @_;

  my $self = bless { mode => 'null_mode',
		     dsn => '',
		   }, $class;

  foreach ($class->valid_fields) {
    if (exists $attr{"-$_"}) {
      $self->$_($attr{"-$_"});
    }
  }

  return $self;
}

sub clean {
  my $self = shift;

  $self->{mode} = 'null_mode';

  return $self;
}

sub dsn {
  my $self = shift;
  if (@_) {
    $self->{dsn} = shift;
  }
  return $self->{dsn};
}

sub mode {
  my $self = shift;
  my $mode = shift;

  if (defined $mode) {
    throw "Attempt to set invalid mode '$mode' for datasource '" . ref($self) . "'"
      unless $self->mode_exists($mode);

    $self->{mode} = $mode;
  }

  return $self->{mode};
}

sub required_params {
  my $self = shift;
  my $mode = $self->lookup_mode_data;

  my @params;

  if (exists $mode->{query}) {
    push @params, @{$mode->{query}->{params} || []};
  }

  if (exists $mode->{elaborators}) {
    foreach my $elab (@{$mode->{elaborators}}) {
      push @params, @{$elab->{params} || []};
    }
  }

  my %seen;
  my @uniq_params = grep { ! $seen{$_}++ } @params;

  return @uniq_params;
}

sub get_query_body {
  my $self = shift;

  my $mode_data = $self->lookup_mode_data;
  return $mode_data->{query}->{body};
}

sub execute_query {
  my $self = shift;
  my %params = @_;

  my $mode_data = $self->lookup_mode_data;

  my $trans = delete $params{-transaction};

  my %query_params = $self->parse_params($mode_data->{query}->{params}, %params);

  my $data = $self->run_query(-transaction => $trans, -body => $mode_data->{query}->{body}, -params => \%query_params);

  return $data;
}

sub execute_full {
  my $self = shift;
  my %params = @_;

  my $data = $self->execute_query(%params);
  $data = $self->elaborate($data, %params);

  return $data;
}

sub elaborate {
  my $self = shift;
  my $data = shift;
  my %params = @_;

  throw "elaborate requires data param" unless ($data);

  my $mode_data = $self->lookup_mode_data;

  return $data unless (exists $mode_data->{elaborators}
		       and @{$mode_data->{elaborators}}
		       and @{$data});

  my @ids = map { $_->{ID} } grep { exists $_->{ID} } @{$data};

  throw "No id column found for mode '" . $self->mode . "'." unless @ids;

  foreach my $elab ( @{$mode_data->{elaborators}} ) {
    my %query_params = $self->parse_params($elab->{params}, %params);
    $query_params{__sprintf_ids__} = \@ids;

    my $elab_data = $self->run_complex_query(-body => $elab->{body}, -params => \%query_params);
    $data = $self->collate_data($data, $elab_data, $elab->{multiple});
  }

  return $data;
}

sub parse_params {
  my $self = shift;
  my $needed = shift;
  my %provided = @_;

  my %query_params;

  foreach my $pname (@{$needed}) {
    throw "missing param '-$pname' when executing query in mode '" . $self->mode . "'."
      unless exists $provided{"-$pname"};

    $query_params{$pname} = $provided{"-$pname"};
  }

  return %query_params;
}

#class or object method
sub slice_data {
  my $self = shift;
  my $data = shift;
  my $lower = shift;
  my $upper = shift;

  throw "slice_data requires lower and upper"
    unless (defined $lower && defined $upper);

  if ($lower > @{$data}) {
    return [ ];
  }

  if ($upper > @{$data}) {
    $upper = @{$data};
  }

  $data = [ @{$data}[$lower - 1 .. $upper - 1] ];

  return $data;
}

sub collate_data {
  my $self = shift;
  my $data = shift;
  my $elab_data = shift;
  my $multiple = shift;

  return $data unless @{$elab_data};

  my $num_cols = keys(%{$elab_data->[0]}) - 1; #-1 so we don't count the 'id' key
  my $elab_hash;

  foreach my $row (@{$elab_data}) {
    my $id = delete $row->{ID};

    throw "No id field from elaborator.  Row: " . Data::Dumper->Dump([($row)]) unless ($id);

    push @{$elab_hash->{$id}}, $row;
  }

  if ($multiple eq 'T') {
    foreach my $row (@{$data}) {
      my $id = $row->{ID};
      my $elab_rows;

      if (exists $elab_hash->{$id}) {
	$elab_rows = $elab_hash->{$id};
      }
      else {
	$elab_rows = [ ];
      }

      if ($num_cols > 1) {
	$row->{__data__} = $elab_rows;
      }
      else {
	my $elab_rows = $elab_hash->{$id};
	my $col = (keys %{$elab_rows->[0]})[0];

	if (defined $col) {
	  $row->{$col} = [ map $_->{$col}, @{$elab_rows} ];
	}
      }
    }
  }
  else {

    foreach my $row (@{$data}) {
      my $id = $row->{ID};
      my $elab_row = $elab_hash->{$id}->[0];

      foreach my $col (keys %{$elab_row}) {
	$row->{$col} = $elab_row->{$col};
      }
    }
  }

  return $data;
}

# static method to return a list of all the available datasources.
# used by test suite and by query performance metric script

sub available_datasource_files {
  my $class = shift;
  my @extra_entries = @_;

  my $core_dir = $INC{"RHN/DB/DataSource.pm"};
  $core_dir =~ s(\.pm$)(/xml);

  my @ret;

  for my $entry ($core_dir, @extra_entries) {
    my @files;

    if (-d $entry) {
      my $dir = $entry;
      opendir DIR, $dir or die "opendir $dir: $!";
      push @files, grep { -f "$dir/$_" } readdir DIR;
      closedir DIR;
    }
    else {
      push @files, $entry;
    }

    push @ret, map { s(\.xml$)(); $_ } grep { m(\.xml$) } @files;
  }

  return sort @ret;
}

1;
