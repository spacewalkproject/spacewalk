# This -*- perl -*- script makes the send_demo script
# $Id: send_demo.PL,v 1.1 2000-10-20 02:12:06 dfaraldo Exp $

$script = "bin/send_demo";

use Config;
use Cwd;
unlink($script);
$cwd = Cwd::getcwd();
open MIR, ">$script" or die "open for writing $script: $!";
print MIR $Config{'startperl'}," -w\n";
print MIR "use lib qw($cwd/blib);\n";
print MIR <DATA>; 
chmod(0755, $script);

__DATA__
require Mail::Internet;
require Mail::Alias;
use Getopt::Long;

sub expand_aliases 
{
 my $mail = shift;
 my $aliasfile = $ENV{HOME} . "/.mailrc";
 my($tag,$id);

 if( -f $aliasfile )
  {
   my $alias = Mail::Alias::Binmail->new($aliasfile);
   # Expand aliases

   foreach $tag (qw(To Cc Bcc)) 
    {
     @ids = ();
     foreach $id (Mail::Address->parse($mail->get($tag)))
      {
       my $addr = $id->address;
       my @expn = $alias->expand($addr);
       if(scalar(@expn) == 1)
        {
         $id->address($expn[0]);
         push(@ids,$id->format);
        }
       else
        {
         push(@ids,@expn);
        }
      }
     $mail->combine($tag,',');
     $mail->replace($tag, join(", ", @ids));
    }
  }
}


###
### Main program
###

GetOptions(qw(post nosig v));

$opt_post = 1 if $0 =~ m#(\A|/)post\Z#;

$verbose = defined $opt_v && $opt_v ? 1 : 0;
$posting = defined $opt_post && $opt_post ? 1 : 0;
$sign    = defined $opt_nosig && $opt_nosig ? 0 : 1;

$mail =  Mail::Internet->new([ <> ]);

expand_aliases($mail);

$mail->add_signature if($sign);

if($posting)
 {
  my @groups = $mail->nntppost();

  if($verbose && @groups)
   {
    $groups = "Newsgroups: " . join(", ", @groups);
    $groups =~ s/(.{10,78}),/$1\n/g if(length($groups) > 78);
    print $groups,"\n";
   }
 }
else
 {
  $mail->delete('Newsgroups');
 }

@recp = $mail->smtpsend();

if($verbose && @recp)
 {
  $recp = "Recipients: " . join(", ", @recp);
  $recp =~ s/(.{10,78}),/$1\n/g if(length($recp) > 78);
  print $recp,"\n";
 }

exit;


