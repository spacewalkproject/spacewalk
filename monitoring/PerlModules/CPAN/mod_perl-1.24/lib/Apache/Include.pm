package Apache::Include;
use Apache::Registry ();

$VERSION = "1.00";

sub handler {
    my($r, $uri) = (shift,shift);
    %ENV = $r->cgi_env;
    my($ouri,$fname) = ($r->uri, $r->filename);
    $r->uri($uri);
    $r->translate_name; 
    $r->Apache::Registry::handler(@_);
    $r->uri($ouri); $r->filename($fname); #reset
    return 0;

# hmm, this should work, but alloc.c:chk_on_blk_list()
# will fprintf (stderr, "Ouch!  Freeing free block\n"); exit(1);
#    my $subr = $r->lookup_uri($uri);
#    $subr->Apache::Registry::handler(@_);
#    return $subr->status;
}

sub virtual {
    my($self, $uri, $r) = @_;
    $r ||= Apache->request;
    my $subr = $r->lookup_uri($uri);
    $subr->header_in("Content-length" => "0");
    $subr->run;
    return $subr->status;
}

1;

__END__

=head1 NAME

Apache::Include - Utilities for mod_perl/mod_include integration

=head1 SYNOPSIS

 <!--#perl sub="Apache::Include" arg="/perl/ssi.pl" -->


=head1 DESCRIPTION

The B<Apache::Include> module provides a handler, making it simple to
include Apache::Registry scripts with the mod_include perl directive.

Apache::Registry scripts can also be used in mod_include parsed
documents using 'virtual include'.

=head1 METHODS

=over 4

=item Apache::Include->virtual($uri)

The C<virtual> method may be called to include the output of a given
uri in your Perl scripts.  Example:

 use Apache::Include ();

 print "Content-type: text/html\n\n";

 print "before include\n";

 my $uri = "/perl/env.pl";

 Apache::Include->virtual($uri);

 print "after include\n";

=back

=head1 SEE ALSO

perl(1), mod_perl(3), mod_include

=head1 AUTHOR

Doug MacEachern


