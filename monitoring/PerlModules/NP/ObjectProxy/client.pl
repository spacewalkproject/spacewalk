#!/usr/bin/perl

use Data::Dumper;
use IO::Socket;
use NOCpulse::Debug;
use Sys::Hostname;
use Fcntl;
use ObjectProxyPeer;
use ObjectProxyMessage;

my $server = 'davepc.nocpulse.net';
my $port   = 5490;

my $debug = new NOCpulse::Debug();
$debug->addstream(CONTEXT => 'literal',
                  LEVEL   => 9);


# Establish a connection to the server
my $server = new IO::Socket::INET(PeerAddr  => $server,
				  PeerPort  => $port,
				  Proto     => 'tcp')
   or die "Couldn't connect to server: $!";


# Set up the OPP object
my $opp = new ObjectProxyPeer(Connection => $server,
                              Debug      => $debug);


my $msg = new ObjectProxyMessage(Opcode => 'ECHO',
				 Data   => 'Sent at ' . scalar(localtime()),
				 Debug  => $debug);
$opp->send($msg);

my $response = $opp->get_response();
print "Response:  ", &Dumper($response), "\n";

