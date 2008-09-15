#!/usr/local/bin/perl -w

use  Date::Language;


my $time = time;
my $v;

my @lang = qw(English German Italian);

print "1..", scalar(@lang),"\n";

my $loop = 1;
my $lang;

foreach $lang (@lang)
{
 my $l = Date::Language->new($lang);
 $v = $l->str2time($l->ctime($time));

 print $v == $time ? "ok $loop\n" : "FAIL $loop\n";
 $loop++;
}

