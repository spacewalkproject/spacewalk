#!/usr/bin/perl

use strict;

use LWP::UserAgent;
use HTTP::Request;
use CGI;

my $class = shift;
if( not defined $class ) {
    print STDERR "\nUsage: $0 <handler_class_name>\n\n";
    exit(1);
}

my $cgi = CGI->new();

my $request = HTTP::Request->new('POST', 'handler://'.$class);
$request->content($cgi->query_string());

my $ua = LWP::UserAgent->new();
my $response = $ua->request($request);

my $success = $response->is_success;
my $status_line = $response->status_line();
my $content = $response->content();

print "success = $success\n";
print "status_line = $status_line\n";
print "content = $content\n";
