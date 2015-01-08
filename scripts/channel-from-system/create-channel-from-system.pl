#!/usr/bin/perl
#  @author Justin Sherrill jsherril@redhat.com
#use strict;
use Frontier::Client;
use Data::Dumper;
use CGI;



#EDITABLE options here:
my $HOST = 'satellite.yourdomain.com';
my $user = 'admin';
my $pass = 'redhat';
#END editable options



my $new_channel_arch;

if( @ARGV < 3 ){


        print <<EOF;
This script takes the output of
         /bin/rpm -qa --qf \"%{NAME}-%{VERSION}-%{RELEASE}-%{ARCH}\\n\"
and creates a channel out of the packages installed on that system.

Before running this script, you will need the output of the above command redirected to a file.  I recommend running:

 /bin/rpm -qa --qf \"%{NAME}-%{VERSION}-%{RELEASE}-%{ARCH}\\n\" > system1.txt

And then using the resulting "system1.txt" file in conjuntion with this script.



Syntax:    ./create-channel.pl  filename old_channel new_channel
        filename - the output of the above rpm command
        old_channel - the channel label of channel you wish to pull packages from (i.e. rhel-i386-as-4 )
        new_channel - the new channel label that wish to create (i.e. copy-rhel-i386-as-4 )

Questions, concerns, comments?  ->  jsherril\@redhat.com

This script is not supported or warrented in any way by Red Hat Inc.
EOF
        exit(0);
}


my $new_channel_label = $ARGV[2];
my $base_channel_label = $ARGV[1];

my $fileList = $ARGV[0];


my $q           = new CGI;
my $MYURL       = $q->url();

my $client = new Frontier::Client(url => "https://$HOST/rpc/api");
my $session = $client->call('auth.login',$user, $pass);



#find the channel's id
my $new_channel_id = -1;
my $base_channel_id = -1;


my $channels = $client->call('channel.listSoftwareChannels', $session);
foreach my $channel (@$channels) {

 if( $channel->{'channel_label'} eq $base_channel_label ){
        $base_channel_id = $channel->{'channel_id'};
        $new_channel_arch = $channel->{'channel_arch'};
        print "Found old channel: $base_channel_label\n";
 }
 if( $channel->{'channel_label'} eq $new_channel_label ){
        $new_channel_id = $channel->{'channel_id'};
        print "Found new channel - reusing existing channel\n";
 }

}





#attempt to create new channel if it doesn't exist.
if( $new_channel_id == -1){

        $client->call('channel.software.create', $session,$new_channel_label, $new_channel_label, $new_channel_label, getArchLabel( $new_channel_arch ),'' );
        print("New channel created");
}



#get all the packages from the base channel
my $all_packages = $client->call('channel.software.listAllPackages', $session, $base_channel_label);





#@needed_packages = `/bin/rpm -qa --qf "%{NAME}-%{VERSION}-%{RELEASE}-%{ARCH}\n" | sort`;
@needed_packages = `cat $fileList | sort`;
foreach $line (@needed_packages) {
        @elements = split /-/, $line;
        $arch = pop @elements;
        chomp($arch);
        $subver = pop @elements;
        $ver = pop @elements;
        $name = join ("-", @elements);
        chomp($line);
        print "Attempting to add $line:\n";
#       /TODO write a much better package search function (hashes or teeter-totter?)
        foreach $package (@$all_packages){

                if ( 1 == &matches( $name, $package->{'package_name'}, $ver, $package->{'package_version'}, $subver, $package->{'package_release'}, $arch, $package->{'package_arch_label'} ) ){
                        print "\tMatch found, adding.\n";
                        $client->call('channel.software.addPackages', $session, $new_channel_label, $package->{'package_id'});
                        last;
                }
        }


}

print("\n\nChannel $new_channel_label created succesfully!\n");
exit(0);


sub matches{
  #print "test: $_[0]  $_[1], $_[2]  $_[3] , $_[4]  $_[5], $_[6]  $_[7]\n";
  if( $_[0] ne $_[1] ){
        return 0;
  }
  if( $_[2] ne $_[3] ){
        return 0;
  }
  if( $_[4] ne $_[5] ){
        return 0;
  }
  if( $_[6] ne $_[7] ){
        return 0;
  }
  return 1;
}

# converts an achname to an archlabel.
sub getArchLabel(){

        $old_arch = $_[0];

        my $arches = $client->call('channel.software.listArches', $session);
        foreach my $arch (@$arches) {
                if( $arch->{'arch_name'} eq $old_arch) {
                        return $arch->{'arch_label'};
                }
        }

}
