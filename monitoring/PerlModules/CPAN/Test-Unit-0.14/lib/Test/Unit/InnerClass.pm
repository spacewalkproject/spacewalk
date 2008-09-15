package Test::Unit::InnerClass;

use strict;

use vars qw($SIGNPOST $HOW_OFTEN);

# we have a problem here to generate unique class names
# to avoid name clashes if we are used several times

if (defined($Test::Unit::InnerClass::SIGNPOST)) {
    ++$Test::Unit::InnerClass::HOW_OFTEN;
} else {
    $Test::Unit::InnerClass::SIGNPOST = 'I was here';
    $Test::Unit::InnerClass::HOW_OFTEN = 1;
}

{
    my $i = 0;
    sub make_inner_class {
	my ($class, $extension_text, @constructor_args) = @_;
	$extension_text =~ s/(\s*\n)+\z//m; # trim trailing blank lines
	$i++;
	my $classname = "Load" . $Test::Unit::InnerClass::HOW_OFTEN . "_"
	    . "Anonymous" . $i;
	my $inner_class_name = "${class}::${classname}";
	my $code = <<EOEVAL;
package $inner_class_name;
use base qw($class);

$extension_text
EOEVAL
	chop $code;
	
	eval $code;
	die <<EODIE if $@;
Failed to compile inner class: $@
Code follows:
--------- 8< --------- 8< ---------
$code
--------- 8< --------- 8< ---------
EODIE
	return $inner_class_name->new(@constructor_args);
    }
} 

1;
__END__


=head1 NAME

Test::Unit::InnerClass - unit testing framework helper class

=head1 SYNOPSIS

This class is not intended to be used directly 

=head1 DESCRIPTION

This class is used by the framework to emulate the anonymous inner
classes feature of Java. It is much easier to port Java to Perl using
this class.

=head1 AUTHOR

Copyright (c) 2000 Christian Lemburg, E<lt>lemburg@acm.orgE<gt>.

All rights reserved. This program is free software; you can
redistribute it and/or modify it under the same terms as Perl itself.

Thanks go to the other PerlUnit framework people: 
Brian Ewins, Cayte Lindner, J.E. Fritz, Zhon Johansen.

=head1 SEE ALSO

The JUnit testing framework by Kent Beck and Erich Gamma

=cut
