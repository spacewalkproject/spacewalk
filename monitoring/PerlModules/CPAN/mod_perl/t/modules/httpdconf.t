
use Apache::test;

$^W=0;

my $i = 0;

print "1..5\n";

use Apache::httpd_conf ();

mkdir httpd_conf => 0755;

my $conf = Apache::httpd_conf->new(base => "httpd_conf");
$conf->write(Port => 8888);


test ++$i, $conf->Port == 8888;

for (qw(conf/httpd.conf)) {
    test ++$i, -e "httpd_conf/$_";
}

for (qw(DocumentRoot ErrorLog Port)) {
    print "$_ = ", $conf->$_(), "\n";
    test ++$i, $conf->$_();
}

