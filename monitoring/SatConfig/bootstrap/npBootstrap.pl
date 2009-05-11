#!/usr/bin/perl

use strict;

use LWP::UserAgent;
use NOCpulse::Config;
use NOCpulse::SatCluster;
use NOCpulse::Gritch;
use URI::Escape;

my $MAX_RETRIES    = 5;
my $RETRY_INTERVAL = 10;

my $config = NOCpulse::Config->new;
my $url = $config->get('satellite','bootstrapUrl');
my $llnsFile = $config->get('netsaint','llnetsaintFile');
my $keyFile  = $config->get('netsaint','satKeyFile');
my $certFile = $config->get('netsaint','satPemCertFile');
my $hashProg = $config->get('netsaint','cHashProgram');
my $soapbox = new NOCpulse::Gritch('/var/lib/nocpulse/npBootstrap.db');


# get the scout_shared_key formt he /etc/rhn/cluster.ini file
my $cluster_config = NOCpulse::Config->new('/etc/rhn/cluster.ini');
my $ssk=$cluster_config->get('', 'scoutsharedkey');

my $gritchMsg;
if (!$ssk) {
    # Send notification that the scout shared key was not found.
    $gritchMsg .= "\nError retrieving RHN Monitoring Scout shared key for this node!\n";
    $soapbox->gritch('RHN Monitoring Scout ERROR', $gritchMsg);
    print "Failed to get scout shared key data for this node.\n";
    exit 1;
}

# Get the satellite public key, if it exists
my $key;
if (-f $keyFile) {
  open(KFILE, "$keyFile");
  $key = join('', <KFILE>);
  close(KFILE);
  $key = uri_escape($key, '^-_a-zA-Z0-9');
}

# Same, for the PEM certificate
my $cert;
my $certHash;
if (-f $certFile) {
    open (CERT, "$certFile");
    $cert = join('', <CERT>);
    close(CERT);
    $cert = uri_escape($cert, '^-_a-zA-Z0-9');
    $certHash = `$hashProg $certFile`;
    $certHash = (split(' ', $certHash))[0];
}

$url .= "?ssk=$ssk";
$url .= "&publickey=$key" if (defined($key));
$url .= "&cert=$cert" if (defined($cert));
$url .= "&certhash=$certHash" if (defined($certHash));

my $ua = new LWP::UserAgent;
$ua->agent("AgentName/0.1 " . $ua->agent);
 
# Create a request
my $req = new HTTP::Request GET => $url;
 
# Pass request to the user agent and get a response back
print "Requesting $url\n";
my($res, @errs);

for (my $i = 1; $i < $MAX_RETRIES; $i++) {
  $res = $ua->request($req);
  if ($res->is_success) {
    last;
  } else {
    printf("Error on attempt %d:  Status: '%s'; content: '%s'\n", 
             $i, $res->status_line, $res->content);
    sleep $RETRY_INTERVAL;
  }
}
 
# Check the outcome of the response
if ($res->is_success) {
   my($isll, $clustid,$satid,$description,$custid,$ip) = split(/:/, $res->content);

   print "Cluster ID is $clustid\n";
   print "Node ID is $satid\n";
   print "Customer ID is $custid\n";
   print "Description is $description\n";
   print "IP is $ip\n";
   my $cluster = NOCpulse::SatCluster->newInitialized($config);
   $cluster->set_id($clustid);
   $cluster->set_nodeId($satid);
   $cluster->set_description($description);
   $cluster->set_customerId($custid);
   $cluster->set_npIP($ip);
   $cluster->persist;
   $gritchMsg .= "Monitoring Scout configuration successful on ". `uname -n`."\n";

   if ($isll) {
     print "Creating LongLegs flag file\n";
     open(FILE, ">$llnsFile");
     close(FILE);
   } else {
     unlink($llnsFile);
   }
   # Send notification that the sat may have been rebooted.
   $soapbox->gritch('RHN Monitoring Scout started', $gritchMsg);

} else {
   # Send notification that the sat may have been rebooted.
   $gritchMsg .= "\nError configuring RHN Monitoring Scout ".`uname -n`."\n";
   $soapbox->gritch('RHN Monitoring Scout ERROR', $gritchMsg);
   print "Failed $MAX_RETRIES times to get data for this node.\n";
   exit 1;
}                                                                      
