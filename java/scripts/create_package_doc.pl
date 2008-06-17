#!/usr/bin/perl

use Getopt::Long;
use IO::File;

my $usage = <<EOS;
Usage: $0 [--package package [--relative]] --comment comment
EOS

my ($package, $help, $comment);
my $prepack = "com.redhat.rhn.";
my $packfile = "package.html";
my $comment = '';

##############################################################################
# Handle the options
##############################################################################
GetOptions("package=s" => \$package,
           "help" => \$help,
           "relative" => \$relative,
           "comment=s" => \$comment) or die $usage;
die $usage unless $comment;


if ($relative) {
    $package = $prepack . $package;
}

if ($package) {
    $package =~ s/\./\//g;
    $packfile = $package . "/" . $packfile;
}

##############################################################################
# The package.html contents
##############################################################################

my $content = <<EOD;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
<html>
<head>
<!--

  @(#)package.html

  Copyright 2005-2006 Red Hat, Inc.
  All Rights Reserved.

  This software is the confidential and proprietary information of
  Red Hat, Inc. ("Confidential Information").  You shall not
  disclose such Confidential Information and shall use it only in
  accordance with the terms of the license agreement you entered into
  with Red Hat.

  CopyrightVersion 0.1


-->
</head>
<body bgcolor="white">

<!--
##### THIS IS THE TEMPLATE FOR THE PACKAGE DOC COMMENTS. #####
##### TYPE YOUR PACKAGE COMMENTS HERE.  BEGIN WITH A     #####
##### ONE-SENTENCE SUMMARY STARTING WITH A VERB LIKE:    #####
-->
$comment<p>
<!--
<h2>Package Specification</h2>

##### FILL IN ANY SPECS NEEDED BY JAVA COMPATIBILITY KIT #####
<ul>
  <li><a href="">##### REFER TO ANY FRAMEMAKER SPECIFICATION HERE #####</a>
</ul>

<h2>Related Documentation</h2>

For overviews, tutorials, examples, guides, and tool documentation, please see:
<ul>
  <li><a href="">##### REFER TO NON-SPEC DOCUMENTATION HERE #####</a>
</ul>
-->
<!-- Put @see and @since tags down here. -->

</body>
</html>
EOD

##############################################################################
# WRITE FILE: Ok let's write out the package.html file
##############################################################################


$fh = new IO::File;
if ($fh->open("> $packfile")) {
   print "Writing out $packfile\n";
   print $fh $content;
   $fh->close;
}
else {
    print "Could not open file: $packfile\n";
}
