package Test::Unit::tests::TestInnerClass;

use strict;
use base qw(Test::Unit::TestCase);
use Test::Unit::InnerClass;

sub test_inner_class_multiple_load {
    my $self = shift;
    
    $self->assert(defined($Test::Unit::InnerClass::SIGNPOST));
    
    local $^W = 0; # reloading will trigger warnings, turn them off
    do 'Test/Unit/InnerClass.pm'; # we must load it this way to check, sorry
    my $how_often_1 = $Test::Unit::InnerClass::HOW_OFTEN;
    my $innerclass_1 = Test::Unit::InnerClass::make_inner_class("Test::Unit::TestCase", << 'EOIC', "innerclass1");
EOIC
    
    do 'Test/Unit/InnerClass.pm'; # require would not load it - it caches
    my $how_often_2 = $Test::Unit::InnerClass::HOW_OFTEN;
    my $innerclass_2 = Test::Unit::InnerClass::make_inner_class("Test::Unit::TestCase", << 'EOIC', "innerclass2");
EOIC

    $self->assert($how_often_2 > $how_often_1); 
    $self->assert(ref($innerclass_1) ne ref($innerclass_2));
}

1;
