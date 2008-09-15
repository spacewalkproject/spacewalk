#!perl -w
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl t/core.t'

use Net::SSLeay;
use IO::Socket::SSL;
eval {require "t/ssl_settings.req";} ||
eval {require "ssl_settings.req";};

$GUARANTEED_TO_HAVE_NONBLOCKING_SOCKETS = eval "use 5.006; return 1";
$NET_SSLEAY_VERSION = $Net::SSLeay::VERSION;
$OPENSSL_VERSION = 0;
$OPENSSL_VERSION = &Net::SSLeay::OPENSSL_VERSION_NUMBER if ($NET_SSLEAY_VERSION>=1.19);
$CAN_PEEK = ($OPENSSL_VERSION >= 0x0090601f) ? 1 : 0;

$numtests = 29;
$|=1;

foreach ($^O) {
    if (/MacOS/ or /VOS/ or /vmesa/ or /riscos/ or /amigaos/) {
	print "1..0 # Skipped: fork not implemented on this platform\n";
	exit;
    }
}

if ($GUARANTEED_TO_HAVE_NONBLOCKING_SOCKETS) {
    $numtests++;
}

if ($NET_SSLEAY_VERSION>=1.16) {
    $numtests+=4;
}

#We can only test SSL_peek if OpenSSL is v0.9.6a or better
if ($CAN_PEEK) {
    $numtests+=3;
}

print "1..$numtests\n";

$test = 0;

unless (fork) {
    sleep 1;
    %extra_options = ($Net::SSLeay::VERSION>=1.16) ?
        (SSL_key_file => "certs/server-key.enc", SSL_passwd_cb => sub { return "bluebell" },
	 SSL_verify_callback => \&verify_sub) :
        (SSL_key_file => "certs/server-key.pem");


    my $client = new IO::Socket::INET(PeerAddr => $SSL_SERVER_ADDR,
				      PeerPort => $SSL_SERVER_PORT);

    print $client "Test\n";
    (<$client> eq "This server is SSL only") || print "not ";
    &ok("client");
    close $client;

    $client = new IO::Socket::SSL(PeerAddr => $SSL_SERVER_ADDR,
				  PeerPort => $SSL_SERVER_PORT,
				  SSL_verify_mode => 0x01,
				  SSL_ca_file => "certs/test-ca.pem",
				  SSL_use_cert => 1,
				  SSL_cert_file => "certs/server-cert.pem",
				  SSL_version => 'TLSv1',
				  SSL_cipher_list => 'HIGH',
				  %extra_options);
    
    
    sub verify_sub {
	my ($ok, $ctx_store, $cert, $error) = @_;
	unless ($ok && $ctx_store && $cert && !$error) 
	{ print("not ok #client failure\n") && exit; }
	($cert =~ /Dummy IO::Socket::SSL/) || print "not";
	&ok("client");
	return 1;
    }


    $client || (print("not ok #client failure\n") && exit);
    &ok("client");

    $client->fileno() || print "not ";
    &ok("client");

#    $client->untaint() if ($HAVE_SCALAR_UTIL);  # In the future...

    $client->dump_peer_certificate() || print "not ";
    &ok("client");

    $client->peer_certificate("issuer") || print "not ";
    &ok("client");

    $client->get_cipher() || print "not ";
    &ok("client");

    $client->syswrite('00waaaanf00', 7, 2);

    if ($CAN_PEEK) {
	my $buffer;
	$client->read($buffer,2);
	print "not " if ($buffer ne 'ok');
	&ok("client");
    }

    $client->print("Test\n");
    $client->printf("\$%.2f\n%d\n%c\n%s", 1.0444442342, 4.0, ord("y"), "Test\nBeaver\nBeaver\n");
    shutdown($client, 1);

    my $buffer="\0\0aaaaaaaaaaaaaaaaaaaa";
    $client->sysread($buffer, 7, 2);
    print "not " if ($buffer ne "\0\0waaaanf");
    &ok("client");


## The future...
#    if ($HAVE_SCALAR_UTIL) {
#	print "not " if (is_tainted($buffer));
#	&ok("client");
#    }

    my @array = $client->getline();
    print "not "  if (@array != 1 or $array[0] ne "Test\n");
    &ok("client");

    print "not " if ($client->getc ne "\$");
    &ok("client");

    @array = $client->getlines;
    print "not " if (@array != 6);
    &ok("client");

    print "not " if ($array[0] != "1.04\n");
    &ok("client");

    print "not " if ($array[1] ne "4\n");
    &ok("client");

    print "not " if ($array[2] ne "y\n");
    &ok("client");

    print "not " if (join("", @array[3..5]) ne "Test\nBeaver\nBeaver\n");
    &ok("client");

    $client->close(SSL_no_shutdown => 1);

    my $client_2 = new IO::Socket::SSL(PeerAddr => $SSL_SERVER_ADDR,
				       PeerPort => $SSL_SERVER_PORT,
				       SSL_reuse_ctx => $client,
				       SSL_cipher_list => 'HIGH');
    print "not " if (!$client_2);
    &ok("client");
    $buffer = <$client_2>;

    $client_2->close(SSL_ctx_free => 1);
    exit(0);
}


%extra_options = ($Net::SSLeay::VERSION>=1.16) ?
    (SSL_key_file => "certs/client-key.enc", SSL_passwd_cb => sub { return "opossum" }) :
    (SSL_key_file => "certs/client-key.pem");


my $server = new IO::Socket::SSL(LocalPort => $SSL_SERVER_PORT,
				 LocalAddr => $SSL_SERVER_ADDR,
				 Listen => 2,
				 Proto => 'tcp',
				 Timeout => 30,
				 ReuseAddr => 1,
				 SSL_verify_mode => 0x00,
				 SSL_ca_file => "certs/test-ca.pem",
				 SSL_use_cert => 1,
				 SSL_cert_file => "certs/client-cert.pem",
				 SSL_version => 'TLSv1',
				 SSL_cipher_list => 'HIGH',
				 SSL_error_trap => \&error_trap,
				 %extra_options);

if (!$server) {
    print "not ok $test\n";
    exit;
}
&ok("server");

print "not " if (!defined fileno($server));
&ok("server");

my $client = $server->accept;

sub error_trap {
    my $self = shift;
    print $self "This server is SSL only";
    $error_trapped = 1;
    $self->kill_socket;
}

$error_trapped or print "not ";
&ok("server");

if ($client && $client->opened) {
    print "not ok # client stayed alive!\n";
    exit;
}
&ok("server");

$client = $server->accept;

if (!$client) {
    print "not ok # no client\n";
    exit;
}
&ok("server");


fileno($client) || print "not ";
&ok("server");

my $buffer;

if ($CAN_PEEK) {
    $client->peek($buffer, 7, 2);
    print "not " if ($buffer ne "\0\0waaaanf");
    &ok("server");

    print "not " if ($client->pending() != 7);
    &ok("server");

    print $client "ok";
}





sysread($client, $buffer, 7, 2);
print "not " if ($buffer ne "\0\0waaaanf");
&ok("server");


my @array = scalar <$client>;
print "not "  if ($array[0] ne "Test\n");
&ok("server");


print "not " if (getc($client) ne "\$");
&ok("server");


@array = <$client>;
print "not " if (@array != 6);
&ok("server");

print "not " if ($array[0] != "1.04\n");
&ok("server");

print "not " if ($array[1] ne "4\n");
&ok("server");

print "not " if ($array[2] ne "y\n");
&ok("server");

print "not " if (join("", @array[3..5]) ne "Test\nBeaver\nBeaver\n");
&ok("server");

syswrite($client, '00waaaanf00', 7, 2);
print($client "Test\n");
printf $client "\$%.2f\n%d\n%c\n%s", (1.0444442342, 4.0, ord("y"), "Test\nBeaver\nBeaver\n");

close $client;

$client = $server->accept || &bail;

if ($GUARANTEED_TO_HAVE_NONBLOCKING_SOCKETS) {
    $client->blocking(0);
    $client->read($buffer, 20, 0);
    print "not " if ($client->errstr() !~ /wants a read/);
    &ok("server");
}
print $client "Boojums\n";

close($client);

$server->close(SSL_ctx_free => 1);
wait;

sub ok {
    print "ok #$_[0] ", ++$test, "\n"; 
}

sub bail {
	print "Bail Out! $IO::Socket::SSL::ERROR";
}

## The future....
#sub is_tainted {
#    my $arg = shift;
#    my $nada = substr($arg, 0, 0);
#    local $@;
#    eval {eval "# $nada"};
#    return length($@);
#}
