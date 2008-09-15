package Apache::Symdump;

use strict;
use Devel::Symdump ();
use Apache::File ();

my $X = 0;

sub logfile {
    my($r, $name) = @_;
    $r->server_root_relative("logs/$name.$$.$X");
}

sub inc_snap {
    my $r = shift;
    my $fname = logfile($r, "incdump");
    my $fh = Apache::File->new(">$fname") or die $!;
    print $fh map { "$_ = $INC{$_}\n" } sort keys %INC;
    close $fh;
}

sub handler {
    my $r = shift;
    my $fname = logfile($r, "symdump");
    my $fh = Apache::File->new(">$fname") or die $!;
    print $fh +Devel::Symdump->rnew()->as_string;
    close $fh;
    inc_snap($r);
    $X++;
}

1;
__END__

=head1 NAME

Apache::Symdump - Symbol table snapshots

=head1 SYNOPSIS

 PerlLogHandler Apache::Symdump

=head1 DESCRIPTION

Apache:Symdump uses Devel::Symdump to record snapshots of the Perl symbol
table in ServerRoot/logs/symdump.$$.$n
Where B<$$> is the process id and B<$n> is incremented each time the handler
is run.  The B<diff> utility can be used to compare snapshots and get an idea
of what might be making a process grow.  Normally, new symbols come from 
modules or scripts that were not preloaded, the Perl method cache, etc.

 % diff -u symdump.$$.0 symdump.$$.1

=head1 CAVEATS

Apache::Symdump does not cleanup up its snapshot files, do so simply by:

 % rm logs/symdump.* logs/incdump.*

=head1 SEE ALSO

Devel::Symdump(3), Apache::Leak(3)

=head1 AUTHOR

Doug MacEachern
