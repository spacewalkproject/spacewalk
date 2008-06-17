#!/usr/bin/perl

use strict;
use NOCpulse::Debug;
use Getopt::Long;


my $junkLog1 = "/tmp/junkLog1";
my @junkLog1;
my $junkLog2 = "/tmp/junkLog2";
my @junkLog2;
my $stdout1  = "/tmp/stdout1";
my @stdout1;

unlink $junkLog1, $junkLog2;

# Algorithm:
#   1) Exec this script with STDOUT redirected to a file, so 
#      we can test the STDOUT debug stream
#   2) Create output streams and write to them
#   3) Check that the output streams contain what was written.



#
# Pick up command line options
#
my @optspec = qw (file:s debug:i internal=i);
my %optctl;
&GetOptions(\%optctl, @optspec);

if ($optctl{'internal'}) {
    print STDERR "Starting internal run\n";
} else {
    print STDERR "Starting external run\n";
    exec("$0 --internal=1 @ARGV > $stdout1");
}





###############################################
# Test a single literal stream within a single 
# debug object, to STDOUT (default)
###############################################
my $debug   = new NOCpulse::Debug;
my $literal = $debug->addstream( CONTEXT => 'literal', LEVEL => 1 );
my $msg = "Literal output to STDOUT (via default) at debug minimum level 1, dprint debug level of 1\n";
$debug->dprint(1, $msg);
push (@stdout1, $msg);

# Try the willprint stuff
if (! $debug->willprint(1)) {
   print STDERR 'willprint(1) failed\n';
}
if ($debug->willprint(10)) {
   print STDERR 'willprint(10) succeeded\n';
}


######################################
# Increase stream minimum debug level
######################################
$literal->level(3);
$msg = "Literal output to STDOUT (via default) at debug minimum level 3, dprint debug level of 4(shouldn't see this)\n";
$debug->dprint(4, $msg);

$literal->linenumbers(1);
$msg = "Literal output (w/line numbers) to STDOUT (via default) at debug minimum level 3, dprint debug level of 3\n";
$debug->dprint(3, $msg);
push (@stdout1, (__LINE__ - 1) . ": $msg");
$literal->suspend;


########################################
# Add a new 'html' stream to the debug 
# object and output to a FH
########################################
open(LOG, "> $junkLog1") or die "Can't open file $junkLog1:$!\n";
my $html = $debug->addstream( FILE => \*LOG, CONTEXT => 'html', LEVEL => 1 );
$msg = "HTML output to file '$junkLog1' (via FH) at level at debug minimum level 1, dprint debug level of 1\n";
$debug->dprint(1, $msg);
push (@junkLog1, "<pre>$msg</pre>\n");
$html->suspend;


###############################################
# Add a new 'html_comment' stream to the debug 
# object,  output to a STDOUT (using FH)
###############################################
my $html_comment = $debug->addstream( FILE => \*STDOUT, 
                                      CONTEXT => 'html_comment', LEVEL => 1 );
$msg = "HTML commented output to FH STDOUT at level at debug minimum level 1, dprint debug level of 1\n";
$debug->dprint(1, $msg);
push (@stdout1, "<!--$msg-->\n");
$html_comment->suspend;
$literal->flush;
$html_comment->close;
$html_comment->flush;


#############################################################
# Add a new 'literal' stream to the debug object, specifying
# a file name.  Also, add line numbers to the output.
#############################################################
$html->resume;
$literal->resume;
my $literal2 = $debug->addstream( FILE => $junkLog2, CONTEXT => 'literal', 
                                  LEVEL => 1, LINENUM => 1, APPEND => 1 );
$msg = "Literal output to file '$junkLog2' , and html stream, at debug minimum level 1, dprint debug level of 1\n";
$debug->dprint(1, $msg);
push (@stdout1, (__LINE__ - 1) . ": $msg");
push (@junkLog1, "<pre>$msg</pre>\n");
push (@junkLog2, (__LINE__ - 3) . ": $msg");

close LOG;

$debug->flush;
$debug->close;



########################################################
# Verify data in log files/STDOUT against buffered data
########################################################

my $failed = 0;
open (J1, "< $junkLog1") or die "Can't open junk log file $junkLog1:$!\n";
my $flines = join '', <J1>;
close J1;
my $dlines = join '', @junkLog1;
if ($flines ne $dlines) {
    print STDERR "Data verifcation ERROR in file $junkLog1\n";
print STDERR length $dlines,"DATA LINE:$dlines...\n";
print STDERR length $flines,"FILE LINE:$flines...\n";
}
else {
    print STDERR "Data verifcation PASSED in file $junkLog1\n";
    unlink $junkLog1;
}
close J1;



#################################
$failed = 0;
open (J2, "< $junkLog2") or die "Can't open junk log file $junkLog2:$!\n";
$flines = join '', <J2>;
close J2;
$dlines = join '', @junkLog2;
if ($flines ne $dlines) {
    print STDERR "Data verifcation ERROR in file $junkLog2\n";
print STDERR length $dlines,"DATA LINE:$dlines...\n";
print STDERR length $flines,"FILE LINE:$flines...\n";
}
else {
    print STDERR "Data verifcation PASSED in file $junkLog2\n";
    unlink $junkLog2;
}
close J2;



#################################
$failed = 0;
open (J3, "< $stdout1")  or die "Can't open junk log file $stdout1:$!\n";
$flines = join '', <J3>;
close J3;
$dlines = join '', @stdout1;
if ($flines ne $dlines) {
    print STDERR "Data verifcation ERROR in file $stdout1\n";
print STDERR length $dlines,"DATA LINE:$dlines...\n";
print STDERR length $flines,"FILE LINE:$flines...\n";
}
else {
    print STDERR "Data verifcation PASSED in file $stdout1\n";
    unlink $stdout1;
}



