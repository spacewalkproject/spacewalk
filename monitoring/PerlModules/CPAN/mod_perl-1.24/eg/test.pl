#!/user/local/bin/perl

# your httpd.conf should have something like this:

# Alias /perl/  /real/path/to/perl-scripts/

# <Location /perl>
# SetHandler  perl-script
# PerlHandler Apache::Registry
# PerlSendHeader On
# Options +ExecCGI
# </Location>

print "Content-type: text/html\n\n";

print "<b>Date: ", scalar localtime, "</b><br>\n";

print "%ENV: <br>\n", map { "$_ = $ENV{$_} <br>\n" } keys %ENV;


