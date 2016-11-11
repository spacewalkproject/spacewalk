#!/usr/bin/perl

use warnings;

use English;
use Getopt::Long;
use Frontier::Client;
use IO::File;

my $sat_host = 'rlx-3-10.devel.redhat.com';
my $user = 'admin';
my $password = 'spacewalk';
my $alias = 'rlx310';
my $debug = '0';

my $usage = <<EOF;
Usage: $PROGRAM_NAME --sat-host HOSTNAME --user USERNAME --password PASSWORD
EOF

GetOptions("sat-host:s" => \$sat_host,
               "user:s" => \$user,
           "password:s" => \$password,
           "alias:s"    => \$alias,
           "debug:s"    => \$debug) or die $usage;

if ($alias eq "perl") {
    $host = 'http://transam.devel.redhat.com/rpc/api';
}
elsif ($alias eq "dev") {
    $host = 'http://transam.devel.redhat.com/rhn/rpc/api';
}
elsif ($alias eq "prod") {
    $host = 'http://xmlrpc.rhn.redhat.com/rpc/api';
}
elsif ($alias eq "webdev") {
    $host = 'http://xmlrpc.rhn.webdev.redhat.com/rpc/api';
}
elsif ($alias eq "fjs002") {
    $host = 'http://fjs-0-02.rhndev.redhat.com/rpc/api';
}
elsif ($alias eq "rlx310") {
    $host = 'http://rlx-3-10.rhndev.redhat.com/rpc/api';
}


die $usage unless ($alias and $sat_host and $user and $password);

print "------------------------------------------------------------------------------\n";
print "Connecting to $host.  debug = $debug\n";
print "------------------------------------------------------------------------------\n";

# connect to host
my $conn = new Frontier::Client(url => $host, debug => $debug);

test_api_system_version($conn);

## auth
my $session = login($conn, $user, $password);

run_channel_tests($conn, $session);
run_channel_software_tests($conn, $session);
run_errata_tests($conn, $session);
run_package_tests($conn, $session);
run_user_subscribable_tests($conn, $session);
run_user_tests($conn, $session);
#run_proxy_tests($conn, $session);
#run_satellite_tests($conn, $session);
## logout
logout($conn, $session);

exit 0;

sub logtest {
    $msg = shift;
    print "Running $msg ...\n";
}

sub log_debug {
    $msg = shift;
    if ($debug) {
        print $msg;
    }
}

sub test_api_system_version {
    my $conn = shift;
    my $api_ver = $conn->call('api.system_version');

    log_debug("System version: $api_ver\n");

    assertEquals("4.1.0", $api_ver);
}

sub login {
   my $conn = shift;
   my $user = shift;
   my $password = shift;

   my $session = $conn->call('auth.login', $user, $password);

   log_debug("Session: $session\n");

   return $session;
}

sub logout {
    my $conn = shift;
    my $session = shift;
    $conn->call('auth.logout', $session);
}

sub assertEquals {
   my $expectation = shift;
   my $actual = shift;

   if ($expectation ne $actual) {
      warn "[" . $expectation . "] not equal to [" . $actual . "]";
   }
}

sub run_package_tests {
    my $conn = shift;
    my $session = shift;

    logtest('packages.get_details');
    my $pid = '4283';

    my $pkgDetails = $conn->call('packages.get_details', $session, $pid);

    assertEquals(55353, $pkgDetails->{'package_size'});
    assertEquals('i386', $pkgDetails->{'package_arch_label'});
    assertEquals('Red Hat, Inc.', $pkgDetails->{'package_vendor'});
    assertEquals('GPL', $pkgDetails->{'package_license'});
    assertEquals("Theme engines for GTK+ 2.0\n", $pkgDetails->{'package_summary'});
    assertEquals('a69bda3ee0e1d92b08532246255e9cc2', $pkgDetails->{'package_md5sum'});
    assertEquals('2004-11-05', $pkgDetails->{'package_last_modified_date'});
    assertEquals('gtk2-engines-2.2.0-2.i386.rpm', $pkgDetails->{'package_file'});
    assertEquals('2.2.0', $pkgDetails->{'package_version'});
    assertEquals('2', $pkgDetails->{'package_release'});
    assertEquals('porky.devel.redhat.com', $pkgDetails->{'package_build_host'});
    assertEquals('gtk2-engines', $pkgDetails->{'package_name'});
    assertEquals('ragnarok.devel.redhat.com 1043272740',
                 $pkgDetails->{'package_cookie'});
    if ($debug) {
        foreach my $key (keys %{$pkgDetails}){
            print "$key = " . $pkgDetails->{$key} . "\n";
        }
    }

    #logtest('packages.list_changelog');
    #my $chglog = $conn->call('packages.list_changelog', $session, $pid);
    #print $chglog . "\n";
    #if ($debug) {
    #    foreach my $item (@{$chglog}) {
    #        foreach my $key (keys %{$item}) {
    #            print "$key = " . $item->{$key} . "\n";
    #        }
    #    }
    #}
}

sub run_proxy_tests {
    my $conn = shift;
    my $session = shift;

    logtest('proxy.deactivate_proxy');
    my @system_id;
    open(FH, "< systemid") || die ("Could not open file!");
    @system_id = <FH>;
    close(FH);
    my $str = join("", @system_id);

    logtest('proxy.deactivate_proxy');
    my $rc = $conn->call('proxy.deactivate_proxy', $str);
    print "Returned $rc";
    logtest('proxy.activate_proxy');
    $rc = $conn->call('proxy.activate_proxy', $str, '3.7');
    print "Returned $rc";
}

sub run_satellite_tests {
    my $conn = shift;
    my $session = shift;

    my @system_id;
    open(FH, "< systemid") || die ("Could not open file!");
    @system_id = <FH>;
    close(FH);
    my $str = join("", @system_id);

    open(FH, "< sat-cert") || die ("Could not open file!");
    @sat_cert = <FH>;
    close(FH);
    my $str_cert = join("", @sat_cert);
    #my $rc = $conn->call('satellite.activate_satellite', $str, $str_cert);
    my $rc = $conn->call('satellite.deactivate_satellite', $str, $str_cert);
    print "Returned $rc";
}

sub assertChannel {
    my $label = shift;
    my $expArch = shift;
    my $actArch = shift;

    assertEquals($expArch, $actArch);
}

sub run_channel_software_tests {
    my $conn = shift;
    my $session = shift;
    my $rc;

    logtest('channel.software.list_arches');
    $rc = $conn->call('channel.software.list_arches', $session);
    foreach my $item (@{$rc}) {
        foreach my $key (keys %{$item}) {
                if ($debug) {
                    print "$key = " . $item->{$key} . "\n";
                }

                my $value = $item->{$key};

                if ($key eq 'channel-alpha') {
                    assertEquals('Alpha', $value);
                }
                elsif ($key eq 'channel-s390') {
                    assertEquals('s390', $value);
                }
                elsif ($key eq 'channel-pSeries') {
                    assertEquals('pSeries', $value);
                }
                elsif ($key eq 'channel-ia32') {
                    assertEquals('IA-32', $value);
                }
                elsif ($key eq 'channel-iSeries') {
                    assertEquals('iSeries', $value);
                }
                elsif ($key eq 'channel-ia64') {
                    assertEquals('IA-64', $value);
                }
                elsif ($key eq 'channel-s390x') {
                    assertEquals('s390x', $value);
                }
                elsif ($key eq 'channel-sparc') {
                    assertEquals('Sparc', $value);
                }
                elsif ($key eq 'channel-ppc') {
                    assertEquals('PPC', $value);
                }
                elsif ($key eq 'channel-x86_64') {
                    assertEquals('x86_64', $value);
                }
        }
    }

    #
    # Let's create a channel
    #
    eval {
        # see if the channel's there, if it is delete it.
        $rc = $conn->call('channel.software.get_details', $session, 'jesusr-api-test-label');
        $rc = $conn->call('channel.software.delete', $session, 'jesusr-api-test-label');
        assertEquals(1, $rc);
    };
    #my $e = $@;
    #if ($e) {
    #}
    logtest('channel.software.create');
    $rc = $conn->call('channel.software.create', $session, 'jesusr-api-test-label-1', 'Jesusr API Test Channel.1', 'summary', 'channel-x86_64', '');
    assertEquals(1, $rc);

    #logtest('channel.software.delete');
    #$rc = $conn->call('channel.software.delete', $session, 'jesusr-api-test-label');
    logtest('channel.software.is_globally_subscribable');
    $rc = $conn->call('channel.software.is_globally_subscribable', $session, 'rhel-i386-as-4');
    assertEquals(1, $rc);

    logtest('channel.software.get_details');
    #$rc = $conn->call('channel.software.get_details', $session, 'rhel-i386-as-4');
    eval {
        $rc = $conn->call('channel.software.get_details', $session, 'jesusr-api-test-label');
    };
    my $e = $@;
    if ($e) {
    }
    #assertEquals(1, $rc);

    logtest('channel.software.available_entitlements');
    $rc = $conn->call('channel.software.available_entitlements', $session, 'rhel-i386-as-4');
    if ($rc < 1) {
        warn '$rc is < 1';
    }

    #logtest('channel.software.create');
    #$rc = $conn->call('channel.software.create', $session, 'jesusr-api-test-label10', 'Jesusr API Test Channel', 'summary', 'channel-x86_64', '');
    #assertEquals(1, $rc);

    logtest('channel.software.list_latest_packages for rhel-i386-as-4');
    $rc = $conn->call('channel.software.list_latest_packages', $session, 'rhel-i386-as-4');
    foreach my $item (@{$rc}) {
        foreach my $key (keys %{$item}) {
           if ('package_name' eq $key) {
               my $name = $item->{$key};
               if ('redhat-release' eq $name) {
                   log_debug("release: " . $item->{'package_release'});
                   log_debug("epoch: " . $item->{'package_epoch'});
                   log_debug("arch_label: " . $item->{'package_arch_label'});
                   assertEquals('4AS', $item->{'package_version'});
                   assertEquals('3', $item->{'package_release'});
                   assertEquals('i386', $item->{'package_arch_label'});
               }
           }
        }
    }

    if (@$rc < 1) {
        warn "array is empty";
    }

    logtest('channel.software.list_all_packages for rhel-i386-as-4 after 2001-01-01 00:00:00');
    $rc = $conn->call('channel.software.list_all_packages', $session, 'rhel-i386-as-4', '2001-01-01 00:00:00');
    if (@$rc < 1) {
        warn "array is empty";
    }

    logtest('channel.software.list_all_packages for rhel-i386-as-4 between 2001-01-01 00:00:00 and 2001-02-01 00:00:00');
    $rc = $conn->call('channel.software.list_all_packages', $session, 'rhel-i386-as-4', '2001-01-01 00:00:00', '2001-02-01 00:00:00');
    if (@$rc < 1) {
        warn "array is empty";
    }

    logtest('channel.software.list_all_packages for rhel-i386-as-4');
    $rc = $conn->call('channel.software.list_all_packages', $session, 'rhel-i386-as-4');
    if (@$rc < 1) {
        warn "array is empty";
    }

    logtest('channel.software.list_all_packages_by_date for rhel-i386-as-4 after 2001-01-01 00:00:00');
    $rc = $conn->call('channel.software.list_all_packages_by_date', $session, 'rhel-i386-as-4', '2001-01-01 00:00:00');
    if (@$rc < 1) {
        warn "array is empty";
    }

    logtest('channel.software.list_all_packages_by_date for rhel-i386-as-4 between 2001-01-01 00:00:00 2001-02-01 00:00:00');
    $rc = $conn->call('channel.software.list_all_packages_by_date', $session, 'rhel-i386-as-4', '2001-01-01 00:00:00', '2001-02-01 00:00:00');
    if (@$rc < 1) {
        warn "array is empty";
    }

    logtest('channel.software.list_all_packages_by_date for rhel-i386-as-4');
    $rc = $conn->call('channel.software.list_all_packages_by_date', $session, 'rhel-i386-as-4');
    if (@$rc < 1) {
        warn "array is empty";
    }

    logtest('channel.software.list_errata for rhel-i386-as-4');
    $rc = $conn->call('channel.software.list_errata', $session, 'rhel-i386-as-4');
    if (@$rc < 1) {
        warn "array is empty";
    }

    logtest('channel.software.list_subscribed_systems for rhel-i386-as-4');
    $rc = $conn->call('channel.software.list_subscribed_systems', $session, 'rhel-i386-as-4');
    if (@$rc < 1) {
        warn "array is empty";
    }

    $rc = $conn->call('channel.software.delete', $session, 'jesusr-api-test-label');
    assertEquals(1, $rc);
}

sub run_user_subscribable_tests {
    my $conn = shift;
    my $session = shift;
    my $username = 'rhn_api_test_user';
    my $rc = $conn->call(
        "channel.software.is_user_subscribable", $session, 'rhel-i386-as-4', $username);

    assertEquals(0, $rc);
}

sub run_channel_tests {
    my $conn = shift;
    my $session = shift;

    logtest("channel.list_software_channels");
    my $rc = $conn->call('channel.list_software_channels', $session);
    foreach my $item (@{$rc}) {
        foreach my $key (keys %{$item}) {
            if ('rhel-i386-as-4' eq $item->{'channel_label'}) {
                assertEquals(
                    'Red Hat Enterprise Linux AS (v. 4 for 32-bit x86)',
                    $item->{'channel_name'});
                assertEquals('IA-32',
                    $item->{'channel_arch'});
                assertEquals('',
                    $item->{'channel_parent_label'});
                assertEquals('',
                    $item->{'channel_end_of_life'});
            }

            if ($debug) {
                print "$key = " . $item->{$key} . "\n";
            }
        }
    }
}


sub run_errata_tests {
    my $conn = shift;
    my $session = shift;

    #my $advisoryName = 'RHSA-2005:092';
    my $advisoryName ='TEST-2006:314';
    logtest("errata.get_details");
    my $errataDetails = $conn->call('errata.get_details', $session, $advisoryName);
    if ($debug) {
        foreach my $key (keys %{$errataDetails}){
            print "$key = ";
            print $errataDetails->{$key};
            print "\n";
        }
    }

    assertEquals("Test synopsis", $errataDetails->{'errata_synopsis'});
    assertEquals("Test Description", $errataDetails->{'errata_description'});
    assertEquals("Test Topic", $errataDetails->{'errata_topic'});
    assertEquals("2006-04-12", $errataDetails->{'errata_issue_date'});
    assertEquals("2006-04-12", $errataDetails->{'errata_update_date'});
    assertEquals("Bug Fix Advisory", $errataDetails->{'errata_type'});

    logtest("errata.list_affected_systems");
    my $affectedSystems = $conn->call(
        'errata.list_affected_systems', $session, $advisoryName);
    if ($debug) {
        foreach my $system (@{$affectedSystems}) {
            foreach my $key (keys %{$system}) {
                print "$key = " . $system->{$key} . "\n";
            }
        }
    }

    logtest("errata.bugzilla_fixes");
    my $bugzillas = $conn->call('errata.bugzilla_fixes', $session, $advisoryName);
    if ($debug) {
        foreach my $key (keys %{$bugzillas}) {
            print "$key = " . $bugzillas->{$key} . "\n";
        }
    }

    logtest("errata.list_keywords");
    my $keywords = $conn->call('errata.list_keywords', $session, $advisoryName);
    assertEquals('test keyword', @{$keywords});
    if ($debug) {
        foreach my $keyword (@{$keywords}) {
            print "Keyword: $keyword\n";
        }
    }

    logtest("errata.applicable_to_channels");
    my $channels = $conn->call('errata.applicable_to_channels', $session, $advisoryName);
    if ($debug) {
        foreach my $channel (@{$channels}) {
            foreach my $key (keys %{$channel}) {
                print "$key = " . $channel->{$key} . "\n";
            }
        }
    }

    logtest("errata.list_cves");
    my $cves = $conn->call('errata.list_cves', $session, $advisoryName);
    foreach my $cve (@{$cves}) {
        print "CVE: $cve\n";
    }

    logtest("errata.list_packages");
    my $packages = $conn->call('errata.list_packages', $session, $advisoryName);

    if ($debug) {
        foreach my $pkg (@{$packages}) {
            print "### Package ###\n";
            foreach my $key (keys %{$pkg}) {
                print "$key = " . $pkg->{$key} . "\n";
                if ($key eq 'providing_channels') {
                    my $channels = $pkg->{$key};
                    foreach my $channel (@{$channels}) {
                        print "Channel: $channel\n";
                    }
                }
            }
        }
    }
}

sub run_user_tests {
    my $conn = shift;
    my $session = shift;

    ## user
    print "***User module tests***\n";
    my $userlist = $conn->call('user.list_users', $session);
    print "Number of users: " . scalar(@{$userlist}) . "\n";
    #foreach my $u (@{$userlist}) {
    #    print "$u\n";
    #    for $key (keys %{$u}) {
    #        print "KEY: $key :: ";
    #        print "$u->{$key}\n";
    #    }
    #}

    my $targetuser = 'zbeeblebrox';
    my $roles = $conn->call('user.list_roles', $session, $targetuser);
    print "Number of roles for $targetuser: " . scalar(@{$roles}) . "\n";
    foreach my $role (@{$roles}) {
        print "Role: $role\n";
    }

    my $details = $conn->call('user.get_details', $session, $targetuser);
    foreach my $key (keys %{$details}){
        print "$key = ";
        print $details->{$key} .  "\n";
    }

    my $newDetails = { first_names => 'Zaphod-edited2',
                       last_name   => 'Beeblebrox-ed2',
                       email       => 'zbeeblebrox-edited@redhat.com'};

    my $setDetailsResult = $conn->call('user.set_details', $session, $targetuser, $newDetails);
    print "setDetailsResult: $setDetailsResult\n";

    my $addRoleResult = $conn->call('user.add_role', $session, $targetuser, 'org_admin');
    print "result: $addRoleResult\n";
    $roles = $conn->call('user.list_roles', $session, $targetuser);
    print "Number of roles for $targetuser: " . scalar(@{$roles}) . "\n";
    foreach my $role (@{$roles}) {
        print "Role: $role\n";
    }


    my $removeRoleResult = $conn->call('user.remove_role', $session, $targetuser, 'org_admin');
    print "result: $removeRoleResult\n";
    $roles = $conn->call('user.list_roles', $session, $targetuser);
    print "Number of roles for $targetuser: " . scalar(@{$roles}) . "\n";
    foreach my $role (@{$roles}) {
        print "Role: $role\n";
    }


    my $pamResult = $conn->call('user.use_pam_authentication', $session, $user, 1);
    print "pamResult: $pamResult\n";
    # set back...
    $pamResult = $conn->call('user.use_pam_authentication', $session, $user,0);
    print "pamResult: $pamResult\n";

    #Create a new user
    $newuname = 'at-java-004';
    $newpass =  'password';
    $newfname = 'Ted';
    $newlname = 'Nugent';
    $newemail = 'tnugent@redhat.com';

    my $createResult = $conn->call('user.create', $session, $newuname, $newpass,
                               $newfname, $newlname, $newemail);
    print "Create User result: $createResult\n";


    my $disableResult = $conn->call('user.disable', $session, $newuname);
    print "Disable User result: $disableResult\n";

    my $enableResult = $conn->call('user.enable', $session, $newuname);
    print "Enable User result: $enableResult\n";

    my $deleteResult = $conn->call('user.delete', $session, $newuname);
    print "Delete User result: $deleteResult\n";
}
