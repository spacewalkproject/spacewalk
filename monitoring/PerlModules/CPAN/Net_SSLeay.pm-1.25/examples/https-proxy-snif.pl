#!/usr/bin/perl
# 5.6.1998, Sampo Kellomaki <sampo@iki.fi>

$usage = <<USAGE
Usage: ./https-proxy-snif.pl *listen_port* *dest_machine* *dest_port*
E.g:   ./https-proxy-snif.pl 4443 www.bacus.pt 443

This proxy allows you to observe the protocol talked by your browser
to remote https server. Useful for debugging http headers etc sent
in this dialogue as well as capturing the requests for later
automating the task.

The proxying is not perfect: the client will see different
certificate than actually sent by server. You will be able to launch
only one simultaneous connection (set you browser to attempt only
one at a time) because it is iterative server, keep-alives are not
handled at all, etc.

Remeber: you must have cert.pem and key.pem in the current working directory.

Example:
    ./https-proxy-snif.pl 4443 www.bacus.pt 443
Then enter https://localhost:4443/ in Netscape Location prompt.
USAGE
    ;

die $usage unless $#ARGV == 2;
($listen_port, $dest_host, $dest_port) = @ARGV;
$trace = 0;

use Socket;
use Net::SSLeay qw(sslcat die_now die_if_ssl_error);
#$Net::SSLeay::trace = 3; # Super verbose debugging
Net::SSLeay::load_error_strings();
Net::SSLeay::SSLeay_add_ssl_algorithms();

$our_ip = "\0\0\0\0";  # Bind to all interfaces
$sockaddr_template = 'S n a4 x8';
$our_serv_params = pack ($sockaddr_template, &AF_INET, $listen_port, $our_ip);

socket (S, &AF_INET, &SOCK_STREAM, 0)  or die "socket: $!";
bind (S, $our_serv_params)             or die "bind:   $!";
listen (S, 5)                          or die "listen: $!";
$ctx = Net::SSLeay::CTX_new ()         or die_now("CTX_new ($ctx): $!");
Net::SSLeay::set_server_cert_and_key($ctx, 'cert.pem', 'key.pem') or die "key";

while (1) {    
    print "Accepting connections...\n";
    ($addr = accept (NS, S))           or die "accept: $!";
    select (NS); $| = 1; select (STDOUT);  # Piping hot!
    
    ($af,$client_port,$client_ip) = unpack($sockaddr_template,$addr);
    @inetaddr = unpack('C4',$client_ip);
    print "$af connection from "
	. join ('.', @inetaddr) . ":$client_port\n";
    
    ### We now have a network connection, lets fire up SSLeay...
 
    $ssl = Net::SSLeay::new($ctx)      or die_now("SSL_new ($ssl): $!");
    #print &Net::SSLeay::get_cipler_list($ssl, 32000);
    &Net::SSLeay::set_fd($ssl, fileno(NS));
    
    $err = Net::SSLeay::accept($ssl);
    die_if_ssl_error("ssl accept: ($!)");
    print "Cipher `" . Net::SSLeay::get_cipher($ssl) . "'\n";
    
    ### Connected. Get the HTTP request and wrap it for transport
    ### to remote host.
    
    $got = Net::SSLeay::read($ssl) or die "$$: ssl read failed";
    print "Got `$got' (" . length ($got) . " chars)\n" if $trace;
    
    $got =~ s/Host:\s+\S+\r?\n/Host: $dest_host:$dest_port\r\n/i;

    print "Will send `$got' (" . length ($got)
	. " chars) to $dest_host:$dest_port\n";
    
    ### Set up a client socket
    
    $dest_port = getservbyname  ($dest_port, 'tcp')
	unless $dest_port =~ /^\d+$/;
    $dest_serv_ip = gethostbyname ($dest_host);
    $dest_serv_params  = pack ($sockaddr_template, &AF_INET,
			       $dest_port, $dest_serv_ip);
    
    socket  (SS, &AF_INET, &SOCK_STREAM, 0) or die "client: socket: $!";
    connect (SS, $dest_serv_params)         or die "client: connect: $!";
    select  (SS); $| = 1; select (STDOUT);

    ### Do SSL handshake with remote server

    $ssl2 = Net::SSLeay::new($ctx) or die_now("client: SSL_new ($ssl2)");
    &Net::SSLeay::set_fd($ssl2, fileno(SS));
    &Net::SSLeay::set_cipher_list($ssl2, "DES-CBC3-MD5:RC4-MD5");
    &Net::SSLeay::print_errs();
    $err = Net::SSLeay::connect($ssl2);
    &Net::SSLeay::print_errs();
    print "client: Cipher '" . Net::SSLeay::get_cipher($ssl2) . "'\n";
    &Net::SSLeay::print_errs();

    ### Exchange data with remote server

    $err = Net::SSLeay::write($ssl2, $got) or die "client: write: $!";
    &Net::SSLeay::print_errs();
	    
    shutdown SS, 1;
	    
    $reply = Net::SSLeay::read($ssl2);
    &Net::SSLeay::print_errs();

    print "Remote replied `$reply' (" . length ($reply) . " chars)\n";
	    
    &Net::SSLeay::free ($ssl2);
    &Net::SSLeay::print_errs();
    close SS;

    ### Reply to our client

    &Net::SSLeay::write ($ssl, $reply) or die "write: $!";
    &Net::SSLeay::print_errs();
    
    (&Net::SSLeay::write ($ssl, <<HTTP) or die "write: $!") if 0;
HTTP/1.0 200 It works. Cool.
Content-Type: text/html

<title>foo</title>
<h1>Bar Cool</h1>
HTTP
    ;
    
    &Net::SSLeay::free ($ssl);           # Tear down connection
    close NS;
}

__END__
