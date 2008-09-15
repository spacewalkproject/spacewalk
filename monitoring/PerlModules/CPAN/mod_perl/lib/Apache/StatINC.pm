package Apache::StatINC;
use strict;

$Apache::StatINC::VERSION = "1.07";

my %Stat = ($INC{"Apache/StatINC.pm"} => time);

sub handler {
    my $r = shift;
    my $do_undef = ref($r) && ((lc($r->dir_config("StatINC_UndefOnReload") ||
				   $r->dir_config("UndefOnReload")) || '') eq "on");
    my $DEBUG = ref($r) && (lc($r->dir_config("StatINCDebug") || '') eq "on");
    $DEBUG = $r->dir_config("StatINC_Debug") if ref($r) && $r->dir_config("StatINC_Debug");
    
    while(my($key,$file) = each %INC) {
	local $^W = 0;
	my $mtime = (stat $file)[9];
	# warn and skip the files with relative paths which can't be locate by applying @INC;
	warn("Apache::StatINC: Can't locate $file\n"),next unless defined $mtime and $mtime;
	unless(defined $Stat{$file}) { 
	    $Stat{$file} = $^T;
	}
	if($mtime > $Stat{$file}) {
	    if($do_undef and $key =~ /\.pm$/) {
		require Apache::Symbol;
		my $class = Apache::Symbol::file2class($key);
		$class->Apache::Symbol::undef_functions( undef, 1 );
	    }
	    delete $INC{$key};
	    require $key;
	    warn "Apache::StatINC: process $$ reloading $key\n"
		if $DEBUG > 0;
	}
	$Stat{$file} = $mtime;
    }
    
    return 1;
}

1;

__END__

=head1 NAME

Apache::StatINC - Reload %INC files when updated on disk

=head1 SYNOPSIS

  #httpd.conf or some such
  #can be any Perl*Handler
  PerlInitHandler Apache::StatINC

=head1 DESCRIPTION

When Perl pulls a file via C<require>, it stores the filename in the
global hash C<%INC>.  The next time Perl tries to C<require> the same
file, it sees the file in C<%INC> and does not reload from disk.  This
module's handler iterates over C<%INC> and reloads the file if it has
changed on disk. 

Note that StatINC operates on the current context of C<@INC>.  
Which means, when called as a Perl*Handler it will not see C<@INC> paths
added or removed by Apache::Registry scripts, as the value of C<@INC> is
saved on server startup and restored to that value after each request.
In other words, if you want StatINC to work with modules that live in custom
C<@INC> paths, you should modify C<@INC> when the server is started.
Besides, 'use lib' in startup scripts, you can also set the B<PERL5LIB>
variable in the httpd's environment to include any non-standard 'lib' 
directories that you choose.  For example, you might use a
script called 'start_httpd' to start apache, and include a line like this:

        PERL5LIB=/usr/local/foo/myperllibs; export PERL5LIB

When you have problems with modules not being reloaded, please refer
to the following lines in 'perlmodlib':

"Always use B<-w>. Try to C<use strict;> (or C<use strict qw(...);>). 
Remember that you can add C<no strict qw(...);> to individual blocks 
of code that need less strictness. Always use B<-w>. Always use B<-w>! 
Follow the guidelines in the perlstyle(1) manual." 

Warnings when running under mod_perl is enabled with 'PerlWarn On' in
your httpd.conf.

It will most likely help you to find the problem. Really.

=head1 OPTIONS

=over 4

=item StatINC_UndefOnReload

Normally, StatINC will turn of warnings to avoid "Subroutine redefined" 
warnings when it reloads a file.  However, this does not disable the 
Perl mandatory warning when re-defining C<constant> subroutines 
(see perldoc perlsub).  With this option On, StatINC will invoke the 
B<Apache::Symbol> I<undef_functions> method to avoid these mandatory
warnings:

 PerlSetVar StatINC_UndefOnReload On

=item StatINC_Debug

You can make StatINC tell when it reloads a module by setting this
option to on.

 PerlSetVar StatINC_Debug 1

The only used debug level is currently 1. 

=back

=head1 SEE ALSO

mod_perl(3)

=head1 AUTHOR

Currently maintained by Ask Bjoern Hansen <ask@netcetera.dk>.
Written by Doug MacEachern.


