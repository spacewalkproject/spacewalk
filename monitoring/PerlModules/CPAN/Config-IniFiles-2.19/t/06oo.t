use strict;
use Test;
use Config::IniFiles;

BEGIN { plan tests => 9 }

my ($en, $ini, $success);

# test 1
# print "Empty list when no groups ........ ";
$en = new Config::IniFiles( -file => 't/en.ini' );
ok( scalar($en->Groups) == 0 );

# test 2
# print "Creating new object, no file ..... ";
ok($ini = new Config::IniFiles);

# test 3
# print "Setting new file name .............";
ok($ini->SetFileName("t/newfile.ini"));

# test 4
# print "Saving under new file name ........";
if ($ini->RewriteConfig()) {
	if ( -f "t/newfile.ini" ) {
		$success = 1;
	} else {
		$success = 0;
	}
} else {
	$success = 0;
}
ok($success);

# test 5
# print "SetSectionComment .................";
$ini->newval("Section1", "Parameter1", "Value1");
my @section_comment = ("Line 1 of section comment.", "Line 2 of section comment", "Line 3 of section comment");
ok($ini->SetSectionComment("Section1", @section_comment));

# test 6
# print "GetSectionComment .................";
my @comment;
if (@comment = $ini->GetSectionComment("Section1")) {
	if ((join "\n", @comment) eq ("# Line 1 of section comment.\n# Line 2 of section comment\n# Line 3 of section comment")) {
		$success = 1;
	} else {
		$success = 0;
	}
} else {
	$success = 0;
}
ok($success);

# test 7
# print "DeleteSectionComment ..............";
$ini->DeleteSectionComment("Section1");
ok(not defined $ini->GetSectionComment("Section1"));

# test 8
# DeleteSection
$ini->DeleteSection( 'Section1' );
ok( not $ini->Parameters( 'Section1' ) );

# test 9
# Delete entire config
$ini->Delete();
ok( not $ini->Sections() );

