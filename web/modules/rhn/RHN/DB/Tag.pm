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

package RHN::DB::Tag;

use Params::Validate qw/validate/;
Params::Validate::validation_options(strip_leading => "-");

use Carp;

use RHN::DB;
use RHN::DB::TableClass;

use RHN::Exception;

my @t_fields = qw/id org_id name_id created:longdate modified:longdate/;
my @tn_fields = qw/name/;
my $t_table = new RHN::DB::TableClass("rhnTag", "T", "", @t_fields);
my $tn_table = new RHN::DB::TableClass("rhnTagName", "TN", "", @tn_fields);

my $j = $t_table->create_join([$tn_table],
			      {
			       "rhnTag" =>
			       {
				"rhnTag" => ["ID", "ID"],
				"rhnTagName" => ["NAME_ID", "ID"],
			       }
			      });

foreach my $field ($j->method_names) {
   my $sub = q {
       sub [[field]] {
         my $self = shift;
         if (@_) {
           if ($rw_fields{[[field]]} or $self->{__newly_created__}) {
             my $value = shift;
             $self->{":modified:"}->{[[field]]} = 1;
             $self->{__[[field]]__} = $value;
           }
           else {
             croak "RHN::DB::Tag->[[field]] cannot be used to set a value at this time.  It may be a read-only accessor.";
           }
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
  my $sqlstmt;

  $sqlstmt = $j->select_query("T.ID = ?");

  my $sth = $dbh->prepare($sqlstmt);
  $sth->execute($id);
  @columns = $sth->fetchrow;
  $sth->finish;

  my $ret;
  if ($columns[0]) {
    $ret = bless {}, $class;
    foreach ($j->method_names) {
      $ret->{"__".$_."__"} = shift @columns;
    }

    delete $ret->{":modified:"};
  }
  else {
    local $" = ", ";
    throw '(tag_does_not_exist)';
  }

  return $ret;
}

sub remove_tags_from_system {
  my $class = shift;
  my @tags = @{+shift};
  my $sid = shift;

  my $dbh = $params{transaction} || RHN::DB->connect();
  my $query = <<EOQ;
BEGIN
  rhn_server.tag_delete(:server_id, :tag_id);
END;
EOQ

  my $sth = $dbh->prepare($query);
  
  for my $tag (@tags) {
    $sth->execute_h(tag_id => $tag, server_id => $sid);
  }
  $dbh->commit;
}

1;
