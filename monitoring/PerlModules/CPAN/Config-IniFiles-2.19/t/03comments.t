use strict;
use Test;
use Config::IniFiles;

BEGIN { plan tests => 11 }

my $ors = $\ || "\n";
my ($ini, $value);

#
# Comment preservation, -default and -nocase tests added by JW/WADG
#

# test 1

$value = 0;
if( open FILE, "<t/test.ini" ) {
	$_ = join( '', <FILE> );
	$value = /\# This is a section comment[$ors]\[test1\]/;
	close FILE;
}
# print "Section comments preserved ....... ";
ok($value);


# test 2
$value = /\# This is a parm comment[$ors]five=value5/;
# print "Parameter comments preserved ..... ";
ok($value);


# test 3 
$ini = new Config::IniFiles( -file => "t/test.ini", -default => 'test1', -nocase => 1 );
# print "-default option .................. ";
ok( (defined $ini) && ($ini->val('test2', 'three') eq 'value3') );


# test 4
# Case insensitivity in parameters
ok( (defined $ini) && ($ini->val('test2', 'FOUR') eq 'value4') );

# test 5
# Case insensitivity in sections
ok( (defined $ini) && ($ini->val('TEST2', 'four') eq 'value4') );

$ini = new Config::IniFiles ( -file => "t/test.ini" );
$ini->setval("foo","bar","qux");

# test 6
# print "Setting Section Comment........... ";
ok($ini->SetSectionComment("foo", "This is a section comment", "This comment takes two lines!"));

# test 7
# print "Getting Section Comment........... ";
my @comment = $ini->GetSectionComment("foo");
ok( join("", @comment) eq "# This is a section comment# This comment takes two lines!");

#test 8
# print "Deleting Section Comment.......... ";
$ini->DeleteSectionComment("foo");
# Should not exist!
ok(not defined $ini->GetSectionComment("foo"));

# test 9
# print "Setting Parameter Comment......... ";
ok($ini->SetParameterComment("foo", "bar", "This is a parameter comment", "This comment takes two lines!"));

# test 10
# print "Getting Parameter Comment......... ";
@comment = $ini->GetParameterComment("foo", "bar");
ok(join("", @comment) eq "# This is a parameter comment# This comment takes two lines!");

# test 11
# print "Deleting Parameter Comment........ ";
$ini->DeleteParameterComment("foo", "bar");
# Should not exist!
ok(not defined $ini->GetSectionComment("foo", "bar"));

