package Test::Unit::Assert;


use strict;

use Test::Unit::Debug qw(debug);
use Test::Unit::Failure;
use Test::Unit::Error;
use Test::Unit::Exception;

use Test::Unit::Assertion::CodeRef;

use Error qw/:try/;
use Carp;

sub assert {
    my $self = shift;
    my $assertion = $self->normalize_assertion(shift);
    $self->do_assertion($assertion, (caller($Error::Depth))[0 .. 2], @_);
}

sub normalize_assertion {
    my $self      = shift;
    my $assertion = shift;

    if (!ref($assertion) || ref($assertion) =~ 'ARRAY') {
        debug((defined $assertion ? $assertion : '_undef_') .
              " normalized as boolean\n");
        require Test::Unit::Assertion::Boolean;
        return Test::Unit::Assertion::Boolean->new($assertion);
    }

    # If we're this far, we must have a reference.

    if (eval {$assertion->isa('Regexp')}) {
        debug("$assertion normalized as Regexp\n");
        require Test::Unit::Assertion::Regexp;
        return Test::Unit::Assertion::Regexp->new($assertion);
    }

    if (ref($assertion) eq 'CODE') {
        debug("$assertion normalized as coderef\n");
        require Test::Unit::Assertion::CodeRef;
        return Test::Unit::Assertion::CodeRef->new($assertion);
    }

#   if (ref($assertion) eq 'SCALAR') {
#       debug("$assertion normalized as scalar ref\n");
#       require Test::Unit::Assertion::Scalar;
#       return Test::Unit::Assertion::Scalar->new($assertion);
#   }

    if (ref($assertion) !~ /^(GLOB|LVALUE|REF|SCALAR)$/) {
        debug("$assertion already an object\n");
        require Test::Unit::Assertion::Boolean;
        return $assertion->can('do_assertion') ? $assertion :
            Test::Unit::Assertion::Boolean->new($assertion);
    }
    else {
        die "Don't know how to normalize $assertion (ref ", ref($assertion), ")\n";
    }
}

sub assert_raises {
    my $self = shift;
    require Test::Unit::Assertion::Exception;
    my $assertion = Test::Unit::Assertion::Exception->new(shift);
    my ($asserter, $file, $line) = caller($Error::Depth);
    my $exception =
      $self->do_assertion($assertion, (caller($Error::Depth))[0 .. 2], @_);
}

sub do_assertion {
    my $self      = shift;
    my $assertion = shift;
    my $asserter  = shift;
    my $file      = shift;
    my $line      = shift;
    debug("Asserting [$assertion] from $asserter in $file line $line\n");
    my @args = @_;
    try { $assertion->do_assertion(@args) }
    catch Test::Unit::Exception with {
        my $e = shift;
        debug("  Caught $e, rethrowing from $asserter, $file line $line\n");
        $e->throw_new(-package => $asserter,
                      -file    => $file,
                      -line    => $line,
                      -object  => $self);
    }
}

sub multi_assert {
    my $self = shift;
    my ($assertion, @argsets) = @_;
    my ($asserter, $file, $line) = caller($Error::Depth);
    foreach my $argset (@argsets) {
        try {
            $self->assert($assertion, @$argset);
        }
        catch Test::Unit::Exception with {
            my $e = shift;
            debug("  Caught $e, rethrowing from $asserter, $file line $line\n");
            $e->throw_new(-package => $asserter,
                          -file    => $file,
                          -line    => $line,
                          -object  => $self);
        }
    }
}

sub is_numeric {
    my $str = shift;
    local $^W;
    return defined $str && ! ($str == 0 && $str !~ /[+-]?0(e0)?/);
}

# First argument determines the comparison type.
sub assert_equals {
    my $self = shift;
    my($asserter, $file, $line) = caller($Error::Depth);
    my @args = @_;
    try {
        if (! defined($args[0]) and ! defined($args[1])) {
            # pass
        }
        elsif (defined($args[0]) xor defined($args[1])) {
            $self->fail('one arg was not defined');
        }
        elsif (is_numeric($args[0])) {
            $self->assert_num_equals(@args);
        }
        elsif (eval {ref($args[0]) && $args[0]->isa('UNIVERSAL')}) {
            require overload;
            if (overload::Method($args[0], '==')) {
                $self->assert_num_equals(@args);
            }
            else {
                $self->assert_str_equals(@args);
            }
        }
        else {
            $self->assert_str_equals(@args);
        }
    }
    catch Test::Unit::Exception with {
        my $e = shift;
        $e->throw_new(-package => $asserter,
                      -file    => $file,
                      -line    => $line,
                      -object  => $self);
    }
}

sub ok { # To make porting from Test easier
    my $self = shift;
    my @args = @_;
    local $Error::Depth = $Error::Depth + 1;
    if (@args == 1) {
	$self->assert($args[0]); # boolean assertion
    }
    elsif (@args >= 2 && @args <= 3) {
	if (ref($args[0]) eq 'CODE') {
	    my $code     = shift @args;
            my $expected = shift @args;
	    $self->assert_equals($expected, $code->(), @args);
	}
	elsif (eval {$args[1]->isa('Regexp')}) {
	    my $got = shift @args;
	    my $re  = shift @args;
	    $self->assert($re, $got, @args);
	}
	else {
	    my $got 	 = shift @args;
	    my $expected = shift @args;
            $self->assert_equals($expected, $got, @args);
	}
    }
    else {
	$self->error('ok() called with wrong number of args');
    }
}

sub assert_not_equals {
    my $self = shift;
    my($asserter,$file,$line) = caller($Error::Depth);
    my @args = @_;
    try {
        if (! defined($args[0]) && ! defined($args[1])) {
            my $first  = shift @args;
            my $second = shift @args;
            $self->fail(@args ? join('', @args) : 'both args were undefined');
        }
        elsif (defined($args[0]) xor defined($args[1])) {
            # succeed
        }
        elsif (is_numeric($args[0])) {
            $self->assert_num_not_equals(@args);
        }
        elsif (eval {ref($args[0]) && $args[0]->isa('UNIVERSAL')}) {
            require overload;
            if (overload::Method($args[0], '==')) {
                $self->assert_num_not_equals(@args);
            }
            else {
                $self->assert_str_not_equals(@args);
            }
        }
        else {
            $self->assert_str_not_equals(@args);
        }
    }
    catch Test::Unit::Exception with {
        my $e = shift;
        $e->throw_new(-package => $asserter,
                      -file    => $file,
                      -line    => $line,
                      -object  => $self,);
    };
}

# Shamelessly pinched from Test::More and adapted to Test::Unit.
our @Data_Stack;
my $DNE = bless [], 'Does::Not::Exist';
sub assert_deep_equals {
    my $self = shift;
    my $this = shift;
    my $that = shift;

    local $Error::Depth = $Error::Depth + 1;

    if (! ref $this || ! ref $that) {
        Test::Unit::Failure->throw(
            -text => @_ ? join('', @_)
                        : 'Both arguments were not references'
        );
    }

    local @Data_Stack = ();
    if (! $self->_deep_check($this, $that)) {
        Test::Unit::Failure->throw(
            -text => @_ ? join('', @_)
                        : $self->_format_stack(@Data_Stack)
        );
    }
}    

sub _deep_check {
    my $self = shift;
    my ($e1, $e2) = @_;

    # Quiet uninitialized value warnings when comparing undefs.
    local $^W = 0; 

    return 1 if $e1 eq $e2;

    if (UNIVERSAL::isa($e1, 'ARRAY') and UNIVERSAL::isa($e2, 'ARRAY')) {
        return $self->_eq_array($e1, $e2);
    }
    elsif (UNIVERSAL::isa($e1, 'HASH') and UNIVERSAL::isa($e2, 'HASH')) {
        return $self->_eq_hash($e1, $e2);
    }
    elsif (UNIVERSAL::isa($e1, 'REF') and UNIVERSAL::isa($e2, 'REF')) {
        push @Data_Stack, { type => 'REF', vals => [$e1, $e2] };
        my $ok = $self->_deep_check($$e1, $$e2);
        pop @Data_Stack if $ok;
        return $ok;
    }
    elsif (UNIVERSAL::isa($e1, 'SCALAR') and UNIVERSAL::isa($e2, 'SCALAR')) {
        push @Data_Stack, { type => 'REF', vals => [$e1, $e2] };
        return _deep_check($$e1, $$e2);
    }
    else {
        push @Data_Stack, { vals => [$e1, $e2] };
        return 0;
    }
}

sub _eq_array  {
    my $self = shift;
    my($a1, $a2) = @_;
    return 1 if $a1 eq $a2;

    my $ok = 1;
    my $max = $#$a1 > $#$a2 ? $#$a1 : $#$a2;
    for (0..$max) {
        my $e1 = $_ > $#$a1 ? $DNE : $a1->[$_];
        my $e2 = $_ > $#$a2 ? $DNE : $a2->[$_];

        push @Data_Stack, { type => 'ARRAY', idx => $_, vals => [$e1, $e2] };
        $ok = $self->_deep_check($e1,$e2);
        pop @Data_Stack if $ok;

        last unless $ok;
    }
    return $ok;
}

sub _eq_hash {
    my $self = shift;
    my($a1, $a2) = @_;
    return 1 if $a1 eq $a2;

    my $ok = 1;
    my $bigger = keys %$a1 > keys %$a2 ? $a1 : $a2;
    foreach my $k (keys %$bigger) {
        my $e1 = exists $a1->{$k} ? $a1->{$k} : $DNE;
        my $e2 = exists $a2->{$k} ? $a2->{$k} : $DNE;

        push @Data_Stack, { type => 'HASH', idx => $k, vals => [$e1, $e2] };
        $ok = $self->_deep_check($e1, $e2);
        pop @Data_Stack if $ok;

        last unless $ok;
    }

    return $ok;
}

sub _format_stack {
    my $self = shift;
    my @Stack = @_;

    my $var = '$FOO';
    my $did_arrow = 0;
    foreach my $entry (@Stack) {
        my $type = $entry->{type} || '';
        my $idx  = $entry->{'idx'};
        if( $type eq 'HASH' ) {
            $var .= "->" unless $did_arrow++;
            $var .= "{$idx}";
        }
        elsif( $type eq 'ARRAY' ) {
            $var .= "->" unless $did_arrow++;
            $var .= "[$idx]";
        }
        elsif( $type eq 'REF' ) {
            $var = "\${$var}";
        }
    }

    my @vals = @{$Stack[-1]{vals}}[0,1];
    
    my @vars = ();
    ($vars[0] = $var) =~ s/\$FOO/  \$a/;
    ($vars[1] = $var) =~ s/\$FOO/  \$b/;

    my $out = "Structures begin differing at:\n";
    foreach my $idx (0..$#vals) {
        my $val = $vals[$idx];
        $vals[$idx] = !defined $val ? 'undef' : 
                      $val eq $DNE  ? "Does not exist"
                                    : "'$val'";
    }

    $out .= "$vars[0] = $vals[0]\n";
    $out .= "$vars[1] = $vals[1]\n";

    return $out;
}

{
    my %assert_subs = (
        str_equals => sub {
            my $str1 = shift;
            my $str2 = shift;
            defined $str1 or
              Test::Unit::Failure->throw(
                  -text => @_ ? join('',@_) :
                    "expected value was undef; should be using assert_null?"
              );
            defined $str2 or
              Test::Unit::Failure->throw(
                  -text => @_ ? join('',@_) : "expected '$str1', got undef"
              );
            $str1 eq $str2 or
              Test::Unit::Failure->throw(
                  -text => @_ ? join('',@_) : "expected '$str1', got '$str2'"
              );
        },
        str_not_equals => sub {
            my $str1 = shift;
            my $str2 = shift;
            defined $str1 or
              Test::Unit::Failure->throw(
                  -text => @_ ? join('',@_) :
                    "expected value was undef; should be using assert_not_null?"
              );
            defined $str2 or
              Test::Unit::Failure->throw(
                  -text => @_ ? join('',@_) :
                    "expected a string ne '$str1', got undef"
              );
            $str1 ne $str2 or
              Test::Unit::Failure->throw(
                  -text => @_ ? join('',@_) : "'$str1' and '$str2' should differ"
              );
        },
        num_equals => sub {
            my $num1 = shift;
            my $num2 = shift;
            defined $num1 or
              Test::Unit::Failure->throw(
                  -text => @_ ? join('',@_) :
                    "expected value was undef; should be using assert_null?"
              );
            defined $num2 or
              Test::Unit::Failure->throw(
                  -text => @_ ? join('',@_) : "expected '$num1', got undef"
              );
            # silence `Argument "" isn't numeric in numeric eq (==)' warnings
            local $^W; 
            $num1 == $num2 or
              Test::Unit::Failure->throw(
                  -text => @_ ? join('', @_) : "expected $num1, got $num2"
              );
        },
        num_not_equals => sub {
            my $num1 = shift;
            my $num2 = shift;
            defined $num1 or
              Test::Unit::Failure->throw(
                  -text => @_ ? join('',@_) :
                    "expected value was undef; should be using assert_not_null?"
              );
            defined $num2 or
              Test::Unit::Failure->throw(
                  -text => @_ ? join('',@_) :
                    "expected a number != '$num1', got undef"
              );
            # silence `Argument "" isn't numeric in numeric ne (!=)' warnings
            local $^W; 
            $num1 != $num2 or
              Test::Unit::Failure->throw(
                  -text => @_ ? join('', @_) : "$num1 and $num2 should differ"
              );
        },
        matches => sub {
            my $regexp = shift;
            eval { $regexp->isa('Regexp') } or
              Test::Unit::Error->throw(
                  -text => "arg 1 to assert_matches() must be a regexp"
              );
            my $string = shift;
            $string =~ $regexp or
              Test::Unit::Failure->throw
                  (-text => @_ ? join('', @_) :
                     "$string didn't match /$regexp/");
        },
        does_not_match => sub {
            my $regexp = shift;
            eval { $regexp->isa('Regexp') } or
              Test::Unit::Error->throw(
                  -text => "arg 1 to assert_does_not_match() must be a regexp"
              );
            my $string = shift;
            $string !~ $regexp or
              Test::Unit::Failure->throw
                  (-text => @_ ? join('', @_) :
                     "$string matched /$regexp/");
        },
        null       => sub {
            my $arg = shift;
            !defined($arg) or
              Test::Unit::Failure->throw
                  (-text => @_ ? join('',@_) : "$arg is defined");
        },
        not_null   => sub {
            my $arg = shift;
            defined($arg) or
              Test::Unit::Failure->throw
                  (-text => @_ ? join('', @_) : "<undef> unexpected");
        },
    );
    foreach my $type (keys %assert_subs) {
        my $assertion = Test::Unit::Assertion::CodeRef->new($assert_subs{$type});
        no strict 'refs';
        *{"Test::Unit::Assert::assert_$type"} =
            sub {
                local $Error::Depth = $Error::Depth + 3;
                my $self = shift;
                $assertion->do_assertion(@_);
            };
    }
}

sub fail {
    my $self = shift;
    debug(ref($self) . "::fail() called\n");
    my($asserter,$file,$line) = caller($Error::Depth);
    my $message = join '', @_;
    Test::Unit::Failure->throw(-text => $message,
			       -object => $self,
			       -file => $file,
			       -line => $line);
}

sub error {
    my $self = shift;
    debug(ref($self) . "::error() called\n");
    my($asserter,$file,$line) = caller($Error::Depth);
    my $message = join '', @_;
    Test::Unit::Error->throw(-text => $message,
                             -object => $self,
                             -file => $file,
                             -line => $line);
}

sub quell_backtrace {
    my $self = shift;
    carp "quell_backtrace deprecated";
}

sub get_backtrace_on_fail {
    my $self = shift;
    carp "get_backtrace_on_fail deprecated";
}



1;
__END__

=head1 NAME

Test::Unit::Assert - unit testing framework assertion class

=head1 SYNOPSIS

    # this class is not intended to be used directly, 
    # normally you get the functionality by subclassing from 
    # Test::Unit::TestCase

    use Test::Unit::TestCase;

    # more code here ...

    $self->assert($your_condition_here, $your_optional_message_here);

    # or, for regular expression comparisons:
    $self->assert(qr/some_pattern/, $result);

    # or, for functional style coderef tests:
    $self->assert(sub {
                      $_[0] == $_[1]
                        or $self->fail("Expected $_[0], got $_[1]");
                  }, 1, 2); 

    # or, for old style regular expression comparisons
    # (strongly deprecated; see warning below)
    $self->assert(scalar("foo" =~ /bar/), $your_optional_message_here);

    # Or, if you don't mind us guessing
    $self->assert_equals('expected', $actual [, $optional_message]);
    $self->assert_equals(1,$actual);
    $self->assert_not_equals('not expected', $actual [, $optional_message]);
    $self->assert_not_equals(0,1);

    # Or, if you want to force the comparator
    $self->assert_num_equals(1,1);
    $self->assert_num_not_equals(1,0);
    $self->assert_str_equals('string','string');
    $self->assert_str_not_equals('stringA', 'stringB');

    # assert defined/undefined status
    $self->assert_null(undef);
    $self->assert_not_null('');

=head1 DESCRIPTION

This class contains the various standard assertions used within the
framework. With the exception of the C<assert(CODEREF, @ARGS)>, all
the assertion methods take an optional message after the mandatory
fields. The message can either be a single string, or a list, which
will get concatenated. 

Although you can specify a message, it is hoped that the default error
messages generated when an assertion fails will be good enough for
most cases.

=head2 Methods

=over 4

=item assert_equals(EXPECTED, ACTUAL [, MESSAGE])

=item assert_not_equals(NOTEXPECTED, ACTUAL [, MESSAGE])

The catch all assertions of (in)equality. We make a guess about
whether to test for numeric or string (in)equality based on the first
argument. If it looks like a number then we do a numeric test, if it
looks like a string, we do a string test. 

If the first argument is an object, we check to see if the C<'=='>
operator has been overloaded and use that if it has, otherwise we do
the string test.

=item assert_num_equals

=item assert_num_not_equals

Force numeric comparison with these two.

=item assert_str_equals

=item assert_str_not_equals

Force string comparison

=item assert_matches(qr/PATTERN/, STRING [, MESSAGE])

=item assert_does_not_match(qr/PATTERN/, STRING [, MESSAGE])

Assert that STRING does or does not match the PATTERN regex.

=item assert_deep_equals(A, B [, MESSAGE ])

Assert that reference A is a deep copy of reference B.  The references
can be complex, deep structures.  If they are different, the default
message will display the place where they start differing.

B<NOTE> This is NOT well-tested on circular references.  Nor am I
quite sure what will happen with filehandles.

=item assert_null(ARG [, MESSAGE])

=item assert_not_null(ARG [, MESSAGE])

Assert that ARG is defined or not defined.

=item assert(BOOLEAN [, MESSAGE]) 

Checks if the BOOLEAN expression returns a true value that is neither
a CODE ref nor a REGEXP.  Note that MESSAGE is almost non optional in
this case, otherwise all the assertion has to go on is the truth or
otherwise of the boolean.

If you want to use the "old" style for testing regular expression
matching, please be aware of this: the arguments to assert() are
evaluated in list context, e.g. making a failing regex "pull" the
message into the place of the first argument. Since this is usually
just plain wrong, please use scalar() to force the regex comparison
to yield a useful boolean value.

=item assert(qr/PATTERN/, ACTUAL [, MESSAGE])

Matches ACTUAL against the PATTERN regex.  If you omit MESSAGE, you
should get a sensible error message.

=item assert(CODEREF, @ARGS)

Calls CODEREF->(@ARGS).  Assertion fails if this returns false (or
throws Test::Unit::Failure)

=item assert_raises(EXCEPTION_CLASS, CODEREF [, MESSAGE])

Calls CODEREF->().  Assertion fails unless an exception of class
EXCEPTION_CLASS is raised.

=item multi_assert(ASSERTION, @ARGSETS)

Calls $self->assert(ASSERTION, @$ARGSET) for each $ARGSET in @ARGSETS.

=item ok(@ARGS)

Simulates the behaviour of the L<Test|Test> module.  B<Deprecated.>

=back

=head1 AUTHORS

Copyright (c) 2000 Christian Lemburg, E<lt>lemburg@acm.orgE<gt>.

All rights reserved. This program is free software; you can
redistribute it and/or modify it under the same terms as Perl itself.

Thanks go to the other PerlUnit framework people: 
Brian Ewins, Cayte Lindner, J.E. Fritz, Zhon Johansen.

Thanks for patches go to:
Matthew Astley, David Esposito, Piers Cawley.

Thanks for the deep structure comparison routines to Michael Schwern
and the other Test::More folk.

=head1 SEE ALSO

=over 4

=item *

L<Test::Unit::Assertion>

=item *

L<Test::Unit::Assertion::Regexp>

=item *

L<Test::Unit::Assertion::CodeRef>

=item *

L<Test::Unit::Assertion::Boolean>

=item *

L<Test::Unit::TestCase>

=item *

L<Test::Unit::Exception>

=item *

The framework self-testing suite
(L<t::tlib::AllTests|t::tlib::AllTests>)

=back

=cut
