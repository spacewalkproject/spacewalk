package NOCpulse::SetID;
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
use 5.00503;
use strict;

use vars qw($VERSION);
$VERSION = 1.2;

use English;
use Class::MethodMaker 
  new_with_init => 'new',
  new_hash_init => 'hash_init',
  get_set       => [qw(
    ruid
    euid
    rgid
    egid
    orig_id
  )],

  list          => [qw(
    groups
  )],

  hash          => [qw(
    env
  )],
  ;

# Global variables

# - When fetching info to convert names to numbers, do we use
#   'getpwnam' (users) or 'getgrnam' (groups)?

my %PARAM_CLASS = (
  'ruid'   => 'user',
  'euid'   => 'user',
  'rgid'   => 'group',
  'egid'   => 'group',
  'groups' => 'group',
);

my %PARAM_LOOKUP = (
  'user'  => sub {my $u = shift; return getpwnam($u)},
  'group' => sub {my $g = shift; return getgrnam($g)},
);

my @ENV_VARS = qw( HOME LOGNAME SHELL USER USERNAME PATH);

my @BASEPATH = qw(
  /usr/local/bin
  /bin
  /usr/bin
  /usr/X11R6/bin
);

my @ROOTBASEPATH = qw(
  /usr/local/sbin
  /sbin
  /usr/sbin
);

############################# High-level methods #############################

sub init {
  my($self, %args) = @_;
  # Initialize defaults
  if (defined($args{'user'})) {
    # If the 'user' argument is supplied, fetch the ID and env 
    # params from the named user's /etc/passwd and /etc/group
    # entries.
    $self->set_from_user($args{'user'});
    delete($args{'user'});
  } else {
    # If no 'user' argument is supplied, set default ID and
    # env parameters from the current environment
    $self->set_from_current();
  }
  # name2num converts any non-numeric IDs to numerics (doesn't 
  # apply to 'user' or 'env' args)
  $self->hash_init($self->name2num(%args));
}

sub su {
  my $self = shift;
  my %args = @_;
  # Save the current identity for reversion
  $self->orig_id(NOCpulse::SetID->new()) unless ($args{'permanent'});
  # Set IDs
  $self->set_group_ids(%args);
  $self->set_user_ids(%args);
  $self->set_env(%args);
}

sub revert {
  my $self = shift;
  unless ($self->orig_id()) {
    return &fatal("Reversion impossible for permanent ID change");
  }
  $self->orig_id->set_user_ids('permanent' => 1);
  $self->orig_id->set_group_ids('permanent' => 1);
  $self->orig_id->set_env();
}

############################# Low-level methods ##############################

sub set_from_user {
  my $self     = shift;
  my $username = shift;
  my ($pw_name,$pw_passwd,$pw_uid,$pw_gid,$dir,$shell) = 
                                     (getpwnam($username))[0,1,2,3,7,8];
  # Set the UIDS and GIDS
  $self->ruid($pw_uid);
  $self->euid($pw_uid);
  $self->rgid($pw_gid);
  $self->egid($pw_gid);
  # Set up the supplemental groups
  my(@groups, $gr_nam, $gr_gid, $gr_members);
  endgrent();
  while (($gr_nam, undef, $gr_gid, $gr_members) = getgrent()) {
    if (grep(/^$username$/, split(/\s+/, $gr_members))) {
      push(@groups, $gr_gid);
    }
  }
  endgrent();
  $self->groups_clear;
  $self->groups_push(@groups);
  # Set up the environment
  $self->env({
    HOME     => $dir,
    SHELL    => $shell,
    LOGNAME  => $pw_name,
    USER     => $pw_name,
    USERNAME => $pw_name,
  });
  # Set up the path (after HOME var has been set above)
  $self->env({PATH => $self->path()});

}

sub set_from_current {
  my $self     = shift;
  my $username = shift;
  # Set the UIDs and GIDs
  $self->ruid($REAL_USER_ID);
  $self->euid($EFFECTIVE_USER_ID);
  $self->rgid($REAL_GROUP_ID + 0);       # force numeric context
  $self->egid($EFFECTIVE_GROUP_ID + 0);  # force numeric context
  # Set up the supplemental groups
  my @groups = split(/\s+/, $REAL_GROUP_ID);
  shift(@groups);
  $self->groups_clear();
  $self->groups_push(reverse @groups);
  # Set up the environment
  my %env;
  foreach my $var (@ENV_VARS) {
    $env{$var} = $ENV{$var};
  }
  $self->env(\%env);
}

sub set_env {
  my $self = shift;
  # Now transfer to %ENV
  my $env = $self->env();
  foreach my $var (keys %$env) {
    $ENV{$var} = $env->{$var};
  }
}

sub set_group_ids {
  my $self = shift;
  my %args = @_;
  if ($args{'permanent'}) {
    # Set GIDs in PERMANENT order -- effective, then real.
    $self->set_effective_group_id(@_);
    $self->set_real_group_id(@_);
  } else {
    # Set GIDs in TEMPORARY order -- real, then effective.
    $self->set_real_group_id(@_);
    $self->set_effective_group_id(@_);
  }
}

sub set_effective_group_id {
  my $self = shift;
  my %args = shift;
  # Set the effective group ID and supplemental groups, using
  # existing settings to fill in the gaps.  Save effective GID 0
  # unless we're doing a permanent change.
  my $egid = defined($self->egid) ? $self->egid : $EFFECTIVE_GROUP_ID + 0;

  my @groups;
  if ($self->groups_count) {
    # There are supplemental groups
    push(@groups, $self->groups);
  } else {
    # There are no supplemental groups
    push(@groups, $egid);
  }
  my $str = join(' ', $egid, @groups);
  $EFFECTIVE_GROUP_ID = $str;
  # Verify that it worked
  my $want = join(' ', sort {$a <=> $b} split(/\s+/, $str));
  my $am   = join(' ', sort {$a <=> $b} split(/\s+/, $EFFECTIVE_GROUP_ID));

  return &fatal("Couldn't set effective/supplemental group IDs: $!")
    unless ($want eq $am);
}

sub set_real_group_id {
  my $self = shift;
  # There are no real gotchas here, except that $REAL_GROUP_ID
  # and $EFFECTIVE_GROUP_ID are a space-separated list of IDs 
  # in non-numeric scalar context.
  if (defined($self->rgid)) {
    # Set the real group ID
    $REAL_GROUP_ID = $self->rgid;
    # Verify that it worked
    return &fatal("Couldn't set real group ID: $!")
      unless ($REAL_GROUP_ID + 0 == $self->rgid);
  }
}

sub set_user_ids {
  my $self = shift;
  my %args = @_;
  # If both RUID and EUID are non-zero, 
  #  - setting EUID *then* RUID is a permanent change (only
  #    allowed if EUID == RUID)
  #  - setting RUID then EUID is temporary (EUID does not have
  #    to equal RUID)
  # In either case, an exec sets the saved SUID to the EUID
  # If you spawn a shell (directly or indirectly via 'system' et al)
  # and EUID != RUID, the shell will helpfully reset EUID to RUID
  # for you.  So don't do that.
  if ($args{'permanent'}) {
    # Set UIDs in PERMANENT order -- EUID then RUID.  This permanently
    # relinquishes saved permissions.
    $EFFECTIVE_USER_ID = $self->euid if (defined($self->euid));
    if ($EFFECTIVE_USER_ID != $self->euid) {
      return &fatal("Failed to set effective user ID: $!");
    }
    $REAL_USER_ID = $self->ruid if (defined($self->ruid));
    if ($REAL_USER_ID != $self->ruid) {
      return &fatal("Failed to set real user ID: $!");
    }
  } else {
    # Set UIDs in TEMPORARY order -- RUID then EUID.  This change
    # is reversible in the current process and children (but 
    # becomes PERMANENT on exec()).
    $REAL_USER_ID = $self->ruid if (defined($self->ruid));
    if ($REAL_USER_ID != $self->ruid) {
      return &fatal("Failed to set real user ID: $!");
    }

    $EFFECTIVE_USER_ID = $self->euid if (defined($self->euid));
    if ($EFFECTIVE_USER_ID != $self->euid) {
      return &fatal("Failed to set effective user ID: $!");
    }
  }
}

############################## Utility routines ##############################

sub name2num {
  my $self = shift;
  my %in   = @_;
  my %out;
  # Convert usernames and group names into numeric IDs.
  foreach my $param (keys %in) {
    my $class = $PARAM_CLASS{$param};
    unless ($class) {
      # We don't handle this one.
      $out{$param} = $in{$param};
      next;
    }
    # We handle both scalar and arrayref parameters; flaten 
    # them out for now.
    my @args;
    my @out;
    my $array = 0;
    if (ref($in{$param})) {
      @args = @{$in{$param}};
      $array = 1;
    } else {
      @args = ($in{$param});
    }
    # Do the lookups
    foreach my $subject (@args) {
      if ($subject =~ /^\d+$/) {
        # We were passed a numeric ID field.
        push(@out, $subject);
      } else {
        my $resolved;
        # We were passed a username instead of an ID.  Convert to
        # numeric user ID.
        $resolved = &{$PARAM_LOOKUP{$class}}($subject);
        if (defined($resolved)) {
          push(@out, $resolved);
        } else {
          return &fatal("Couldn't find $class ID for $subject: $!");
        }
      }
    }
    if ($array) {
      $out{$param} = \@out;
    } else {
      $out{$param} = $out[0];
    }
  }
  return \%out;
}

sub fatal {
  my($line)              = (caller(0))[2];
  my($pkg, $fname, $sub) = (caller(1))[0,1,3];
  die "ERROR: @_ \n\tat $sub line $line\n";
}

sub path {
  my $self = shift;
  my @path;
  my @candidates = ($self->euid == 0 and $self->ruid == 0) ?
    (@ROOTBASEPATH, @BASEPATH) : (@BASEPATH);
  foreach my $dir (@candidates) {
    push(@path, $dir) if (-d $dir);
  }
  return join(":", @path);
}

1;

__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

NOCpulse::SetID - Set user and group IDs and revert

=head1 SYNOPSIS

  use NOCpulse::SetID;

  # Create a new identity

  my $identity = NOCpulse::SetID->new( user => 'nocpulse');
    

  # Temporarily set credentials

  $identity->su();     # Set IDs to $identity's IDs

  # ... reduced-privilege code goes here

  $identity->revert(); # Revert to credentials before su()

    

  # Permanently set IDs to $identity (revert not possible)

  $identity->su(permanent => 1);

=head1 DESCRIPTION

NOCpulse::SetID allows a process to change its credentials by setting
real and effective user and group IDs, supplemental group memberships,
and user-related environment variables ($HOME, $LOGNAME, $SHELL, $USER,
$USERNAME, and $PATH).


=head1 METHODS

        

=over 2

=item B<new()>

Create a new identity.  Without arguments, new() takes all parameters
from the current environment.  With a 'user' argument, new() takes
all parameters from the user's passwd and group entries.  In either
case, you can override individual parameters.  The full syntax is:

  my $identity = new (
                       [user   => $username,]
                       [ruid   => $username_or_uid,]
                       [euid   => $username_or_uid,]
                       [rgid   => $groupname_or_gid,]
                       [egid   => $groupname_or_gid,]
                       [groups => \@groupnames_or_gids,]
                       [env    => \%env_hash,]
                     );


=item B<su()>

Become the new identity.  Without arguments, su() temporarily changes
to the new identity; the identity that was in effect when su() was
called can be restored by calling revert().  With the 'permanent' 
argument set to a true value, su() will switch to the new identity
permanently, and revert() will generate a fatal error if called.


=item B<revert()>

Switch back to the previous identity.  When you call su(), the
function stores the current identity (real and effective UIDs
and GIDs, supplemental group memberships, and user-related
environment variables) in the object, unless the 'permanent' 
argument is supplied.  revert() switches back to the stored
identity.

=back


=head1 EXPORTS

None.


=head1 AUTHOR

Dave Faraldo E<lt>dfaraldo@redhat.comE<gt>

=head1 SEE ALSO

L<perl>, L<perlvars>, L<English>

=cut
