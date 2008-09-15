
my($r, @args) = @_;
print "Hi, I've been pulled in by mod_include via Apache::Include<p>\n";
print "I'm cached by Apache::Registry in package `", __PACKAGE__, "'<p>\n";

for (@args) {
    print "$_\n";
}

