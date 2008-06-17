package Apache::Constants;

use mod_perl ();

{
    no strict;
    $VERSION = "1.09";
    __PACKAGE__->mod_perl::boot($VERSION);
}

unless(defined &import) {
    require Exporter;
    require Apache::Constants::Exports;
    *import = \&Exporter::import;
}

if ($ENV{MOD_PERL}) {
    #outside of mod_perl this will recurse looking for __AUTOLOAD, grr
    *AUTOLOAD  = sub {
        if (defined &__AUTOLOAD) { #make extra sure we don't recurse
            #why must we stringify first???
            __AUTOLOAD() if "$Apache::Constants::AUTOLOAD";
            goto &$Apache::Constants::AUTOLOAD;
        }
        else {
            require Carp;
            Carp::confess("__AUTOLOAD is undefined, ",
                          "trying to AUTOLOAD $Apache::Constants::AUTOLOAD");
        }
    };
}

my %ConstNameCache = ();

sub export {
    my $class = shift;
    for my $new (@_) {
	next if grep { $new eq $_ } @Apache::Constants::EXPORT_OK;
	push @Apache::Constants::EXPORT_OK, $new;
	if(%Apache::Constants::EXPORT) {
	    $Apache::Constants::EXPORT{$new} = 1;
	}
    }
}

sub name {
    my($self, $const) = @_;
    require Apache::Constants::Exports;
    return $ConstNameCache{$const} if $ConstNameCache{$const};
    
    for (@Apache::Constants::EXPORT, 
	 @Apache::Constants::EXPORT_OK) {
	if ((\&{$_})->() eq $const) {
	    return ($ConstNameCache{$const} = $_);
	}
    }
}

1;

__END__

=head1 NAME

Apache::Constants - Constants defined in apache header files

=head1 SYNOPSIS

    use Apache::Constants;
    use Apache::Constants ':common';
    use Apache::Constants ':response';

=head1 DESCRIPTION

Server constants used by apache modules are defined in
B<httpd.h> and other header files, this module gives Perl access
to those constants. 

=head1 EXPORT TAGS

=over 4

=item common

This tag imports the most commonly used constants.

 OK
 DECLINED
 DONE
 NOT_FOUND
 FORBIDDEN
 AUTH_REQUIRED
 SERVER_ERROR 

=item response

This tag imports the B<common> response codes, plus these
response codes: 

 DOCUMENT_FOLLOWS
 MOVED
 REDIRECT
 USE_LOCAL_COPY
 BAD_REQUEST
 BAD_GATEWAY
 RESPONSE_CODES
 NOT_IMPLEMENTED
 CONTINUE
 NOT_AUTHORITATIVE

B<CONTINUE> and B<NOT_AUTHORITATIVE> are aliases for B<DECLINED>.

=item methods

This are the method numbers, commonly used with
the Apache B<method_number> method.

 METHODS
 M_CONNECT
 M_DELETE
 M_GET
 M_INVALID
 M_OPTIONS
 M_POST
 M_PUT
 M_TRACE 
 M_PATCH
 M_PROPFIND
 M_PROPPATCH
 M_MKCOL
 M_COPY
 M_MOVE
 M_LOCK
 M_UNLOCK

=item options

These constants are most commonly used with 
the Apache B<allow_options> method:

 OPT_NONE
 OPT_INDEXES
 OPT_INCLUDES 
 OPT_SYM_LINKS
 OPT_EXECCGI
 OPT_UNSET
 OPT_INCNOEXEC
 OPT_SYM_OWNER
 OPT_MULTI
 OPT_ALL

=item satisfy

These constants are most commonly used with 
the Apache B<satisfies> method:

 SATISFY_ALL
 SATISFY_ANY
 SATISFY_NOSPEC

=item remotehost

These constants are most commonly used with 
the Apache B<get_remote_host> method:

 REMOTE_HOST
 REMOTE_NAME
 REMOTE_NOLOOKUP
 REMOTE_DOUBLE_REV

=item http

This is the full set of HTTP response codes:
(NOTE: not all implemented here)

 HTTP_OK
 HTTP_MOVED_TEMPORARILY
 HTTP_MOVED_PERMANENTLY
 HTTP_METHOD_NOT_ALLOWED 
 HTTP_NOT_MODIFIED
 HTTP_UNAUTHORIZED
 HTTP_FORBIDDEN
 HTTP_NOT_FOUND
 HTTP_BAD_REQUEST
 HTTP_INTERNAL_SERVER_ERROR
 HTTP_NOT_ACCEPTABLE 
 HTTP_NO_CONTENT
 HTTP_PRECONDITION_FAILED
 HTTP_SERVICE_UNAVAILABLE
 HTTP_VARIANT_ALSO_VARIES

=item server

These are constants related to server version:

 MODULE_MAGIC_NUMBER
 SERVER_VERSION
 SERVER_BUILT

=item config

These are constants related to configuration directives:

 DECLINE_CMD

=item types

These are constants related to internal request types:

 DIR_MAGIC_TYPE

=item override

These constants are used to control and test the context of configuration
directives.

 OR_NONE
 OR_LIMIT
 OR_OPTIONS
 OR_FILEINFO
 OR_AUTHCFG
 OR_INDEXES
 OR_UNSET
 OR_ALL
 ACCESS_CONF
 RSRC_CONF

=item args_how

 RAW_ARGS
 TAKE1
 TAKE2
 TAKE12
 TAKE3
 TAKE23
 TAKE123
 ITERATE
 ITERATE2
 FLAG
 NO_ARGS

=back

=head1 AUTHORS

Doug MacEachern, Gisle Aas and h2xs
