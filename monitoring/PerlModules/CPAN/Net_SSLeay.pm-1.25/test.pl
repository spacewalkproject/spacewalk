#!/usr/bin/perl
# 24.6.1998, 8.7.1998, Sampo Kellomaki <sampo@iki.fi>
# 31.7.1999, added more tests --Sampo
# 7.4.2001,  upgraded to OpenSSL-0.9.6a --Sampo
# 25.4.2001, added test for 64 bit pointer cast by aspa --Sampo
# 20.8.2001, moved checking which perl to use higher up. Thanks
#            Gordon Lack <gml4410@ggr.co.uk> --Sampo
# 7.12.2001, added test cases for client certificates and proxy SSL --Sampo
# 28.5.2002, added contributed test cases for callbacks --Sampo
# $Id: test.pl,v 1.1.1.1 2003-08-22 19:31:39 cvs Exp $
#
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

use Config;

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN {print "1..20\n";}
END {print "not ok 1\n" unless $::loaded;}
select(STDOUT); $|=1;
use Net::SSLeay qw(die_now die_if_ssl_error);
$::loaded = 1;
print "ok 1\n";

######################### End of black magic.

my $trace = $ENV{TEST_TRACE} || 1;  # 0=silent, 1=verbose, 2=debugging
#$Net::SSLeay::trace = 3;

my $mb = 1;     # size of the bulk tests
my $errors = 0;
my $silent = $trace>1 ? '' : '>makecert.out 2>makecert.err';
my ($pid,$redir,$res,$bytes,$secs);

sub test {
    my ($num, $test) = @_;
    $errors++ unless $test;
    return $test ? "ok $num\n" : "*** not ok $num\n\n"
}

my $inc = join ' ', map("-I$_", @INC);
#$perl = "perl $inc";
my $perl = "$Config{perlpath} $inc";
print "Using perl at `$perl'\n" if $trace>1;

### Pointer casting test for 64 bit architectures

print "Testing pointer to int casting...\n";
system "$perl ptrtstrun.pl";

&Net::SSLeay::load_error_strings();
&Net::SSLeay::SSLeay_add_ssl_algorithms();
print &test(2, &Net::SSLeay::hello == 1);

my $cert_pem = "examples/cert.pem";
my $key_pem =  "examples/key.pem";

unless (-r $cert_pem && -r $key_pem) {
    print "### Making self signed certificate just for these tests...\n"
	if $trace;
    
    open F, "openssl_path" or die "Can't read `./openssl_path': $!\n";
    $exe_path = <F>;
    close F;
    chomp $exe_path;

    $ENV{RANDFILE} = '.rnd';  # not random, but good enough
    system "$perl examples/makecert.pl examples $exe_path $silent";
    print "    certificate done.\n\n" if $trace;
}

# Test decrypting key here

$res = `$perl examples/passwd-cb.pl $key_pem.e secret`;
print ">>>$res<<<\n" if $trace>1;
print &test(3, $res !~ /failed/ && $res =~ /calls=1/);

$res = `$perl examples/passwd-cb.pl $key_pem.e incorrect`;
print ">>>$res<<<\n" if $trace>1;
print &test(4, $res =~ /failed/ && $res =~ /calls=1/);

unless ($pid = fork) {
    print "\tSpawning a TCP test server on port 1211, pid=$$...\n" if $trace;
    $redir = $trace<3 ? '>>tcpecho.log 2>&1' : '';
    exec("$perl examples/tcpecho.pl 1211 $redir");
}
sleep 1;  # if server is slow

$res = `$perl examples/tcpcat.pl 127.0.0.1 1211 ssleay-tcp-test`;
print $res if $trace>1;
print &test('5tcp', ($res =~ /SSLEAY-TCP-TEST/));

unless ($pid = fork) {
    print "\tSpawning a SSL test server on port 1212, pid=$$...\n" if $trace;
    $redir = $trace<3 ? '>>sslecho.log 2>&1' : '';
    exec("$perl examples/sslecho.pl 1212 $cert_pem $key_pem $redir");
}
sleep 1;  # if server is slow

$res = `$perl examples/sslcat.pl 127.0.0.1 1212 ssleay-test`;
print $res if $trace>1;
print &test(5, ($res =~ /SSLEAY-TEST/));

$res = `$perl examples/minicli.pl 127.0.0.1 1212 another`;
print $res if $trace>1;
print &test(6, ($res =~ /ANOTHER/));

$res = `$perl examples/callback.pl 127.0.0.1 1212 examples`;
print $res if $trace>1;
print &test(7, ($res =~ /OK\s*$/));

$res = `$perl examples/bio.pl`;
print $res if $trace>1;
print &test(8, ($res =~ /OK\s*$/));

$res = `$perl examples/ephemeral.pl`;
print $res if $trace>1;
print &test(9, ($res =~ /OK\s*$/));

$bytes = $mb * 1024 * 1024;
print "\tSending $mb MB over localhost, may take a while (and some VM)...\n"
    if $trace;
$secs = time;
$res = `$perl examples/bulk.pl 127.0.0.1 1212 $bytes`;
print $res if $trace>1;
$secs = (time - $secs) || 1;
print "\t\t...took $secs secs (" . int($mb*1024/$secs). " KB/s)\n" if $trace;
print &test(10, ($res =~ /OK\s*$/));

kill $pid;  # We don't need that server any more

if ($exe_path !~ /\.exe$/i) {  # Not Windows where fork does not work
    $res = `$perl examples/cli-cert.pl $cert_pem $key_pem examples`;
    print $res if $trace>1;
    print &test(11, ($res =~ /client cert: Subject Name: \/C=XX/));

    print "\tSending $mb MB over pipes, may take a while (and some VM)...\n"
	if $trace;
    $secs = time;
    $res = `$perl examples/stdio_bulk.pl $cert_pem $key_pem $bytes`;
    print $res if $trace>1;
    $secs = (time - $secs) || 1;
    print "\t\t...took $secs secs (".int($mb*1024/$secs)." KB/s)\n" if $trace;
    print &test(12, ($res =~ /OK\s*$/));
} else {
    print "skipped on Windows 11\n";
    print "skipped on Windows 12\n";
}

sub provide_password {
    return '1234';
}

### Check that the default password callback works

$ctx=Net::SSLeay::CTX_new();
Net::SSLeay::CTX_set_default_passwd_cb($ctx,\&provide_password);
$r=Net::SSLeay::CTX_use_PrivateKey_file($ctx,"examples/server_key.pem",
					&Net::SSLeay::FILETYPE_PEM());
print &test(13, $r);

#app.iplanet.com
my @sites = qw(
www.cdw.com
banking.wellsfargo.com
secure.worldgaming.net
www.ubs.com
	    );
#www.engelschall.com
#www.openssl.org

if ($trace) {
print "    Now about to contact external sites...\n\twww.bacus.pt\n";
print map "\t$_\n", @sites;
print "    You have 5 seconds of time to hit Ctrl-C if you do not like this.\n";
print "    So far there were no errors in tests.\n" unless $errors;
print "*** $errors tests failed already.\n" if $errors;
print "    Following tests _will_ fail if you do not have network\n"
    . "    connectivity (or if the servers are down or have changed).\n";
sleep 5;
}

$ENV{RND_SEED} = '1234567890123456789012345678901234567890';
print &test('14 www.bacus.pt',
	    &Net::SSLeay::sslcat("www.bacus.pt", 443,
				 "get\n\r\n\r") =~ /<TITLE>/);

sub test_site ($$) {
    my ($test_nro, $site) = @_;
    my ($p, $r) = ('','');
    my %h;
    warn "Trying $site...\n";
    $Net::SSLeay::trace=0;
    $Net::SSLeay::version=0;
    
    ($p, $r, %h) = Net::SSLeay::get_https($site, 443, '/');
    if (!defined($h{SERVER})) {
	print &test("$test_nro $site ($r)", scalar($r =~ /^HTTP\/1/s));
	print "\t$site, initial attempt with auto negotiate failed\n";

	$Net::SSLeay::trace=3;
	$Net::SSLeay::version=2;
	print "\tset version to 2\n";
	($p, $r, %h) = Net::SSLeay::get_https($site, 443, '/');
	
	$Net::SSLeay::version=3;
	print "\tset version to 3\n";
	($p, $r, %h) = Net::SSLeay::get_https($site, 443, '/');
	$Net::SSLeay::trace=0;
    }
    
    print join '', map("\t$_=>$h{$_}\n", sort keys %h) if $trace>1;

    if (defined($h{SERVER})) {
	print &test("$test_nro $site ($h{SERVER})", scalar($r =~ /^HTTP\/1/s));
    } else {
	print &test("$test_nro $site ($r)", scalar($r =~ /^HTTP\/1/s));
    }
}

my $i = 15;
my $s;
for $s (@sites) {
    &test_site($i++, $s );
}

die "*** WARNING: There were $errors errors in the tests.\n" if $errors;
print "All tests completed OK.\n" if $trace;
__END__
