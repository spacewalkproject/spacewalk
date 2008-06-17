#!/usr/bin/perl -w

# expand_test.pl - test script for Mail::Alias expand() method

use Mail::Alias;

my ($alias_obj);

$alias_obj = Mail::Alias::Sendmail->new("/etc/mail/aliases");		

print "\nEnter an alias to be expanded: ";
$alias = <>;
chomp ($alias);

if ($alias) {
	@namelist = $alias_obj->expand($alias);

}

print "@namelist\n";
