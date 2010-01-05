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

package RHN::DB::AppInstall::Session;

use strict;

use RHN::Exception qw/throw/;
use RHN::DB;
use RHN::DB::TableClass;
use RHN::Server;
use RHN::User;
use RHN::AppInstall::Instance;
use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

my %valid_fields = (id => 0,
		    app_instance => { isa => 'RHN::AppInstall::Instance',
				      optional => 1 },
		    instance_id => 0,
		    checksum_id => 0,
		    process_name => { type => SCALAR },
		    step_number => { type => SCALAR | UNDEF,
				     default => -1 },
		    session_data => { type => HASHREF,
				      default => {} },
		    acl_parser => { can => 'eval_acl',
				    optional => 1 },
		    user => { isa => 'RHN::User',
			      optional => 1 },
		    server => { isa => 'RHN::Server',
			        optional => 1 },
		    user_id => 0,
		    server_id => 0,
		    action_runner => { isa => 'RHN::AppInstall::ActionHandler::ActionRunner',
				       optional => 1,
				     },
		    action_scheduler => { isa => 'RHN::AppInstall::ActionHandler::ActionScheduler',
					  optional => 1,
				     },
		    requirement_handler => { isa => 'RHN::AppInstall::RequirementHandler',
					     optional => 1,
					   },
		   );

sub valid_fields {
  return %valid_fields;
}

# some fields are not actually stored in the object, merely helpers to
# access fields in member objects
sub virtual_fields {
  return qw/instance_id user_id server_id/;
}

sub sequence { return 'rhn_appinst_session_id_seq' }

my %db_fields = (id => 1,
		 instance_id => 1,
		 checksum_id => 1,
		 process_name => 1,
		 step_number => 1,
		 user_id => 1,
		 server_id => 1,
		 );

my $tc = new RHN::DB::TableClass("rhnAppInstallSession", "AIS", "", keys %db_fields);

# preferred constructor:
sub lookup_or_new {
  my $class = shift;
  my %params = validate(@_, {user => 1, server => 1, app_instance => 1, process_name => 1});

  my $object;

  eval {
    $object = $class->lookup(-user_id => $params{user}->id, -server_id => $params{server}->id,
			     -app_instance => $params{app_instance},
			     -process_name => $params{process_name});
  };
  if ($@) {
    my $E = $@;

    unless (ref $E and $E->is_rhn_exception('lookup_failed')) {
      throw $E;
    }
  }

  if (not $object) {
    $object = $class->new(%params);
  }

  return $object;
}

sub new {
  my $class = shift;
  my %fields = $class->valid_fields();
  my %attr = validate(@_, \%fields);

  delete $fields{$_} foreach ($class->virtual_fields);

  my $self = bless { map { ( $_, undef ) } keys(%fields),
		   }, $class;

  if (not $attr{app_instance} and not $attr{instance_id}) {
    throw "(missing_parameter) Call to $class->new needs either an app_instance or an instance_id";
  }

  if (not $attr{user} and not $attr{user_id}) {
    throw "(missing_parameter) Call to $class->new needs either an user or a user_id";
  }

  if (not $attr{server} and not $attr{server_id}) {
    throw "(missing_parameter) Call to $class->new needs either an server or a server_id";
  }

  foreach (keys %attr) {
    my $func = "set_${_}";
    throw "Invalid function: $func"
      unless $self->can($func);

    $self->$func($attr{$_});
  }

  $self->_init();

  return $self;
}

sub _init {
  my $self = shift;

  $self->{":modified:"}->{instance_id} = 1;
  $self->{":modified:"}->{user_id} = 1;
  $self->{":modified:"}->{server_id} = 1;

  return;
}

sub lookup {
  my $class = shift;
  my %params = validate(@_, {id => 0, user_id => 0, server_id => 0, process_name => 0, app_instance => 1});
  my $id = $params{id};

  my $dbh = RHN::DB->connect;;
  my $sqlstmt;
  my %query_params;

  if ($params{id}) {
    $sqlstmt = $tc->select_query("AIS.ID = :id");
    $query_params{id} = $params{id};
  }
  elsif ($params{user_id} and $params{server_id} and exists $params{app_instance} and $params{process_name}) {
    $sqlstmt = $tc->select_query("AIS.user_id = :user_id" .
				 " AND AIS.server_id = :server_id" .
				 " AND AIS.instance_id = :instance_id" .
				 " AND AIS.process_name = :process_name");
    $query_params{user_id} = $params{user_id};
    $query_params{server_id} = $params{server_id};
    $query_params{instance_id} = $params{app_instance}->get_id;
    $query_params{process_name} = $params{process_name};
  }
  else {
    throw "(invalid_params) Call to $class->lookup did not have enough parameters: '" . join(', ', %params) . "'";
  }

  my $sth = $dbh->prepare($sqlstmt);
  $sth->execute_h(%query_params);
  my $data = $sth->fetchrow_hashref;

  my %obj_params = map { ("-" . lc($_), $data->{$_}) } keys %{$data};
  $sth->finish;

  my $object;

  if (%obj_params) {
    if ($params{app_instance}) {
      delete $obj_params{-instance_id};
      $obj_params{-app_instance} = $params{app_instance};
    }
    $object = $class->new(%obj_params);
    delete $object->{":modified:"};
  }
  else {
    throw "(lookup_failed) Could not lookup $class with parameters: '" . join(', ', %query_params) . "'";
  }

  $object->lookup_session_data();

  return $object;
}

sub lookup_session_data {
  my $self = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
SELECT AISD.key, AISD.value, AISD.extra_data
  FROM rhnAppInstallSessionData AISD
 WHERE AISD.session_id = :session_id
EOQ

  $sth->execute_h(session_id => $self->get_id);

  my $data = {};

  while (my $row = $sth->fetchrow_hashref) {
    if ($row->{EXTRA_DATA}) {
      $data->{$row->{KEY}} = [ $row->{VALUE}, $row->{EXTRA_DATA} ];
    }
    else {
      $data->{$row->{KEY}} = $row->{VALUE};
    }
  }

  $sth->finish;

  $self->set_session_data($data);

  return;
}

sub commit {
  my $self = shift;
  my $mode = 'update';

  my $dbh = RHN::DB->connect;
  $dbh->nest_transactions;

  $self->get_app_instance->commit();

  unless ($self->get_id) {
    my $seq = $self->sequence;

    my $sth = $dbh->prepare("SELECT $seq.nextval FROM DUAL");
    $sth->execute;
    my ($id) = $sth->fetchrow;

    die "No new id from seq $seq (possible error: " . $sth->errstr . ")" unless $id;
    $sth->finish;

    $self->set_id($id);
    $mode = 'insert';
  }

  my @modified = $self->modified_fields();
  return unless (@modified);

  if (grep { $_ ne 'session_data' } @modified) {
    my $query;
    if ($mode eq 'update') {
      $query = $tc->update_query($tc->methods_to_columns(@modified));
      $query .= "AIS.ID = ?";
    }
    else {
      $query = $tc->insert_query($tc->methods_to_columns(@modified));
    }

    my $sth = $dbh->prepare($query);
    my @params = map { my $method = "get_$_"; $self->$method() }
      grep { $self->is_modified($_) } $tc->method_names;

    push(@params, $self->get_id) if ($mode eq 'update');

    $sth->execute(@params);
  }

  $self->commit_session_data();

  $dbh->nested_commit;

  delete $self->{":modified:"};

  return;
}

sub commit_session_data {
  my $self = shift;

  my $dbh = RHN::DB->connect;
  my %data = $self->get_session_data();

  my $sth = $dbh->prepare(<<EOQ);
DELETE
  FROM rhnAppInstallSessionData AISD
 WHERE AISD.session_id = :session_id
EOQ

  $sth->execute_h(session_id => $self->get_id);

  my $val_sth = $dbh->prepare(<<EOQ);
INSERT
  INTO rhnAppInstallSessionData
       (id, session_id, key, value)
VALUES (rhn_appinst_sdata_id_seq.nextval, :session_id, :key, :value)
EOQ

  my $dat_sth = $dbh->prepare(<<EOQ);
INSERT
  INTO rhnAppInstallSessionData
       (id, session_id, key, value, extra_data)
VALUES (rhn_appinst_sdata_id_seq.nextval, :session_id, :key, :value, :extra_data)
EOQ

  foreach my $key (keys %data) {
    my $value = $data{$key};
    if (ref($value) eq 'ARRAY') {
      $dat_sth->execute_h(session_id => $self->get_id, key => $key, value => $value->[0],
			  extra_data => $dbh->encode_blob($value->[1], "extra_data"));
    }
    else {
      $val_sth->execute_h(session_id => $self->get_id, key => $key, value => $value);
    }
  }

  $dbh->commit;

  return;
}

sub clear_session {
  my $class = shift;
  my %attr = validate(@_, {user_id => 1,
			   server_id => 1,
			   app_instance_id => 1,
			   process => 1,
			  });

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
DELETE
  FROM rhnAppInstallSession AIS
 WHERE AIS.instance_id = :instance_id
   AND AIS.process_name = :process
   AND AIS.user_id = :user_id
   AND AIS.server_id = :server_id
EOQ

  $sth->execute_h(instance_id => $attr{app_instance_id}, process => $attr{process},
		  user_id => $attr{user_id}, server_id => $attr{server_id});

  $dbh->commit;

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

  # handle some fields manually
  next if (grep { $field eq $_ } (virtual_fields()));

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
