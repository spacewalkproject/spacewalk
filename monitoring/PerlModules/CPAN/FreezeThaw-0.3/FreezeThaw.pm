=head1 NAME

FreezeThaw - converting Perl structures to strings and back.

=head1 SYNOPSIS

  use FreezeThaw qw(freeze thaw cmpStr safeFreeze cmpStrHard);
  $string = freeze $data1, $data2, $data3;
  ...
  ($olddata1, $olddata2, $olddata3) = thaw $string;
  if (cmpStr($olddata2,$data2) == 0) {print "OK!"}

=head1 DESCRIPTION

Converts data to/from stringified form, appropriate for
saving-to/reading-from permanent storage.

Deals with objects, circular lists, repeated appearence of the same
refence. Does not deal with overloaded I<stringify> operator yet.

=head1 EXPORT

=over 12

=item Default

None.

=item Exportable

C<freeze thaw cmpStr cmpStrHard safeFreeze>.

=back

=head1 User API

=over 12

=item C<cmpStr>

analogue of C<cmp> for data. Takes two arguments and compares them as
separate entities.

=item C<cmpStrHard>

analogue of C<cmp> for data. Takes two arguments and compares them
considered as a group.

=item C<freeze>

returns a string that encupsulates its arguments (considered as a
group). C<thaw>ing this string leads to a fatal error if arguments to
C<freeze> contained references to C<GLOB>s and C<CODE>s.

=item C<safeFreeze>

returns a string that encupsulates its arguments (considered as a
group). The result is C<thaw>able in the same process. C<thaw>ing the
result in a different process should result in a fatal error if
arguments to C<safeFreeze> contained references to C<GLOB>s and
C<CODE>s.

=item C<thaw>

takes one string argument and returns an array. The elements of the
array are "equivalent" to arguments of the C<freeze> command that
created the string. Can result in a fatal error (see above).

=back

=head1 Developer API

C<FreezeThaw> C<freeze>s and C<thaw>s data blessed in some package by
calling methods C<Freeze> and C<Thaw> in the package. The fallback
methods are provided by the C<FreezeThaw> itself. The fallback
C<Freeze> freezes the "content" of blessed object (from Perl point of
view). The fallback C<Thaw> blesses the C<thaw>ed data back into the package.

So the package needs to define its own methods only if the fallback
methods will fail (for example, for a lot of data the "content" of an
object is an address of some B<C> data). The methods are called like

  $newcooky = $obj->Freeze($cooky);
  $obj = Package->Thaw($content,$cooky);

To save and restore the data the following method are applicable:

  $cooky->FreezeScalar($data,$ignorePackage,$noduplicate);

during Freeze()ing, and

  $data = $cooky->ThawScalar;

Two optional arguments $ignorePackage and $noduplicate regulate
whether the freezing should not call the methods even if $data is a
reference to a blessed object, and whether the data should not be
marked as seen already even if it was seen before. The default methods

  sub UNIVERSAL::Freeze {
    my ($obj, $cooky) = (shift, shift);
    $cooky->FreezeScalar($obj,1,1);
  }

  sub UNIVERSAL::Thaw {
    my ($package, $cooky) = (shift, shift);
    my $obj = $cooky->ThawScalar;
    bless $obj, $package;
  }

call the C<FreezeScalar> method of the $cooky since the freezing
engine will see the data the second time during this call. Indeed, it
is the freezing engine who calls UNIVERSAL::Freeze(), and it calls it
because it needs to freeze $obj. The above call to
$cooky->FreezeScalar() handles the same data back to engine, but
because flags are different, the code does not cycle.

Freezing and thawing $cooky also allows the following additional methods:

  $cooky->isSafe;

to find out whether the current freeze was initiated by C<freeze> or
C<safeFreeze> command. Analogous method for thaw $cooky returns
whether the current thaw operation is considered safe (i.e., either
does not contain cached elsewhere data, or comes from the same
application). You can use 

  $cooky->makeSafe;

to prohibit cached data for the duration of the rest of freezing or
thawing of current object.

Two methods 

  $value = $cooky->repeatedOK;
  $cooky->noRepeated;		# Now repeated are prohibited

allow to find out/change the current setting for allowing repeated
references.

If you want to flush the cache of saved objects you can use

  FreezeThaw->flushCache;

this can invalidate some frozen string, so that thawing them will
result in fatal error.

=head2 Instantiating

Sometimes, when an object from a package is recreated in presense of
repeated references, it is not safe to recreate the internal structure
of an object in one step. In such a situation recreation of an object
is carried out in two steps: in the first the object is C<allocate>d,
in the second it is C<instantiate>d.

The restriction is that during the I<allocation> step you cannot use any
reference to any Perl object that can be referenced from any other
place. This restriction is applied since that object may not exist yet. 

Correspondingly, during I<instantiation> step the previosly I<allocated>
object should be C<filled>, i.e., it can be changed in any way such
that the references to this object remain valid.

The methods are called like this:

  $pre_object_ref = Package->Allocate($pre_pre_object_ref);
	# Returns reference
  Package->Instantiate($pre_object_ref,$cooky);
	# Converts into reference to blessed object

The reverse operations are 

  $object_ref->FreezeEmpty($cooky);
  $object_ref->FreezeInstance($cooky);

during these calls object can C<freezeScalar> some information (in a
usual way) that will be used during C<Allocate> and C<Instantiate>
calls (via C<thawScalar>). Note that the return value of
C<FreezeEmpty> is cached during the phase of creation of uninialized
objects. This B<must> be used like this: the return value is the
reference to the created object, so it is not destructed until other
objects are created, thus the frozen values of the different objects
will not share the same references. Example of bad result:

  $o1->FreezeEmpty($cooky)

freezes C<{}>, and C<$o2-E<gt>FreezeEmpty($cooky)> makes the same. Now
nobody guaranties that that these two copies of C<{}> are different,
unless a reference to the first one is preserved during the call to
C<$o2-E<gt>FreezeEmpty($cooky)>. If C<$o1-E<gt>FreezeEmpty($cooky)>
returns the value of C<{}> it uses, it will be preserved by the
engine.

The helper function C<FreezeThaw::copyContents> is provided for
simplification of instantiation. The syntax is 

  FreezeThaw::copyContents $to, $from;

The function copies contents the object $from point to into what the
object $to points to (including package for blessed references). Both
arguments should be references.

The default methods are provided. They do the following:

=over 12

=item C<FreezeEmpty>

Freezes an I<empty> object of underlying type.

=item C<FreezeInstance>

Calls C<Freeze>.

=item C<Allocate>

Thaws what was frozen by C<FreezeEmpty>.

=item C<Instantiate>

Thaws what was frozen by C<FreezeInstance>, uses C<copyContents> to
transfer this to the $pre_object.

=back

=head1 BUGS/FEATURES

A lot of objects are blessed in some obscure packages by XSUB
typemaps. It is not clear how to (automatically) prevent the
C<UNIVERSAL> methods to be called for objects in these packages.

=cut

require 5.002;			# defined ref stuff...

# Different line noise chars:
#
# $567|			next 567 chars form a scalar
# 
# @34|			next 34 scalars form an array
# 
# %34|			next 34 scalars form a hash
# 
# ?			next scalar is a safe-stamp at beginning
# 
# ?			next scalar is a stringified data
# 
# !  repeated array follows (after a scalar denoting array $#),
# (possibly?) followed by instantiation array. At beginning
#
# <45|			ordinal of element in repeated array
#
# *			stringified glob follows
#
# &			stringified coderef follows
#
# \\			stringified defererenced data follows
#
# >			stringified package name follows, then frozen data
#
# {			stringified package name follows, then allocation data
#
# }			stringified package name follows, then instantiation data
#
# _			frozen form of undef


package FreezeThaw;

use Exporter;

@ISA = qw(Exporter);

use Carp;

@EXPORT_OK = qw(freeze thaw cmpStr cmpStrHard safeFreeze);
$safe = 0;
$lock = (reverse time) ^ $$ ^ \&freezeString; # To distingush processes

sub flushCache {$lock ^= rand; undef %saved;}

sub getref {
  my $ref = ref $_[0];
  if (defined $Empty{$ref}) {
    $ref;
  } else {
    my $obj = shift;
    ($ref) = ("$obj" =~ /=(.*)\(/);
    $ref;
  }
}

sub freezeString {$string .= "\$" . length($_[0]) . '|' . $_[0]}

sub freezeNumber {$string .= $_[0] . '|'}

sub thawString {	# Returns array of a string and offset of rest 
  substr($string, $_[0]) =~ /^\$(\d+)\|/ or confess "Wrong format of frozen string: " . substr($string, $_[0]);
  length($string) - $_[0] > length($1) + 1 + $1 
    or confess "Frozen string too short: `" .
      substr($string, $_[0]) . "', expect " . (length($1) + 2 + $1);
  (substr($string, $_[0] + length($1) + 2, $1), $_[0] + length($1) + 2 + $1);
}

sub thawNumber {	# Returns array of a number and offset of rest 
  substr($string, $_[0]) =~ /^(\d+)\|/ or confess "Wrong format of frozen string: " . substr($string, $_[0]);
  ($1, $_[0] + length($1) + 1);
}

sub freezeArray {
  $string .= '@' . @{$_[0]} . '|'; 
  for (@{$_[0]}) {
    freezeScalar($_);
  }
}

sub thawArray {
  substr($string, $_[0]) =~ /^[\@%](\d+)\|/ # % To make it possible thaw hashes
    or confess "Wrong format of frozen array: \n$_[0]";
  my $count = $1;
  my $off = $_[0] + 2 + length $count;
  my (@res, $res);
  while ($count and length $string > $off) {
    ($res,$off) = thawScalar($off);
    push(@res,$res);
    --$count;
  }
  confess "Wrong length of data in thawing Array: $count left" if $count;
  (\@res, $off);
}

sub freezeHash {
  my @arr = sort keys %{$_[0]};
  $string .= '%' . (2*@arr) . '|';
  for (@arr, @{$_[0]}{@arr}) {
    freezeScalar($_);
  }
}

sub thawHash {
  my ($arr, $rest) = &thawArray;
  my %hash;
  my $l = @$arr/2;
  foreach (0 .. $l - 1) {
    $hash{$arr->[$_]} = $arr->[$l + $_];
  }
  (\%hash,$rest);
}

# Second optional argument: ignore the package
# Third optional one: do not check for duplicates on outer level

sub freezeScalar {
  $string .= '_', return unless defined $_[0];
  return &freezeString unless ref $_[0];
  my $ref = ref $_[0];
  if ($_[1] and $ref) {
    $ref = $1 if "$_[0]" =~ /=(\w+)/;
  }
  # Die if a) repeated prohibited, b) met, c) not explicitely requested to ingore.
  confess "Repeated reference met when prohibited" 
    if $norepeated && !$_[2] && defined $count{"$_[0]"};
  if ($secondpass and !$_[2]) {
    $string .= "<$address{$_[0]}|", return
      if defined $count{"$_[0]"} and $count{"$_[0]"} > 1;
  } elsif (!$_[2]) {
    # $count{"$_[0]"} is defined if we have seen it on this pass.
    $address{$_[0]} = @multiple, push(@multiple, $_[0]) 
      if defined $count{"$_[0]"} and not exists $address{$_[0]};
    # This is for debugging and shortening thrown-away output (also
    # internal data in arrays and hashes is not duplicated).
    $string .= "<$address{$_[0]}|", ++$count{"$_[0]"}, return
      if defined $count{"$_[0]"};
    ++$count{"$_[0]"};
  }
  return &freezeArray if $ref eq ARRAY;
  return &freezeHash if $ref eq HASH;
  $string .= "*", return &freezeString 
    if $ref eq GLOB and !$safe;
  $string .= "&", return &freezeString 
    if $ref eq CODE and !$safe;
  $string .= '\\', return &freezeScalar( $ {shift()} ) 
    if $ref eq REF or $ref eq SCALAR;
  if ($noCache and (($ref eq CODE) or $ref eq GLOB)) {
    confess "CODE and GLOB references prohibited now";
  }
  if ($safe and (($ref eq CODE) or $ref eq GLOB)) {
    $unsafe = 1;
    $saved{"$_[0]"} = $_[0] unless defined $saved{"$_[0]"};
    $string .= "?";
    return &freezeString;
  }
  $string .= '>';
  local $norepeated = $norepeated;
  local $noCache = $noCache;
  freezePackage(ref $_[0]);
  $_[0]->Freeze($cooky);
}

sub freezePackage {
  my $packageid = $seen_packages{$_[0]};
  if (defined $packageid) {
    $string .= ')';
    &freezeNumber( $packageid );
  } else {
    $string .= '>';
    &freezeNumber( $seen_packages );
    &freezeScalar( $_[0] );
    $seen_packages{ $_[0] } = $seen_packages++;
  }
}

sub thawPackage {		# First argument: offset
  my $key = substr($string,$_[0],1);
  my ($get, $rest, $id);
  ($id, $rest) = &thawNumber($_[0] + 1);
  if ($key eq ')') {
    $get = $seen_packages{$id};
  } else {
    ($get, $rest) = &thawString($rest);
    $seen_packages{$id} = $get;
  }
  ($get, $rest);
}

# First argument: offset; Optional other: index in the @uninit array

sub thawScalar {
  my $key = substr($string,$_[0],1);
  if ($key eq "\$") {&thawString}
  elsif ($key eq '@') {&thawArray}
  elsif ($key eq '%') {&thawHash}
  elsif ($key eq '\\') {
    my ($out,$rest) = &thawScalar( $_[0]+1 ) ;
    (\$out,$rest);
  }
  elsif ($key eq '_') { (undef, $_[0]+1) }
  elsif ($key eq '&') {confess "Do not know how to thaw CODE"}
  elsif ($key eq '*') {confess "Do not know how to thaw GLOB"}
  elsif ($key eq '?') {
    my ($address,$rest) = &thawScalar( $_[0]+1 ) ;
    confess "The saved data accessed in unprotected thaw" unless $unsafe;
    confess "The saved data disappeared somewhere" 
      unless defined $saved{$address};
    ($saved{$address},$rest);
  } elsif ($key eq '<') {
    confess "Repeated data prohibited at this moment" unless $uninitOK;
    my ($off,$end) = &thawNumber ($_[0]+1);
    ($uninit[$off],$end);
  } elsif ($key eq '>' or $key eq '{' or $key eq '}') {
    my ($package,$rest) = &thawPackage( $_[0]+1 );
    my $cooky = bless \$rest, FreezeThaw::TCooky;
    local $uninitOK = $uninitOK;
    local $unsafe = $unsafe;
    if ($key eq '{') {
      my $res = $package->Allocate($cooky);
      ($res, $rest);
    } elsif ($key eq '}') {
      warn "Here it is undef!" unless defined $_[1];
      $package->Instantiate($uninit[$_[1]],$cooky);
      (undef, $rest);
    } else {
      ($package->Thaw($cooky),$rest);
    }
  } else {
    confess "Do not know how to thaw data with code `$key'";
  } 
}

%Empty = ( ARRAY   => sub {[]}, HASH => sub {{}}, 
	   SCALAR  => sub {my $undef; \$undef},
	   REF     => sub {my $undef; \$undef},
	   CODE    => 0, GLOB => 0); # 0 means atomic

sub freezeEmpty {		# Takes a type, freezes ref to empty object
  my $e = $Empty{ref $_[0]};
  if (ref $e) {
    my $cache = &$e;
    freezeScalar $cache;
    $cache;
  } elsif (defined $e) {
    my $cache = shift;
    freezeScalar($cache,1,1);	# Atomic
    $cache;
  } else {
    $string .= "{"; 
    freezePackage ref $_[0];
    $_[0]->FreezeEmpty($cooky);
  }
}

sub freeze {
  local @multiple;
  local %seen_packages;
  local $seen_packages = 0;
  local %seen_packages;
#  local @seentypes;
  local %count;
  local %address;
  local $string = 'FrT;';
  local $unsafe;
  local $noCache;
  local $cooky = bless \$cooky, FreezeThaw::FCooky; # Just something fake
  local $secondpass;
  freezeScalar(\@_);
  if (@multiple) {
    # Now repeated structures are enumerated with order of *second* time
    # they appear in the what we freeze.
    # What we want is to have them enumerated with respect to the first time
####    $string = '';		# Start again
####    @multiple = ();
####    %address = ();
####    for (keys %count) {
####      $count{$_} = undef if $count{$_} <= 1; # As at start
####      $count{$_} = 0 if $count{$_}; # As at start
####    }
####    $seen_packages = 0;
####    %seen_packages = ();
####    freezeScalar(\@_);
    # Now repeated structures are enumerated with order of first time
    # they appear in the what we freeze
####    my $oldstring = substr $string, 4;
    $string = 'FrT;!'; # Start again
    $seen_packages = 0;
    %seen_packages = ();	# XXXX We reshuffle parts of the
                                # string, so the order of packages may
                                # be wrong...
    freezeNumber($#multiple);
    {
      my @cache;		# Force different values for different
                                # empty objects.
      foreach (@multiple) {
	push @cache, freezeEmpty $_;
      }
    }
#    for (keys %count) {
#      $count{$_} = undef 
#	if !(defined $count{$_}) or $count{$_} <= 1; # As at start
#    }
    # $string .= '@' . @multiple . '|';
    $secondpass = 1;
    for (@multiple) {
      freezeScalar($_,0,1,1), next if defined $Empty{ref $_};
      $string .= "}"; 
      freezePackage ref $_;
      $_->FreezeInstance($cooky);
    }
####    $string .= $oldstring;
    freezeScalar(\@_);
  }
  return "FrT;?\$" . length($lock) . "|" . $lock . substr $string, 4
    if $unsafe;
  $string;    
}

sub safeFreeze {
  local $safe = 1;
  &freeze;
}

sub copyContents {  # Given two references, copies contents of the
                    # second one to the first one, provided they have
		    # the same basic type. The package is copied too.
  my($first,$second) = @_;
  my $ref = getref $second;
  if ($ref eq 'SCALAR' or $ref eq 'REF') {
    $$first = $$second;
  } elsif ($ref eq 'ARRAY') {
    @$first = @$second;
  } elsif ($ref eq 'HASH') {
    %$first = %$second;
  } else {
    croak "Don't know how to copyContents of type `$ref'";
  }
  if (ref $second ne ref $first) { # Rebless
    bless $first, ref $second;
  }
}

sub thaw {
  confess "thaw requires one argument" unless @_ ==1;
  local $string = shift;
  local %seen_packages;
  my $initoff = 0;
  #print STDERR "Thawing `$string'", substr ($string, 0, 4), "\n";
  if (substr($string, 0, 4) ne 'FrT;') {
    warn "Signature not present, continuing anyway" if $^W;
  } else {
    $initoff = 4;
  }
  local $unsafe = $initoff + (substr($string, $initoff, 1) eq "?" ? 1 : 0);
  if ($unsafe != $initoff) {
    my $key;
    ($key,$unsafe) = thawScalar($unsafe);
    confess "The lock in frozen data does not match the key" 
      unless $key eq $lock;
  }
  local @multiple;
  local $uninitOK = 1;		# The methods can change it.
  my $repeated = substr($string,$unsafe,1) eq '!' ? 1 : 0;
  my ($res, $off);
  if ($repeated) {
    ($res, $off) = thawNumber($repeated + $unsafe);
  } else {
    ($res, $off) = thawScalar($repeated + $unsafe);
  }
  my $cooky = bless \$off, FreezeThaw::TCooky;
  if ($repeated) {
    local @uninit;
    my $lst = $res;
    foreach (0..$lst) {
      ($res, $off) = thawScalar($off, $_);
      push(@uninit, $res);
    }
    my @init;
    foreach (0..$lst) {
      ($res, $off) = thawScalar($off, $_);
      push(@init, $res);
    }
    #($init, $off)  = thawScalar($off);
    #print "Instantiating...\n";
    #my $ref;
    for (0..$#uninit) {
      copyContents $uninit[$_], $init[$_] if ref $init[$_];
    }
    ($res, $off) = thawScalar($off);
  }
  croak "Extra elements in frozen structure: `" . substr($string,$off) . "'"
    if $off != length $string;
  return @$res;
}

sub cmpStr {
  confess "Compare requires two arguments" unless @_ == 2;
  freeze(shift) cmp freeze(shift);
}

sub cmpStrHard {
  confess "Compare requires two arguments" unless @_ == 2;
  local @multiple;
#  local @seentypes;
  local %count;
  local %address;
  local $string = 'FrT;';
  local $unsafe;
  local $noCache;
  local $cooky = bless \$cooky, FreezeThaw::FCooky; # Just something fake
  freezeScalar($_[0]);
  my %cnt1 = %count;
  freezeScalar($_[1]);
  my %cnt2 = %count;
  %count = ();
  # Now all the caches are filled, delete the entries for guys which
  # are in one argument only.
  my ($elt, $val);
  while (($elt, $val) = each %cnt1) {
    $count{$elt}++ if $cnt2{$elt} > $cnt1{$elt};
  }
  $string = '';
  freezeScalar($_[0]);
  my $str1 = $string;
  $string = '';
  freezeScalar($_[1]);
  $str1 cmp $string;
}

#   local $string = freeze(shift,shift);
#   local $uninitOK = 1;
#   #print "$string\n";
#   my $off = 7;			# Hardwired offset after @2|
#   if (substr($string,4,1) eq '!') {
#     $off = 5;			# Hardwired offset after !
#     my ($uninit, $len);
#     ($len,$off) = thawScalar $off;
#     local @uninit;
#     foreach (0..$len) {
#       ($uninit,$off) = thawScalar $off, $_;
#     }
#     $off += 3;			# Hardwired offset after @2|
#   }
#   croak "Unknown format of frozen array: " . substr($string,$off-3)
#     unless substr($string,$off-3,1) eq '@';
#   my ($first,$off2) = thawScalar $off;
#   my $off3;
#   ($first,$off3) = thawScalar $off2;
#   substr($string, $off, $off2-$off) cmp substr($string,$off2,$off3-$off2);
# }

sub FreezeThaw::FCooky::FreezeScalar {
  shift;
  &freezeScalar;
}

sub FreezeThaw::FCooky::isSafe {
  $safe || $noCache;
}

sub FreezeThaw::FCooky::makeSafe {
  $noCache = 1;
}

sub FreezeThaw::FCooky::repeatedOK {
  !$norepeated;
}

sub FreezeThaw::FCooky::noRepeated {
  $norepeated = 1;
}

sub FreezeThaw::TCooky::repeatedOK {
  $uninitOK;
}

sub FreezeThaw::TCooky::noRepeated {
  undef $uninitOK;
}

sub FreezeThaw::TCooky::isSafe {
  !$unsafe;
}

sub FreezeThaw::TCooky::makeSafe {
  undef $unsafe;
}

sub FreezeThaw::TCooky::ThawScalar {
  my $self = shift; 
  my ($res,$off) = &thawScalar($$self);
  $$self = $off;
  $res;
}

sub UNIVERSAL::Freeze {
  my ($obj, $cooky) = (shift, shift);
  $cooky->FreezeScalar($obj,1,1);
}

sub UNIVERSAL::Thaw {
  my ($package, $cooky) = (shift, shift);
  my $obj = $cooky->ThawScalar;
  bless $obj, $package;
}

sub UNIVERSAL::FreezeInstance {
  my($obj,$cooky) = @_;
  $obj->Freeze($cooky);
}

sub UNIVERSAL::Instantiate {
  my($package,$pre,$cooky) = @_;
  my $obj = $package->Thaw($cooky);
  copyContents $pre, $obj;
}

sub UNIVERSAL::Allocate {
  my($package,$cooky) = @_;
  $cooky->ThawScalar;
}

sub UNIVERSAL::FreezeEmpty {
  my $obj = shift;
  my ($type) = ("$obj" =~ /=(.*)\(/);
  my $e = $Empty{$type};
  if (ref $e) {
    my $ref = &$e;
    freezeScalar $ref;
    $ref;			# Put into cache.
  } elsif (defined $e) {
    freezeScalar($obj,1,1);	# Atomic
    undef;
  } else {
    die "Do not know how to FreezeEmpty $type";
  }
}

1;
