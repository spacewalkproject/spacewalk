use lib "./t";

use MIME::Tools;
use File::Path;
use File::Basename;
use ExtUtils::TBone;
use Globby;
use MIME::WordDecoder qw(unmime);

use strict;
config MIME::Tools DEBUGGING=>0;

use MIME::Parser;

my $T = typical ExtUtils::TBone;
#print STDERR "\n";

### Verify directory paths:
(-d "testout") or die "missing testout directory\n";
my $output_dir = $T->catdir(".", "testout", "Ref_t");

### Get messages to process:
my @refpaths = @ARGV;
if (!@refpaths) { 
    opendir DIR, "testmsgs" or die "opendir: $!\n";
    @refpaths = map { $T->catfile(".", "testmsgs", $_) 
		      } grep /\w.*\.ref$/, readdir(DIR);
    closedir DIR; 
}

### Create checker:
$T->begin(2 * int(@refpaths));

### For each reference:
foreach my $refpath (@refpaths) {

    ### Get message:
    my $msgpath = $refpath; $msgpath =~ s/\.ref$/.msg/;
#   print STDERR "   $msgpath\n";

    ### Get reference, as ref to array:
    my $ref = read_ref($refpath);
    if ($ref->{Parser}{Message}) {
	$msgpath = $T->catfile(".", (split /\//, $ref->{Parser}{Message}));
    }
    $T->log("Trying $refpath [$msgpath]\n");

    ### Create parser which outputs to testout/scratch:
    my $parser = MIME::Parser->new;
    $parser->output_dir($output_dir);
    $parser->extract_nested_messages($ref->{Parser}{ExtractNested});
    $parser->extract_uuencode($ref->{Parser}{ExtractUuencode});
    $parser->output_to_core(0);
    $parser->ignore_errors(0);

    ### Set character set:
    my $tgt = $ref->{Parser}{Charset} || 'ISO-8859-1';
    my $wd;
    if ($tgt =~ /^ISO-8859-(\d+)/) {
	$wd = new MIME::WordDecoder::ISO_8859 $1;
    }
    else {
	$wd = new MIME::WordDecoder([uc($tgt)   => 'KEEP',
				     'US-ASCII' => 'KEEP',
      				     '*'        => 'WARN']);
    }
    $T->log("Default charset: $tgt");
    MIME::WordDecoder->default($wd);
	
    ### Pre-clean:    
    rmtree($output_dir);
    (-d $output_dir) or mkpath($output_dir) or die "mkpath $output_dir: $!\n";

    ### Parse:
    my $ent = eval { $parser->parse_open($msgpath) };
    my $parse_error = $@;

    ### Output parse log:
    $T->msg("PARSE LOG FOR $refpath [$msgpath]");
    if ($parser->results) {
	$T->msg($parser->results->msgs);
    }
    else {
	$T->msg("Parse failed before results object was created");
    }

    ### Interpret results:
    if ($parse_error || !$ent) {
	$T->ok($ref->{Msg}{Fail},
	       $refpath,
	       Problem => $parse_error);
    }
    else {
	my $ok = eval { check_ref($msgpath, $ent, $ref) };
	$T->ok($ok,
	       $refpath,
	       ($@ ? (Error => $@) : ()),
	       Message => $msgpath,
	       Parser  => ($ref->{Parser}{Name} || 'default'));
    }

    ### Is purge working?
    my @a_files = list_dir($output_dir);
    my @p_files = $parser->filer->purgeable;
    $parser->filer->purge;
    my @z_files = list_dir($output_dir);
    $T->ok((@z_files == 0),
	   "Did purge work?",
	    Purgeable => \@p_files,
	    Original  => \@a_files,
	    Remaining => \@z_files
	   );
	
    ### Cleanup for real:
    rmtree($output_dir);
}

### Done!
exit(0);
1;

#------------------------------

sub list_dir {
    my $dir = shift;
    opendir DIR, $dir or die "opendir $dir; $!\n";
    my @files = grep !/^\.+$/, readdir DIR;
    closedir DIR;
    return sort @files;
}

#------------------------------

sub read_ref {
    my $path = shift;
    open IN, "<$path" or die "open $path: $!\n";
    my $expr = join('', <IN>);
    close IN;
    my $ref = eval $expr; $@ and die "syntax error in $path\n";
    $ref;
}

#------------------------------

sub trim {
    local $_ = shift;
    s/^\s*//;
    s/\s*$//;
    $_;
}

#------------------------------

sub check_ref {
    my ($msgpath, $ent, $ref) = @_;

    ### For each Msg in the ref:
  MSG:
    foreach my $partname (sort keys %$ref) {
	$partname =~ /^(Msg|Part_)/ or next;
	my $msg_ref = $ref->{$partname};
	my $part    = get_part($ent, $partname) || 
	    die "no such part: $partname\n";
	my $head    = $part->head; $head->unfold;
	my $body    = $part->bodyhandle;

	### For each attribute in the Msg:
      ATTR:
	foreach (sort keys %$msg_ref) {

	    my $want = $msg_ref->{$_};
	    my $got = undef;

	    if    (/^Boundary$/) { 
		$got = $head->multipart_boundary;
	    }
	    elsif (/^From$/)     { 
		$got  = trim($head->get("From", 0)); 
		$want = trim($want); 
	    }
	    elsif (/^To$/)       { 
		$got  = trim($head->get("To", 0)); 
		$want = trim($want); 
	    }
	    elsif (/^Subject$/)  { 
		$got  = trim($head->get("Subject", 0));
		$want = trim($want); 
	    }
	    elsif (/^Charset$/)  { 
		$got = $head->mime_attr("content-type.charset"); 
	    }
	    elsif (/^Disposition$/) { 
		$got = $head->mime_attr("content-disposition"); 
	    }
	    elsif (/^Type$/)     {
		$got = $head->mime_type;
	    }
	    elsif (/^Encoding$/) {
		$got = $head->mime_encoding;
	    }
	    elsif (/^Filename$/) {
		$got = unmime $head->recommended_filename; 
	    }
	    elsif (/^BodyFilename$/) {
		$got = (($body and $body->path) 
			? basename($body->path) 
			: undef);
	    }
	    elsif (/^Preamble$/) {
		$got = join('', @{$part->preamble});
	    }
	    elsif (/^Epilogue$/) {
		$got = join('', @{$part->epilogue});
	    }
	    elsif (/^Size$/)     { 
		if ($head->mime_type =~ m{^(text|message)}) {
		    $T->log("Skipping Size evaluation in text message ".
			    "due to variations in local newline ".
			    "conventions\n\n");
		    next ATTR;
		}
		if ($body and $body->path) { $got = (-s $body->path) }
	    }
	    else {
		die "$partname: unrecognized reference attribute: $_\n";
	    }

	    ### Log this sub-test:
	    $T->log("SUB-TEST: msg=$msgpath; part=$partname; attr=$_:\n");
	    $T->log("  want: ".encode($want)."\n");
	    $T->log("  got:  ".encode($got )."\n");
	    $T->log("\n");

	    next ATTR if (!defined($want) and !defined($got));
	    next ATTR if ($want eq $got);
	    die "$partname: wanted qq{$want}, got qq{$got}\n";
	}
    }

    1;
}

# Encode a string
sub encode {
	local $_ = shift;
	return '<undef>' if !defined($_);

	s{([\n\t\x00-\x1F\x7F-\xFF\\\"])}
         {'\\'.sprintf("%02X",ord($1)) }exg;
        s{\\0A}{\\n}g;
	return qq{"$_"};
}

#------------------------------

sub get_part {
    my ($ent, $name) = @_;

    if ($name eq 'Msg') {
	return $ent;
    }
    elsif ($name =~ /^Part_(.*)$/) {
	my @path = split /_/, $1;
	my $part = $ent;
	while (@path) {
	    my $i = shift @path;
	    $part = $part->parts($i - 1);
	}
	return $part;
    }
    undef;   
}

1;

