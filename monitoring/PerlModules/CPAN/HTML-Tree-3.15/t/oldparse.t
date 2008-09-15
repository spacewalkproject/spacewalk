print "1..1\n";

use HTML::Parse;

# This is a very simple test.  It basically just ensures that the
# HTML::Parse module is parsed ok by perl.

$HTML = <<'EOT';

<Title>Test page
</title>

<h1>Header</h1>

This is a link to
<a href="http://www.sn.no/">Schibsted</a> <b>Nett</b> in Norway.

<p>Sofie Amundsen var på vei hjem fra skolen.  Det første stykket
hadde hun gått sammen med Jorunn.  De hadde snakket om roboter.
Jorunn hadde ment at menneskets hjerne var som en komplisert
datamaskin.  Sofie var ikke helt sikker på om hun var enig.  Et
menneske m&aring;tte da være noe mer enn en maskin?


<!-- This is

a <strong>comment</strong>

<!--

-->  <-- this one did not terminate the comment
         because "--" on the previous line

more comment

-->

<p>
<table>
<tr><th colspan=2>Name
<tr><td>Aas<td>Gisle
<tr><td>Koster<td>Martijn
</table>

EOT


$h = parse_html $HTML;

# This ensures that the output from $h->dump goes to STDOUT
open(STDERR, '>&STDOUT');  # Redirect STDERR to STDOUT
print STDERR "\n";
$h->dump;

$html = $h->as_HTML;

# This is a very simple test just to ensure that we get something
# sensible back.
print "not " unless $html =~ /<BODY>/i && $html =~ /www\.sn\.no/
	         && $html !~ /comment/ && $html =~ /Gisle/;

print "ok 1\n\n";

$h->delete;


exit;
