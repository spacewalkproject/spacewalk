#!/usr/bin/perl -w

# test_update.pl - test script for Mail::Alias package
#	Version 1.0		19 August 2000		T. Zeltwanger
#
# Note: for this test to succeed, you must have the following aliases in your file:
#	test_alias1		test_alias2

use Mail::Alias;

my ($alias_obj);


$alias_obj = Mail::Alias->new();									# Use default filename
#$alias_obj = Mail::Alias->new("--insert alias filename here --");	# Set the filename


# Define the first alias update - all in one line

	my ($update1) = 'test_alias1: newaddress@testing.net';
	my ($alias) = "test1_alias1";
	
	# Process the update
	if ($alias_obj->update($update1)) {
		print "The FIRST update was completed\n";
		print "the new line is: ";
		print $alias_obj->exists($alias), "\n";
	}
	
	else {
		print "There was an error in the 1st update\n";
		print $alias_obj->error_check, "\n";
	}	


	
# Define the second update - separate alias and address_string	

	my ($update2_alias, $update2_address) = ("tEst_alias2", 'othernewone\@updates.org');


	# Process the 2nd update
	if ($alias_obj->update($update2_alias, $update2_address)) {
		print "The SECOND update was completed\n";
		print "the new line is: ";
		print $alias_obj->exists($update2_alias), "\n";
	}
	
	else {
		print "There was an error in the 2nd update\n";
		print $alias_obj->error_check, "\n";
	}	


	