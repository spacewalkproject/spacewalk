package Apache::Leak;

use strict;
use DynaLoader ();
use Exporter ();
*import = \&Exporter::import;
{
    no strict;
    @EXPORT = qw(leak_test);
    $VERSION = '1.00';
    @ISA = qw(DynaLoader);
    __PACKAGE__->bootstrap($VERSION);
}

sub LOOP_N () {2}

sub leak_test (&;$$) {
    my($cv, $x, $fh) = @_;
    $x  ||= LOOP_N;
    $fh ||= \*STDERR;
    my $first = $x;

    while($x--) {
	my $handle;
	my $enter = NoteSV($handle);
	my $leave = 0;
	print $fh "ENTER: $enter SVs\n";
	{
	    $cv->();
	}
	$leave = CheckSV($handle);
	print $fh "\nLEAVE: $leave SVs\n";
	if($enter != $leave) {
	    my $n = $leave - $enter;
	    if($x+1 == $first) {
	    }
	    else {
		print $fh "!!! $n SVs leaked !!!\n";
	    }
	}
    }
}

sub handler {
    my $r = shift; 
    my $uri = $r->uri;
    my $handle;
    my $count = NoteSV($handle);
    $r->push_handlers(PerlLogHandler => sub {
	warn "Leak test for $uri:\n";
        warn "  ENTER: $count SVs\n";
        $count = CheckSV($handle);
        warn "  LEAVE: $count SVs\n";
    });
    0;
}

1;
__END__

=head1 NAME

Apache::Leak - Module for tracking memory leaks in mod_perl code

=head1 SYNOPSIS

    use Apache::Leak;

    leak_test {
	my $obj = Foo->new;
	$obj->thingy;
    };
    #now look in error_log for results

=head1 DESCRIPTION

"Under Construction."

=head1 SEE ALSO

Devel::Leak

=head1 AUTHOR

Doug MacEachern
Leak.xs derived from Nick Ing-Simmons' Devel::Leak
