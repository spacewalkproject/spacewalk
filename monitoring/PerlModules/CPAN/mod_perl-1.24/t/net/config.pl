package net;

BEGIN { 
    for( qw(HTTP_PROXY http_proxy) ) {
	delete $ENV{$_};
    }
}

$Is_Win32 = ($^O eq "MSWin32"); 

# Configure these for your local system
$httpserver  = "localhost:8529";
$perldir      = "/perl";
#######################################
%callback_hooks = ();

{
    package main;

    # avoid -w warnings
    sub dummy_sub { 
	return($net::httpserver, 
	       $net::perldir, 
	       $net::Is_Win32,
	       %net::callback_hooks,
	       );
    }
}
  
1;



%callback_hooks = (
   PERL_STACKED_HANDLERS => 1,
   PERL_SAFE_STARTUP => 0,
   PERL_METHOD_HANDLERS => 1,
   PERL_ACCESS => 1,
   PERL_HEADER_PARSER => 1,
   PERL_TIE_SCRIPTNAME => 0,
   PERL_UTIL_API => 1,
   PERL_LOG_API => 1,
   PERL_AUTOPRELOAD => 0,
   PERL_TABLE_API => 1,
   PERL_DSO_UNLOAD => 0,
   PERL_CONNECTION_API => 1,
   PERL_AUTHZ => 1,
   DO_INTERNAL_REDIRECT => 0,
   PERL_DIRECTIVE_HANDLERS => 1,
   PERL_DEFAULT_OPMASK => 0,
   PERL_SERVER_API => 1,
   PERL_DISPATCH => 1,
   XS_IMPORT => 0,
   PERL_INIT => 1,
   PERL_STARTUP_DONE_CHECK => 0,
   PERL_CHILD_INIT => 1,
   PERL_FILE_API => 1,
   PERL_CHILD_EXIT => 1,
   PERL_HANDLER => 1,
   PERL_RUN_XS => 0,
   PERL_STASH_POST_DATA => 0,
   PERL_LOG => 1,
   PERL_TYPE => 1,
   PERL_ORALL_OPMASK => 0,
   PERL_MARK_WHERE => 0,
   PERL_RESTART => 1,
   PERL_AUTHEN => 1,
   PERL_TRANS => 1,
   PERL_CLEANUP => 1,
   PERL_URI_API => 1,
   PERL_POST_READ_REQUEST => 1,
   PERL_FIXUP => 1,
   MMN => 19990320,
);
1;
