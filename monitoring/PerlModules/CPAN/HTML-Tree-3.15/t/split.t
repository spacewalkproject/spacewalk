# Testing of the incremental parsing.  Try to split a HTML document at
# every possible position and make sure that the result is the same as
# when parsing everything in one chunk.

# Now we use a shorter document, because we don't have all day on
# this.

$HTML = <<'EOT';

<Title>Tittel
</title>

<H1>Overskrift</H1>

<!-- Comment -->

Text <b>bold</b>
<a href="..." name=foo bar>italic</a>
some &#101;ntities (&aring)
EOT

$| = 1;

$notests = length($HTML);
print "1..$notests\n";


require HTML::TreeBuilder;
$h = new HTML::TreeBuilder;
$h->parse($HTML)->eof;
$html = $h->as_HTML;
$h->delete;

print $html;

# This test tries to parse the when we split it in two.
for $pos (1 .. length($HTML) - 1) {
    $first = substr($HTML, 0, $pos);
    $last  = substr($HTML, $pos);
    die "This is bad" unless $HTML eq ($first . $last);
    eval {
	$h = new HTML::TreeBuilder;
	$h->parse($first);
	$h->parse($last);
	$h->eof;
    };
    if ($@) {
	print "Died when splitting at position $pos:\n";
	$before = 10;
	$before = $pos if $pos < $before;
	print "«", substr($HTML, $pos - $before, $before);
	print "»\n«";
	print substr($HTML, $pos, 10);
	print "»\n";
	print "not ok $pos\n";
	$h->delete;
	next;
    }
    $new_html = $h->as_HTML;
    if ($new_html ne $html) {
	print "\n\nSomething is different when splitting at position $pos:\n";
	$before = 10;
	$before = $pos if $pos < $before;
	print "«", substr($HTML, $pos - $before, $before);
	print "»\n«";
	print substr($HTML, $pos, 10);
	print "»\n";
	print "\n$html$new_html\n";
	print "not ";
    }
    print "ok $pos\n";
    $h->delete;
}

# Also try what happens when we feed the document one-char at a time
print "Parse document once char at a time...\n";
$h = new HTML::TreeBuilder;
while ($HTML =~ /(.)/sg) {
    $h->parse($1);
}
$h->eof;
$new_html = $h->as_HTML;
if ($new_html ne $html) {
   print "Also different when parsed one char at a time\n";
   print "\n$html$new_html\n";
   $BAD = 1;
}

print "not " if $BAD;
print "ok $notests\n";
