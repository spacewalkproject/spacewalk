
#test internal redirects

my %loc = (
   internal => "/test.html",
   remote   => "http://perl.apache.org/",
   content  => "/content.html",
);

my $ix = $ENV{QUERY_STRING} || "internal";

print "Content-type: text/plain\n";
print "Location: $loc{$ix}\n\n";

print "shouldn't see this";

