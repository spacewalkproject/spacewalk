use strict;
use HTML::Parser;

print "1..3\n";

my $text = "";
sub text
{
    my $cdata = shift() ? "CDATA" : "TEXT";
    my($offset, $t) = @_;
    $text .= "[$cdata:$offset:$t]";
}

sub tag
{
    $text .= shift;
}

my $p = HTML::Parser->new(unbroken_text => 1,
			  text_h =>  [\&text, "is_cdata,offset,text"],
			  start_h => [\&tag, "text"],
			  end_h   => [\&tag, "text"],
			 );

$p->parse("foo ");
$p->parse("bar ");
$p->parse("<foo>");
$p->parse("bar\n");
$p->parse("</foo>");
$p->parse("<xmp>xmp</xmp>");
$p->parse("atend");

print "not " unless $text eq "[TEXT:0:foo bar ]<foo>[TEXT:13:bar\n]</foo><xmp>[CDATA:28:xmp]</xmp>";
print "ok 1\n";
$text = "";

$p->eof;
print "not " unless $text eq "[TEXT:37:atend]";
print "ok 2\n";


$p = HTML::Parser->new(unbroken_text => 1,
		       text_h => [\&text, "is_cdata,offset,text"],
		      );

$text = "";
$p->parse("foo");
$p->parse("<foo");
$p->parse(">bar\n");
$p->parse("foo<xm");
$p->parse("p>xmp");
$p->parse("</xmp");
$p->parse(">bar");
$p->eof;

print "not " unless $text eq "[TEXT:0:foo][TEXT:8:bar\nfoo][CDATA:20:xmp][TEXT:29:bar]";
print "ok 3\n";


