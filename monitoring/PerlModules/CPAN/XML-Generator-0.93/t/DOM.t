#!/usr/bin/perl -w
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { 
  print "1..0 # Skipped: XML::DOM not installed\n" unless eval "use XML::DOM; 1";
  exit;
}

BEGIN { $| = 1; print "1..37\n"; }
END {print "not ok 1\n" unless $loaded;}
use XML::Generator::DOM;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

my $x = new XML::Generator::DOM or print "not ";
print "ok 2\n";

my $xml = $x->foo();
$xml->toString eq '<foo/>' or print "not ";
print "ok 3\n";

$xml = $x->bar(42);
$xml->toString eq '<bar>42</bar>' or print "not ";
print "ok 4\n";

$xml = $x->baz({'foo'=>3});
$xml->toString eq '<baz foo="3"/>' or print "not ";
print "ok 5\n";

$xml = $x->bam({'bar'=>42},$x->foo(),"qux");
$xml->toString eq '<bam bar="42"><foo/>qux</bam>' or print "not ";
print "ok 6\n";

$xml = $x->new(3);
$xml->toString eq '<new>3</new>' or print "not ";
print "ok 7\n";

$xml = $x->foo(['baz']);
$xml->toString eq '<baz:foo/>' or print "not ";
print "ok 8\n";

$xml = $x->foo(['baz','bam']);
$xml->toString eq '<baz:bam:foo/>' or print "not ";
print "ok 9\n";

$xml = $x->foo(['baz'],{'bar'=>42},3);
$xml->toString eq '<baz:foo baz:bar="42">3</baz:foo>' or print "not ";
print "ok 10\n";

$xml = $x->foo({'id' => 4}, 3, 5);
$xml->toString eq '<foo id="4">35</foo>' or print "not ";
print "ok 11\n";

$xml = $x->foo({'id' => 4}, 0, 5);
$xml->toString eq '<foo id="4">05</foo>' or print "not ";
print "ok 12\n";

$xml = $x->foo({'id' => 4}, 3, 0);
$xml->toString eq '<foo id="4">30</foo>' or print "not ";
print "ok 13\n";

my $foo_bar = "foo-bar";
$xml = $x->$foo_bar(42);
$xml->toString eq '<foo-bar>42</foo-bar>' or print "not ";
print "ok 14\n";

$x = new XML::Generator::DOM 'namespace' => 'A';

$xml = $x->foo({'bar' => 42}, $x->bar(['B'], {'bar' => 54}));
$xml->toString eq '<A:foo A:bar="42"><B:bar B:bar="54"/></A:foo>' or print "not ";
print "ok 15\n";

$xml = $x->xmldecl();
UNIVERSAL::isa($xml, 'XML::DOM::XMLDecl') or print "not ";
print "ok 16\n";

$xml->getVersion eq '1.0' or print "not ";
print "ok 17\n";

defined $xml->getEncoding and print "not ";
print "ok 18\n";

$xml->getStandalone eq 'yes' or print "not ";
print "ok 19\n";

$xml = $x->xmlcmnt("test");
UNIVERSAL::isa($xml, 'XML::DOM::Comment') or print "not ";
print "ok 20\n";

$xml->getData eq 'test' or print "not ";
print "ok 21\n";

$x = new XML::Generator::DOM
			'version' => '1.1',
			'encoding' => 'iso-8859-2';
$xml = $x->xmldecl();
$xml->getVersion eq '1.1' or print "not ";
print "ok 22\n";

$xml->getEncoding eq 'iso-8859-2' or print "not ";
print "ok 23\n";

$xml = $x->xmlpi("target", 'option="value"');
UNIVERSAL::isa($xml, 'XML::DOM::ProcessingInstruction') or print "not ";
print "ok 24\n";

$xml->getTarget eq 'target' or print "not ";
print "ok 25\n";

$xml->getData eq 'option="value"' or print "not ";
print "ok 26\n";

eval {
  my $t = "42";
  $x->$t();
};
UNIVERSAL::isa($@, 'XML::DOM::DOMException') or print "not ";
print "ok 27\n";

$xml = $x->foo(['bar'], {'baz:foo' => 'qux', 'fob' => 'gux'});
$xml->toString eq '<bar:foo baz:foo="qux" bar:fob="gux"/>' or print "not ";
print "ok 28\n";

$x = new XML::Generator::DOM 'dtd' => [ 'foo', 'SYSTEM', '"http://foo.com/foo"' ];
$xml = $x->xmldecl();
$xml->getStandalone eq 'no' or print "not ";
print "ok 29\n";

$xml = $x->xmlcdata("test");
UNIVERSAL::isa($xml, 'XML::DOM::CDATASection') or print "not ";
print "ok 30\n";

$xml->getData eq 'test' or print "not ";
print "ok 31\n";

$x = new XML::Generator::DOM; 

$xml = $x->foo($x->xmlcdata("bar"), $x->xmlpi("baz", "bam"));
$xml->toString eq '<foo><![CDATA[bar]]><?baz bam?></foo>' or print "not ";
print "ok 32\n";

$xml = $x->foo(42);
$xml = $x->xml($xml);
$xml->toString eq
'<?xml version="1.0" standalone="yes"?>
<foo>42</foo>
' or print "not ";
print "ok 33\n";

eval {
  $xml = $x->bar($xml);
};
$@ && $@->getName eq 'WRONG_DOCUMENT_ERR' or print "not ";
print "ok 34\n";

$xml = $x->foo();
$cmnt = $x->xmlcmnt("comment");
$pi = $x->xmlpi("foo", "bar");
$xml = $x->xml($cmnt, $xml, $pi);
$xml->toString eq '<?xml version="1.0" standalone="yes"?>
<!--comment-->
<foo/>
<?foo bar?>
' or print "not ";
print "ok 35\n";

require XML::DOM;
$doc = XML::DOM::Parser->new->parse('<doc/>');
$x = XML::Generator::DOM->new( dom_document => $doc );
$doc->getFirstChild->appendChild($x->foo(42));
$doc->toString eq
'<doc><foo>42</foo></doc>
' or print "not ";
print "ok 36\n";

eval {
  $xml = $x->xml($x->bar(12));
};
$@ =~ /method not allowed/ or print "not ";
print "ok 37\n";
