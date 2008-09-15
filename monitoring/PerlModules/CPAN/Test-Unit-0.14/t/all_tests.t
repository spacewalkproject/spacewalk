use lib './lib';

use Test::Unit::HarnessUnit;

my $testrunner = Test::Unit::HarnessUnit->new();
$testrunner->start("Test::Unit::tests::AllTests");
