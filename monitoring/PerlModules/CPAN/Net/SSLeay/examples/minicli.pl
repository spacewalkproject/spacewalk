#!/usr/local/bin/perl
# minicli.pl - Sampo Kellomaki <sampo@iki.fi>

use Socket;
use Net::SSLeay;
Net::SSLeay::load_error_strings();
Net::SSLeay::SSLeay_add_ssl_algorithms();
Net::SSLeay::randomize();

($dest_serv, $port, $msg) = @ARGV;      # Read command line
$port = getservbyname  ($port, 'tcp')   unless $port =~ /^\d+$/;
$dest_ip = gethostbyname ($dest_serv);
$dest_serv_params = sockaddr_in($port, $dest_ip);

socket  (S, &AF_INET, &SOCK_STREAM, 0)  or die "socket: $!";
connect (S, $dest_serv_params)          or die "connect: $!";
select  (S); $| = 1; select (STDOUT);

# The network connection is now open, lets fire up SSL    

$ctx = Net::SSLeay::CTX_new() or die_now("Failed to create SSL_CTX $!");
$ssl = Net::SSLeay::new($ctx) or die_now("Failed to create SSL $!");
Net::SSLeay::set_fd($ssl, fileno(S));   # Must use fileno
$res = Net::SSLeay::connect($ssl);
print "Cipher '" . Net::SSLeay::get_cipher($ssl) . "'\n";

# Exchange data

$res = Net::SSLeay::write($ssl, $msg);  # Perl knows how long $msg is
shutdown S, 1;  # Half close --> No more output, sends EOF to server
$got = Net::SSLeay::read($ssl);         # Perl returns undef on failure
print $got;

Net::SSLeay::free ($ssl);               # Tear down connection
Net::SSLeay::CTX_free ($ctx);
close S;

__END__
