#!/usr/local/bin/perl -w
# bulk.pl - 8.6.1998, Sampo Kellomaki <sampo@iki.fi>
# Send tons of stuff over SSL (just for testing).
# There's also an example about using the call back.

use Socket;
use Net::SSLeay qw(die_now die_if_ssl_error);
$ENV{RND_SEED} = '1234567890123456789012345678901234567890';
Net::SSLeay::randomize();
Net::SSLeay::load_error_strings();
Net::SSLeay::ERR_load_crypto_strings();
Net::SSLeay::SSLeay_add_ssl_algorithms();

($dest_serv, $port, $how_much) = @ARGV;      # Read command line
$port = getservbyname  ($port, 'tcp')   unless $port =~ /^\d+$/;
$dest_ip = gethostbyname ($dest_serv);

$dest_serv_params  = sockaddr_in($port, $dest_ip);
socket  (S, &AF_INET, &SOCK_STREAM, 0)  or die "socket: $!";
connect (S, $dest_serv_params)          or die "connect: $!";
select  (S); $| = 1; select (STDOUT);

# The network connection is now open, lets fire up SSL    

$ctx = Net::SSLeay::CTX_new() or die_now("Failed to create SSL_CTX $!");
$ssl = Net::SSLeay::new($ctx) or die_now("Failed to create SSL $!");
Net::SSLeay::set_fd($ssl, fileno(S));   # Must use fileno
Net::SSLeay::connect($ssl);
die_if_ssl_error('bulk: ssl connect');
print "Cipher `" . Net::SSLeay::get_cipher($ssl) . "'\n";

$cert = Net::SSLeay::get_peer_certificate($ssl);
die_if_ssl_error('get_peer_certificate');
print "Subject Name: "
    . Net::SSLeay::X509_NAME_oneline(
	            Net::SSLeay::X509_get_subject_name($cert)) . "\n";
print "Issuer Name:  "
    . Net::SSLeay::X509_NAME_oneline(
	            Net::SSLeay::X509_get_issuer_name($cert)) . "\n";

# Exchange data

$data = 'A' x $how_much;
Net::SSLeay::ssl_write_all($ssl, \$data) or die "ssl write failed";
shutdown S, 1;  # Half close --> No more output, sends EOF to server
$got = Net::SSLeay::ssl_read_all($ssl) or die "ssl read failed";

Net::SSLeay::free ($ssl);               # Tear down connection
Net::SSLeay::CTX_free ($ctx);
close S;

print $data eq $got ? "OK\n" : "ERROR\n";
exit;

__END__
