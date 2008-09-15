shift->send_http_header("text/plain");

unless($My::config_is_perl) {
    while (my($key,$val) = each %ENV) {
	print "$key=$val\n";
    }
}

print "TOTAL: ", scalar keys %ENV;
