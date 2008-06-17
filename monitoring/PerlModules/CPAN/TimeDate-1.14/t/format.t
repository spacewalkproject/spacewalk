
use Date::Format qw(ctime time2str);
use Date::Language;

print "1..150\n";

my $i = 1;

$pkg = 'Date::Format::Generic';

while(<DATA>) {
  chomp;
  if (/^(\d+)/) {
    $t = $1;
    next;
  }
  elsif (/^(\w+)/) {
    $pkg = Date::Language->new($1);
    next;
  }

  my($fmt,$res) = split(/\t+/,$_);
  my $str = $pkg->time2str($fmt,$t,'GMT');
  print "# '$fmt'$res'$str'\nnot " unless $str eq $res;
  print "ok ",$i++,"\n";
}

__DATA__
936709362 # Tue Sep  7 11:22:42 1999 GMT
%y	99
%Y	1999
%%	%
%a	Tue
%A	Tuesday
%b	Sep
%B	September
%c	09/07/99 13:02:42
%C	Tue Sep  7 13:02:42 GMT 1999
%d	07
%e	 7
%D	09/07/99
%h	Sep
%H	13
%I	01
%j	250
%k	13
%l	 1
%L	9
%m	09
%M	02
%o	 7th
%p	PM
%q	3
%r	01:02:42 PM
%R	13:02
%s	936709362
%S	42
%T	13:02:42
%U	36
%w	2
%W	36
%x	09/07/99
%X	13:02:42
%y	99
%Y	1999
%Z	GMT
%z	+0000
%Od	VII
%Oe	VII
%OH	XIII
%OI	I
%Oj	CCL
%Ok	XIII
%Ol	I
%Om	IX
%OM	II
%Oq	III
%OY	MCMXCIX
%Oy	XCIX
German
%y	99
%Y	1999
%%	%
%a	Die
%A	Dienstag
%b	Sep
%B	September
%c	09/07/99 13:02:42
%C	Die Sep  7 13:02:42 GMT 1999
%d	07
%e	 7
%D	09/07/99
%h	Sep
%H	13
%I	01
%j	250
%k	13
%l	 1
%L	9
%m	09
%M	02
%o	 7.
%p	PM
%q	3
%r	01:02:42 PM
%R	13:02
%s	936709362
%S	42
%T	13:02:42
%U	36
%w	2
%W	36
%x	09/07/99
%X	13:02:42
%y	99
%Y	1999
%Z	GMT
%z	+0000
%Od	VII
%Oe	VII
%OH	XIII
%OI	I
%Oj	CCL
%Ok	XIII
%Ol	I
%Om	IX
%OM	II
%Oq	III
%OY	MCMXCIX
%Oy	XCIX
Italian
%y	99
%Y	1999
%%	%
%a	Mar
%A	Martedi
%b	Set
%B	Settembre
%c	09/07/99 13:02:42
%C	Mar Set  7 13:02:42 GMT 1999
%d	07
%e	 7
%D	09/07/99
%h	Set
%H	13
%I	01
%j	250
%k	13
%l	 1
%L	9
%m	09
%M	02
%o	 7th
%p	PM
%q	3
%r	01:02:42 PM
%R	13:02
%s	936709362
%S	42
%T	13:02:42
%U	36
%w	2
%W	36
%x	09/07/99
%X	13:02:42
%y	99
%Y	1999
%Z	GMT
%z	+0000
%Od	VII
%Oe	VII
%OH	XIII
%OI	I
%Oj	CCL
%Ok	XIII
%Ol	I
%Om	IX
%OM	II
%Oq	III
%OY	MCMXCIX
%Oy	XCIX
