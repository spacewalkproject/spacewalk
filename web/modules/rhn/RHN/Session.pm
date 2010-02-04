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

package RHN::Session;

use Carp;
use Digest::MD5;
use Storable qw/freeze thaw/;
use MIME::Base64;
use RHN::SatInstall;

use PXT::Config ();
use RHN::DB ();

use strict;

# make a guaranteed unique md5 key.  very fast (16k keys/sec on a p3 500)

# default alias to use for db connection; if left undefined
# uses RHN::DB default
sub new {
  my $class = shift;

  my $self = bless { __id__ => -1 }, $class;

  $self->{__values__} = { };
  $self->{__can_persist__} = 0;

  return $self;
}

sub key {
  my $self = shift;

  if ($self->{__id__} < 0) {
    croak "Attempted to get key for session with id $self->{__id__}";
  }

  return $self->{__id__} . "x" . $self->generate_session_key($self->{__id__});
}

# the odd join is to introduce proprietary chaff so that people
# can't fake our cookies

sub generate_session_key {
  my $class = shift;
  my $id = shift;

  my $chaff = join(":",
		   PXT::Config->get('session_secret_1'),
		   PXT::Config->get('session_secret_2'),
		   $id,
		   PXT::Config->get('session_secret_3'),
		   PXT::Config->get('session_secret_4')
		  );

  my $ret = Digest::MD5::md5_hex($chaff);

  return $ret;
}

sub uid {
  my $self = shift;

  if (@_) {
    $self->{__uid__} = shift;
  }

  return $self->{__uid__};
}

sub set {
  my $self = shift;
  my $key = shift;

  return $self->{__values__}->{$key} = shift;
}

sub get {
  my $self = shift;
  return $self->{__values__}->{+shift};
}

sub unset {
  my $self = shift;
  delete $self->{__values__}->{+shift};
}

sub can_persist {
  my $self = shift;

  return $self->{__can_persist__};
}

sub load {
  my $class = shift;
  my $key = shift;

  my ($given_id, $md5) = split /x/, $key;

  my $dbh = RHN::DB->soft_connect();

  # No database handle?
  if (not $dbh or not RHN::SatInstall->test_db_schema()) {
    my $ret = new $class;
    return $ret;
  }

  my $sth;
  my ($id, $value, $web_user_id, $expires, $computed_md5);

  if ($given_id and $md5) {
    $computed_md5 = $class->generate_session_key($given_id);
    $sth = $dbh->prepare_cached("SELECT id, value, web_user_id, expires FROM PXTSessions WHERE id = ?");
    $sth->execute($given_id);

    ($id, $value, $web_user_id, $expires) = $sth->fetchrow_array;
    $sth->finish;
  }

  # bad cookie?  expired?  combine code for both, since they are similar
  if (not $id or $computed_md5 ne $md5) {
    if (not $id) {
      # supplied cookie ($key) not found, must make a new one
    }
    elsif ($computed_md5 ne $md5) {
      # md5's didn't match, oddly enough.  make a new cookie
    }
    else {
      $sth = $dbh->prepare("DELETE FROM PXTSessions WHERE id = ?");
      $sth->execute($id);
      $dbh->commit;
    }

    my $ret = new $class;
    return $ret;
  }

  my $session = new $class;
  $session->{__id__} = $id;
  $session->{__uid__} = $web_user_id;
  $session->{__values__} = thaw(MIME::Base64::decode($value) || freeze( { } ));

  $sth->finish;

  return $session;
}

sub serialize {
  my $self = shift;
  my %params = @_;

  # Uncomment to view sessions as they're saved.
  # warn "Session contents: " . Data::Dumper->Dump([$self->{__values__}]);

  my $duration = $params{duration} || PXT::Config->get("session_database_lifetime");

  my $tmpvalue = freeze($self->{__values__});
  my ($web_user_id, $value, $expires) = ($self->{__uid__},
					 MIME::Base64::encode($tmpvalue),
					 time + $duration);
  my $dbh = RHN::DB->soft_connect();

  # no-op, no database, can't save transient session
  if (not $dbh or not RHN::SatInstall->test_db_schema()) {
    return;
  }

  $self->{__can_persist__} = 1;
  my $sth;
  if (not exists $self->{__id__} or $self->{__id__} <= 0) {
    $sth = $dbh->prepare_cached("SELECT create_pxt_session(?, ?, ?) FROM DUAL");
    $sth->execute($web_user_id, $expires, $value);
    my ($id) = $sth->fetchrow;
    $sth->finish;

    $dbh->commit;
    $self->{__id__} = $id;
  }
  else {
    $sth = $dbh->prepare_cached("UPDATE PXTSessions SET value = ?, expires = ?, web_user_id = ? WHERE id = ?");
    $sth->execute($value, $expires, $web_user_id, $self->{__id__});
    $dbh->commit;
  }
}

#	my $session_cookie = new Apache::Cookie $r,
#	  -name => "pxt_session",
#	    -value => $request->session->key,
#	      -expires => PXT::Config->get("session_cookie_lifetime") || "+20m",
#		-domain => PXT::Config->get("base_domain");

1;

=head1 NAME

RHN::Session 

Database session handling for the RHN used internally by PXT. This class
does not handle cookies directly. Sessions are stored into the database under the table
PXTSessions, with the following columns:

=over 4

=item MD5SUM - Not Null - Char(32)

A 32 bit Md5sum (see Digest::MD5)

=item WEB_USER_ID - Not Null - Number

All users on RHN have an id and this is it (see $session->uid for details)

=item EXPIRES - Not Null - Number

How long the session cookie lives in the database, in seconds

=item VALUE - Not Null - VARCHAR2(4000)

This is treated as a blob and 'thaw' and 'freeze' are used to retrieve/store a perl
hash structure (see Storable and $session->set and $session->get)

=back

=head1 SYNOPSIS 

use RHN::Session;

$session = RHN::Session->new();

=over 4

=item $session->new

Generates a new session object, including the md5 key. Session is not saved into 
database until $session->serialize is called

=item $session->key

Returns the calculate md5sum for this session. The md5sum is generated at object 
construction by the internal method generate_session_key

=item $session->uid

Set or return the user id for this session. On $session->load this is set to the users
WEB_USER_ID

=item $session->set('key',$value)

Sets a value for this session, named by key stored in VALUE

=item $val = $session->get('key')

Gets the value of the named key from the session

=item $session->load($md5key)

This loads or creates a user session from the PXTSessions table. If the md5 key is
found in the table, but the session has expired a new session is created. If the md5
key is no found in the table, a new session is created

=item $session->serialize()

This saves a session (including all the values set using $sesssion->set) into the
database.

=back

=head1 SEE ALSO

Digest::MD5, Storable

=cut
