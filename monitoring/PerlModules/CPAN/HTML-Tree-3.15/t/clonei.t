
# -*-Perl-*-
# Time-stamp: "2000-03-26 20:21:19 MST"

use HTML::TreeBuilder;
print "1..1\n";
{
  use strict;
  my $t = HTML::TreeBuilder->new;
  $t->parse('stuff <em name="foo">lalal</em>');
  $t->eof;
  my $c = $t->clone();
  $c->delete();
  print "not " unless $t->find_by_attribute('name', 'foo');
  print "ok 1\n";
  $t->delete();
}
