package Crypt::GeneratePassword;
use strict;

=head1 NAME

Crypt::GeneratePassword - generate secure random pronounceable passwords

=head1 SYNOPSIS

  use Crypt::GeneratePassword qw(word chars);
  $word = word($minlen,$maxlen);
  $word = chars($minlen,$maxlen);
  *Crypt::GeneratePassword::restrict = \&my_restriction_filter;

=head1 DESCRIPTION

Crypt::GeneratePassword generates random passwords that are
(more or less) pronounceable. Unlike Crypt::RandPasswd, it
doesn't use the FIPS-181 NIST standard, which is proven to be
insecure. It does use a similar interface, so it should be a
drop-in replacement in most cases.

If you want to use passwords from a different language than english,
you can use one of the packaged alternate unit tables or generate
your own. See below for details.

For details on why FIPS-181 is insecure and why the solution
used in this module is reasonably secure, see "A New Attack on
Random Pronounceable Password Generators" by Ravi Ganesan and
Chris Davies, available online in may places - use your
favourite search engine.

This module improves on FIPS-181 using a true random selection with
the word generator as mere filter. Other improvements are
better pronounceability using third order approximation instead
of second order and multi-language support.
Drawback of this method is that it is usually slower. Then again,
computer speed has improved a little since 1977.

=head1 Functions

=cut

require Exporter;
@Crypt::GeneratePassword::ISA = ('Exporter');
@Crypt::GeneratePassword::EXPORT_OK = qw(word word3 analyze analyze3 chars generate_language load_language);
%Crypt::GeneratePassword::EXPORT_TAGS = ( 'all' => [ @Crypt::GeneratePassword::EXPORT_OK ] );

my $default_language = 'en';
use vars qw(%languages);
%languages = ();

=head2 chars

  $word = chars($minlen, $maxlen [, $set [, $characters, $maxcount ] ... ] );

Generatess a completely random word between $minlen and $maxlen in length.
If $set is given, it must be an array ref of characters to use. You can
restrict occurrence of some characters by providing ($characters, $maxcount)
pairs, as many as you like. $characters must be a string consisting of those
characters which may appear at most $maxcount times in the word.

Note that the length is determined via relative probability, not uniformly.

=cut

my @signs = ('0'..'9', '%', '$', '_', '-', '+', '*', '&', '/', '=', '!', '#');
my $signs = join('',@signs);
my @caps = ('A' .. 'Z');
my $caps = join('',@caps);

my @set = (
	   [ ["\x00",'a'..'z'], ["\x00",'a'..'z',@caps] ],
	   [ ["\x00",'a'..'z',@signs], ["\x00",'a'..'z',@caps,@signs] ]
	  );

sub chars($$;$@) {
  my ($minlen, $maxlen, $set, @restrict) = @_;
  $set ||= $set[1][1];
  my $res;
  my $diff = $maxlen-$minlen;
  WORD: {
    $res = join '', map { $$set[rand(@$set)] } 1..$maxlen;
    $res =~ s/\x00{0,$diff}$//;
    redo if $res =~ m/\x00/;
    for (my $i = 0; $i < @restrict; $i+=2) {
      my $match = $restrict[$i];
      my $more = int($restrict[$i+1])+1;
      redo WORD if $res =~ m/([\Q$match\E].*){$more,}/;
    }
  }
  return $res;
}

=head2 word

  $word = word($minlen, $maxlen [, $lang [, $signs [, $caps [, $minfreq, $avgfreq ] ] ] );
  $word = word3($minlen, $maxlen [, $lang [, $signs [, $caps [, $minfreq, $avgfreq ] ] ] );

Generates a random pronounceable word. The length of the returned
word will be between $minlen and $maxlen. If you supply a non-zero
value for $numbers, up to that many numbers and special characters
will occur in the password. If you specify a non-zero value for $caps,
up to this many characters will be upper case. $lang is the language
description to use, loaded via load_language or built-in. Built-in
languages are: 'en' (english) and 'de' (german). Contributions
welcome. The default language is 'en' but may be changed by calling
load_language with a true value as third parameter. Pass undef as
language to select the current default language. $minfreq and $minsum
determine quality of the password: $minfreq and $avgfreq are the minimum
frequency each quad/trigram must have and the average frequency that the
quad/trigrams must have for a word to be selected. Both are values between 0.0
and 1.0, specifying the percentage of the maximum frequency. Higher
values create less secure, better pronounceable passwords and are slower.
Useful $minfreq values are usually between 0.001 and 0.0001, useful $avgfreq
values are around 0.05 for trigrams (word3) and 0.001 for quadgrams (word).

=cut

use vars qw($total);

sub word($$;$$$$$) {
  my $language = splice(@_,2,1) || '';
  $language =~ s/[^a-zA-Z_]//g;
  $language ||= $default_language;
  eval "require Crypt::GeneratePassword::$language";
  my $lang = $languages{$language};
  die "language '${language}' not found" if !$lang;

  my ($minlen, $maxlen, $numbers, $capitals, $minfreq, $avgfreq) = map { int($_) } @_;
  $minfreq ||= 0;
  $avgfreq ||= 0.001;
  $minfreq = int($$lang{'maxquad'}*$minfreq) || 1;
  $avgfreq = int($$lang{'maxquad'}*$avgfreq);

 WORD: {
    my $randword = chars($minlen,$maxlen,$set[$numbers?1:0][$capitals?1:0],($numbers?($signs,$numbers):()),($capitals?($caps,$capitals):()));
    $total++;
    my $stripped = lc($randword);
    $stripped =~ s/[\Q$signs\E]//g;
    my $sum = 0;
    my $k0 = -1;
    my $k1 = -1;
    my $k2 = -1;
    my $k3 = -1;

    foreach my $char (split(//,$stripped)) {
      $k3 = $char;
      if ($k3 gt 'Z') {
	$k3 = ord($k3) - ord('a');
      } else {
	$k3 = ord($k3) - ord('A');
      }

      if ($k0 > 0) {
	redo WORD if $$lang{'quads'}[$k0][$k1][$k2][$k3] < $minfreq;
	$sum += $$lang{'quads'}[$k0][$k1][$k2][$k3];
      }

      $k0 = $k1;
      $k1 = $k2;
      $k2 = $k3;
    }
    redo if $sum/length($stripped) < $avgfreq;
    redo if (restrict($stripped,$language));
    return $randword;
  }
}

sub word3($$;$$$$$) {
  my $language = splice(@_,2,1) || '';
  $language =~ s/[^a-zA-Z_]//g;
  $language ||= $default_language;
  eval "require Crypt::GeneratePassword::$language";
  my $lang = $languages{$language};
  die "language '${language}' not found" if !$lang;

  my ($minlen, $maxlen, $numbers, $capitals, $minfreq, $avgfreq) = map { int($_) } @_;
  $minfreq ||= 0.01;
  $avgfreq ||= 0.05;
  $minfreq = int($$lang{'maxtri'}*$minfreq) || 1;
  $avgfreq = int($$lang{'maxtri'}*$avgfreq);

 WORD: {
    my $randword = chars($minlen,$maxlen,$set[$numbers?1:0][$capitals?1:0],($numbers?($signs,$numbers):()),($capitals?($caps,$capitals):()));
    $total++;
    my $stripped = lc($randword);
    $stripped =~ s/[\Q$signs\E]//g;
    my $sum = 0;
    my $k1 = -1;
    my $k2 = -1;
    my $k3 = -1;

    foreach my $char (split(//,$stripped)) {
      $k3 = $char;
      if ($k3 gt 'Z') {
	$k3 = ord($k3) - ord('a');
      } else {
	$k3 = ord($k3) - ord('A');
      }

      if ($k1 > 0) {
	redo WORD if $$lang{'tris'}[$k1][$k2][$k3] < $minfreq;
	$sum += $$lang{'tris'}[$k1][$k2][$k3];
      }

      $k1 = $k2;
      $k2 = $k3;
    }
    redo if $sum/length($stripped) < $avgfreq;
    redo if (restrict($stripped,$language));
    return $randword;
  }
}

=head2 analyze

  $ratio = analyze($count,@word_params);
  $ratio = analyze3($count,@word_params);

Returns a statistical(!) security ratio to measure password
quality. $ratio is the ratio of passwords chosen among all
possible ones, e.g. a ratio of 0.0149 means 1.49% of the
theoretical password space was actually considered a
pronounceable password. Since this analysis is only
statistical, it proves absolutely nothing if you are deeply
concerned about security - but in that case you should use
chars(), not word() anyways. In reality, it says a lot
about your chosen parameters if you use large values for
$count.

=cut

sub analyze($@) {
  my $count = shift;
  $total = 0;
  for (1..$count) {
    my $word = &word(@_);
  }
  return $count/$total;
}

sub analyze3($@) {
  my $count = shift;
  $total = 0;
  for (1..$count) {
    my $word = &word3(@_);
  }
  return $count/$total;
}

=head2 generate_language

  $language_description = generate_language($wordlist);

Generates a language description which can be saved in a file and/or
loaded with load_language. $wordlist can be a string containing
whitespace separated words, an array ref containing one word per
element or a file handle or name to read words from, one word per line7.
Alternatively, you may pass an array directly, not as reference.
A language description is about 1MB in size.

If you generate a general-purpose language description for a
language not yet built-in, feel free to contribute it for inclusion
into this package.

=cut

sub generate_language($@) {
  my ($wordlist) = @_;
  if (@_ > 1) {
    $wordlist = \@_;
  } elsif (!ref($wordlist)) {
    $wordlist = [ split(/\s+/,$wordlist) ];
    if (@$wordlist == 1) {
      local *FH;
      open(FH,'<'.$$wordlist[0]);
      $wordlist = [ <FH> ];
      close(FH);
    }
  } elsif (ref($wordlist) ne 'ARRAY') {
    $wordlist = [ <$wordlist> ];
  }

  my @quads = map { [ map { [ map { [ map { 0 } 1..26 ] } 1..26 ] } 1..26 ] } 1..26;
  my @tris = map { [ map { [ map { 0 } 1..26 ] } 1..26 ] } 1..26;
  my $sigmaquad = 0;
  my $maxquad = 0;
  my $sigmatri = 0;
  my $maxtri = 0;

  foreach my $word (@$wordlist) {
    my $k0 = -1;
    my $k1 = -1;
    my $k2 = -1;
    my $k3 = -1;

    foreach my $char (split(//,$word)) {
      $k3 = $char;
      if ($k3 gt 'Z') {
	$k3 = ord($k3) - ord('a');
      } else {
	$k3 = ord($k3) - ord('A');
      }

      next unless ($k3 >= 0 && $k3 <= 25);

      if ($k0 >= 0) {
	$quads[$k0][$k1][$k2][$k3]++;
	$sigmaquad++;
	if ($quads[$k0][$k1][$k2][$k3] > $maxquad) {
	  $maxquad = $quads[$k0][$k1][$k2][$k3];
	}
      }

      if ($k1 >= 0) {
	$tris[$k1][$k2][$k3]++;
	$sigmatri++;
	if ($tris[$k1][$k2][$k3] > $maxtri) {
	  $maxtri = $tris[$k1][$k2][$k3];
	}
      }

      $k0 = $k1;
      $k1 = $k2;
      $k2 = $k3;
    }
  }

  {
    require Data::Dumper;
    local $Data::Dumper::Indent = 0;
    local $Data::Dumper::Purity = 0;
    local $Data::Dumper::Pad = '';
    local $Data::Dumper::Deepcopy = 1;
    local $Data::Dumper::Terse = 1;

    my $res = Data::Dumper::Dumper(
			    {
			     maxtri => $maxtri,
			     sigmatri => $sigmatri,
			     maxquad => $maxquad,
			     sigmaquad => $sigmaquad,
			     tris => \@tris,
			     quads => \@quads,
			    }
			   );
    $res =~ s/[' ]//g;
    return $res;
  }
}

=head2 load_language

  load_language($language_description, $name [, $default]);

Loads a language description which is then available in words().
$language_desription is a string returned by generate_language,
$name is a name of your choice which is used to select this
language as the fifth parameter of words(). You should use the
well-known ISO two letter language codes if possible, for best
interoperability.

If you specify $default with a true value, this language will
be made global default language. If you give undef as
$language_description, only the default language will be changed.

=cut

sub load_language($$;$) {
  my ($desc,$name,$default) = @_;
  $languages{$name} = eval $desc if $desc;
  $default_language = $name if $default;
}

=head2 restrict

  $forbidden = restrict($word,$language);

Filters undesirable words. Returns false if the $word is allowed
in language $lang, false otherwise. Change this to a function of
your choice by doing something like this:

    {
      local $^W; # squelch sub redef warning.
      *Crypt::GeneratePassword::restrict = \&my_filter;
    }

The default implementation scans for a few letter sequences that
english or german people might find offending, mostly because of
their sexual nature. You might want to hook up a regular password
checker here, or a wordlist comparison.

=cut

sub restrict($$) {
  return ($_[0] =~ m/f.ck|ass|rsch|tit|cum|ack|asm|orn|eil|otz|oes/i);
}

=head1 VERSION

This document describes version 0.02

=cut

$Crypt::GeneratePassword::VERSION = 0.02;

=head1 AUTHOR

Copyright 2002 by Jörg Walter <jwalt@cpan.org>,
inspired by ideas from Tom Van Vleck and Morris
Gasser/FIPS-181.

=head1 COPYRIGHT

This perl module is free software; it may be redistributed and/or modified
under the same terms as Perl itself.


=head1 SEE ALSO

L<Crypt::RandPasswd>.

=cut
