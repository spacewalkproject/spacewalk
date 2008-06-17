#!/usr/bin/perl

use strict;
use URI::URL;
use CGI;


my $SELF     = $0; $SELF =~ s,.*/,,;
my $HOST     = $ENV{'HTTP_HOST'}   || '<HTTP_PATH>';
my $PATH     = $ENV{'REQUEST_URI'} || "/$SELF";
my $MYURL    = "http://$HOST$PATH";
my $UL_DIR   = '/var/tmp';
my $ul_fname = "upload.$$";
chomp(my $hostname = `hostname -s`);


my $usage = qq{
  Usage:  
    lwp-request -m POST '$MYURL?name=FNAME' < DATAFILE
  Where:
    FNAME    is the name of the uploaded file
    DATAFILE is the pathname of the file to upload
\n};


# Fetch the filename out of the query string.  (Be sure to
# sanitize the filename for security.)
my $cgi = CGI->new($ENV{'QUERY_STRING'});
my $fname = $cgi->param('name')  || $cgi->param('filename') ||
            $cgi->param('fname') || $cgi->param('file') ||
            $ul_fname;
$fname =~ s/[^-\w#%=+:.,]+/_/g;



open(FILE, ">$UL_DIR/$fname") or die "Couldn't create $UL_DIR/$fname: $!";
while (<STDIN>) {
  print FILE $_;
}
close(FILE);

print "Content-type: text/html\n\n";

if ($. or $fname ne $ul_fname) {

  # We got some data
  print "Uploaded to ${hostname}:$UL_DIR/$fname\n";

} else {

  # We got bupkis -- show the usage
  print "No data uploaded!\n", $usage, "\n\n";

}

