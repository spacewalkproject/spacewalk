# This -*- perl -*- script makes the rplyto_demo script
# $Id: rplyto_demo.PL,v 1.1 2000-10-20 02:12:06 dfaraldo Exp $

$script = "bin/rplyto_demo";

use Config;
use Cwd;
unlink($script);
open MIR, ">$script" or die "open for writing $script: $!";
print MIR $Config{'startperl'}," -w\n";
$cwd = Cwd::getcwd();
print MIR "use lib qw($cwd/blib);\n";
print MIR <DATA>; 
chmod(0755, $script);

__DATA__
use Mail::Internet;

$mail = Mail::Internet->new([<>]);
$rply = $mail->reply(Keep => [qw(Newsgroups)]);

$file = "/tmp/reply.$$";

open(REPLY,">$file") || die "Cannot open $file:$!\n";

$rply->print(\*REPLY);

close(REPLY);

$editor = $ENV{"EDITOR"} || die "\$EDITOR not defined\n";

warn "$editor :$!\n" if (system("$editor $file"));

# Cleanup
unlink($file,$file . '%',$file . '~');

exit 0;


