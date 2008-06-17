package Params::Validate;

use strict;
use warnings;

use Scalar::Util ();

# suppress subroutine redefined warnings if we tried to load the XS
# version and failed.
no warnings 'redefine';


BEGIN
{
    sub SCALAR    () { 1 }
    sub ARRAYREF  () { 2 }
    sub HASHREF   () { 4 }
    sub CODEREF   () { 8 }
    sub GLOB      () { 16 }
    sub GLOBREF   () { 32 }
    sub SCALARREF () { 64 }
    sub UNKNOWN   () { 128 }
    sub UNDEF     () { 256 }
    sub OBJECT    () { 512 }

    sub HANDLE    () { 16 | 32 }
    sub BOOLEAN   () { 1 | 256 }
}

# Various internals notes (for me and any future readers of this
# monstrosity):
#
# - A lot of the weirdness is _intentional_, because it optimizes for
#   the _success_ case.  It does not really matter how slow the code is
#   after it enters a path that leads to reporting failure.  But the
#   "success" path should be as fast as possible.
#
# -- We only calculate $called as needed for this reason, even though it
#    means copying code all over.
#
# - All the validation routines need to be careful never to alter the
#   references that are passed.
#
# -- The code assumes that _most_ callers will not be using the
#    skip_leading or ignore_case features.  In order to not alter the
#    references passed in, we copy them wholesale when normalizing them
#    to make these features work.  This is slower but lets us be faster
#    when not using them.


# Matt Sergeant came up with this prototype, which slickly takes the
# first array (which should be the caller's @_), and makes it a
# reference.  Everything after is the parameters for validation.
sub validate_pos (\@@)
{
    return if $NO_VALIDATION && ! defined wantarray;

    my $p = shift;

    my @specs = @_;

    my @p = @$p;
    if ( $NO_VALIDATION )
    {
        # if the spec is bigger that's where we can start adding
        # defaults
        for ( my $x = $#p + 1; $x <= $#specs; $x++ )
	{
            $p[$x] =
                $specs[$x]->{default}
                    if ref $specs[$x] && exists $specs[$x]->{default};
	}

	return wantarray ? @p : \@p;
    }

    # I'm too lazy to pass these around all over the place.
    local $options ||= _get_options( (caller(0))[0] )
        unless defined $options;

    my $min = 0;

    while (1)
    {
        last unless ( ref $specs[$min] ?
                      ! ( exists $specs[$min]->{default} || $specs[$min]->{optional} ) :
                      $specs[$min] );

	$min++;
    }

    my $max = scalar @specs;

    my $actual = scalar @p;
    unless ($actual >= $min && ( $options->{allow_extra} || $actual <= $max ) )
    {
	my $minmax =
            ( $options->{allow_extra} ?
              "at least $min" :
              ( $min != $max ? "$min - $max" : $max ) );

	my $val = $options->{allow_extra} ? $min : $max;
	$minmax .= $val != 1 ? ' were' : ' was';

        my $called = _get_called();

	$options->{on_fail}->
            ( "$actual parameter" .
              ($actual != 1 ? 's' : '') .
              " " .
              ($actual != 1 ? 'were' : 'was' ) .
              " passed to $called but $minmax expected\n" );
    }

    my $bigger = $#p > $#specs ? $#p : $#specs;
    foreach ( 0..$bigger )
    {
	my $spec = $specs[$_];

	next unless ref $spec;

	if ( $_ <= $#p )
	{
	    my $value = defined $p[$_] ? qq|"$p[$_]"| : 'undef';
	    _validate_one_param( $p[$_], \@p, $spec, "Parameter #" . ($_ + 1) . " ($value)");
	}

	$p[$_] = $spec->{default} if $_ > $#p && exists $spec->{default};
    }

    _validate_pos_depends(\@p, \@specs);

    foreach ( grep { defined $p[$_] && ! ref $p[$_]
                     && ref $specs[$_] && $specs[$_]{untaint} }
              0..$bigger )
    {
        ($p[$_]) = $p[$_] =~ /(.+)/;
    }

    return wantarray ? @p : \@p;
}

sub _validate_pos_depends
{
    my ( $p, $specs ) = @_;

    for my $p_idx ( 0..$#$p )
    {
        my $spec = $specs->[$p_idx];

        next unless $spec && UNIVERSAL::isa( $spec, 'HASH' ) && exists $spec->{depends};

        my $depends = $spec->{depends};

        if ( ref $depends )
        {
            require Carp;
            local $Carp::CarpLevel = 2;
            Carp::croak( "Arguments to 'depends' for validate_pos() must be a scalar" )
        }

        my $p_size = scalar @$p;
        if ( $p_size < $depends - 1 )
        {
            my $error = ( "Parameter #" . ($p_idx + 1) . " depends on parameter #" .
                          $depends . ", which was not given" );

            $options->{on_fail}->($error);
        }
    }
    return 1;
}

sub _validate_named_depends
{
    my ( $p, $specs ) = @_;

    foreach my $pname ( keys %$p )
    {
        my $spec = $specs->{$pname};

        next unless $spec && UNIVERSAL::isa( $spec, 'HASH' ) && $spec->{depends};

        unless ( UNIVERSAL::isa( $spec->{depends}, 'ARRAY' ) || ! ref $spec->{depends} )
        {
            require Carp;
            local $Carp::CarpLevel = 2;
            Carp::croak( "Arguments to 'depends' must be a scalar or arrayref" );
        }

        foreach my $depends_name ( ref $spec->{depends}
                                   ? @{ $spec->{depends} }
                                   : $spec->{depends} )
        {
            unless ( exists $p->{$depends_name} )
            {
                my $error = ( "Parameter '$pname' depends on parameter '" .
                              $depends_name . "', which was not given" );

                $options->{on_fail}->($error);
            }
        }
    }
}

sub validate (\@$)
{
    return if $NO_VALIDATION && ! defined wantarray;

    my $p = $_[0];

    my $specs = $_[1];
    local $options = _get_options( (caller(0))[0] ) unless defined $options;

    if ( ref $p eq 'ARRAY' )
    {
        # we were called as validate( @_, ... ) where @_ has a
        # single element, a hash reference
        if ( ref $p->[0] )
        {
            $p = $p->[0];
        }
        elsif ( @$p % 2 )
        {
            my $called = _get_called();

            $options->{on_fail}->
                ( "Odd number of parameters in call to $called " .
                  "when named parameters were expected\n" );
        }
        else
        {
            $p = {@$p};
        }
    }

    if ( $options->{normalize_keys} )
    {
        $specs = _normalize_callback( $specs, $options->{normalize_keys} );
        $p = _normalize_callback( $p, $options->{normalize_keys} );
    }
    elsif ( $options->{ignore_case} || $options->{strip_leading} )
    {
	$specs = _normalize_named($specs);
	$p = _normalize_named($p);
    }

    if ($NO_VALIDATION)
    {
        return
            ( wantarray ?
              (
               # this is a hash containing just the defaults
               ( map { $_ => $specs->{$_}->{default} }
                 grep { ref $specs->{$_} && exists $specs->{$_}->{default} }
                 keys %$specs
               ),
               ( ref $p eq 'ARRAY' ?
                 ( ref $p->[0] ?
                   %{ $p->[0] } :
                   @$p ) :
                 %$p
               )
              ) :
              do
              {
                  my $ref =
                      ( ref $p eq 'ARRAY' ?
                        ( ref $p->[0] ?
                          $p->[0] :
                          {@$p} ) :
                        $p
                      );

                  foreach ( grep { ref $specs->{$_} && exists $specs->{$_}->{default} }
                            keys %$specs )
                  {
                      $ref->{$_} = $specs->{$_}->{default}
                          unless exists $ref->{$_};
                  }

                  return $ref;
              }
            );
    }

    _validate_named_depends($p, $specs);

    unless ( $options->{allow_extra} )
    {
        my $called = _get_called();

	if ( my @unmentioned = grep { ! exists $specs->{$_} } keys %$p )
	{
	    $options->{on_fail}->
                ( "The following parameter" . (@unmentioned > 1 ? 's were' : ' was') .
                  " passed in the call to $called but " .
                  (@unmentioned > 1 ? 'were' : 'was') .
                  " not listed in the validation options: @unmentioned\n" );
	}
    }

    my @missing;

    # the iterator needs to be reset in case the same hashref is being
    # passed to validate() on successive calls, because we may not go
    # through all the hash's elements
    keys %$specs;
 OUTER:
    while ( my ($key, $spec) = each %$specs )
    {
	if ( ! exists $p->{$key} &&
             ( ref $spec
               ? ! (
                    do
                    {
                        # we want to short circuit the loop here if we
                        # can assign a default, because there's no need
                        # check anything else at all.
                        if ( exists $spec->{default} )
                        {
                            $p->{$key} = $spec->{default};
                            next OUTER;
                        }
                    }
                    ||
                    do
                    {
                        # Similarly, an optional parameter that is
                        # missing needs no additional processing.
                        next OUTER if $spec->{optional};
                    }
                   )
               : $spec
             )
           )
        {
            push @missing, $key;
	}
        # Can't validate a non hashref spec beyond the presence or
        # absence of the parameter.
        elsif (ref $spec)
        {
	    my $value = defined $p->{$key} ? qq|"$p->{$key}"| : 'undef';
	    _validate_one_param( $p->{$key}, $p, $spec, "The '$key' parameter ($value)" );
	}
    }

    if (@missing)
    {
        my $called = _get_called();

	my $missing = join ', ', map {"'$_'"} @missing;
	$options->{on_fail}->
            ( "Mandatory parameter" .
              (@missing > 1 ? 's': '') .
              " $missing missing in call to $called\n" );
    }

    # do untainting after we know everything passed
    foreach my $key ( grep { defined $p->{$_} && ! ref $p->{$_}
                             && ref $specs->{$_} && $specs->{$_}{untaint} }
                      keys %$p )
    {
        ($p->{$key}) = $p->{$key} =~ /(.+)/;
    }

    return wantarray ? %$p : $p;
}

sub validate_with
{
    return if $NO_VALIDATION && ! defined wantarray;

    my %p = @_;

    local $options = _get_options( (caller(0))[0], %p );

    unless ( $NO_VALIDATION )
    {
        unless ( exists $options->{called} )
        {
            $options->{called} = (caller( $options->{stack_skip} ))[3];
        }

    }

    if ( UNIVERSAL::isa( $p{spec}, 'ARRAY' ) )
    {
	return validate_pos( @{ $p{params} }, @{ $p{spec} } );
    }
    else
    {
        # intentionally ignore the prototype because this contains
        # either an array or hash reference, and validate() will
        # handle either one properly
	return &validate( $p{params}, $p{spec} );
    }
}

sub _normalize_callback
{
    my ( $p, $func ) = @_;

    my %new;

    foreach my $key ( keys %$p )
    {
        my $new_key = $func->( $key );

        unless ( defined $new_key )
        {
            die "The normalize_keys callback did not return a defined value when normalizing the key '$key'";
        }

        if ( exists $new{$new_key} )
        {
            die "The normalize_keys callback returned a key that already exists, '$new_key', when normalizing the key '$key'";
        }

        $new{$new_key} = $p->{ $key };
    }

    return \%new;
}

sub _normalize_named
{
    # intentional copy so we don't destroy original
    my %h = ( ref $_[0] ) =~ /ARRAY/ ? @{ $_[0] } : %{ $_[0] };

    if ( $options->{ignore_case} )
    {
        $h{ lc $_ } = delete $h{$_} for keys %h;
    }

    if ( $options->{strip_leading} )
    {
	foreach my $key (keys %h)
	{
	    my $new;
	    ($new = $key) =~ s/^\Q$options->{strip_leading}\E//;
	    $h{$new} = delete $h{$key};
	}
    }

    return \%h;
}

sub _validate_one_param
{
    my ($value, $params, $spec, $id) = @_;

    if ( exists $spec->{type} )
    {
        unless ( defined $spec->{type}
                 && Scalar::Util::looks_like_number( $spec->{type} )
                 && $spec->{type} > 0 )
        {
            my $msg = "$id has a type specification which is not a number. It is ";
            if ( defined $spec->{type} )
            {
                $msg .= "a string - $spec->{type}";
            }
            else
            {
                $msg .= "undef";
            }

            $msg .= ".\n Use the constants exported by Params::Validate to declare types.";

            $options->{on_fail}->($msg);
        }

	unless ( _get_type($value) & $spec->{type} )
	{
            my $type = _get_type($value);

	    my @is = _typemask_to_strings($type);
	    my @allowed = _typemask_to_strings($spec->{type});
	    my $article = $is[0] =~ /^[aeiou]/i ? 'an' : 'a';

            my $called = _get_called(1);

	    $options->{on_fail}->
                ( "$id to $called was $article '@is', which " .
                  "is not one of the allowed types: @allowed\n" );
	}
    }

    # short-circuit for common case
    return unless ( $spec->{isa} || $spec->{can} ||
                    $spec->{callbacks} || $spec->{regex} );

    if ( exists $spec->{isa} )
    {
	foreach ( ref $spec->{isa} ? @{ $spec->{isa} } : $spec->{isa} )
	{
	    unless ( eval { $value->isa($_) } )
	    {
		my $is = ref $value ? ref $value : 'plain scalar';
		my $article1 = $_ =~ /^[aeiou]/i ? 'an' : 'a';
		my $article2 = $is =~ /^[aeiou]/i ? 'an' : 'a';

                my $called = _get_called(1);

		$options->{on_fail}->
                    ( "$id to $called was not $article1 '$_' " .
                      "(it is $article2 $is)\n" );
	    }
	}
    }

    if ( exists $spec->{can} )
    {
	foreach ( ref $spec->{can} ? @{ $spec->{can} } : $spec->{can} )
	{
            unless ( eval { $value->can($_) } )
            {
                my $called = _get_called(1);

                $options->{on_fail}->( "$id to $called does not have the method: '$_'\n" );
            }
	}
    }

    if ( $spec->{callbacks} )
    {
        unless ( UNIVERSAL::isa( $spec->{callbacks}, 'HASH' ) )
        {
            my $called = _get_called(1);

            $options->{on_fail}->
                ( "'callbacks' validation parameter for $called must be a hash reference\n" );
        }


	foreach ( keys %{ $spec->{callbacks} } )
	{
            unless ( UNIVERSAL::isa( $spec->{callbacks}{$_}, 'CODE' ) )
            {
                my $called = _get_called(1);

                $options->{on_fail}->( "callback '$_' for $called is not a subroutine reference\n" );
            }

            unless ( $spec->{callbacks}{$_}->($value, $params) )
            {
                my $called = _get_called(1);

                $options->{on_fail}->( "$id to $called did not pass the '$_' callback\n" );
            }
	}
    }

    if ( exists $spec->{regex} )
    {
        unless ( ( defined $value ? $value : '' ) =~ /$spec->{regex}/ )
        {
            my $called = _get_called(1);

            $options->{on_fail}->( "$id to $called did not pass regex check\n" );
        }
    }
}

{
    # if it UNIVERSAL::isa the string on the left then its the type on
    # the right
    my %isas = ( 'ARRAY'  => ARRAYREF,
		 'HASH'   => HASHREF,
		 'CODE'   => CODEREF,
		 'GLOB'   => GLOBREF,
		 'SCALAR' => SCALARREF,
	       );
    my %simple_refs = map { $_ => 1 } keys %isas;

    sub _get_type
    {
	return UNDEF unless defined $_[0];

	my $ref = ref $_[0];
	unless ($ref)
	{
	    # catches things like:  my $fh = do { local *FH; };
	    return GLOB if UNIVERSAL::isa( \$_[0], 'GLOB' );
	    return SCALAR;
	}

	return $isas{$ref} if $simple_refs{$ref};

	foreach ( keys %isas )
	{
	    return $isas{$_} | OBJECT if UNIVERSAL::isa( $_[0], $_ );
	}

	# I really hope this never happens.
	return UNKNOWN;
    }
}

{
    my %type_to_string = ( SCALAR()    => 'scalar',
			   ARRAYREF()  => 'arrayref',
			   HASHREF()   => 'hashref',
			   CODEREF()   => 'coderef',
			   GLOB()      => 'glob',
			   GLOBREF()   => 'globref',
			   SCALARREF() => 'scalarref',
			   UNDEF()     => 'undef',
			   OBJECT()    => 'object',
			   UNKNOWN()   => 'unknown',
			 );

    sub _typemask_to_strings
    {
	my $mask = shift;

	my @types;
	foreach ( SCALAR, ARRAYREF, HASHREF, CODEREF, GLOB, GLOBREF,
                  SCALARREF, UNDEF, OBJECT, UNKNOWN )
	{
	    push @types, $type_to_string{$_} if $mask & $_;
	}
	return @types ? @types : ('unknown');
    }
}

{
    my %defaults = ( ignore_case   => 0,
		     strip_leading => 0,
		     allow_extra   => 0,
		     on_fail       => sub { require Carp;
                                            Carp::confess($_[0]) },
		     stack_skip    => 1,
                     normalize_keys => undef,
		   );

    *set_options = \&validation_options;
    sub validation_options
    {
	my %opts = @_;

	my $caller = caller;

	foreach ( keys %defaults )
	{
	    $opts{$_} = $defaults{$_} unless exists $opts{$_};
	}

	$OPTIONS{$caller} = \%opts;
    }

    sub _get_options
    {
	my ( $caller, %override ) = @_;

        if ( %override )
        {
            return
                ( $OPTIONS{$caller} ?
                  { %{ $OPTIONS{$caller} },
                    %override } :
                  { %defaults, %override }
                );
        }
        else
        {
            return
                ( exists $OPTIONS{$caller} ?
                  $OPTIONS{$caller} :
                  \%defaults );
        }
    }
}

sub _get_called
{
    my $extra_skip = $_[0] || 0;

    # always add one more for this sub
    $extra_skip++;

    my $called =
        ( exists $options->{called} ?
          $options->{called} :
          ( caller( $options->{stack_skip} + $extra_skip ) )[3]
        );

    $called = 'N/A' unless defined $called;

    return $called;
}

1;

__END__

=head1 NAME

Params::ValidatePP - pure Perl implementation of Params::Validate

=head1 SYNOPSIS

  See Params::Validate

=head1 DESCRIPTION

This is a pure Perl implementation of Params::Validate.  See the
Params::Validate documentation for details.

=head1 COPYRIGHT

Copyright (c) 2004-2007 David Rolsky.  All rights reserved.  This
program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
