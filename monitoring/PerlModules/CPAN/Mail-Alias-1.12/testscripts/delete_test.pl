#!/usr/bin/perl -w

# test_delete_alias.pl - test script for Mail::Alias package

use Mail::Alias;

my ($alias_obj);

$alias_obj = Mail::Alias->new();									# Use default filename
#$alias_obj = Mail::Alias->new("--insert alias filename here --");	# Set the filename


# Define the list of aliases to be deleted

	my (@alias_list) = ("test_alias1", "failed", "test_alias2");
	
	
# delete_alias() test

	if ($alias_obj->delete(@alias_list)) {
	}
	
	else {
		print "ERROR: unable to delete the alias from the file\n";
		print $alias_obj->error_check, "\n";
	}	

	
