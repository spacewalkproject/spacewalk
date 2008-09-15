#Configuration directives specific to mod_perl
ServerRoot /opt/www
ServerName localhost
DocumentRoot docs

#mod_perl stuff
PerlScript t/docs/startup.pl

PerlTaintCheck On

Alias /perl/ /opt/www/perl/
Port  8529

<Perl>

$User  = getpwuid($>) || $>;
$Group = getgrgid($)) || $); 

$ServerAdmin = $User;

my(%handlers) = (
   "/perl"    => "",
   "/perl/io" => "",
   "/perl/perl-status" => "Apache::Status",
);

for (keys %handlers) {
    $Location{$_} = {
	PerlHandler => $handlers{$_} || "Apache::Registry",
	SetHandler  => "perl-script",
	Options     => "ExecCGI",
    };
}

$Location{"/perl/io"}->{PerlSendHeader} = "On";

for (qw(status info)) {
    $Location{"/server-$_"} = {
	SetHandler => "server-$_",
    };
}

@PerlModule = qw(Config Net::Ping);

$Location{"/~dougm/"} = {
    AuthUserFile => '/tmp/htpasswd',
    AuthType => 'Basic',
    AuthName => 'test',
    Limit => {
	METHODS => 'GET POST',
	require => 'user dougm',
    },
};

</Perl>



