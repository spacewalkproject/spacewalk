package Apache::Symbol;

use strict;
use DynaLoader ();

@Apache::Symbol::ISA = qw(DynaLoader);
$Apache::Symbol::VERSION = '1.31';
$Apache::Symbol::DEBUG ||= 0;

use Devel::Symdump ();

sub file2class {
    my $file = shift;
    return $file unless $file =~ s,\.pm$,,;
    $file =~ s,/,::,g;
    $file;
}

sub undef_functions {
    my( $package, $skip, $only_undef_exports ) = @_;

    my $stab = Devel::Symdump->rnew($package);
    my @functions = $stab->functions;

    if( $only_undef_exports ) {
        no strict 'refs';
        my $any_export_var;
        $any_export_var = 1 if @{$package . "::EXPORT"};
        $any_export_var = 1 if @{$package . "::EXPORT_OK"};
        $any_export_var = 1 if %{$package . "::EXPORT_TAGS"};
        $any_export_var = 1 if @{$package . "::EXPORT_EXTRAS"};

        if( $any_export_var ) {
            my @names = (@{$package . "::EXPORT"},
                         @{$package . "::EXPORT_OK"},
                         @{$package . "::EXPORT_EXTRAS"});
            foreach my $tagdata (values %{$package . "::EXPORT_TAGS"}) {
                push @names, @$tagdata;
            }
            my %exported = map { $package . "::" . $_ => 1 } @names;
            @functions = grep( $exported{$_}, @functions );
        }
    }

    for my $cv (@functions) {
        no strict 'refs';
	next if substr($cv, 0, 14) eq "Devel::Symdump";
        next if $skip and $cv =~ /$skip/;
        #warn "$cv=", *{$cv}{CODE}, "\n";
        Apache::Symbol::undef(*{$cv}{CODE});
    }

}

sub make_universal {
    *UNIVERSAL::undef_functions = \&undef_functions;
}

if($ENV{APACHE_SYMBOL_UNIVERSAL}) {
    __PACKAGE__->make_universal;
}

sub handler {
    my $fh;
    if ($Apache::Symbol::DEBUG) {
	require IO::File;
	$fh = IO::File->new(">/tmp/Apache::Symbol.debug");
	print $fh "Apache::Symbol debug for process $$\n";
    }
    my $skip = join "|", __PACKAGE__,  qw(Devel::Symdump);

    my $stab = Devel::Symdump->new('main');
    for my $class ($stab->packages) {
	next if $class =~ /($skip)/;
	if($class->can('undef_functions')) {
	    print $fh "$class->undef_functions\n" if $fh;
	    $class->undef_functions;
	}
    }
    close $fh if $fh;

    1;
}

bootstrap Apache::Symbol $Apache::Symbol::VERSION;

1;

__END__

=head1 NAME

Apache::Symbol - Things for symbol things

=head1 SYNOPSIS

 use Apache::Symbol ();

 @ISA = qw(Apache::Symbol);

=head1 DESCRIPTION

B<perlsub/Constant Functions> says:

 If you redefine a subroutine which was eligible for inlining you'll get
 a mandatory warning.  (You can use this warning to tell whether or not a
 particular subroutine is considered constant.)  The warning is
 considered severe enough not to be optional because previously compiled
 invocations of the function will still be using the old value of the
 function.

I<mandatory warning> means there is _no_ way to avoid this warning 
no matter what tricks you pull in Perl.  This is bogus for us mod_perl
users when restarting the server with B<PerlFreshRestart> on or when 
Apache::StatINC pulls in a module that has changed on disk.

You can, however, pull some tricks with XS to avoid this warning,
B<Apache::Symbol::undef> does just that.

=head1 ARGUMENTS

C<undef_functions> takes two arguments: C<skip> and C<only_undef_exports>.

C<skip> is a regular expression indicating the function names to skip.

Use the C<only_undef_exports> flag to undef only those functions
which are listed in C<@EXPORT>, C<@EXPORT_OK>, C<%EXPORT_TAGS>, or
C<@EXPORT_EXTRAS>.  C<@EXPORT_EXTRAS> is not used by the Exporter, it
is only exists to communicate with C<undef_functions>.

As a special case, if none of the EXPORT variables are defined ignore
C<only_undef_exports>.  This takes care of trivial modules that don't
use the Exporter.

=head1 ARGUMENTS

C<undef_functions> takes two arguments: C<skip> and C<only_undef_exports>.

C<skip> is a regular expression indicating the function names to skip.

Use the C<only_undef_exports> flag to undef only those functions
which are listed in C<@EXPORT>, C<@EXPORT_OK>, C<%EXPORT_TAGS>, or
C<@EXPORT_EXTRAS>.  C<@EXPORT_EXTRAS> is not used by the Exporter, it
is only exists to communicate with C<undef_functions>.

As a special case, if none of the EXPORT variables are defined ignore
C<only_undef_exports>.  This takes care of trivial modules that don't
use the Exporter.

=head1 PLAYERS

This module and the undefining of functions is optional, if you wish
to have this functionality enabled, there are one or more switches you
need to know about.

=over 4

=item PerlRestartHandler

Apache::Symbol defines a PerlRestartHandler which can be useful in
conjuction with C<PerlFreshRestart On> as it will avoid subroutine
redefinition messages.  Configure like so:

 PerlRestartHandler Apache::Symbol

=item Apache::Registry

By placing the SYNOPSIS bit in you script, Apache::Registry will
undefine subroutines in your script before it is re-compiled to
avoid "subroutine re-defined" warnings. 

=item Apache::StatINC

See Apache::StatINC's docs.

=item APACHE_SYMBOL_UNIVERSAL

If this environment variable is true when Symbol.pm is compiled,
it will define UNIVERSAL::undef_functions, which means all classes
will inherit B<Apache::Symbol::undef_functions>.

=item Others

Module such as B<HTML::Embperl> and B<Apache::ePerl> who compile 
and script cache scripts ala Apache::Registry style can use  
C<undef_functions> with this bit of code:

    if($package->can('undef_functions')) {
	$package->undef_functions;
    }

Where C<$package> is the name of the package in which the script is
being re-compiled.

=back

=head1 SEE ALSO

perlsub(1), Devel::Symdump(3)

=head1 AUTHOR

Doug MacEachern
