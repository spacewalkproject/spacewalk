#!perl -w
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl t/compatibility.t'

use IO::Socket::SSL;
eval {require "t/ssl_settings.req";} ||
eval {require "ssl_settings.req";};

$|=1;

foreach ($^O) {
    if (/MacOS/ or /VOS/ or /vmesa/ or /riscos/ or /amigaos/) {
	print "1..0 # Skipped: fork not implemented on this platform\n";
	exit;
    }
}

$SIG{'CHLD'} = "IGNORE";

print "1..9\n";
IO::Socket::SSL::context_init(SSL_verify_mode => 0x01, SSL_version => 'TLSv1' );


unless (fork) {
    sleep 1;
    $MyClass::client = new IO::Socket::INET("$SSL_SERVER_ADDR:$SSL_SERVER_PORT");
    package MyClass;
    use IO::Socket::SSL;
    @ISA = "IO::Socket::SSL";
    MyClass->start_SSL($client) || print "not ";
    print "ok\n";
    (ref($client) eq "MyClass") || print "not ";
    print "ok\n";
    $client->issuer_name || print "not ";
    print "ok\n";
    $client->subject_name || print "not ";
    print "ok\n";
    $client->opened || print "not ";
    print "ok\n";
    print $client "Ok to close\n";
    close $client;
    exit(0);
}

my $server = new IO::Socket::INET(LocalPort => $SSL_SERVER_PORT,
	                          LocalAddr => $SSL_SERVER_ADDR,
				  Listen => 1,
				  Proto => 'tcp', ReuseAddr => 1, Timeout => 15);

if (!$server) {
    print "Bail out! ";
    print("Setup of test IO::Socket::INET client and server failed.  All the rest of ",
	  "the tests in this suite will fail also unless you change the values in ",
	  "ssl_settings.req in the t/ directory.");
    exit;
}

print "ok\n";

my $contact = $server->accept;

IO::Socket::SSL::socketToSSL($contact, 
			     {SSL_server => 1, 
			      SSL_verify_mode => 0}) || print "not ";
print "ok\n";
<$contact>;
close $contact;
close $server;

bless $contact, "MyClass";
print "not " if IO::Socket::SSL::socket_to_SSL($contact, SSL_server => 1);
print "ok\n";

print "not " unless (ref($contact) eq "MyClass");
print "ok\n";

sub bail {
	print "Bail Out! $IO::Socket::SSL::ERROR";
}
