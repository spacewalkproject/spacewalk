#!/usr/local/bin/perl -w
# callback.pl - 8.6.1998, Sampo Kellomaki <sampo@iki.fi>
# 31.7.1999, fixed callback args, --Sampo 
# 7.4.2001,  adapted to 0.9.6a and numerous bug reports --Sampo
#
# Test and demonstrate verify call back
#
# WARNING! Although this code works, it is by no means stable. Expect
# that this stuff may break with newer than 0.9.3a --Sampo

use Socket;
use Net::SSLeay qw(die_now die_if_ssl_error);
$ENV{RND_SEED} = '1234567890123456789012345678901234567890';
Net::SSLeay::randomize();
Net::SSLeay::load_error_strings();
Net::SSLeay::ERR_load_crypto_strings();
Net::SSLeay::SSLeay_add_ssl_algorithms();

($dest_serv, $port, $cert_dir) = @ARGV;      # Read command line

my $callback_called = 0;

$ctx = Net::SSLeay::CTX_new() or die_now("Failed to create SSL_CTX $!");
#Net::SSLeay::CTX_set_default_verify_paths($ctx);
Net::SSLeay::CTX_load_verify_locations($ctx, '', $cert_dir)
    or die_now("CTX load verify loc=`$cert_dir' $!");
Net::SSLeay::CTX_set_verify($ctx, &Net::SSLeay::VERIFY_PEER, \&verify2);
die_if_ssl_error('callback: ctx set verify');

$port = getservbyname  ($port, 'tcp')   unless $port =~ /^\d+$/;
$dest_ip = gethostbyname ($dest_serv);

$dest_serv_params  = pack ('S n a4 x8', &AF_INET, $port, $dest_ip);
socket  (S, &AF_INET, &SOCK_STREAM, 0)  or die "socket: $!";
connect (S, $dest_serv_params)          or die "connect: $!";
select  (S); $| = 1; select (STDOUT);

# The network connection is now open, lets fire up SSL

$ssl = Net::SSLeay::new($ctx) or die_now("Failed to create SSL $!");
#Net::SSLeay::set_verify ($ssl, &Net::SSLeay::VERIFY_PEER, \&verify);
Net::SSLeay::set_fd($ssl, fileno(S));
print "callback: starting ssl connect...\n";
Net::SSLeay::connect($ssl);
die_if_ssl_error('callback: ssl connect');

print "Cipher `" . Net::SSLeay::get_cipher($ssl) . "'\n";
print Net::SSLeay::dump_peer_certificate($ssl);

Net::SSLeay::ssl_write_all($ssl,"\tcallback ok\n");
shutdown S, 1;
my $ra;
print defined($ra = Net::SSLeay::ssl_read_all($ssl)) ? $ra : '';

Net::SSLeay::free ($ssl);
Net::SSLeay::CTX_free ($ctx);
close S;

print $callback_called ? "OK\n" : "ERROR\n";
exit;

sub verify2 {
    my ($ok, $x509_store_ctx) = @_;
    print "**** Verify 2 called ($ok)\n";
    my $x = Net::SSLeay::X509_STORE_CTX_get_current_cert($x509_store_ctx);
    if ($x) {
	print "Certificate:\n";
	    print "  Subject Name: "
		. Net::SSLeay::X509_NAME_oneline(
	            Net::SSLeay::X509_get_subject_name($x))
		    . "\n";
	    print "  Issuer Name:  "
		. Net::SSLeay::X509_NAME_oneline(
	            Net::SSLeay::X509_get_issuer_name($x))
		    . "\n";
    }
    $callback_called++;
    return 1;
}

sub verify {
    my ($ok, $x509_store_ctx) = @_;

    print "**** Verify called ($ok)\n";
    my $x = Net::SSLeay::X509_STORE_CTX_get_current_cert($x509_store_ctx);
    if ($x) {
	print "Certificate:\n";
	    print "  Subject Name: "
		. Net::SSLeay::X509_NAME_oneline(
	            Net::SSLeay::X509_get_subject_name($x))
		    . "\n";
	    print "  Issuer Name:  "
		. Net::SSLeay::X509_NAME_oneline(
	            Net::SSLeay::X509_get_issuer_name($x))
		    . "\n";
    }
    $callback_called++;
    return 1; #$ok; # 1=accept cert, 0=reject
}

__END__
