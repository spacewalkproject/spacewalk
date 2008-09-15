#!/usr/bin/perl -w

# append_test.pl - test script for append() in Alias module
#	Version 1.1			30 August 2000		T. Zeltwanger

use Mail::Alias;

my ($alias_obj);

$alias_obj = Mail::Alias->new();		# Use default filename /etc/mail/aliases
#$alias_obj = Alias->new("--insert alias filename here --");	# Set the filename


# Define the test variables
# WARNING: use single quotes or you must Escape addresses (xxx\@yyy.zzz) or PERL will scream

	my ($alias, $address_string, $alias_line);
	$alias = "test_alias1";
	$address_string = 'test1_addr1@one.com, nullaccount@nowhere.zzz';
	$alias_line = "";
	
# append() test

	if ($alias_obj->append($alias, $address_string)) {
		print "SUCCESS: added the following line to $alias_obj->{_filename}\n";
		print "$alias: $address_string\n";
	}
	
	else {
		print "ERROR: unable to add the alias to the file\n";
		print $alias_obj->error_check, "\n";
	}	

