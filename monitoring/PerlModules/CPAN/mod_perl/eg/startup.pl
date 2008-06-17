
#example PerlRequire script for mod_perl

#it's recommened that you use Apache::Registry as your default
#handler for the handler stage of a request
#or, implement your handler for this or any stage of a request
#as a PerlModule under the Apache:: namespace
#PerlRequire is here if you choose otherwise...

#To load this file when the server starts -
#can be a full path or relative to ServerRoot
#add this to srm.conf:
#PerlRequire scripts/startup.pl

# make sure we are in a sane environment.
$ENV{MOD_PERL} or die "not running under mod_perl!";

#modify @INC if needed
#use lib qw(/foo/perl/lib);

#load perl modules of your choice here
#this code is interpreted *once* when the server starts
#use CGI ();
#use LWP::UserAgent ();
#use Apache::DBI ();

#you may define Perl*Handler subroutines here too 

1; #return true value





