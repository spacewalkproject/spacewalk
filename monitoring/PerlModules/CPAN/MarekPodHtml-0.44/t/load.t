# Testing of Pod::HTML
# Author: Marek Rouchal <marekr@cpan.org>

$| = 1;

use Test;

BEGIN { plan tests => 1 }

# load the module
eval "use Marek::Pod::HTML qw(pod2html)";
if($@) {
  ok(0);
  print "$@\n";
} else {
  ok(1);
}

__END__

require Cwd;
my $THISDIR = Cwd::cwd();

print "*** searching $THISDIR/lib\n";
my %pods = pod_find("$THISDIR/lib");
my $result = join(',', sort values %pods);
print "*** found $result\n";
my $compare = join(',', qw(
    Pod::Checker
    Pod::Find
    Pod::InputObjects
    Pod::ParseUtils
    Pod::Parser
    Pod::PlainText
    Pod::Select
    Pod::Usage
));
ok($result,$compare);

