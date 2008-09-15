#!/usr/local/bin/perl5_latest -w

# Copyright (c) 2000                            RIPE NCC
#
# All Rights Reserved
#
# Permission to use, copy, modify, and distribute this software and its
# documentation for any purpose and without fee is hereby granted,
# provided that the above copyright notice appear in all copies and that
# both that copyright notice and this permission notice appear in
# supporting documentation, and that the name of the author not be
# used in advertising or publicity pertaining to distribution of the
# software without specific, written prior permission.
#
# THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING
# ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS; IN NO EVENT SHALL
# AUTHOR BE LIABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY
# DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN
# AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

#------------------------------------------------------------------------------
# Module Header
# Filename          : ipcount.pl
# Purpose           : IP addresses calculator
# Author            : Manuel Valente <manuel@ripe.net>
# Date              : 20000329
# Description       : 
# Language Version  : Perl 5
# OSs Tested        : BSDI 3.1
# Command Line      :
# Input Files       :
# Output Files      :
# External Programs : Net::IP.pm
# Problems          :
# To Do             :
# Comments          : 
# $Id: ipcount.pl,v 1.1.1.1 2001-03-06 22:01:26 kboomsli Exp $
#------------------------------------------------------------------------------

use Net::IP qw(:PROC);
use strict;

scalar (@ARGV) < 1 and usage();

my $arg = join '',@ARGV;
$arg =~ s/\s+//g;

my $flag = 0;

my ($ip);

if ($arg =~ m!^(.+?)\+(.+)$!) 
{
	my $addnum = $2;

	$ip = new Net::IP($1) or die ("Cannot create IP object $1: ".Error());
	
	$addnum = ip_inttobin ($addnum, $ip->version()) or die (Error());
		
	my $end_bin = ip_binadd ($ip->binip(),$addnum) or die (Error());
	
	my $end = ip_bintoip ($end_bin,$ip->version()) or die (Error());
		
	print ($ip->ip().'-'.$end,$ip->version()."\n");
	
	$ip->set($ip->ip().'-'.$end,$ip->version()) or die($ip->error());
}
else
{
	$ip = new Net::IP($arg) or die ("Cannot create IP object $arg: ".Error());
};


my @list = $ip->find_prefixes() or die ($ip->error());

my ($addr,@pr,$tot);

foreach (@list) 
{
	$addr = new Net::IP ($_) or die ("Cannot create IP object $_: ".Error());
		
	printf ("%18s    %15s - %-15s [%s]\n",$addr->prefix(),$addr->ip(),$addr->last_ip(), $addr->size());
	
	$tot += $addr->size();
	push (@pr,'/'.$addr->prefixlen());	
};

if (scalar(@list) > 1) 
{
 	print "\n";
 	printf ("%18s    %15s - %-15s [%s]\n",$ip->ip().(join ',',@pr),$ip->ip(),$ip->last_ip(),$tot);
};


# Print usage and die
sub usage()
{
	print "Usage: 
ipcount IP + size
ipcount IP1 - IP2
ipcount IP/len
";
	
	exit (1);
};

