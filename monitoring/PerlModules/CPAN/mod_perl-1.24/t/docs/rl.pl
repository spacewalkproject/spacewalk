#test Apache::RegistryLoader

{
    use Apache::RegistryLoader ();
    use DirHandle ();
    use strict;
    
    my $rl = Apache::RegistryLoader->new(trans => sub {
	my $uri = shift; 
	$Apache::Server::CWD."/t/net${uri}";
    });

    my $path = Apache->server_root_relative("net/perl");
    my $d = DirHandle->new($path) or die "Can't open $path $!";

    for my $file ($d->read) {
	next if $file eq "hooks.pl"; 
	next unless $file =~ /\.pl$/;
	Apache->untaint($file);
	my $status = $rl->handler("/perl/$file");
	unless($status == 200) {
	    warn "pre-load of `/perl/$file' failed, status=$status\n";
	}
    }
}

1;
