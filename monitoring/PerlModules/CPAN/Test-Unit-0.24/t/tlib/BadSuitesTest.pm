package BadSuitesTest;

use strict;

use Test::Unit::TestCase;
use Test::Unit::TestRunner;

use base 'Test::Unit::TestCase';

sub test_suite_with_syntax_error {
    my $self = shift;
    my $runner = Test::Unit::TestRunner->new();
    eval {
        $runner->start('BadSuite::SyntaxError');
    };
    $self->assert(qr!^syntax error at .*/SyntaxError\.pm!, "$@");
}

sub test_suite_with_bad_use {
    my $self = shift;
    my $runner = Test::Unit::TestRunner->new();
    eval {
        $runner->start('BadSuite::BadUse');
    };
    $self->assert(qr!^Can't locate TestSuite/NonExistent\.pm in \@INC!, "$@");
}

1;
