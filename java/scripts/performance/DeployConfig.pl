#!/usr/bin/perl
#
# This script is used for deploying config files to all systems on a satellite to generate
#    many config deploy actions.  It also deploys the files spread over a year
#
#
use Frontier::Client;
use Data::Dumper;
use CGI;


my $alpha = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";

#EDITABLE options here:
my $HOST = 'rlx-0-06.rhndev.redhat.com';
#my $HOST = 'sat.dev';
my $user = 'admin';
my $pass = 'redhat';
#END editable options


my $client = new Frontier::Client(url => "http://$HOST/rpc/api");
my $session = $client->call('auth.login',$user, $pass);

$systems = $client->call('system.listUserSystems', $session);



$i = 0;
$day = 0;
$month = 0;

while (1) {
foreach  $system (@$systems) {
        print "$i - ";
        $day_temp = ($day%28)+1;
        if( $day_temp < 10 ){
                $day_temp = "0$day_temp";
        }
        $month_temp = ($month%12+1);
        if( $month_temp < 10 ){
                $month_temp = "0$month_temp";
        }


        $date = $client->date_time("2007$month_temp$day_temp"."T16:04:00");
        print "2007$month_temp$day_temp"."T16:04:00\n";
        push(@array, ( $system->{'id'} ));

        $client->call('system.config.deployAll', $session, \@array, $date);
        $i++;
        $day++;
        $month++;

}


}








