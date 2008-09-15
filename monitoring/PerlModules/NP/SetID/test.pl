#REAL Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
BEGIN { plan tests => 1 };
use NOCpulse::SetID;
ok(1); # If we made it this far, we're ok.

#########################

use strict;
use English;

# Test 2 -- make sure we're running as root
if ($REAL_USER_ID != 0 and $EFFECTIVE_USER_ID != 0) {
  print "not ok 2 - *** You must be root to run tests ***\n";
  exit 1;
}

# Save original info
my($sruid, $seuid, $srgid, $segid, $shome, $sshell, $susername) = (
  $REAL_USER_ID, 
  $EFFECTIVE_USER_ID,
  $REAL_GROUP_ID, 
  $EFFECTIVE_GROUP_ID,
  $ENV{'HOME'},
  $ENV{'SHELL'},
  $ENV{'LOGNAME'});


# Find a test user
my($username,$uid,$gid,$home,$shell,@groups) = &find_user();



#####################
# Test temporary su #
#####################

my $id_test = NOCpulse::SetID->new(user => $username);
$id_test->su();


# Verify that we switched identities

# IDS:
ok($REAL_USER_ID       == $uid,      1, 'Failed to set RUID');
ok($EFFECTIVE_USER_ID  == $uid,      1, 'Failed to set EUID');
ok($REAL_GROUP_ID      == $gid,      1, 'Failed to set RGID');
ok($EFFECTIVE_GROUP_ID == $gid,      1, 'Failed to set EGID');

# ENV:
ok($ENV{'HOME'}        eq $home,     1, 'Failed to set $HOME');
ok($ENV{'SHELL'}       eq $shell,    1, 'Failed to set $SHELL');
ok($ENV{'LOGNAME'}     eq $username, 1, 'Failed to set $LOGNAME');
ok($ENV{'USER'}        eq $username, 1, 'Failed to set $USER');
ok($ENV{'USERNAME'}    eq $username, 1, 'Failed to set $USERNAME');

# Supplemental groups:
my $want = &groupstr($gid, @groups);
my $am   = &groupstr($EFFECTIVE_GROUP_ID);
ok($want, $am, 'Failed to set supplemental groups');


###############
# Test revert #
###############
$id_test->revert();

# IDS:
ok($REAL_USER_ID       == $sruid,     1, 'Failed to revert RUID');
ok($EFFECTIVE_USER_ID  == $seuid,     1, 'Failed to revert EUID');
ok($REAL_GROUP_ID      == $srgid,     1, 'Failed to revert RGID');
ok($EFFECTIVE_GROUP_ID == $segid,     1, 'Failed to revert EGID');

# ENV:
ok($ENV{'HOME'}        eq $shome,     1, 'Failed to revert $HOME');
ok($ENV{'SHELL'}       eq $sshell,    1, 'Failed to revert $SHELL');
ok($ENV{'LOGNAME'}     eq $susername, 1, 'Failed to revert $LOGNAME');
ok($ENV{'USER'}        eq $susername, 1, 'Failed to revert $USER');
ok($ENV{'USERNAME'}    eq $susername, 1, 'Failed to revert $USERNAME');

# Supplemental groups:
my $want = &groupstr($segid);
my $am   = &groupstr($EFFECTIVE_GROUP_ID);
ok($want, $am, 'Failed to set supplemental groups');




#####################
# Test permanent su #
#####################
$id_test->su('permanent' => 1);


# Verify that we switched identities

# IDS:
ok($REAL_USER_ID       == $uid,      1, 'Failed to set RUID');
ok($EFFECTIVE_USER_ID  == $uid,      1, 'Failed to set EUID');
ok($REAL_GROUP_ID      == $gid,      1, 'Failed to set RGID');
ok($EFFECTIVE_GROUP_ID == $gid,      1, 'Failed to set EGID');

# ENV:
ok($ENV{'HOME'}        eq $home,     1, 'Failed to set $HOME');
ok($ENV{'SHELL'}       eq $shell,    1, 'Failed to set $SHELL');
ok($ENV{'LOGNAME'}     eq $username, 1, 'Failed to set $LOGNAME');
ok($ENV{'USER'}        eq $username, 1, 'Failed to set $USER');
ok($ENV{'USERNAME'}    eq $username, 1, 'Failed to set $USERNAME');

# Supplemental groups:
my $want = &groupstr($gid, @groups);
my $am   = &groupstr($EFFECTIVE_GROUP_ID);
ok($want, $am, 'Failed to set supplemental groups');



# Verify that revert fails
eval {
  $id_test->revert();
};
ok(length($@) > 0, 1, 'Revert from permanent su failed to fail');


# Verify that we cannot, in any way, reset the UIDs
$> = $sruid;
ok($> == $sruid, undef, 'Managed to reset RUID after permanent su');

$< = $seuid;
ok($< == $seuid, undef, 'Managed to reset EUID after permanent su');


##############
sub groupstr {
##############

  my($gid, @groups) = split(/\s+/, "@_");

  # Remove duplicates from @groups
  my %stuff;
  @stuff{@groups} = (1..scalar(@groups));
  delete($stuff{$gid});
  @groups = keys %stuff;

  return join(' ', $gid, @groups);

}


###############
sub find_user {
###############

  my(%groups, @groups, $gr_nam, $gr_gid, $gr_members, $username);

  # Read in the group table
  while (($gr_nam, undef, $gr_gid, $gr_members) = getgrent()) {
    foreach my $candidate (split(/\s+/, $gr_members)) {
      push(@{$groups{$candidate}}, $gr_gid);
    }
  }

  # Find a non-root user that belongs to at least 3 groups
  foreach my $candidate (keys %groups) {
    if (@{$groups{$candidate}} >= 3 and $candidate ne 'root') {
      $username = $candidate;
      @groups = @{$groups{$candidate}};
    }
  }

  # Get the users passwd info
  my($uid,$gid,$dir,$shell) = (getpwnam($username))[2,3,7,8];

  return ($username,$uid,$gid,$dir,$shell,@groups);

}
