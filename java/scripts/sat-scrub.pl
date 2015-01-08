#!/usr/bin/perl
use warnings;

use English;
use Getopt::Long;
use Frontier::Client;

my $sat_host = 'fjs-0-11.rhndev.redhat.com';
my $user = 'admin';
my $password = 'spacewalk';

my $conn = get_frontier_object($sat_host);

## auth
my $session = $conn->call('auth.login', $user, $password);

remove_test_users($conn, $session);
remove_test_systems($conn, $session);

#ok, we may have left some crap since we skip the user/system
#when the session invalidates. so, run again and pick up any
#stragglers (I know, I suck) :(
remove_test_users($conn, $session);
remove_test_systems($conn, $session);

## logout
#$conn->call('auth.logout', $session);

exit 0;

sub get_frontier_object {
    my $host = shift;

  # Use http unless $host specifies https
    if ($host !~ /^http/) {
        $host = 'http://' . $host;
    }

    ## perl
    my $s = new Frontier::Client(url => "$host/rpc/api");
    ## java
#    my $s = new Frontier::Client(url => "$host/rhn/XMLRPC");
}

sub remove_test_systems {
    $conn = shift;
    $session = shift;

    # keep track of how many users were deleted
    my $deleted_systems = 0;
    my @not_deleted;


    my $systems = $conn->call('system.list_user_systems', $session);
    print "Number of systems to delete: ";
    print scalar(@{$systems});
    print "\n";

    my @sids;
    foreach my $system (@{$systems}) {
        my $name = $system->{"name"};
        if ($name=~/test/i) {
            push(@sids, $system->{"id"});
        }
    }

    my $result = eval {
        my $delete_result = $conn->call('system.delete_systems', $session, @sids);
        if ($delete_result) {
            print "Deleted $delete_result systems\n";
        }
    };

    if ($@ && $@ =~ /invalid_session/) {
        #re-login and delete user
        $session = $conn->call('auth.login', $user, $password);
    }
}

sub remove_test_users {
    $conn = shift;
    $session = shift;

    # keep track of how many users were deleted
    my $deleted_users = 0;
    my @not_deleted;

    my $userlist = $conn->call('user.list_users', $session);
    foreach my $u (@{$userlist}) {
        my $login = $u->{"login"};
        if ($login=~/test/i) {
        my $result =  eval {
            my $delete_result = $conn->call('user.delete', $session, $login);
            if ($delete_result) {
                $deleted_users++;
            }
            else {
                push(@not_deleted, $login);
            }
          };

          if ($@ && $@ =~ /invalid_session/) {
              #re-login and delete user
              $session = $conn->call('auth.login', $user, $password);
          }
        }
    }

    print "$deleted_users users were deleted.\n";
    if (scalar(@not_deleted)) {
        print "Users NOT removed: ";
        print join(", ", @not_deleted);
        print "\n";
        print scalar(@not_deleted);
        print " users NOT removed\n";
    }
}
