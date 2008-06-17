package Sys::SetID;

use 5.00503;
use strict;
use English;

require Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
@ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Sys::SetID ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
%EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

@EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

@EXPORT = qw(
	
);
$VERSION = '0.01';

my %FIELDS = (
  'user'  => [qw(ruid euid)],
  'group' => [qw(rgid egid groups)],
);

my %LOOKUP = (
  'user'  => sub {my $u = shift; return getpwnam($u)},
  'group' => sub {my $g = shift; return getgrnam($g)},
);

my @ENV_VARS = qw( BASH_ENV HOME LOGNAME SHELL USER USERNAME);


# Class variables
my($SAVED_RUID, $SAVED_EUID, 
   $SAVED_RGID, $SAVED_EGID, $SAVED_GROUPS) = &get_all_ids();

my $SAVED_ENV = &get_environment();




##############################################################################
###############################  Subroutines  ################################
##############################################################################


##################
sub get_user_ids {
##################
  return($REAL_USER_ID, $EFFECTIVE_USER_ID);
}


###################
sub get_group_ids {
###################

  my($rgid) = $REAL_GROUP_ID + 0;

  my($egid, @groups) = split(/\s+/, $EFFECTIVE_GROUP_ID);
  @groups = grep(!/^$egid$/, @groups);


  return($rgid, $egid, \@groups);
}

#################
sub get_all_ids {
#################
  return (&get_user_ids(), &get_group_ids());
}


#####################
sub get_environment {
#####################
  my %env;

  foreach my $var (@ENV_VARS) {
    $env{$var} = $ENV{$var};
  }

  return \%env;
}


###############
sub names2ids {
###############
  my $in = shift;
  my %out;
  my %cache;

  # Convert usernames and group names into numeric IDs.
  # Cache IDs to prevent multiple lookups on the same name.

  foreach my $class (qw(user group)) {

    foreach my $param (@{$FIELDS{$class}}) {

      my @args;
      my @out;
      my $array = 0;

      if (ref($in->{$param}) =~ /ARRAY/) {

        @args = @{$in->{$param}};
        $array = 1;

      } else {

        @args = ($in->{$param});

      }

      foreach my $subject (@args) {

        if ($subject =~ /^\d+$/) {

          # We were passed a numeric ID field.
          push(@out, $subject);

        } else {

          my $resolved;

          # We were passed a username instead of an ID.  Convert to
          # numeric user ID.

          if ($cache{$class}{$subject}) {

            $resolved = $cache{$class}{$subject};

          } else {

            $resolved = $cache{$class}{$subject} = &{$LOOKUP{$class}}($subject);

          }

          if (defined($resolved)) {
            push(@out, $resolved);
          } else {
            return &set_error("Couldn't find $class ID for $subject: $!");
          }

        }

      }

      if ($array) {
        $out{$param} = \@out;
      } else {
        $out{$param} = $out[0];
      }

    }
  }

  return \%out;

}


##################
sub set_user_ids {
##################
  my %args = @_;

  # Args:
  #   ruid => [num or username]
  #   euid => [num or username]
  #   perm => [0 or 1, default 0]

  my $ids = &names2ids(\%args);

  return &set_error("set_user_ids requires at least one of:  ",
                     join(',', @{$FIELDS{'user'}}, "\n")) unless (%$ids);

  if ($args{'perm'}) {

    # Set UIDs in PERMANENT order -- EUID then RUID.  This permanently
    # relinquishes saved permissions.

    $EFFECTIVE_USER_ID = $ids->{'euid'} if (exists($ids->{'euid'}));
    if ($EFFECTIVE_USER_ID != $ids->{'euid'}) {
      return &set_error("Failed to set effective user ID: $!");
    }

    $REAL_USER_ID      = $ids->{'ruid'} if (exists($ids->{'ruid'}));
    if ($REAL_USER_ID != $ids->{'ruid'}) {
      return &set_error("Failed to set real user ID: $!");
    }

  } else {

    # Set UIDs in TEMPORARY order -- RUID then EUID.  This order sets
    # both IDs, but is reversible.

    $REAL_USER_ID      = $ids->{'ruid'} if (exists($ids->{'ruid'}));
    if ($REAL_USER_ID != $ids->{'ruid'}) {
      return &set_error("Failed to set real user ID: $!");
    }

    $EFFECTIVE_USER_ID = $ids->{'euid'} if (exists($ids->{'euid'}));
    if ($EFFECTIVE_USER_ID != $ids->{'euid'}) {
      return &set_error("Failed to set effective user ID: $!");
    }

  }

  return 1;

}

###################
sub set_group_ids {
###################
  my %args = @_;

  # Args:
  #   rgid    => [num or username]
  #   egid    => [num or username]
  #   groups  => [array ref of nums or usernames]

  # If the 'rgid' or 'egid' argument is supplied, reset the 
  #   real and/or effective group ID as requested.
  # If a 'groups' argument is supplied but is undef, 
  #   the user wants no supplemental groups.

  my $ids = &names2ids(\%args);

  return &set_error("set_group_ids requires at least one of:  ",
                     join(',', @{$FIELDS{'group'}}, "\n")) unless (%$ids);

  if (defined($ids->{'rgid'})) {

    # Set the real group ID
    $REAL_GROUP_ID = $ids->{'rgid'};

    # Verify that it worked
    return &set_error("Couldn't set real group ID: $!")
      unless ($REAL_GROUP_ID == $ids{'rgid'});

  }

  if (exists($ids->{'egid'}) or exists($ids->{'groups'})) {

    # Set the effective group ID and supplemental groups, using
    # existing settings to fill in the gaps.
    my(undef, $egid, $groups) = &get_group_ids();
    $egid   = $ids->{'egid'}   if (defined($ids->{'egid'}));

    if (defined($ids->{'groups'})) {
      $groups = $ids->{'groups'};
    } elsif (exists($ids->{'groups'})) {
      $groups = [$egid];
    }
    my $str = join(" ", $egid, $groups);
    $EFFECTIVE_GROUP_ID = $str;

    # Verify that it worked
    return &set_error("Couldn't set effective group ID: $!")
      unless ("$EFFECTIVE_GROUP_ID" eq $str);

  }

  return 1;

}



#####################
sub reset_saved_ids {
#####################
  # Use to reset all saved IDs to the current IDs (for 
  # restore_saved_ids).
  ($SAVED_RUID,    $SAVED_EUID,
   $SAVED_RGID,    $SAVED_EGID, $SAVED_GROUPS) = &get_all_ids();

  return 1;
}


#######################
sub restore_saved_ids {
#######################
  &set_user_ids(
    ruid => $SAVED_RUID,
    euid => $SAVED_EUID,
  ) or return undef;

  &set_group_ids(
    rgid    => $SAVED_RGID,
    egid    => $SAVED_EGID,
    groups  => $SAVED_GROUPS,
  ) or return undef;

  return 1;
}



#####################
sub reset_saved_env {
#####################
  # Use to reset all saved IDs to the current IDs (for 
  # restore_saved_ids).

  $SAVED_ENV = &get_environment();

  return 1;
}


#######################
sub restore_saved_env {
#######################
  foreach my $var (@ENV_VARS) {
    $ENV{$var} = $SAVED_ENV->{'var'};
  }
  return 1;
}


########
sub su {
########
  my %args = @_;
  my $username = shift;

  # Switch to the named user.  Save the current environment
  # in case we go back later (via &restore_saved_env);
  &save_environment();

  # Become $username in all respects.
  my ($name,$passwd,$uid,$dgid,$quota,
      $comment,$gcos,$dir,$shell,$expire) = getpwnam($username);

  # Set the user environment
  $ENV{'HOME'}     = $dir;
  $ENV{'SHELL'}    = $shell;
  $ENV{'LOGNAME'}  = $ENV{'USER'} = $ENV{'USERNAME'} = $name;
  delete($ENV{'BASH_ENV'});

  # Set the user and group IDs for $username
  my $groups = &groups_for_user($username);

  &set_group_ids(
    'rgid'   => $dgid,
    'egid'   => $dgid,
    'groups' => $groups,
  ) or return undef;

  &set_user_ids(
    ruid => $uid,
    euid => $uid,
    perm => $args{'perm'},
  ) or return undef;


  # There ... now that wasn't so hard, was it?  :-)

  return 1;

}


#####################
sub groups_for_user {
#####################
  my $username = shift;

  my(@groups, $grnam, $gpass, $gid, @users);
  while (($grnam, $gpass, $gid, @users) = getgrent()) {
    if (grep(/^$username$/, @users)) {
      push(@groups, $gid);
    }
  }

  return \@groups;

}



###############
sub set_error {
###############
  $@ = join("\n", @_);
  return undef;
}



1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Sys::SetID - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Sys::SetID;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Sys::SetID, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.


=head1 AUTHOR

A. U. Thor, E<lt>a.u.thor@a.galaxy.far.far.awayE<gt>

=head1 SEE ALSO

L<perl>.

=cut
