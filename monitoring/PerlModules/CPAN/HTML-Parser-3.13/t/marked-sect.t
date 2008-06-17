#!/usr/bin/perl -w

use strict;
my $tag;
my $text;

use HTML::Parser ();
my $p = HTML::Parser->new(start_h => [sub { $tag = shift  }, "tagname"],
	                  text_h  => [sub { $text .= shift }, "dtext"],
                         );

eval {
    $p->marked_sections(1);
};
if ($@) {
    print $@;
    print "1..0\n";
    exit;
}

print "1..10\n";

$p->parse("<![[foo]]>");
print "not " unless $text eq "foo";
print "ok 1\n";

$p->parse("<![TEMP INCLUDE[bar]]>");
print "not " unless $text eq "foobar";
print "ok 2\n";

$p->parse("<![ INCLUDE -- IGNORE -- [foo<![IGNORE[bar]]>]]>\n<br>");
print "not " unless $text eq "foobarfoo\n";
print "ok 3\n";

$text = "";
$p->parse("<![  CDATA   [&lt;foo");
$p->parse("<![IGNORE[bar]]>,bar&gt;]]><br>");
print "not " unless $text eq "&lt;foo<![IGNORE[bar,bar>]]>";
print "ok 4\n";

$text = "";
$p->parse("<![ RCDATA [&aring;<a>]]><![CDATA[&aring;<a>]]>&aring;<a><br>");
print "not " unless $text eq "å<a>&aring;<a>å" && $tag eq "br";
print "ok 5\n";

$text = "";
$p->parse("<![INCLUDE RCDATA CDATA IGNORE [foo&aring;<a>]]><br>");
print "not " unless $text eq "";
print "ok 6\n";

$text = "";
$p->parse("<![INCLUDE RCDATA CDATA [foo&aring;<a>]]><br>");
print "not " unless $text eq "foo&aring;<a>";
print "ok 7\n";

$text = "";
$p->parse("<![INCLUDE RCDATA [foo&aring;<a>]]><br>");
print "not " unless $text eq "fooå<a>";
print "ok 8\n";

$text = "";
$p->parse("<![INCLUDE [foo&aring;<a>]]><br>");
print "not " unless $text eq "fooå";
print "ok 9\n";

$text = "";
$p->parse("<![[foo&aring;<a>]]><br>");
print "not " unless $text eq "fooå";
print "ok 10\n";

