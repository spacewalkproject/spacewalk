# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..22\n"; }
END {print "not ok 1\n" unless $loaded;}
use HTML::TableExtract;
$loaded = 1;
print "ok  1 (load)\n";

######################### End of black magic.

# Init test count
$tcount = 2;

# For dataset 'chain'
%CHAIN_DATA = (
	       bulk   => [ [3,0],[3,1],[2,0],[3,2],[3,3],[2,1],[1,0],
			   [3,4],[3,5],[2,2],[3,6],[3,7],[2,3],[1,1],[0,0] ],
	       d2cd1a => [ [3,0],[3,1],[3,2],[3,3],[3,4],[3,5],[3,6],[3,7] ],
	       d2cd1b => [ [3,0],[3,1],[3,2],[3,3],[1,0],[3,4],[3,5],[3,6],[3,7],[1,1] ],
	       c2cc1a => [ [3,3],[3,5],[2,3] ],
	       c2cc1b => [ [3,1],[3,3],[2,1],[3,5],[2,3],[1,1] ],
	       h2ch1a => [ [3,1],[2,1],[1,1] ],
	       h2ch1b => [ [3,1],[2,1],[1,1],[0,0] ],
	       d2cd2  => [ [3,0],[3,1],[3,2],[3,3],[1,0],[3,4],[3,5],[3,6],[3,7],[1,1] ],
	       c2cc2  => [ [3,0],[2,0],[3,3],[1,0],[3,5],[2,3],[0,0] ],
	       h2ch2  => [ [3,2],[3,3],[2,2],[2,3],[0,0] ],
	       c2cc3  => [ [3,0],[2,0],[3,3],[1,0],[2,3],[0,0] ],
	       h2ch3  => [ [2,2],[2,3],[0,0] ],
	       h2ch4  => [ [3,1],[3,2],[3,3],[2,1],[2,2],[2,3],[1,1],[0,0] ],
	       d2h2c  => [ [3,3] ],
	      );

# For dataset 'chain'
@LINEAGE_DATA = (
		 [ "0,0", "1,0", "2,0", "3,0" ],
		 [ "0,0", "1,0", "2,0", "3,1" ],
		 [ "0,0", "1,0", "2,0" ],
		 [ "0,0", "1,0", "2,1", "3,2" ],
		 [ "0,0", "1,0", "2,1", "3,3" ],
		 [ "0,0", "1,0", "2,1" ],
		 [ "0,0", "1,0" ],
		 [ "0,0", "1,1", "2,2", "3,4" ],
		 [ "0,0", "1,1", "2,2", "3,5" ],
		 [ "0,0", "1,1", "2,2" ],
		 [ "0,0", "1,1", "2,3", "3,6" ],
		 [ "0,0", "1,1", "2,3", "3,7" ],
		 [ "0,0", "1,1", "2,3" ],
		 [ "0,0", "1,1" ],
		 [ "0,0" ]
		);

# For data set 'basic'
@headers = (
	    'Header Zero',
	    'Header One',
	    'Header Two',
	    'Header Three',
	    'Header Four',
	    'Header Five',
	    'Header Six',
	    'Header Seven',
	    'Header Eight',
	    'Header Nine',
	   );

# For data set 'skew'
@SKEW_DATA = (
	      [ 'THIS IS A WHOLE ROW-CELL OF JUNK','','','' ],
	      [ 'JUNK','Tasty tidbit (1,1)','JUNK','Tasty tidbit (1,3)' ],
	      [ '',"BIG\nJUNK",'','Tasty tidbit (2,3)' ],
	      [ 'Tasty tidbit (3,0)','','','Tasty tidbit (3,3)' ],
	      [ 'Tasty tidbit (4,0)','','','Tasty tidbit (4,3)' ],
	      [ 'JUNK BUTTON','','Tasty tidbit (5,2)','Tasty tidbit (5,3)' ],
	     );

# Constructs array called @docs
eval join('', <DATA>) or die $@;

$html = $docs{chain};

# By bulk, lineage integrity
$pass = 1;
$te = new HTML::TableExtract();
$te->parse($html);
$label = 'bulk';
@tablestates = $te->table_states;
$pass = 0 unless @tablestates == @{$CHAIN_DATA{$label}};
$pass = 0 unless good_chain_data($te, $label);
foreach $tsc (0 .. $#tablestates) {
  $ts = $tablestates[$tsc];
  foreach (0 .. $#{$ts->{lineage}}) {
    $pass = 0 unless $ts->{lineage}[$_] eq $LINEAGE_DATA[$tsc][$_];
  }
}
print $pass ? "ok " : "not ok ";
printf "%2d (by bulk with lineage check)\n", $tcount;
++$tcount;

$html = $docs{basic};

# By count
$pass = 1;
$te = new HTML::TableExtract(
			     count => 1,
			    );
$te->parse($html);
@tablestates = $te->table_states;
$pass = 0 unless @tablestates == 2;
foreach (@tablestates) {
  $pass = 0 unless good_data($_);
}
print $pass ? "ok " : "not ok ";
printf "%2d (by count)\n", $tcount;
++$tcount;

# By depth
$pass = 1;
$te = new HTML::TableExtract(
			     depth => 1,
			    );
$te->parse($html);
@tablestates = $te->table_states;
$pass = 0 unless @tablestates == 2;
foreach (@tablestates) {
  $pass = 0 unless good_data($_);
}
print $pass ? "ok " : "not ok ";
printf "%2d (by depth)\n", $tcount;
++$tcount;

# By header
$pass = 1;
$te = new HTML::TableExtract(
			     headers => [qw(Eight Six Four Two Zero)],
			    );
$te->parse($html);
@tablestates = $te->table_states;
$pass = 0 unless @tablestates == 5;
foreach (@tablestates) {
  $pass = 0 unless good_data($_);
}

print $pass ? "ok " : "not ok ";
printf "%2d (by header)\n", $tcount;
++$tcount;

# By depth and count
$pass = 1;
$te = new HTML::TableExtract(
			     depth     => 0,
			     count     => 2,
			    );
$te->parse($html);
@tablestates = $te->table_states;
$pass = 0 unless @tablestates == 1;
foreach (@tablestates) {
  $pass = 0 unless good_data($_);
}

print $pass ? "ok " : "not ok ";
printf "%2d (by depth and count)\n", $tcount;
++$tcount;

# By subtable scoop
$pass = 1;
$te = new HTML::TableExtract(
			     depth     => 0,
			     count     => 2,
			     subtables => 1,
			    );
$te->parse($html);
@tablestates = $te->table_states;
$pass = 0 unless @tablestates == 3;
foreach (@tablestates) {
  $pass = 0 unless good_data($_);
}

print $pass ? "ok " : "not ok ";
printf "%2d (by depth and count, subtable scoop)\n", $tcount;
++$tcount;

# Advanced header extraction. Test skew and column mapping.
$html = $docs{skew};

# Column skew
$pass = 1;
$te = new HTML::TableExtract(
			     headers => [ qw(head0 head1 head2 head3) ],
			    );
$te->parse($html);
@tablestates = $te->table_states;
$pass = 0 unless @tablestates == 1;
$pass = 0 unless good_skew_data($tablestates[0]);
print $pass ? "ok " : "not ok ";
printf "%2d (by header with span correction)\n", $tcount;
++$tcount;

# Column skew and column mapping
$pass = 1;
$te = new HTML::TableExtract(
			     headers => [ qw(head3 head2 head1 head0) ],
			    );
$te->parse($html);
@tablestates = $te->table_states;
$pass = 0 unless @tablestates == 1;
$pass = 0 unless good_skew_data($tablestates[0], 'reverse');
print $pass ? "ok " : "not ok ";
printf "%2d (by header with column mapping)\n", $tcount;
++$tcount;

# Chaining tests
$html = $docs{chain};

# Depth to depth chaining
$pass = 1;
$te = new HTML::TableExtract(
			     depth => 1,
			     chain => [
				       { depth => 1 }
				      ],
			    );
$te->parse($html);
@tablestates = $te->table_states;
$label = 'd2cd1a';
$pass = 0 unless @tablestates == @{$CHAIN_DATA{$label}};
$pass = 0 unless good_chain_data($te, $label);
print $pass ? "ok " : "not ok ";
printf "%2d (by depth to chain depth)\n", $tcount;
++$tcount;

# Depth to depth chaining, keep global
$pass = 1;
$te = new HTML::TableExtract(
			     depth => 1,
			     keep  => 1,
			     chain => [
				       { depth => 1 }
				      ],
			    );
$te->parse($html);
@tablestates = $te->table_states;
$label = 'd2cd1b';
$pass = 0 unless @tablestates == @{$CHAIN_DATA{$label}};
$pass = 0 unless good_chain_data($te, $label);
print $pass ? "ok " : "not ok ";
printf "%2d (by depth to chain depth, retain global)\n", $tcount;
++$tcount;

# Count to count chaining
$pass = 1;
$te = new HTML::TableExtract(
			     count => 1,
			     chain => [
				       { count => 1 }
				      ],
			    );
$te->parse($html);
@tablestates = $te->table_states;
$label = 'c2cc1a';
$pass = 0 unless @tablestates == @{$CHAIN_DATA{$label}};
$pass = 0 unless good_chain_data($te, $label);
print $pass ? "ok " : "not ok ";
printf "%2d (by count to chain count)\n", $tcount;
++$tcount;

# Count to count chaining, keep global
$pass = 1;
$te = new HTML::TableExtract(
			     count => 1,
			     keep  => 1,
			     chain => [
				       { count => 1 }
				      ],
			    );
$te->parse($html);
@tablestates = $te->table_states;
$label = 'c2cc1b';
$pass = 0 unless @tablestates == @{$CHAIN_DATA{$label}};
$pass = 0 unless good_chain_data($te, $label);
print $pass ? "ok " : "not ok ";
printf "%2d (by count to chain count, retain global)\n", $tcount;
++$tcount;

# Header to header chaining
# Note: this should demonstrate the "bug" of not matching subtables until
# a complete header match is obtained...
$pass = 1;
$te = new HTML::TableExtract(
			     headers => [ '0,0: \(0,0\)', '0,0: \(0,1\)' ],
			     chain => [
				       { headers => [ '1: \(0,0\)', '1: \(0,1\)' ] }
				      ],
			    );
$te->parse($html);
@tablestates = $te->table_states;
$label = 'h2ch1a';
$pass = 0 unless @tablestates == @{$CHAIN_DATA{$label}};
$pass = 0 unless good_chain_data($te, $label);
print $pass ? "ok " : "not ok ";
printf "%2d (by header to chain header)\n", $tcount;
++$tcount;

# Header to header chaining, keep global
# Note: this should demonstrate the "bug" of not matching subtables until
# a complete header match is obtained...
$pass = 1;
$te = new HTML::TableExtract(
			     headers => [ '0,0: \(0,0\)', '0,0: \(0,1\)' ],
			     chain   => [
					 { headers => [ '1: \(0,0\)', '1: \(0,1\)' ] }
					],
			     keep    => 1,
			    );
$te->parse($html);
@tablestates = $te->table_states;
$label = 'h2ch1b';
$pass = 0 unless @tablestates == @{$CHAIN_DATA{$label}};
$pass = 0 unless good_chain_data($te, $label);
print $pass ? "ok " : "not ok ";
printf "%2d (by header to chain header, retain global)\n", $tcount;
++$tcount;

# Depth to waypoint depth to terminus depth chaining
$pass = 1;
$te = new HTML::TableExtract(
			     depth => 1,
			     chain => [
				       { depth => 0 },
				       { depth => 0 }
				      ],
			     keep  => 1,
			    );
$te->parse($html);
@tablestates = $te->table_states;
$label = 'd2cd2';
$pass = 0 unless @tablestates == @{$CHAIN_DATA{$label}};
$pass = 0 unless good_chain_data($te, $label);
print $pass ? "ok " : "not ok ";
printf "%2d (by depth to chain depth with depth waypoint, retain global)\n", $tcount;
++$tcount;

# Count to count waypoint to count terminus chaining
$pass = 1;
$te = new HTML::TableExtract(
			     count => 0,
			     chain => [
				       { count => 1 },
				       { count => 1 }
				      ],
			     keep  => 1,
			    );
$te->parse($html);
@tablestates = $te->table_states;
$label = 'c2cc2';
$pass = 0 unless @tablestates == @{$CHAIN_DATA{$label}};
$pass = 0 unless good_chain_data($te, $label);
print $pass ? "ok " : "not ok ";
printf "%2d (by count to chain count with count waypoint, retain global)\n", $tcount;
++$tcount;

# Header to header waypoint to header terminus chaining
$pass = 1;
$te = new HTML::TableExtract(
			     headers => [ '0,0: \(0,0\)', '0,0: \(0,1\)' ],
			     chain   => [
					 { headers => [ '1: \(0,0\)', '1: \(0,1\)' ] },
					 { headers => [ '\(0,0\)', '\(0,1\)' ] }
					],
			     keep    => 1,
			    );
$te->parse($html);
@tablestates = $te->table_states;
$label = 'h2ch2';
$pass = 0 unless @tablestates == @{$CHAIN_DATA{$label}};
$pass = 0 unless good_chain_data($te, $label);
print $pass ? "ok " : "not ok ";
printf "%2d (by header to chain header with header waypoint, retain global)\n", $tcount;
++$tcount;

# Count to count waypoint to count terminus chaining, non-elastic
$pass = 1;
$te = new HTML::TableExtract(
			     count   => 0,
			     chain   => [
					 { count => 1 },
					 { count => 1 }
					],
			     elastic => 0,
			     keep    => 1,
			    );
$te->parse($html);
@tablestates = $te->table_states;
$label = 'c2cc3';
$pass = 0 unless @tablestates == @{$CHAIN_DATA{$label}};
$pass = 0 unless good_chain_data($te, $label);
print $pass ? "ok " : "not ok ";
printf "%2d (by count to chain count with count waypoint, non-elastic, retain global)\n", $tcount;
++$tcount;

# Header to header waypoint to header terminus chaining, non-elastic
$pass = 1;
$te = new HTML::TableExtract(
			     headers => [ '0,0: \(0,0\)', '0,0: \(0,1\)' ],
			     chain   => [
					 { headers => [ '1: \(0,0\)', '1: \(0,1\)' ] },
					 { headers => [ '\(0,0\)', '\(0,1\)' ] }
					],
			     elastic => 0,
			     keep    => 1,
			    );
$te->parse($html);
@tablestates = $te->table_states;
$label = 'h2ch3';
$pass = 0 unless @tablestates == @{$CHAIN_DATA{$label}};
$pass = 0 unless good_chain_data($te, $label);
print $pass ? "ok " : "not ok ";
printf "%2d (by header to chain header with header waypoint, non-elastic, retain global)\n", $tcount;
++$tcount;

# Header to header waypoint to header terminus chaining, keep all waypoints
$pass = 1;
$te = new HTML::TableExtract(
			     headers => [ '0,0: \(0,0\)', '0,0: \(0,1\)' ],
			     chain   => [
					 { headers => [ '1: \(0,0\)', '1: \(0,1\)' ] },
					 { headers => [ '\(0,0\)', '\(0,1\)' ] }
					],
			     keepall => 1,
			    );
$te->parse($html);
@tablestates = $te->table_states;
$label = 'h2ch4';
$pass = 0 unless @tablestates == @{$CHAIN_DATA{$label}};
$pass = 0 unless good_chain_data($te, $label);
print $pass ? "ok " : "not ok ";
printf "%2d (by header to chain header with header waypoint, retain all waypoints)\n", $tcount;
++$tcount;

# Depth to header waypoint to count terminus
$pass = 1;
$te = new HTML::TableExtract(
			     depth   => 1,
			     chain   => [
					 { headers => [ '1: \(0,0\)', '1: \(0,1\)' ] },
					 { count   => 1 },
					],	
			    );
$te->parse($html);
@tablestates = $te->table_states;
$label = 'd2h2c';
$pass = 0 unless @tablestates == @{$CHAIN_DATA{$label}};
$pass = 0 unless good_chain_data($te, $label);
print $pass ? "ok " : "not ok ";
printf "%2d (by depth to count, header waypoint)\n", $tcount;
++$tcount;

exit;

sub good_data {
  my $ts = shift;
  ref $ts or die "Oops: Table state ref required\n";
  my $t = $ts->{content};
  my $skew;
  if ($t->[0][0] =~ /^Header/) {
    $skew = 1;
  }
  else {
    $skew = 0;
  }
  my $row = 0 + $skew;

  # Must have rows
  return 0 unless @{$t};

  # See if we got the numbers.
  foreach my $r ($row .. $#$t) {
    # Must have columns
    return 0 unless @{$t->[$r]};
    foreach my $c (0 .. $#{$t->[$r]}) {
      my $rc = $skew ? $r : $r + 1;
      next if $ts->{headers} && !$ts->{hits}{$c};
      $t->[$r][$c] =~ /^ \($rc,$c\)$/ or return 0;
    }
  }

  # Header order check
  if ($skew) {
    foreach my $c (0 .. $#{$t->[0]}) {
      my $hs = $headers[$c];
      $t->[0][$c] =~ /^$hs$/ or return 0;
    }
  }
  1;
}

sub good_skew_data {
  my($ts, $reverse) = @_;
  ref $ts or die "Oops: Table state ref required\n";
  my $t = $ts->{content};
  foreach my $r (0 .. $#$t) {
    my @cols = 0 .. $#{$t->[$r]};
    @cols = reverse @cols if $reverse;
    foreach my $c (@cols) {
      return 0 unless $t->[$r][$c] eq $SKEW_DATA[$r][$c];
    }
  }
  1;
}

sub good_chain_data {
  my($te, $key) = @_;
  ref $te or die "Oops: TableExtract object required\n";
  $CHAIN_DATA{$key} or die "Oops: Valid CHAIN_DATA key required\n";
  my $coord_list = [map([$_->depth,$_->count], $te->table_states)];
  my $data = $CHAIN_DATA{$key};
#  print 'clist: ',join(',', map('[' . join(',', @$_) . ']', @$coord_list)),"\n";
#  print 'dlist: ',join(',', map('[' . join(',', @$_) . ']', @$data)),"\n";
  @$coord_list == @$data or return 0;
#  print scalar @$coord_list, " in both lists\n";
  foreach (0 .. $#{$coord_list}) {
#    print "comp cl[$_][0]:$coord_list->[$_][0] to dl[$_][0]:$data->[$_][0]\n";
    $coord_list->[$_][0] == $data->[$_][0] or return 0;
#    print "comp cl[$_][1]:$coord_list->[$_][1] to dl[$_][1]:$data->[$_][1]\n";
    $coord_list->[$_][1] == $data->[$_][1] or return 0;
  }
  1;
}

__DATA__
$doc1 = <<__DOC1;
<html>
<head><title>TableExtract Test HTML</title></head>
<body>
<h3>Here lies Table 1:</h3>
<table border=1><tr><td>Header Zero</td><td>Header One</td><td>Header Two</td><td>Header Three</td><td>Header Four</td><td>Header Five</td><td>Header Six</td><td>Header Seven</td><td>Header Eight</td><td>Header Nine</td></tr><tr><td> (1,0)</td><td> (1,1)</td><td> (1,2)</td><td> (1,3)</td><td> (1,4)</td><td> (1,5)</td><td> (1,6)</td><td> (1,7)</td><td> (1,8)</td><td> (1,9)</td></tr><tr><td> (2,0)</td><td> (2,1)</td><td> (2,2)</td><td> (2,3)</td><td> (2,4)</td><td> (2,5)</td><td> (2,6)</td><td> (2,7)</td><td> (2,8)</td><td> (2,9)</td></tr><tr><td> (3,0)</td><td> (3,1)</td><td> (3,2)</td><td> (3,3)</td><td> (3,4)</td><td> (3,5)</td><td> (3,6)</td><td> (3,7)</td><td> (3,8)</td><td> (3,9)</td></tr><tr><td> (4,0)</td><td> (4,1)</td><td> (4,2)</td><td> (4,3)</td><td> (4,4)</td><td> (4,5)</td><td> (4,6)</td><td> (4,7)</td><td> (4,8)</td><td> (4,9)</td></tr><tr><td> (5,0)</td><td> (5,1)</td><td> (5,2)</td><td> (5,3)</td><td> (5,4)</td><td> (5,5)</td><td> (5,6)</td><td> (5,7)</td><td> (5,8)</td><td> (5,9)</td></tr><tr><td> (6,0)</td><td> (6,1)</td><td> (6,2)</td><td> (6,3)</td><td> (6,4)</td><td> (6,5)</td><td> (6,6)</td><td> (6,7)</td><td> (6,8)</td><td> (6,9)</td></tr><tr><td> (7,0)</td><td> (7,1)</td><td> (7,2)</td><td> (7,3)</td><td> (7,4)</td><td> (7,5)</td><td> (7,6)</td><td> (7,7)</td><td> (7,8)</td><td> (7,9)</td></tr><tr><td> (8,0)</td><td> (8,1)</td><td> (8,2)</td><td> (8,3)</td><td> (8,4)</td><td> (8,5)</td><td> (8,6)</td><td> (8,7)</td><td> (8,8)</td><td> (8,9)</td></tr><tr><td> (9,0)</td><td> (9,1)</td><td> (9,2)</td><td> (9,3)</td><td> (9,4)</td><td> (9,5)</td><td> (9,6)</td><td> (9,7)</td><td> (9,8)</td><td> (9,9)</td></tr></table>

<h3>Here lies Table 2:</h3>
<table border=1><tr><td>Header Zero</td><td>Header One</td><td>Header Two</td><td>Header Three</td><td>Header Four</td><td>Header Five</td><td>Header Six</td><td>Header Seven</td><td>Header Eight</td><td>Header Nine</td></tr><tr><td> (1,0)</td><td> (1,1)</td><td> (1,2)</td><td> (1,3)</td><td> (1,4)</td><td> (1,5)</td><td> (1,6)</td><td> (1,7)</td><td> (1,8)</td><td> (1,9)</td></tr><tr><td> (2,0)</td><td> (2,1)</td><td> (2,2)</td><td> (2,3)</td><td> (2,4)</td><td> (2,5)</td><td> (2,6)</td><td> (2,7)</td><td> (2,8)</td><td> (2,9)</td></tr><tr><td> (3,0)</td><td> (3,1)</td><td> (3,2)</td><td> (3,3)</td><td> (3,4)</td><td> (3,5)</td><td> (3,6)</td><td> (3,7)</td><td> (3,8)</td><td> (3,9)</td></tr><tr><td> (4,0)</td><td> (4,1)</td><td> (4,2)</td><td> (4,3)</td><td> (4,4)</td><td> (4,5)</td><td> (4,6)</td><td> (4,7)</td><td> (4,8)</td><td> (4,9)</td></tr><tr><td> (5,0)</td><td> (5,1)</td><td> (5,2)</td><td> (5,3)</td><td> (5,4)</td><td> (5,5)</td><td> (5,6)</td><td> (5,7)</td><td> (5,8)</td><td> (5,9)</td></tr><tr><td> (6,0)</td><td> (6,1)</td><td> (6,2)</td><td> (6,3)</td><td> (6,4)</td><td> (6,5)</td><td> (6,6)</td><td> (6,7)</td><td> (6,8)</td><td> (6,9)</td></tr><tr><td> (7,0)</td><td> (7,1)</td><td> (7,2)</td><td> (7,3)</td><td> (7,4)</td><td> (7,5)</td><td> (7,6)</td><td> (7,7)</td><td> (7,8)</td><td> (7,9)</td></tr><tr><td> (8,0)</td><td> (8,1)</td><td> (8,2)</td><td> (8,3)</td><td> (8,4)</td><td> (8,5)</td><td> (8,6)</td><td> (8,7)</td><td> (8,8)</td><td> (8,9)</td></tr><tr><td> (9,0)</td><td> (9,1)</td><td> (9,2)</td><td> (9,3)</td><td> (9,4)</td><td> (9,5)</td><td> (9,6)</td><td> (9,7)</td><td> (9,8)</td><td> (9,9)</td></tr></table>

<h3>Here lies Table 3 with 4 and 5 inside:</h3>
<table border=1><tr><td>Header Zero</td><td>Header One</td><td>Header Two</td><td>Header Three</td><td>Header Four</td><td>Header Five</td><td>Header Six</td><td>Header Seven</td><td>Header Eight</td><td>Header Nine</td></tr><tr><td> (1,0)</td><td> (1,1)</td><td> (1,2)</td><td> (1,3)</td><td> (1,4)</td><td> (1,5)</td><td> (1,6)</td><td> (1,7)</td><td> (1,8)</td><td> (1,9)</td></tr><tr><td> (2,0)</td><td> (2,1)</td><td> (2,2)</td><td> (2,3)</td><td> (2,4)</td><td> (2,5)</td><td> (2,6)</td><td> (2,7)</td><td> (2,8)</td><td> (2,9)</td></tr><tr><td> (3,0)</td><td> (3,1)</td><td> (3,2)</td><td> (3,3)</td><td> (3,4)</td><td> (3,5)</td><td> (3,6)</td><td> (3,7)</td><td> (3,8)</td><td> (3,9)</td></tr><tr><td> (4,0)</td><td> (4,1)</td><td> (4,2)</td><td> (4,3)</td><td> (4,4)</td><td> (4,5)</td><td> (4,6)</td><td> (4,7)</td><td> (4,8)</td><td> (4,9)</td></tr><tr><td> (5,0)</td><td> (5,1)</td><td> (5,2)</td><td> (5,3)</td><td> (5,4)</td><td> (5,5)<table border=1><tr><td>Header Zero</td><td>Header One</td><td>Header Two</td><td>Header Three</td><td>Header Four</td><td>Header Five</td><td>Header Six</td><td>Header Seven</td><td>Header Eight</td><td>Header Nine</td></tr><tr><td> (1,0)</td><td> (1,1)</td><td> (1,2)</td><td> (1,3)</td><td> (1,4)</td><td> (1,5)</td><td> (1,6)</td><td> (1,7)</td><td> (1,8)</td><td> (1,9)</td></tr><tr><td> (2,0)</td><td> (2,1)</td><td> (2,2)</td><td> (2,3)</td><td> (2,4)</td><td> (2,5)</td><td> (2,6)</td><td> (2,7)</td><td> (2,8)</td><td> (2,9)</td></tr><tr><td> (3,0)</td><td> (3,1)</td><td> (3,2)</td><td> (3,3)</td><td> (3,4)</td><td> (3,5)</td><td> (3,6)</td><td> (3,7)</td><td> (3,8)</td><td> (3,9)</td></tr><tr><td> (4,0)</td><td> (4,1)</td><td> (4,2)</td><td> (4,3)</td><td> (4,4)</td><td> (4,5)</td><td> (4,6)</td><td> (4,7)</td><td> (4,8)</td><td> (4,9)</td></tr><tr><td> (5,0)</td><td> (5,1)</td><td> (5,2)</td><td> (5,3)</td><td> (5,4)</td><td> (5,5)</td><td> (5,6)</td><td> (5,7)</td><td> (5,8)</td><td> (5,9)</td></tr><tr><td> (6,0)</td><td> (6,1)</td><td> (6,2)</td><td> (6,3)</td><td> (6,4)</td><td> (6,5)</td><td> (6,6)</td><td> (6,7)</td><td> (6,8)</td><td> (6,9)</td></tr><tr><td> (7,0)</td><td> (7,1)</td><td> (7,2)</td><td> (7,3)</td><td> (7,4)</td><td> (7,5)</td><td> (7,6)</td><td> (7,7)</td><td> (7,8)</td><td> (7,9)</td></tr><tr><td> (8,0)</td><td> (8,1)</td><td> (8,2)</td><td> (8,3)</td><td> (8,4)</td><td> (8,5)</td><td> (8,6)</td><td> (8,7)</td><td> (8,8)</td><td> (8,9)</td></tr><tr><td> (9,0)</td><td> (9,1)</td><td> (9,2)</td><td> (9,3)</td><td> (9,4)</td><td> (9,5)</td><td> (9,6)</td><td> (9,7)</td><td> (9,8)</td><td> (9,9)</td></tr></table></td><td> (5,6)</td><td> (5,7)</td><td> (5,8)</td><td> (5,9)</td></tr><tr><td> (6,0)</td><td> (6,1)</td><td> (6,2)</td><td> (6,3)</td><td> (6,4)</td><td> (6,5)</td><td> (6,6)</td><td> (6,7)</td><td> (6,8)</td><td> (6,9)</td></tr><tr><td> (7,0)</td><td> (7,1)</td><td> (7,2)</td><td> (7,3)</td><td> (7,4)</td><td> (7,5)</td><td> (7,6)</td><td> (7,7)<table border=1><tr><td>Header Zero</td><td>Header One</td><td>Header Two</td><td>Header Three</td><td>Header Four</td><td>Header Five</td><td>Header Six</td><td>Header Seven</td><td>Header Eight</td><td>Header Nine</td></tr><tr><td> (1,0)</td><td> (1,1)</td><td> (1,2)</td><td> (1,3)</td><td> (1,4)</td><td> (1,5)</td><td> (1,6)</td><td> (1,7)</td><td> (1,8)</td><td> (1,9)</td></tr><tr><td> (2,0)</td><td> (2,1)</td><td> (2,2)</td><td> (2,3)</td><td> (2,4)</td><td> (2,5)</td><td> (2,6)</td><td> (2,7)</td><td> (2,8)</td><td> (2,9)</td></tr><tr><td> (3,0)</td><td> (3,1)</td><td> (3,2)</td><td> (3,3)</td><td> (3,4)</td><td> (3,5)</td><td> (3,6)</td><td> (3,7)</td><td> (3,8)</td><td> (3,9)</td></tr><tr><td> (4,0)</td><td> (4,1)</td><td> (4,2)</td><td> (4,3)</td><td> (4,4)</td><td> (4,5)</td><td> (4,6)</td><td> (4,7)</td><td> (4,8)</td><td> (4,9)</td></tr><tr><td> (5,0)</td><td> (5,1)</td><td> (5,2)</td><td> (5,3)</td><td> (5,4)</td><td> (5,5)</td><td> (5,6)</td><td> (5,7)</td><td> (5,8)</td><td> (5,9)</td></tr><tr><td> (6,0)</td><td> (6,1)</td><td> (6,2)</td><td> (6,3)</td><td> (6,4)</td><td> (6,5)</td><td> (6,6)</td><td> (6,7)</td><td> (6,8)</td><td> (6,9)</td></tr><tr><td> (7,0)</td><td> (7,1)</td><td> (7,2)</td><td> (7,3)</td><td> (7,4)</td><td> (7,5)</td><td> (7,6)</td><td> (7,7)</td><td> (7,8)</td><td> (7,9)</td></tr><tr><td> (8,0)</td><td> (8,1)</td><td> (8,2)</td><td> (8,3)</td><td> (8,4)</td><td> (8,5)</td><td> (8,6)</td><td> (8,7)</td><td> (8,8)</td><td> (8,9)</td></tr><tr><td> (9,0)</td><td> (9,1)</td><td> (9,2)</td><td> (9,3)</td><td> (9,4)</td><td> (9,5)</td><td> (9,6)</td><td> (9,7)</td><td> (9,8)</td><td> (9,9)</td></tr></table></td><td> (7,8)</td><td> (7,9)</td></tr><tr><td> (8,0)</td><td> (8,1)</td><td> (8,2)</td><td> (8,3)</td><td> (8,4)</td><td> (8,5)</td><td> (8,6)</td><td> (8,7)</td><td> (8,8)</td><td> (8,9)</td></tr><tr><td> (9,0)</td><td> (9,1)</td><td> (9,2)</td><td> (9,3)</td><td> (9,4)</td><td> (9,5)</td><td> (9,6)</td><td> (9,7)</td><td> (9,8)</td><td> (9,9)</td></tr></table>

</body>
</html>
__DOC1
$docs{basic} = $doc1;

$doc2 = <<__DOC2;
<html><head><title>skew test</title></head>
<body>
<table border=1>
<tr>
    <td>head0</td>
    <td>head1</td>
    <td>head2</td>
    <td>head3</td>
</tr>
<tr>
    <td colspan=4>THIS IS A WHOLE ROW-CELL OF JUNK</td>
</tr>
<tr>
    <td rowspan=2>JUNK</td>
    <td>Tasty tidbit (1,1)</td>
    <td>JUNK</td>
    <td>Tasty tidbit (1,3)</td>
</tr>
<tr>
    <td colspan=2 rowspan=3>BIG<BR>JUNK</td>
    <td>Tasty tidbit (2,3)</td>
</tr>
<tr>
    <td>Tasty tidbit (3,0)</td>
    <td>Tasty tidbit (3,3)</td>
</tr>
<tr>
    <td>Tasty tidbit (4,0)</td>
    <td>Tasty tidbit (4,3)</td>
</tr>
<tr>
    <td colspan=2>JUNK BUTTON</td>
    <td>Tasty tidbit (5,2)</td>
    <td>Tasty tidbit (5,3)</td>
</tr>
</table>
</body>
</html>
__DOC2
$docs{skew} = $doc2;

$doc3 = <<__DOC3;
<HTML>
<HEAD><TITLE>Chain Test</TITLE></HEAD>
<BODY>
<H2>You like ugly? I'll show you <font color=blue>U</font><font color=green>G</font><font color=cyan>L</font><font color=red>Y</font>:</H2>
<table bgcolor="blue" border=1><tr valign="top"><td valign="top"><font size="-2">0,0: (0,0)</font></td><td valign="top"><font size="-2">0,0: (0,1)</font></td></tr><tr valign="top"><td valign="top"><font size="-2">0,0: (1,0)</font><table bgcolor="green" border=1><tr valign="top"><td valign="top"><font size="-2">1,0: (0,0)</font></td><td valign="top"><font size="-2">1,0: (0,1)</font></td></tr><tr valign="top"><td valign="top"><font size="-2">1,0: (1,0)</font><table bgcolor="cyan" border=1><tr valign="top"><td valign="top"><font size="-2">2,0: (0,0)</font></td><td valign="top"><font size="-2">2,0: (0,1)</font></td></tr><tr valign="top"><td valign="top"><font size="-2">2,0: (1,0)</font><table bgcolor="red" border=1><tr valign="top"><td valign="top"><font size="-2">3,0: (0,0)</font></td><td valign="top"><font size="-2">3,0: (0,1)</font></td></tr><tr valign="top"><td valign="top"><font size="-2">3,0: (1,0)</font></td><td valign="top"><font size="-2">3,0: (1,1)</font></td></tr><tr valign="top"><td valign="top"><font size="-2">3,0: (2,0)</font></td><td valign="top"><font size="-2">3,0: (2,1)</font></td></tr></table></td><td valign="top"><font size="-2">2,0: (1,1)</font></td></tr><tr valign="top"><td valign="top"><font size="-2">2,0: (2,0)</font></td><td valign="top"><font size="-2">2,0: (2,1)</font><table bgcolor="red" border=1><tr valign="top"><td valign="top"><font size="-2">3,1: (0,0)</font></td><td valign="top"><font size="-2">3,1: (0,1)</font></td></tr><tr valign="top"><td valign="top"><font size="-2">3,1: (1,0)</font></td><td valign="top"><font size="-2">3,1: (1,1)</font></td></tr><tr valign="top"><td valign="top"><font size="-2">3,1: (2,0)</font></td><td valign="top"><font size="-2">3,1: (2,1)</font></td></tr></table></td></tr></table></td><td valign="top"><font size="-2">1,0: (1,1)</font></td></tr><tr valign="top"><td valign="top"><font size="-2">1,0: (2,0)</font></td><td valign="top"><font size="-2">1,0: (2,1)</font><table bgcolor="cyan" border=1><tr valign="top"><td valign="top"><font size="-2">2,1: (0,0)</font></td><td valign="top"><font size="-2">2,1: (0,1)</font></td></tr><tr valign="top"><td valign="top"><font size="-2">2,1: (1,0)</font></td><td valign="top"><font size="-2">2,1: (1,1)</font><table bgcolor="red" border=1><tr valign="top"><td valign="top"><font size="-2">3,2: (0,0)</font></td><td valign="top"><font size="-2">3,2: (0,1)</font></td></tr><tr valign="top"><td valign="top"><font size="-2">3,2: (1,0)</font></td><td valign="top"><font size="-2">3,2: (1,1)</font></td></tr><tr valign="top"><td valign="top"><font size="-2">3,2: (2,0)</font></td><td valign="top"><font size="-2">3,2: (2,1)</font></td></tr></table></td></tr><tr valign="top"><td valign="top"><font size="-2">2,1: (2,0)</font><table bgcolor="red" border=1><tr valign="top"><td valign="top"><font size="-2">3,3: (0,0)</font></td><td valign="top"><font size="-2">3,3: (0,1)</font></td></tr><tr valign="top"><td valign="top"><font size="-2">3,3: (1,0)</font></td><td valign="top"><font size="-2">3,3: (1,1)</font></td></tr><tr valign="top"><td valign="top"><font size="-2">3,3: (2,0)</font></td><td valign="top"><font size="-2">3,3: (2,1)</font></td></tr></table></td><td valign="top"><font size="-2">2,1: (2,1)</font></td></tr></table></td></tr></table></td><td valign="top"><font size="-2">0,0: (1,1)</font></td></tr><tr valign="top"><td valign="top"><font size="-2">0,0: (2,0)</font></td><td valign="top"><font size="-2">0,0: (2,1)</font><table bgcolor="green" border=1><tr valign="top"><td valign="top"><font size="-2">1,1: (0,0)</font></td><td valign="top"><font size="-2">1,1: (0,1)</font></td></tr><tr valign="top"><td valign="top"><font size="-2">1,1: (1,0)</font></td><td valign="top"><font size="-2">1,1: (1,1)</font><table bgcolor="cyan" border=1><tr valign="top"><td valign="top"><font size="-2">2,2: (0,0)</font></td><td valign="top"><font size="-2">2,2: (0,1)</font></td></tr><tr valign="top"><td valign="top"><font size="-2">2,2: (1,0)</font><table bgcolor="red" border=1><tr valign="top"><td valign="top"><font size="-2">3,4: (0,0)</font></td><td valign="top"><font size="-2">3,4: (0,1)</font></td></tr><tr valign="top"><td valign="top"><font size="-2">3,4: (1,0)</font></td><td valign="top"><font size="-2">3,4: (1,1)</font></td></tr><tr valign="top"><td valign="top"><font size="-2">3,4: (2,0)</font></td><td valign="top"><font size="-2">3,4: (2,1)</font></td></tr></table></td><td valign="top"><font size="-2">2,2: (1,1)</font></td></tr><tr valign="top"><td valign="top"><font size="-2">2,2: (2,0)</font></td><td valign="top"><font size="-2">2,2: (2,1)</font><table bgcolor="red" border=1><tr valign="top"><td valign="top"><font size="-2">3,5: (0,0)</font></td><td valign="top"><font size="-2">3,5: (0,1)</font></td></tr><tr valign="top"><td valign="top"><font size="-2">3,5: (1,0)</font></td><td valign="top"><font size="-2">3,5: (1,1)</font></td></tr><tr valign="top"><td valign="top"><font size="-2">3,5: (2,0)</font></td><td valign="top"><font size="-2">3,5: (2,1)</font></td></tr></table></td></tr></table></td></tr><tr valign="top"><td valign="top"><font size="-2">1,1: (2,0)</font><table bgcolor="cyan" border=1><tr valign="top"><td valign="top"><font size="-2">2,3: (0,0)</font></td><td valign="top"><font size="-2">2,3: (0,1)</font></td></tr><tr valign="top"><td valign="top"><font size="-2">2,3: (1,0)</font></td><td valign="top"><font size="-2">2,3: (1,1)</font><table bgcolor="red" border=1><tr valign="top"><td valign="top"><font size="-2">3,6: (0,0)</font></td><td valign="top"><font size="-2">3,6: (0,1)</font></td></tr><tr valign="top"><td valign="top"><font size="-2">3,6: (1,0)</font></td><td valign="top"><font size="-2">3,6: (1,1)</font></td></tr><tr valign="top"><td valign="top"><font size="-2">3,6: (2,0)</font></td><td valign="top"><font size="-2">3,6: (2,1)</font></td></tr></table></td></tr><tr valign="top"><td valign="top"><font size="-2">2,3: (2,0)</font><table bgcolor="red" border=1><tr valign="top"><td valign="top"><font size="-2">3,7: (0,0)</font></td><td valign="top"><font size="-2">3,7: (0,1)</font></td></tr><tr valign="top"><td valign="top"><font size="-2">3,7: (1,0)</font></td><td valign="top"><font size="-2">3,7: (1,1)</font></td></tr><tr valign="top"><td valign="top"><font size="-2">3,7: (2,0)</font></td><td valign="top"><font size="-2">3,7: (2,1)</font></td></tr></table></td><td valign="top"><font size="-2">2,3: (2,1)</font></td></tr></table></td><td valign="top"><font size="-2">1,1: (2,1)</font></td></tr></table></td></tr></table>
</BODY>
</HTML>
__DOC3
$docs{chain} = $doc3;

1;
