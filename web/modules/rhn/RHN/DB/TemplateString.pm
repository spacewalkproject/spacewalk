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

package RHN::DB::TemplateString;

use RHN::DB;
use RHN::DB::TableClass;

use RHN::Exception qw/throw/;
use Params::Validate;
Params::Validate::validation_options(strip_leading => "-");

my @ts_fields = qw/ID CATEGORY_ID LABEL VALUE DESCRIPTION CREATED:longdate MODIFIED:longdate/;
my @tc_fields = qw/LABEL DESCRIPTION/;

my $ts_table = new RHN::DB::TableClass("rhnTemplateString", "TS", "", @ts_fields);
my $tc_table = new RHN::DB::TableClass("rhnTemplateCategory", "TC", "category", @tc_fields);

my $j = $ts_table->create_join([$tc_table],
			       { rhnTemplateString =>
				 { rhnTemplateString => [ "ID", "ID" ],
				   rhnTemplateCategory => [ "CATEGORY_ID", "ID" ],
				   } } );

# build some accessors
foreach my $field ($j->method_names) {

  my $sub = q{
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

  if ($@) {
    die $@;
  }
}

sub lookup {
   my $class = shift;
   my %params = validate(@_, {id => 1});
   my $id = $params{id};

   my @columns;

   my $dbh = RHN::DB->connect;
   my $query = $j->select_query("TS.ID = ?");

   my $sth = $dbh->prepare($query);
   $sth->execute($id);
   @columns = $sth->fetchrow;
   $sth->finish;

   my $ret;
   if ($columns[0]) {
     $ret = $class->_blank_templatestring();
     foreach ($j->method_names) {
       $ret->{"__${_}__"} = shift @columns;
     }

     delete $ret->{":modified:"};
   }
   else {
     throw "No string with id '$id' found\n";
   }

   return $ret;
}


sub _blank_templatestring {
  my $class = shift;

  my $self = bless { }, $class;
  return $self;
}

#just get a string by id or label - don't bother with loading the object
sub get_string {
  my $class = shift;
  my %params = validate(@_, {id => 0, label => 0});

  my $query;
  my %q_params;

  if (my $id = $params{id}) {
    $query = 'SELECT value FROM rhnTemplateString WHERE id = :id';
    $q_params{id} = $id;
  }
  elsif (my $label = $params{label}) {
    $query = 'SELECT value FROM rhnTemplateString WHERE label = :label';
    $q_params{label} = $label;
  }
  else {
    throw "No id or label.";
  }

  my $dbh = RHN::DB->connect;

  my $sth = $dbh->prepare($query);
  $sth->execute_h(%q_params);

  my ($value) = $sth->fetchrow;
  $sth->finish;

  return $value;
}

#load all label/value pairs
sub load_all {
  my $class = shift;

  my $dbh = RHN::DB->connect;

  my $query = <<EOQ;
SELECT TS.label, TS.value
  FROM rhnTemplateString TS
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute;

  my %strings;

  while (my ($key, $value) = $sth->fetchrow) {
    $strings{$key} = $value || '';
  }

  return %strings;
}

sub commit {
  my $self = shift;
  my $dbh = shift || RHN::DB->connect;
  my $mode = 'update';

  if ($self->id == -1) {
    my $sth = $dbh->prepare("SELECT rhn_template_str_id_seq.nextval FROM DUAL");
    $sth->execute;
    my ($id) = $sth->fetchrow;
    die "No id from rhn_template_str_id_seq (possible error: " . $sth->errstr . ")" unless $id;
    $sth->finish;

    $self->{":modified:"}->{id} = 1;
    $self->{__id__} = $id;
    $mode = 'insert';
  }

  die "$self->commit called without valid id" unless $self->id and $self->id > 0;

  my @modified = keys %{$self->{":modified:"}};
  my %modified = map { $_ => 1 } @modified;

  return unless @modified;

  my $query;
  if ($mode eq 'update') {
    $query = $ts_table->update_query($ts_table->methods_to_columns(@modified));
    $query .= "TS.ID = ?";
  }
  else {
    $query = $ts_table->insert_query($ts_table->methods_to_columns(@modified));
  }

  my $sth = $dbh->prepare($query);

  $sth->execute((map { $self->$_() } grep { $modified{$_} } $ts_table->method_names), ($mode eq 'update') ? ($self->id) : ());

  $dbh->commit;

  delete $self->{":modified:"};
}

1;
