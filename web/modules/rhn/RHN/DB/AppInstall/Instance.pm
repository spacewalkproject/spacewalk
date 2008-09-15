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

package RHN::DB::AppInstall::Instance;

use strict;

use RHN::Exception qw/throw/;
use RHN::DB;
use RHN::DB::TableClass;
use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

my %valid_fields = (id => 0,
		    name => 0,
		    label => 0,
		    version => 0,
		    prerequisites => { type => ARRAYREF,
				       default => [],
				     },
		    ts_and_cs => 0,
		    md5 => 0,
		    install_process => { class => 'RHN::AppInstall::Process::Install',
					 optional => 1,
				       },
		    install_progress_process => { class => 'RHN::AppInstall::Process::InstallProgress',
						  optional => 1,
						},
		    configure_process => { class => 'RHN::AppInstall::Process::Configure',
					   optional => 1,
					 },
		    remove_process => { class => 'RHN::AppInstall::Process::Remove',
					optional => 1,
				      },
		    acl_mixins => { type => ARRAYREF,
				    default => [],
				  },
		    app_dir => 0,
		   );

sub valid_fields {
  return %valid_fields;
}

sub sequence { return 'rhn_appinst_instance_id_seq' }

my %db_fields = (id => 1,
		 name => 1,
		 label => 1,
		 version => 1,
		);

my $tc = new RHN::DB::TableClass("rhnAppInstallInstance", "AII", "", keys %db_fields);

sub new {
  my $class = shift;
  my %fields = $class->valid_fields();
  my %attr = validate(@_, \%fields);

  my $self = bless { map { ( "__${_}__", undef ) } keys(%fields),
		   }, $class;

  foreach (keys %attr) {
    my $func = "set_${_}";
    throw "Invalid function: $func"
      unless $self->can($func);

    $self->$func($attr{$_});
  }

  return $self;
}

sub lookup {
  my $class = shift;
  my %params = validate(@_, {id => 0, label => 0, version => 0});
  my $id = $params{id};

  my $dbh = RHN::DB->connect;;
  my $sqlstmt;
  my %query_params;

  if ($params{id}) {
    $sqlstmt = $tc->select_query("AII.ID = :id");
    $query_params{id} = $params{id};
  }
  elsif ($params{label} and $params{version}) {
    $sqlstmt = $tc->select_query("AII.LABEL = :label AND AII.version = :version");
    $query_params{label} = $params{label};
    $query_params{version} = $params{version};
  }
  else {
    throw "(invalid_params) Call to $class->lookup did not have enough parameters";
  }

  my $sth = $dbh->prepare($sqlstmt);
  $sth->execute_h(%query_params);
  my $data = $sth->fetchrow_hashref;

  my %obj_params = map { ("-" . lc($_), $data->{$_}) } keys %{$data};
  $sth->finish;

  my $object;

  if (%obj_params) {
    $object = $class->new(%obj_params);
    delete $object->{":modified:"};
  }
  else {
    throw "(lookup_failed) Could not lookup $class with parameters: '" . join(', ', %params) . "'\n";
  }

  return $object;
}

sub commit {
  my $self = shift;
  my $mode = 'update';

  unless ($self->get_id) {

    # This wasn't looked up from the DB - see if a record already exists, and insert if not.
    my $exists = 0;
    eval {
      if (my $old_app = lookup(ref $self, -label => $self->get_label, -version => $self->get_version)) {
	$exists = 1;
	$self->set_id($old_app->get_id);
      }
    };
    if ($@) {
      my $E = $@;
      unless (ref $E and $E->is_rhn_exception('lookup_failed')) {
	throw $E;
      }
    }

    unless ($exists) {
      my $dbh = RHN::DB->connect;
      my $seq = $self->sequence;

      my $sth = $dbh->prepare("SELECT $seq.nextval FROM DUAL");
      $sth->execute;
      my ($id) = $sth->fetchrow;

      die "No new id from seq $seq (possible error: " . $sth->errstr . ")" unless $id;
      $sth->finish;

      $self->set_id($id);
      $mode = 'insert';
    }
  }

  my @modified = $self->modified_fields();
  return unless (@modified);

  my $dbh = RHN::DB->connect;

  my $query;
  if ($mode eq 'update') {
    $query = $tc->update_query($tc->methods_to_columns(@modified));
    $query .= "AII.ID = ?";
  }
  else {
    $query = $tc->insert_query($tc->methods_to_columns(@modified));
  }

  my $sth = $dbh->prepare($query);
  my @params = map { my $method = "get_$_"; $self->$method() }
    grep { $self->is_modified($_) } $tc->method_names;

  push(@params, $self->get_id) if ($mode eq 'update');

  $sth->execute(@params);
  $dbh->commit;

  delete $self->{":modified:"};

  return;
}

sub is_modified {
  my $self = shift;
  my $field = shift;

  return 1 if $self->{":modified:"}->{$field};

  return 0;
}

sub modified_fields {
  my $self = shift;

  return grep { exists $db_fields{$_} } keys %{$self->{":modified:"}};
}



sub get_field_type {
  my $field_name = shift;

  my $req = $valid_fields{$field_name};
  my $type = 0;

  if (ref $req eq 'HASH' and exists $req->{type}) {
    $type = $req->{type};
  }

  return $type;
}

foreach my $field (keys %valid_fields) {
  my $getter = q {
    sub get_[[field]] {
      my $self = shift;

      my $val = $self->{__[[field]]__};
      if (ref $val eq 'ARRAY') {
        return @{$val};
      }
      elsif (ref $val eq 'HASH') {
        return %{$val};
      }
      else {
        return $val;
      }
    }
  };

  my $setter;

  if (get_field_type($field) == ARRAYREF) {
    $setter = q {
      sub set_[[field]] {
        my $self = shift;
        my @vals;

        if (scalar @_ == 1 and ref $_[0] eq 'ARRAY') {
          @vals = @{$_[0]};
        }
        else {
          @vals = @_;
        }

        $self->{__[[field]]__} = \@vals;
        $self->{":modified:"}->{[[field]]} = 1;
      }
    };
  }
  elsif (get_field_type($field) == HASHREF) {
    $setter = q {
      sub set_[[field]] {
        my $self = shift;
        my %data;

        if (scalar @_ == 1 and ref $_[0] eq 'HASH') {
          %data = %{$_[0]};
        }
        else {
          %data = @_;
        }

        $self->{__[[field]]__} = \%data;
        $self->{":modified:"}->{[[field]]} = 1;
      }
    };
  }
  else {
    $setter = q {
      sub set_[[field]] {
        my $self = shift;
        my @vals = validate_pos(@_, $valid_fields{[[field]]});

        $self->{__[[field]]__} = $vals[0];
        $self->{":modified:"}->{[[field]]} = 1;
      }
    };
  }

  $getter =~ s/\[\[field\]\]/$field/g;
  $setter =~ s/\[\[field\]\]/$field/g;

  eval $getter;
  if ($@) {
    die $@;
  }

  eval $setter;
  if ($@) {
    die $@;
  }
}

1;
