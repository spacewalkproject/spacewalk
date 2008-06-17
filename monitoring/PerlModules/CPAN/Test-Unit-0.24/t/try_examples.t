#!/usr/bin/perl -w

use strict;

use lib 't/tlib', 'tlib';

# using the standard built-in 'Test' module (assume nothing)
use strict;
use Test;

warn("\nThe STDERR redirection may not work or may behave differently under\n".
     "your OS. This will probably cause this test to fail.\n")
    if $^O =~ /Win32/i;
# this will apply to various OSes. Is there a "capable of doing unix
# redirections" flag somewhere?

foreach (qw(Makefile.PL Makefile examples lib t)) {
    die("Please run 'make test' from the top-level source directory\n".
	"(I can't see $_)\n")
	unless -e $_;
}

my %skip = map { ("examples/$_") => 1 }
               qw(. .. CVS Experimental README tester.pl tester.png);
my @examples = grep { ! $skip{$_} } glob("examples/*");

my %guru_checked = (

     "examples/patch100132" => <<'EGC',
...
Time:  0 wallclock secs ( 0.00 usr +  0.00 sys =  0.00 CPU)

OK (3 tests)
EGC

     "examples/patch100132-1" => <<'EGC',
...
Time:  0 wallclock secs ( 0.00 usr +  0.00 sys =  0.00 CPU)

OK (3 tests)
EGC

     "examples/patch100132-2" => <<'EGC',
...
Time:  0 wallclock secs ( 0.01 usr +  0.00 sys =  0.01 CPU)

OK (3 tests)
EGC

     "examples/fail_example.pm" => <<'EGC',
Suite setup
.F.Suite teardown

Time:  0 wallclock secs ( 0.01 usr +  0.00 sys =  0.01 CPU)

!!!FAILURES!!!
Test Results:
Run: 2, Failures: 1, Errors: 0

There was 1 failure:
1) examples/fail_example.pm:19 - test_fail(fail_example)
Born to lose ...

Test was not successful.
EGC

     );

plan(tests => scalar(@examples));

foreach my $e (keys %guru_checked) {
    warn("Guru ".(defined $guru_checked{$e} ? 'answer' : 'excuse').
	 " exists for '$e' but there is no test file\n")
	unless grep { $_ eq $e } @examples;
}


warn "There might be problems with error redirection undef $^O"
    if grep { $^O =~ $_ } ( qr/win/i );

foreach my $e (@examples) {
    if (defined $guru_checked{$e}) {
	# get program output
        my $runner = $e =~ /\.pm$/ ? './TestRunner.pl ' : '';
        my $cmd = "perl -I lib -I examples $runner$e 2>&1";
#        warn "cmd $cmd\n";
	my $out = `$cmd`;
	foreach ($out, $guru_checked{$e}) {
	    # mess about with start & end newlines
	    s/^\n+//;
	    $_ .= "\n" unless /\n$/;
	    # bin the naughty carriage returns
	    s/\r//g;
	    # we can't assume the order of tests will be the same
	    s/^[\.F]+$/TEST-RUN-SUMMARY/sm;
	    s/::Load[0-9_]+Anonymous[0-9_]+/::LOAD_ANONYMOUS_CLASSNAME/;
	    # indent lines with '# ' so they're comments if the test fails
	    s/\n/\n# /g;
	    # hide things that look like CPU usage
	    s{Time:\s+[\d\.]+\s+wallclock secs \([\d\s\.]+usr\s+\+[\d\s\.]+sys\s+=[\d\s\.]+CPU\)}
	    {TIME-SUMMARY}g;
	}
	ok($out, $guru_checked{$e});
    } else {
	warn "Skipping example file '$e', no guru-checked answer\n"
	    unless exists $guru_checked{$e};
	ok(0);
    }
}
