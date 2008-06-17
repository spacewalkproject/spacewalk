package HTML::TableExtract;

# This package extracts tables from HTML. Tables of interest may be
# specified using header information, depth, order in a depth, or some
# combination of the three. See the POD for more information.
#
# Author: Matthew P. Sisk. See the POD for copyright information.

use strict;
use Carp;

use vars qw($VERSION @ISA);

$VERSION = '1.08';

use HTML::Parser;
@ISA = qw(HTML::Parser);

use HTML::Entities;

my %Defaults = (
		headers      => undef,
		depth        => undef,
		count        => undef,
		chain        => undef,
		subtables    => undef,
		gridmap      => 1,
		decode       => 1,
		automap      => 1,
		br_translate => 1,
		head_include => 0,
		elastic      => 1,
		keep         => 0,
		keepall      => 0,
		debug        => 0,
		keep_html    => 0,
	       );
my $Dpat = join('|', keys %Defaults);

### Constructor

sub new {
  my $that = shift;
  my $class = ref($that) || $that;

  my(%pass, %parms, $k, $v);
  while (($k,$v) = splice(@_, 0, 2)) {
    if ($k eq 'headers' || $k eq 'chain') {
      ref $v eq 'ARRAY'
 	or croak "Param '$k'  must be passed in ref to array\n";
      if ($k eq 'chain') {
	# Filter out non-links (has refs...allows for extra commas, etc)
	@$v = grep(ref eq 'HASH', @$v);
      }
      $parms{$k} = $v;
    }
    elsif ($k =~ /^$Dpat$/) {
      $parms{$k} = $v;
    }
    else {
      $pass{$k} = $v;
    }
  }

  my $self = $class->SUPER::new(%pass);
  bless $self, $class;
  foreach (keys %parms, keys %Defaults) {
    $self->{$_} = exists $parms{$_} && defined $parms{$_} ?
      $parms{$_} : $Defaults{$_};
  }
  if ($self->{headers}) {
    print STDERR "TE here, headers: ", join(',', @{$self->{headers}}),"\n"
      if $self->{debug};
    $self->{gridmap} = 1;
  }
  # Initialize counts and containers
  $self->{_cdepth}        = -1;
  $self->{_tablestack}    = [];
  $self->{_tables}        = {};
  $self->{_ts_sequential} = [];
  $self->{_table_mapback} = {};
  $self->{_counts}        = {};

  $self;
}

### HTML::Parser overrides

sub start {
  my $self = shift;

  # Create a new table state if entering a table.
  if ($_[0] eq 'table') {
    $self->_enter_table;
  }

  # Rows and cells are next. We obviously need not bother checking any
  # tags if we aren't in a table.
  if ($self->{_in_a_table}) {
    my $ts = $self->_current_table_state;
    my $skiptag = 0;
    if ($_[0] eq 'tr') {
      $ts->_enter_row;
      ++$skiptag;
    }
    elsif ($_[0] eq 'td' || $_[0] eq 'th') {
      $ts->_enter_cell;
      # Inspect rowspan/colspan attributes, record as necessary for
      # future column count transforms.
      if ($self->{gridmap}) {
	my %attrs = ref $_[1] ? %{$_[1]} : {};
	if (exists $attrs{rowspan} || exists $attrs{colspan}) {
	  $ts->_skew($attrs{rowspan} || 1, $attrs{colspan} || 1);
	}
      }
      ++$skiptag;
    }
    if ($self->{keep_html} && !$skiptag) {
      $self->text($_[3]);
    }
  }

  # <br> patch. We like to dispense with HTML, but blindly zapping
  # <br> will sometimes make the resulting text hard to parse if there
  # is no newline. Therefore, when enabled, we replace <br> with
  # newline. Pointed out by Volker Stuerzl <Volker.Stuerzl@gmx.de>
  if ($_[0] eq 'br' && $self->{br_translate} && !$self->{keep_html}) {
    $self->text("\n");
  }


} # end start

sub end {
  my $self = shift;
  # Don't bother if we're not actually in a table.
  if ($self->{_in_a_table}) {
    my $ts = $self->_current_table_state;
    if ($_[0] eq 'td' || $_[0] eq 'th') {
      $ts->_exit_cell;
    }
    elsif ($_[0] eq 'tr') {
      $ts->_exit_row;
    }
    elsif ($_[0] eq 'table') {
      $self->_exit_table;
    }
    $self->text($_[1]) if $self->{keep_html} && $ts->{in_cell};
  }
}

sub text {
  my $self = shift;
  # Don't bother unless we are in a table
  if ($self->{_in_a_table}) {
    my $ts = $self->_current_table_state;
    # Don't bother unless we are in a row or cell
    return unless $ts->{in_cell};
    if ($ts->_text_hungry) {
      $ts->_taste_text($self->{decode} ? decode_entities($_[0]) : $_[0]);
    }
  }
}

### End HTML::Parser overrides

### Report Methods

sub depths {
  # Return all depths where valid tables were located.
  my $self = shift;
  return () unless ref $self->{_tables};
  sort { $a <=> $b } keys %{$self->{_tables}};
}

sub counts {
  # Given a depth, return the counts of all valid tables found therein.
  my($self, $depth) = @_;
  defined $depth or croak "Depth required\n";
  sort { $a <=> $b } keys %{$self->{_tables}{$depth}};
}

sub table {
  # Return the table content for a particular depth and count
  shift->table_state(@_)->{content};
}

sub table_state {
  # Return the table state for a particular depth and count
  my($self, $depth, $count) = @_;
  defined $depth or croak "Depth required\n";
  defined $count or croak "Count required\n";
  if (! $self->{_tables}{$depth} || ! $self->{_tables}{$depth}{$count}) {
    return undef;
  }
  $self->{_tables}{$depth}{$count};
}

sub rows {
  # Return the rows for a table. First table found if no table
  # specified.
  my($self, $table) = @_;
  my @tc;
  if (!$table) {
    $table = $self->first_table_found;
  }
  return () unless ref $table;
  my $ts = $self->{_table_mapback}{$table};
  $ts->rows;
}

sub first_table_found {
  shift->first_table_state_found(@_)->{content};
}

sub first_table_state_found {
  my $self = shift;
  ref $self->{_ts_sequential}[0] ? $self->{_ts_sequential}[0] : {};
}

sub tables {
  # Return content of all valid tables found, in the order that
  # they were seen.
  map($_->{content}, shift->table_states(@_));
}
  
sub table_states {
  # Return all valid table records  found, in the order that
  # they were seen.
  my $self = shift;
  @{$self->{_ts_sequential}};
}

sub table_coords {
  # Return the depth and count of a table
  my($self, $table) = @_;
  ref $table or croak "Table reference required\n";
  my $ts = $self->{_table_mapback}{$table};
  return () unless ref $ts;
  $ts->coords;
}

sub column_map {
  # Return the column numbers of a particular table in the same order
  # as the provided headers.
  my($self, $table) = @_;
  if (! defined $table) {
    $table = $self->first_table_found;
  }
  my $ts = $self->{_table_mapback}{$table};
  return () unless ref $ts;
  $ts->column_map;
}

### Runtime

sub _enter_table {
  my $self = shift;

  ++$self->{_cdepth};
  ++$self->{_in_a_table};

  my $depth = $self->{_cdepth};

  # Table states can come and go on the stack...here we retrieve the
  # table state for the table surrounding the current table tag
  # (parent table state). If the current table tag belongs to a top
  # level table, then this will be undef.
  my $pts = $self->_current_table_state;

  # Counts are tracked for each depth. Depth count hashes are
  # maintained for each of the table state objects; descendant
  # tables accumulate a list of these hashes, all of which track
  # counts relative to the point of view of that table state.
  my $counts = ref $pts ? $pts->{counts} : [$self->{_counts}];
  foreach (@{$counts}) {
    my $c = $_;
    if (exists $_->{$depth}) {
      ++$_->{$depth};
    }
    else {
      $_->{$depth} = 0;
    }
  }
  my $count = $self->{_counts}{$depth} || 0;

  print STDERR "TABLE: cdepth $depth, ccount $count, it: $self->{_in_a_table}\n"
    if $self->{debug} >= 2;

  # Umbrella status means that this current table and all of its
  # descendant tables will be harvested. This can happen when there
  # exist target conditions with no headers, depth, or count, or
  # when a particular table has been selected and the subtables
  # parameter was initially specified.
  my $umbrella = 0;
  if (ref $pts) {
    # If the subtables parameter was specified and the last table was
    # being harvested, the upcoming table (and therefore all of it's
    # descendants) is under an umbrella.
    ++$umbrella if $self->{subtables} && $pts->_active;
  }
  if (! defined $self->{depth} && !defined $self->{count}
      && !$self->{headers} && !$self->{chain}) {
    ++$umbrella;
  }

  # Basic parameters for the soon-to-be-created table state.
  my %tsparms = (
		 depth     => $depth,
		 count     => $count,
		 umbrella  => $umbrella,
		 automap   => $self->{automap},
		 elastic   => $self->{elastic},
		 counts    => $counts,
		 keep      => $self->{keep},
		 keepall   => $self->{keepall},
		 debug     => $self->{debug},
		 keep_html => $self->{keep_html},
		);

  # Target constraints. There is no point in passing any of these
  # along if we are under an umbrella. Notice that with table states,
  # "depth" and "count" are absolute coordinates recording where this
  # table was created, whereas "tdepth" and "tcount" are the target
  # constraints. Headers and chain have no "absolute" meaning,
  # therefore are passed by the same name.
  if (!$umbrella) {
    $tsparms{tdepth} = $self->{depth} if defined $self->{depth};
    $tsparms{tcount} = $self->{count} if defined $self->{count};
    foreach (qw(headers chain head_include)) {
      $tsparms{$_} = $self->{$_} if defined $self->{$_};
    }
  }

  # Abracadabra
  my $ts = HTML::TableExtract::TableState->new(%tsparms);

  # Inherit lineage
  unshift(@{$ts->{lineage}}, @{$pts->{lineage}}) if ref $pts;

  # Chain evolution from parent table state. Once again, however,
  # there is no point in passing the chain info along if we are under
  # an umbrella. These frames are just *potential* matches from the
  # chain. If no match occurs for a particular frame, then that frame
  # will simply be passed along to the next generation of table states
  # unchanged (assuming elastic behavior has not been disabled). Note:
  # frames based on top level constraints, as opposed to chain
  # specifications, are formed during TableState instantiation above.
  $pts->_spawn_frames($ts) if ref $self->{chain} && !$umbrella && ref $pts;

  # Inform the new table state that there will be no more constraints
  # forthcoming.
  $ts->_pre_latch;

  # Push the newly created and configured table state onto the
  # stack. This will now be the _current_table_state().
  push(@{$self->{_tablestack}}, $ts);
}

sub _exit_table {
  my $self = shift;
  my $ts = $self->_current_table_state;

  # Last ditch fix for HTML mangle
  $ts->_exit_cell if $ts->{in_cell};
  $ts->_exit_row if $ts->{in_row};

  if ($ts->_active) {
    # Retain our newly captured table, assuming we bothered with it.
    $self->_add_table_state($ts);
    print STDERR "Captured table ($ts->{depth},$ts->{count})\n"
      if $self->{debug} >= 2;
  }

  # Restore last table state
  pop(@{$self->{_tablestack}});
  --$self->{_in_a_table};
  my $lts = $self->_current_table_state;
  if (ref $lts) {
    $self->{_cdepth} = $lts->{depth};
  }
  else {
    # Back to the top level
    $self->{_cdepth} = -1;
  }
  print STDERR "LEAVE: cdepth: $self->{_cdepth}, ccount: $ts->{count}, it: $self->{_in_a_table}\n" if $self->{debug} >= 2;
}

sub _add_table_state {
  my($self, $ts) = @_;
  croak "Table state ref required\n" unless ref $ts;
  # Preliminary init sweep to appease -w
  #
  # These undefs would exist for empty <TD> since text() never got
  # called. Don't want to blindly do this in a start('td') because
  # headers might have vetoed. Also track max row length in case we
  # need to pad the other rows in gridmap mode.
  my $cmax = 0;
  foreach my $r (@{$ts->{content}}) {
    $cmax = $#$r if $#$r > $cmax;
    foreach (0 .. $#$r) {
      $r->[$_] = '' unless defined $r->[$_];
    }
  }
  # Pad right side of columns if gridmap or header slicing
  if ($self->{gridmap}) {
    foreach my $r (@{$ts->{content}}) {
      grep($r->[$_] = '', $#$r + 1 .. $cmax) if $#$r < $cmax;
    }
  }

  $self->{_tables}{$ts->{depth}}{$ts->{count}} = $ts;
  $self->{_table_mapback}{$ts->{content}} = $ts;
  push(@{$self->{_ts_sequential}}, $ts);
}

sub _current_table_state {
  my $self = shift;
  $self->{_tablestack}[$#{$self->{_tablestack}}];
}

##########

{

  package HTML::TableExtract::TableState;

  use strict;
  use Carp;

  sub new {
    my $that  = shift;
    my $class = ref($that) || $that;
    # Note: 'depth' and 'count' are where this table were found.
    #       'tdepth' and 'tcount' are target constraints on which to trigger.
    #       'headers' represent a target constraint, location independent.
    my $self  = {
		 umbrella => 0,
		 in_row   => 0,
		 in_cell  => 0,
		 rc       => -1,
		 cc       => -1,
		 frames   => [],
		 content  => [],
		 htxt     => '',
		 order    => [],
		 counts   => [{}],
		 debug    => 0,
		};
    bless $self, $class;

    my %parms = @_;

    # Depth and Count -- this is the absolute address of the table.
    croak "Absolute depth required\n" unless defined $parms{depth};
    croak "Count required\n"          unless defined $parms{count};

    # Inherit count contexts
    if ($parms{counts}) {
      push(@{$self->{counts}}, @{$parms{counts}});
      delete $parms{counts};
    }

    foreach (keys %parms) {
      $self->{$_} = $parms{$_};
    }

    # Register lineage
    $self->{lineage} = [ "$self->{depth},$self->{count}" ];

    # Umbrella is a short circuit. This table and all descendants will
    # be harvested if the umbrella parameter was asserted. If it was
    # not, then the initial conditions specified for the new table
    # state are passed along as the first frame in the chain.
    if (!$self->{umbrella}) {
      # Frames are designed to be used when chains are specified. With
      # no chains specified, there is only a single frame, the global
      # frame, so frames become a bit redundant. We use the mechanisms
      # anyway for consistency in the extraction engine. Each frame
      # contains information that might be relative to a chain
      # frame. Currently this means depth, count, and headers.
      my %frame;
      # Frame depth and count represent target depth and count, in
      # absolute terms. If present, our initial frame takes these from
      # the target values in the table state. Unlike frames generated
      # by chains, the counts hash for the initial frame comes from
      # the global level (this is necessary since the top-level HTML
      # document has no table state from which to inherit!). Counts
      # relative to this frame will be assigned and updated based on
      # chain links, assuming there are any.
      $frame{depth}    = $self->{tdepth}  if exists $self->{tdepth};
      $frame{count}    = $self->{tcount}  if exists $self->{tcount};
      $frame{headers}  = $self->{headers} if exists $self->{headers};
      $frame{counts}   = $self->{counts}[$#{$self->{counts}}];
      $frame{global}   = 1;
      $frame{terminus} = 1 if $self->{keep};
      $frame{heritage} = "($self->{depth},$self->{count})";
      $self->_add_frame(\%frame);
    }
    else {
      # Short circuit since we are an umbrella. Activate table state.
      $self->{active} = 1;
    }
    $self;
  }

  sub _text_hungry {
    # Text hungry only means that we are interested in gathering the
    # text, whether it be for header scanning or harvesting.
    my $self = shift;
    return 1 if $self->{umbrella};
    return 0 if $self->{prune};
    $self->_any_dctrigger;
  }

  sub _taste_text {
    # Gather the provided text, either for header scanning or
    # harvesting.
    my($self, $text) = @_;

    # Calculate and track skew, regardless of whether we actually want
    # this column or not.
    my $sc  = $self->_skew;

    # Harvest if trigger conditions have been met in a terminus
    # frame. If headers have been found, and we are not beneath a
    # header column, then ignore this text.
    if ($self->_terminus_trigger && $self->_column_wanted ||
	$self->{umbrella}) {
      if (defined $text) { # -w appeasement
	print STDERR "Add text '$text'\n" if $self->{debug} > 3;
	$self->_add_text($text, $sc);
      }
    }
    # Regardless of whether or not we are harvesting, we still try to
    # scan for headers in waypoint frames.
    if (defined $text && $self->_any_headers && !$self->_any_htrigger) {
      $self->_htxt($text);
    }
    1;
  }

  ### Init

  sub _pre_latch {
    # This should be called at some point soon after object creation
    # to inform the table state that there will be no more constraints
    # added. This way latches can be pre-set if possible for
    # efficiency.
    my $self = shift;

    $self->_trigger_frames;
    return 0 if $self->{prune};

    if ($self->{umbrella}) {
      ++$self->{dc_trigger};
      ++$self->{head_trigger};
      ++$self->{trigger};
      ++$self->{active};
      return;
    }
    # The following latches are detectable immediately for a
    # particular table state.
    $self->_terminus_dctrigger;
    $self->_any_dctrigger;
    $self->_terminus_headers;
    $self->_any_headers;

  }

  ### Latch methods...'terminus' vs 'any' is an important distinction,
  ### because conditions might only be satisifed for a waypoint
  ### frame. In this case, the next frame in the chain will be
  ### created, but the table itself will not be captured.

  sub _terminus_dctrigger {
    my $self = shift;
    return $self->{terminus_dctrigger} if defined $self->{terminus_dctrigger};
    $self->{terminus_dctrigger} = $self->_check_dctrigger($self->_terminus_frames);
  }

  sub _any_dctrigger {
    my $self = shift;
    return $self->{any_dctrigger} if defined $self->{any_dctrigger};
    $self->{any_dctrigger} = $self->_check_dctrigger(@{$self->{frames}});
  }

  sub _terminus_headers {
    my $self = shift;
    return $self->{terminus_headers} if defined $self->{terminus_headers};
    $self->{terminus_headers} = $self->_check_headers($self->_terminus_frames);
  }

  sub _any_headers {
    my $self = shift;
    return $self->{any_headers} if defined $self->{any_headers};
    $self->{any_headers} = $self->_check_headers(@{$self->{frames}});
  }

  sub _terminus_htrigger {
    # Unlike depth and count, this trigger should only latch on
    # positive values since each row is to be examined.
    my $self = shift;
    return $self->{terminus_htrigger} if $self->{terminus_htrigger};
    $self->{terminus_htrigger} = $self->_check_htrigger($self->_terminus_frames);
  }

  sub _any_htrigger {
    my $self = shift;
    return $self->{any_htrigger} if defined $self->{any_htrigger};
    $self->{any_htrigger} = $self->_check_htrigger(@{$self->{frames}});
  }

  sub _terminus_trigger {
    # This has to be the same frame reporting on dc/header
    # success. First found is the hero.
    my $self = shift;
    return $self->{terminus_trigger} if $self->{terminus_trigger};
    $self->{terminus_trigger} = $self->_check_trigger($self->_terminus_frames);
  }

  sub _any_trigger {
    # This has to be the same frame reporting on dc/header
    # success. First found is the hero.
    my $self = shift;
    return $self->{any_trigger} if $self->{any_trigger};
    $self->{any_trigger} = $self->_check_trigger(@{$self->{frames}});
  }

  ### Latch engines

  sub _check_dctrigger {
    my($self, @frames) = @_;
    return @frames if $self->{umbrella};
    my @dctriggered;
    foreach my $f (@frames) {
      my $dc_hit = 1;
      if ($f->{null}) {
	# Special case...
	$dc_hit = 0;
      }
      else {
	if (defined $f->{depth} && $f->{depth} != $self->{depth}) {
	  $dc_hit = 0;
	}
	elsif (defined $f->{count}) {
	  $dc_hit = 0;
	  if (exists $f->{counts}{$self->{depth}} &&
	      $f->{count} == $f->{counts}{$self->{depth}}) {
	    # Note: frame counts, though relative to chain genesis
	    # depth, are recorded in terms of absolute depths. A
	    # particular counts hash is shared among frames descended
	    # from the same chain instance.
	    $dc_hit = 1;
	  }
	}
      }
      push(@dctriggered, $f) if $dc_hit;
    }
    return @dctriggered ? \@dctriggered : undef;
  }

  sub _check_htrigger {
    my($self, @frames) = @_;
    my @htriggered;
    foreach my $f (@frames) {
      if ($f->{headers}) {
	push(@htriggered, $f) if $f->{head_found};
      }
      else {
	push(@htriggered, $f);
      }
    }
    @htriggered ? \@htriggered : undef;
  }

  sub _check_trigger {
    # This has to be the same frame reporting on dc/header
    # success. First found is the hero.
    my($self, @frames) = @_;
    return () unless @frames;
    my $tdct = $self->_check_dctrigger(@frames);
    my $tht  = $self->_check_htrigger(@frames);
    my %tframes;
    my %tdc_frames;
    foreach (ref $tdct ? @$tdct : ()) {
      $tdc_frames{$_} = $_;
      $tframes{$_} = $_ unless $tframes{$_};
    }
    my %th_frames;
    foreach (ref $tht ? @$tht : ()) {
      $th_frames{$_} = $_;
      $tframes{$_} = $_ unless $tframes{$_};
    }
    my @frame_order = grep($tframes{$_}, @frames);
    my @triggered;
    foreach (@frame_order) {
      if ($tdc_frames{$_} && $th_frames{$_}) {
	push(@triggered, $tframes{$_});
      }
    }
    @triggered ? \@triggered : undef;
  }

  sub _check_headers {
    my($self, @frames) = @_;
    foreach my $f (@frames) {
      return 1 if $f->{headers};
    }
    0;
  }

  ###

  sub _terminus_frames {
    # Return all frames that are at the end of a chain, or specified
    # as a terminus.
    my $self = shift;
    my @res;
    foreach (@{$self->{frames}}) {
      push(@res, $_) if $_->{terminus};
    }
    @res;
  }

  ###

  sub _trigger_frames {
    # Trigger each frame whose conditions have been met (i.e., rather
    # than merely detect conditions, set state in the affected frame
    # as well).
    my $self = shift;
    if (!@{$self->{frames}}) {
      ++$self->{prune};
      return 0;
    }
    my $t = 0;
    foreach my $f (@{$self->{frames}}) {
      if ($f->{triggered}) {
	++$t;
	next;
      }
      if ($self->_check_trigger($f)) {
	++$t;
	$f->{triggered} = 1;
      }
    }
    $t;
  }

  ### Maintain table context

  sub _enter_row {
    my $self = shift;
    $self->_exit_cell if $self->{in_cell};
    $self->_exit_row if $self->{in_row};
    ++$self->{rc};
    ++$self->{in_row};

    # Reset next_col for gridmapping
    $self->{next_col} = 0;
    while ($self->{taken}{"$self->{rc},$self->{next_col}"}) {
      ++$self->{next_col};
    }

    ++$self->{active} if $self->_terminus_trigger;
    if ($self->{active}) {
      # Add the new row, unless we're using headers and are still in
      # the header row
      push(@{$self->{content}}, [])
	unless $self->_terminus_headers && $self->_still_in_header_row;
    }
    $self->_evolve_frames if $self->_trigger_frames;
  }

  sub _exit_row {
    my $self = shift;
    if ($self->{in_row}) {
      $self->_exit_cell if $self->{in_cell};
      $self->{in_row} = 0;
      $self->{cc} = -1;
      $self->_reset_header_scanners;
      if ($self->_terminus_headers && $self->_still_in_header_row) {
        ++$self->{hslurp};
        # Store header row number so that we can adjust later (we keep
        # it around for now in case of skew situations, which are in
        # absolute row terms)
        $self->{hrow} = $self->{rc};
      }
    }
    else {
      print STDERR "Mangled HTML in table ($self->{depth},$self->{count}), extraneous </TR> ignored after row $self->{rc}\n"
        if $self->{debug};
    }
  }

  sub _enter_cell {
    my $self = shift;
    $self->_exit_cell if $self->{in_cell};
    if (!$self->{in_row}) {
      # Go ahead and try to recover from mangled HTML, because we
      # care.
      print STDERR "Mangled HTML in table ($self->{depth},$self->{count}), inferring <TR> as row $self->{rc}\n"
        if $self->{debug};
      $self->_enter_row;
    }
    ++$self->{cc};
    ++$self->{in_cell};
  }

  sub _exit_cell {
    my $self = shift;
    if ($self->{in_cell}) {
      # Trigger taste_text just in case this was an empty cell.
      $self->_taste_text(undef) if $self->_text_hungry;
      $self->{in_cell} = 0;
      $self->_hmatch;
    }
    else {
      print STDERR "Mangled HTML in table ($self->{depth},$self->{count}), extraneous </TD> ignored in row $self->{rc}\n"
        if $self->{debug};
    }
  }

  ###

  sub _add_frame {
    # Add new frames to this table state.
    my($self, @frames) = @_;
    return 1 if $self->{umbrella};
    foreach my $f (@frames) {
      ref $f or croak "Hash ref required\n";

      if (! exists $f->{depth} && ! exists $f->{count} && ! $f->{headers}) {
	# Special case. If there were no constraints, then umbrella
	# gets set. Otherwise, with chains, we want all nodes to
	# trigger but not become active due to the potential chain
	# constraint. This is just a heads up.
	++$f->{null};
      }

      # Take the opportunity to prune frames that are out of their
      # depth. Keep in mind, depths are specified in absolute terms
      # for frames, as opposed to relative terms in chains.
      if (defined $f->{depth} && $f->{depth} < $self->{depth}) {
	print STDERR "Pruning frame for depth $f->{depth} at depth $self->{depth}\n" if $self->{debug} > 2;
	next;
      }

      # If we are an intermediary in a chain, we will never trigger a
      # harvest (well, unless 'keep' was specified, anyway). Avoid
      # autovivifying here, because $self->{chain} is used as a test
      # many times.
      if (ref $self->{chain}) {
	if (defined $f->{chaindex} && $f->{chaindex} == $#{$self->{chain}}) {
	  ++$f->{terminus};
	}
      }
      elsif ($f->{global}) {
	# If there is no chain, the global frame is a terminus.
	++$f->{terminus};
      }

      # Scoop all triggers if keepall has been asserted.
      if ($self->{keepall}) {
	++$f->{terminus};
      }

      # Set up header pattern if we have headers.
      if ($f->{headers}) {
	my $hstring = '(' . join('|', map("($_)", @{$f->{headers}})) . ')';
	print STDERR "HPAT: /$hstring/\n" if $self->{debug} >= 2;
	$f->{hpat} = $hstring;
	$self->_reset_hits($f);
      }

      if ($self->{debug} > 3) {
        print STDERR "Adding frame ($f):\n   {\n";
        foreach (sort keys %$f) {
	  next unless defined $f->{$_}; # appease -w
	  print STDERR "    $_ => $f->{$_}\n";
	}
	print STDERR "   }\n";
      }

      push(@{$self->{frames}}, $f);
    }
    # Activate header state if there were any header conditions in the
    # frames.
    $self->_scan_state('headers');
    # Arbitrary true return value.
    scalar @{$self->{frames}};
  }

  # Header stuff

  sub _htxt {
    # Accumulate or reset header text. This is shared across all
    # frames.
    my $self = shift;
    if (@_) {
      if (defined $_[0]) {
	$self->{htxt} .= $_[0] if $_[0] !~ /^\s*$/;
      }
      else {
	$self->{htxt} = '';
      }
    }
    $self->{htxt};
  }

  sub _hmatch {
    # Given the current htxt, test all frames for matches. This *will*
    # set state in the frames in the event of a match.
    my $self = shift;
    my @hits;
    return 0 unless $self->_any_headers;
    foreach my $f (@{$self->{frames}}) {
      next unless $f->{hpat};
      if ($self->{htxt} =~ /$f->{hpat}/im) {
	my $hit = $1;
	print STDERR "HIT on '$hit' in $self->{htxt} ($self->{rc},$self->{cc})\n" if $self->{debug} >= 4;
	++$f->{scanning};
	# Get rid of the header segment that matched so we can tell
	# when we're through with all header patterns.
	foreach (keys %{$f->{hits_left}}) {
	  if ($hit =~ /$_/im) {
	    delete $f->{hits_left}{$_};
	    $hit = $_;
	    last;
	  }
	}
	push(@hits, $hit);
	#
	my $cc = $self->_skew;
	$f->{hits}{$cc} = $hit;
	push(@{$f->{order}}, $cc);
	if (!%{$f->{hits_left}}) {
	  # We have found all headers for this frame, but we won't
	  # start slurping until this row has ended
	  ++$f->{head_found};
	  $f->{scanning} = undef;
	}
      }
    }
    # Propogate relevant frame states to overall table state.
    foreach (qw(head_found scanning)) {
      $self->_scan_state($_);
    }
    # Reset htxt buffer
    $self->_htxt(undef);

    wantarray ? @hits : scalar @hits;
  }

  # Header and header state booleans

  sub _scan_state {
    # This just sets analagous flags on a table state basis
    # rather than a frame basis, for testing efficiency to
    # reduce the number of method calls involved.
    my($self, $state) = @_;
    foreach (@{$self->{frames}}) {
      ++$self->{$state} if $_->{state};
    }
    $self->{$state};
  }

  sub _headers     { shift->_check_state('headers'   ) }
  sub _head_found  { shift->_check_state('head_found') }
  sub _scanning    { shift->_check_state('scanning')   }

  # End header stuff

  sub _check_state {
    my($self, $state) = @_;
    defined $state or croak "State name required\n";
    my @frames_with_state;
    foreach my $f (@{$self->{frames}}) {
      push(@frames_with_state, $f) if $f->{$state};
    }
    return () unless @frames_with_state;
    wantarray ? @frames_with_state : $frames_with_state[0];   
  }

  # Misc

  sub _evolve_frames {
    # Retire frames that were triggered; integrate the next link in
    # the chain if available. If it was the global frame, or the frame
    # generated from the last in the chain sequence, then activate the
    # frame and start a new chain.
    my $self = shift;
    return if $self->{evolved};
    $self->{newframes} = [] unless $self->{newframes};
    foreach my $f (@{$self->{frames}}) {
      # We're only interested in newly triggered frames.
      next if !$f->{triggered} || $f->{retired};
      my %new;
      if ($self->{chain}) {
	if ($f->{global}) {
	  # We are the global frame, and we have a chain. Spawn a new
	  # chain.
	  $new{chaindex} = 0;
	  # Chain counts are always relative to the table state in
	  # which frame genisis occurred. Table states inherit the
	  # count contexts of parent table states, so that they can be
	  # updated (and therefore descendant frames get updated as
	  # well). Count contexts are represented as hashes with
	  # depths as keys. This frame-specific hash is shared amongst
	  # all frames descended from chains started in this table
	  # state.
	  $new{heritage} = "($self->{depth},$self->{count})";
	}
	elsif (defined $f->{chaindex}) {
	  # Generate a new frame based on the next link in the chain
	  # (unless we are the global frame, in which case we initialize
	  # a new chain since there is no chain link for the global
	  # frame).
	  $new{chaindex} = $f->{chaindex} + 1;
	  # Relative counts always are inherited from chain genesis. We
	  # pass by reference so siblings can all update the depth
	  # counts for that chain.
	  $new{heritage} = $f->{heritage};
	}
      }

      if ($f->{terminus}) {
	# This is a hit since we matched either in the global frame,
	# the last link of the chain, or in a link specified as a
	# keeper.
	++$f->{active} unless $f->{null};
	# If there is a chain, start a new one from this match if it
	# was the global frame (if we ever decided to have chains
	# spawn chains, this would be the place to do it. Currently
	# only the global frame spawns chains).

      }

      # Since we triggered, one way or the other this frame is retired.
      ++$f->{retired};

      # Frames always inherit the count context of the table state in
      # which they were created.
      $new{counts} = $self->{counts}[0];

      if (defined $new{chaindex}) {
	my $link = $self->{chain}[$new{chaindex}];
	# Tables immediately below the current table state are
	# considered depth 0 as specified in chains...hence actual
	# depth plus one forms the basis for depth 0 in relative
	# terms.
	$new{depth} = ($self->{depth} + 1) + $link->{depth}
	  if exists $link->{depth};
	$new{count}   = $link->{count}   if exists $link->{count};
	$new{headers} = $link->{headers} if exists $link->{headers};
	++$new{terminus} if $link->{keep};
	if ($self->{debug} > 3) {
	  print STDERR "New proto frame (in ts $self->{depth},$self->{count}) for chain rule $new{chaindex}\n";
	  print STDERR "   {\n";
	  foreach (sort keys %new) {
	    print STDERR "    $_ => $new{$_}";
	    if ($_ eq 'counts') {
	      print STDERR " ",join(' ', map("$_,$new{counts}{$_}",
					     sort { $a <=> $b } keys %{$new{counts}}));
	    }
	    print STDERR "\n";
	  }
	  print STDERR "   }\n";
	}
	push(@{$self->{newframes}}, \%new);
      }

    }
    # See if we're done evolving our frames.
    foreach my $f (@{$self->{frames}}) {
      return 0 unless $f->{retired};
    }
    # If we are, then flag the whole table state as evolved.
    ++$self->{evolved};
  }

  sub _spawn_frames {
    # Build and pass new frames to a child table state. This involves
    # retiring old frames and passing along untriggered and new
    # frames.
    my($self, $child) = @_;
    ref $child or croak "Child table state required\n";
    if ($self->{umbrella}) {
      # Don't mess with frames, just pass the umbrella.
      ++$child->{umbrella};
      return;
    }

    my @frames;
    my @fields = qw(chaindex depth count headers counts heritage terminus);

    foreach my $f (@{$self->{frames}}) {
      # Not interested in retired frames (which just matched), root
      # frames (which get regenerated each time a frame is created),
      # or in unmatched frames when not in elastic mode.
      next if !$self->{elastic} || $f->{retired};
      my %new;
      foreach (grep(exists $f->{$_}, @fields)) {
	$new{$_} = $f->{$_};
      }
      push(@frames, \%new);
    }

    # Always interested in newly created frames. Make sure and pass
    # copies, though, so that siblings don't update each others frame
    # sets.
    foreach my $f (@{$self->{newframes}}) {
      my %new;
      foreach (grep(exists $f->{$_}, @fields)) {
	$new{$_} = $f->{$_};
      }
      push(@frames, \%new);
    }

    $child->_add_frame(@frames) if @frames;
  }

  # Report methods

  sub depth { shift->{depth} }
  sub count { shift->{count} }
  sub coords {
    my $self = shift;
    ($self->depth, $self->count);
  }

  sub lineage {
    my $self = shift;
    map([split(',', $_)], @{$self->{lineage}});
  }

  sub rows {
    my $self = shift;
    if ($self->{automap} && $self->_map_makes_a_difference) {
      my @tc;
      my @cm = $self->column_map;
      foreach (@{$self->{content}}) {
	my $r = [@{$_}[@cm]];
	# since there could have been non-existent <TD> we need
	# to double check initilization to appease -w
	foreach (0 .. $#$r) {
	  $r->[$_] = '' unless defined $r->[$_];
	}
	push(@tc, $r);
      }
      return @tc;
    }
    # No remapping
    @{$self->{content}};
  }

  sub column_map {
    # Return the column numbers of this table in the same order as the
    # provided headers.
    my $self = shift;
    my $tframes = $self->_terminus_trigger;
    my $tframe = ref $tframes ? $tframes->[0] : undef;
    if ($tframe && $tframe->{headers}) {
      # First we order the original column counts by taking a hash
      # slice based on the original header order. The resulting
      # original column numbers are mapped to the actual content
      # indicies since we could have a sparse slice.
      my %order;
      foreach (keys %{$tframe->{hits}}) {
	$order{$tframe->{hits}{$_}} = $_;
      }
      return @order{@{$tframe->{headers}}};
    }
    else {
      return 0 .. $#{$self->{content}[0]};
    }
  }

  sub _map_makes_a_difference {
    my $self = shift;
    my $diff = 0;
    my @order  = $self->column_map;
    my @sorder = sort { $a <=> $b } @order;
    ++$diff if $#order != $#sorder;
    ++$diff if $#sorder != $#{$self->{content}[0]};
    foreach (0 .. $#order) {
      if ($order[$_] != $sorder[$_]) {
	++$diff;
	last;
      }
    }
    $diff;
  }

  sub _add_text {
    my($self, $txt, $skew_column) = @_;
    # We don't check for $txt being defined, sometimes we want to
    # merely insert a placeholder in the content.
    my $row = $self->{content}[$#{$self->{content}}];
    if (! defined $row->[$skew_column]) {
      # Init to appease -w
      $row->[$skew_column] = '';
    }
    return unless defined $txt;
    $row->[$skew_column] .= $txt;
    $txt;
  }

  sub _skew {
    # Skew registers the effects of rowspan/colspan issues when
    # gridmap is enabled.

    my($self, $rspan, $cspan) = @_;
    my($r,$c) = ($self->{rc},$self->{cc});

    if ($self->{debug} > 5) {
      print STDERR "($self->{rc},$self->{cc}) Inspecting skew for ($r,$c)";
      print STDERR defined $rspan ? " (set with $rspan,$cspan)\n" : "\n";
    }

    my $sc = $c;
    if (! defined $self->{skew_cache}{"$r,$c"}) {
      $sc = $self->{next_col} if defined $self->{next_col};
      $self->{skew_cache}{"$r,$c"} = $sc;
      my $next_col = $sc + 1;
      while ($self->{taken}{"$r,$next_col"}) {
	++$next_col;
      }
      $self->{next_col} = $next_col;
    }
    else {
      $sc = $self->{skew_cache}{"$r,$c"};
    }

    # If we have span arguments, set skews
    if (defined $rspan) {
      # Default span is always 1, even if not explicitly stated.
      $rspan = 1 unless $rspan;
      $cspan = 1 unless $cspan;
      --$rspan;
      --$cspan;
      # 1,1 is a degenerate case, there's nothing to do.
      if ($rspan || $cspan) {
	foreach my $rs (0 .. $rspan) {
	  my $cr = $r + $rs;
	  # If we in the same row as the skewer, the "span" is one less
	  # because the skewer cell occupies the same row.
	  my $start_col = $rs ? $sc : $sc + 1;
	  my $fin_col   = $sc + $cspan;
	  foreach ($start_col .. $fin_col) {
	    $self->{taken}{"$cr,$_"} = "$r,$sc" unless $self->{taken}{"$cr,$_"};
	  }
	  if (!$rs) {
	    my $next_col = $fin_col + 1;
	    while ($self->{taken}{"$cr,$next_col"}) {
	      ++$next_col;
	    }
	    $self->{next_col} = $next_col;
	  }
	}
      }
    }

    # Grid column number
    $sc;
  }

  sub _reset_header_scanners {
    # When a row ends, this should be called in order to reset frames
    # who are in the midst of header scans.
    my $self = shift;
    my @scanners;
    foreach my $f (@{$self->{frames}}) {
      next unless $f->{headers} && $f->{scanning};
      if ($self->{debug}) {
	my $str = "Incomplete header match in row $self->{rc}, resetting scan";
	$str .= " link $f->{chaindex}" if defined $f->{chaindex};
	$str .= "\n";
	print STDERR $str;
      }
      push(@scanners, $f);
    }
    $self->_reset_hits(@scanners) if @scanners;
  }

  sub _header_quest {
    # Loosely translated: "Should I even bother scanning for header
    # matches?"
    my $self = shift;
    return 0 unless $self->_any_headers && !$self->_head_found;
    foreach my $f (@{$self->{frames}}) {
      return 1 if $f->{headers} && $f->{dc_trigger};
    }
    0;
  }

  sub _still_in_header_row {
    my $self = shift;
    return 0 unless $self->_terminus_headers;
    !$self->{hslurp} && $self->_terminus_htrigger;
  }

  # Non waypoint answers

  sub _active {
    my $self = shift;
    return 1 if $self->{active};
    my @active;
    foreach my $f (@{$self->{frames}}) {
      push(@active, $f) if $f->{active};
    }
    return () unless @active;
    ++$self->{active} if @active;
    wantarray ? @active : $active[0];
  }

  sub _column_wanted {
    my $self = shift;
    my $tframes = $self->_terminus_trigger;
    my $tframe = ref $tframes ? $tframes->[0] : undef;
    return 0 unless $tframe;
    my $wanted = 1;
    if ($self->_terminus_headers && $self->{hslurp}) {
      # If we are using headers, veto the grab unless we are in an
      # applicable column beneath one of the headers.
      $wanted = 0
	unless exists $tframe->{hits}{$self->_skew};
    }
    print STDERR "Want ($self->{rc},$self->{cc}): $wanted\n"
      if $self->{debug} > 7;
    $wanted;
  }

  sub _reset_hits {
    # Reset hits in provided frames. WARNING!!! If you do not provide
    # frames, all frames will be reset!
    my($self, @frames) = @_;
    foreach my $frame (@frames ? @frames : @{$self->{frames}}) {
      next unless $frame->{headers};
      $frame->{hits}     = {};
      $frame->{order}    = [];
      $frame->{scanning} = undef;
      foreach (@{$frame->{headers}}) {
	++$frame->{hits_left}{$_};
      }
    }
    1;
  }

}

1;

__END__

=head1 NAME

HTML::TableExtract - Perl extension for extracting the text contained in tables within an HTML document.

=head1 SYNOPSIS

 # Matched tables are returned as "table state" objects; tables can be
 # matched using column headers, depth, count within a depth, or some
 # combination of the three.

 # Using column header information. Assume an HTML document with
 # tables that have "Date", "Price", and "Cost" somewhere in a
 # row. The columns beneath those headings are what you want to
 # extract. They will be returned in the same order as you specified
 # the headers since 'automap' is enabled by default.

 use HTML::TableExtract;
 $te = new HTML::TableExtract( headers => [qw(Date Price Cost)] );
 $te->parse($html_string);

 # Examine all matching tables
 foreach $ts ($te->table_states) {
   print "Table (", join(',', $ts->coords), "):\n";
   foreach $row ($ts->rows) {
      print join(',', @$row), "\n";
   }
 }

 # Old style, using top level methods rather than table state objects.
 foreach $table ($te->tables) {
   print "Table (", join(',', $te->table_coords($table)), "):\n";
   foreach $row ($te->rows($table)) {
     print join(',', @$row), "\n";
   }
 }

 # Shorthand...top level rows() method assumes the first table found
 # in the document if no arguments are supplied.
 foreach $row ($te->rows) {
    print join(',', @$row), "\n";
 }

 # Using depth and count information. Every table in the document has
 # a unique depth and count tuple, so when both are specified it is a
 # unique table. Depth and count both begin with 0, so in this case we
 # are looking for a table (depth 2) within a table (depth 1) within a
 # table (depth 0, which is the top level HTML document). In addition,
 # it must be the third (count 2) such instance of a table at that
 # depth.

 $te = new HTML::TableExtract( depth => 2, count => 2 );
 $te->parse($html_string);
 foreach $ts ($te->table_states) {
    print "Table found at ", join(',', $ts->coords), ":\n";
    foreach $row ($ts->rows) {
       print "   ", join(',', @$row), "\n";
    }
 }

=head1 DESCRIPTION

HTML::TableExtract is a subclass of HTML::Parser that serves to
extract the textual information from tables of interest contained
within an HTML document. The text from each extracted table is stored
in tabe state objects which hold the information as an array of arrays
that represent the rows and cells of that table.

There are three constraints available to specify which tables you
would like to extract from a document: I<Headers>, I<Depth>, and
I<Count>.

I<Headers>, the most flexible and adaptive of the techniques, involves
specifying text in an array that you expect to appear above the data
in the tables of interest. Once all headers have been located in a row
of that table, all further cells beneath the columns that matched your
headers are extracted. All other columns are ignored: think of it as
vertical slices through a table. In addition, TableExtract
automatically rearranges each row in the same order as the headers you
provided. If you would like to disable this, set I<automap> to 0
during object creation, and instead rely on the column_map() method to
find out the order in which the headers were found. Furthermore,
TableExtract will automatically compensate for cell span issues so
that columns are really the same columns as you would visually see in
a browser. This behavior can be disabled by setting the I<gridmap>
parameter to 0. HTML is stripped from the entire textual content of a
cell before header matches are attempted -- unless the I<keep_html>
parameter was enabled.

I<Depth> and I<Count> are more specific ways to specify tables in
relation to one another. I<Depth> represents how deeply a table
resides in other tables. The depth of a top-level table in the
document is 0. A table within a top-level table has a depth of 1, and
so on. Each depth can be thought of as a layer; tables sharing the
same depth are on the same layer. Within each of these layers,
I<Count> represents the order in which a table was seen at that depth,
starting with 0. Providing both a I<depth> and a I<count> will
uniquely specify a table within a document.

Each of the I<Headers>, I<Depth>, and I<Count> specifications are
cumulative in their effect on the overall extraction. For instance, if
you specify only a I<Depth>, then you get all tables at that depth
(note that these could very well reside in separate higher-level
tables throughout the document since depth extends across tables). If
you specify only a I<Count>, then the tables at that I<Count> from all
depths are returned (i.e., the I<n>th occurrence of a table at each
depth). If you only specify I<Headers>, then you get all tables in the
document containing those column headers. If you have specified
multiple constraints of I<Headers>, I<Depth>, and I<Count>, then each
constraint has veto power over whether a particular table is
extracted.

If no I<Headers>, I<Depth>, or I<Count> are specified, then all
tables match.

Text that is gathered from the tables is decoded with HTML::Entities
by default; this can be disabled by setting the I<decode> parameter to
0.

=head2 Chains

Make sure you fully understand the notions of I<depth> and I<count>
before proceeding, because it is about to become a bit more involved.

Table matches using I<Headers>, I<Depth>, or I<Count> can be chained
together in order to further specify tables relative to one
another. Links in chains are successively applied to tables within
tables. Top level constraints (i.e., I<header>, I<depth>, and I<count>
parameters for the TableExtract object) behave as the first link in
the chain. Additional links are specified using the I<chain>
parameter. Each link in the chain has its own set of constraints. For
example:

 $te = new HTML::TableExtract
   (
    headers => [qw(Summary Region)],
    chain   => [
                { depth => 0, count => 2 },
                { headers => [qw(Part Qty Cost)] }
               ],
   );

The matching process in this case will start with B<all> tables in the
document that have "Summary" and "Region" in their headers. For now,
assume that there was only one table that matched these headers. Each
table contained within that table will be compared to the first link
in the chain. Depth 0 means that a matching table must be immediately
contained within the current table; count 2 means that the matching
table must also be the third at that depth (counts and depths start at
0). In other words, the next link of the chain will match on the
third table immediately contained within our first matched table. Once
this link matches, then B<all> further tables beneath that table that
have "Part", "Qty", and "Cost" in their headers will match. By
default, it is only tables at the end of the chains that are returned
to the application, so these tables are returned.

Each time a link in a chain matches a table, an additional context for
I<depth> and I<count> is established. It is perhaps easiest to
visualize a I<context> as a brand-new HTML document, with new depths
and counts to compare to the remaining links in the chain. The top
level HTML document is the first context. Each table in the document
establishes a new context. I<Depth> in a chain link is relative to the
context that the matching table creates (i.e., a link depth of 0 would
be a table immediately contained within the table that matched the
prior link in the chain). Likewise, that same context keeps track of
I<counts> within the new depth scheme for comparison to the remaining
links in the chain. Headers still apply if they are present in a link,
but they are always independent of context.

As it turns out, specifying a depth and count provides a unique
address for a table within a context. For non-unique constraints, such
as just a depth, or headers, there can be multiple matches for a given
link. In these cases the chain "forks" and attempts to make further
matches within each of these tables.

By default, chains are I<elastic>. This means that when a particular
link does not match on a table, it is passed down to subtables
unchanged. For example:

 $te = new HTML::TableExtract
   (
    headers => [qw(Summary Region)],
    chain   => [
                { headers => [qw(Part Qty Cost)] }
               ],
   );

If there are intervening tables between the two header queries, they
will be ignored; this query will extract all tables with "Part",
"Qty", and "Cost" in the headers that are contained in any table with
"Summary" and "Region" in its headers, regardless of how embedded the
inner tables are. If you want a chain to be inelastic, you can set the
I<elastic> parameter to 0 for the whole TableExtract object. Using the
same example:

 $te = new HTML::TableExtract
   (
    headers => [qw(Summary Region)],
    chain   => [
                { headers => [qw(Part Qty Cost)] }
               ],
    elastic => 0,
   );

In this case, the inner table (Part, Qty, Cost) must be B<immediately>
contained within the outer table (Summary, Region) in order for the
match to take place. This is equivalent to specifying a depth of 0 for
each link in the chain; if you only want particular links to be
inelastic, then simply set their depths to 0.

By default, only tables that match at the end of the chains are
retained. The intermediate matches along the chain are referred to as
I<waypoints>, and are not extracted by default. A waypoint may be
retained, however, by specifiying the I<keep> parameter in that link
of the chain. This parameter may be specified at the top level as well
if you want to keep tables that match the first set of constraints in
the object. If you want to keep all tables that match along the chain,
the specify the I<keepall> parameter at the top level.

Are chains overkill? Probably. In reality, nested HTML tables tend not
to be very deep, so there will usually not be much need for lots of
links in a chain. Theoretically, however, chains offer precise
targeting of tables relative to one another, no matter how deeply
nested they are.

=head2 Pop Quiz

What happens with the following table extraction?

 $te = new HTML::TableExtract(
                              chain => [ { depth => 0 } ],
                             );

Answer: All tables that are contained in another table are extracted
from the document. In this case, there were no top-level constraints
specified, which if you recall means that B<all> tables match the
first set of constraints (or non-constraints, in this case!). A depth
of 0 in the next link of the chain means that the matching table must
be immediately contained within the table from a prior match.

The following is equivalent:

 $te = new HTML::TableExtract(
                              depth     => 1,
                              subtables => 1,
                             )

The I<subtables> parameter tells TableExtract to scoop up all tables
contained within the matching tables. In conjunction with a depth of
1, this has the affect of discarding all top-level tables in the
document, which is exactly what occurred in the prior example.

=head2 Advice

The main point of this module was to provide a flexible method of
extracting tabular information from HTML documents without relying to
heavily on the document layout. For that reason, I suggest using
I<Headers> whenever possible -- that way, you are anchoring your
extraction on what the document is trying to communicate rather than
some feature of the HTML comprising the document (other than the fact
that the data is contained in a table).

HTML::TableExtract is a subclass of HTML::Parser, and as such inherits
all of its basic methods. In particular, C<start()>, C<end()>, and
C<text()> are utilized. Feel free to override them, but if you do not
eventually invoke them in the SUPER class with some content, results
are not guaranteed.

=head1 METHODS

The following are the top-level methods of the HTML::TableExtract
object. Tables that have matched a query are actually returned as
separate objects of type HTML::TableExtract::TableState. These table
state objects have their own methods, documented further below. There
are some top-level methods that are present for convenience and
backwards compatibility that are nothing more than front-ends for
equivalent table state methods.

=over

=head2 Constructor

=item new()

Return a new HTML::TableExtract object. Valid attributes are:

=over

=item headers

Passed as an array reference, headers specify strings of interest at
the top of columns within targeted tables. These header strings will
eventually be passed through a non-anchored, case-insensitive regular
expression, so regexp special characters are allowed. The table row
containing the headers is B<not> returned. Columns that are not
beneath one of the provided headers will be ignored. Columns will, by
default, be rearranged into the same order as the headers you provide
(see the I<automap> parameter for more information). Additionally, by
default columns are considered what you would see visually beneath
that header when the table is rendered in a browser. See the
I<gridmap> parameter for more information. HTML within a header is
stripped before the match is attempted, unless the B<keep_html>
parameter was specified.

=item depth

Specify how embedded in other tables your tables of interest should
be. Top-level tables in the HTML document have a depth of 0, tables
within top-level tables have a depth of 1, and so on.

=item count

Specify which table within each depth you are interested in, beginning
with 0.

=item chain

List of additional constraints to be matched sequentially from the top
level constraints. This is a reference to an array of hash
references. Each hash is a link in the chain, and can be specified in
terms of I<depth>, I<count>, and I<headers>. Further modifiers include
I<keep>, which means to retain the table if it would normally be
dropped as a waypoint.

=item automap

Automatically applies the ordering reported by column_map() to the
rows returned by rows(). This only makes a difference if you have
specified I<Headers> and they turn out to be in a different order in
the table than what you specified. Automap will rearrange the columns
in the same order as the headers appear. To get the original ordering,
you will need to take another slice of each row using
column_map(). I<automap> is enabled by default.

=item gridmap

Controls whether the table contents are returned as a grid or a
tree. ROWSPAN and COLSPAN issues are compensated for, and columns
really are columns. Empty phantom cells are created where they would
have been obscured by ROWSPAN or COLSPAN settings. This really becomes
an issue when extracting columns beneath headers. Enabled by default.

=item keepall

Keep all tables that matched along a chain, including tables matched
by top level contraints. By default, waypoints are dropped and only
the matches at the end of the chain are retained. To retain a
particular waypoint along a chain, use the I<keep> parameter in that
link.

=item elastic

When set to 0, all links in chains will be treated as though they had
a depth of 0 specified, which means there can be no intervening
unmatched tables between matches on links.

=item subtables

Extract all tables within matched tables.

=item decode

Automatically decode retrieved text with
HTML::Entities::decode_entities(). Enabled by default.

=item br_translate

Translate <br> tags into newlines. Sometimes the remaining text can be
hard to parse if the <br> tag is simply dropped. Enabled by default.
Has no effect if I<keep_html> is enabled.

=item keep_html

Return the raw HTML contained in the cell, rather than just the
visible text. Embedded tables are B<not> retained in the HTML
extracted from a cell. Patterns for header matches must take into
account HTML in the string if this option is enabled.

=item debug

Prints some debugging information to STDOUT, more for higher values.

=back

=head2 Regular Methods

=item depths()

Returns all depths that contained matched tables in the document.

=item counts($depth)

For a particular depth, returns all counts that contained matched
tables.

=item table_state($depth, $count)

For a particular depth and count, return the table state object for
the table found, if any.

=item table_states()

Return table state objects for all tables that matched.

=item first_table_state_found()

Return the table state object for the first table matched in the
document.

=head2 TABLE STATE METHODS

The following methods are invoked from an
HTML::TableExtract::TableState object, such as those returned from the
C<table_states()> method.

=item rows()

Return all rows within a matched table. Each row returned is a
reference to an array containing the text of each cell.

=item depth()

Return the (absolute) depth at which this table was found.

=item count()

Return the count for this table within the depth it was found.

=item coords()

Return depth and count in a list.

=item column_map()

Return the order (via indices) in which the provided headers were
found. These indices can be used as slices on rows to either order the
rows in the same order as headers or restore the rows to their natural
order, depending on whether the rows have been pre-adjusted using the
I<automap> parameter.

=item lineage()

Returns the path of matched tables that led to matching this
table. Lineage only makes sense if chains were used. Tables that were
not matched by a link in the chain are not included in lineage. The
lineage path is a list of array refs containing depth and count values
for each table involved.

=head2 Procedural Methods

The following top level methods are alternatives to invoking methods
in a table state object. If you do not want to deal with table state
objects, then these methods are for you. The "tables" they deal in are
actually just arrays of arrays, which happen to be the current
internal data structure of the table state objects. They are here for
backwards compatibility.

=item table($depth, $count)

Same as C<table_state()>, but returns the internal data structure
rather than the table state object.

=item tables()

Same as C<table_states()>, but returns the data structures rather than
the table state objects.

=item first_table_found()

Same as C<first_table_state_found()>, except returns the data
structure for first table that matched.

=item table_coords($table)

Returns the depth and count for a particular table data structure. See
the C<coords()> method provided by table state objects.

=item rows()

=item rows($table)

Return a lsit of the rows for a particular table data structure (first
table found by default). See the C<rows()> method provided by table
state objects.

=item column_map()

=item column_map($table)

Return the column map for a particular table data structure (first
found by default). See the C<column_map()> method provided by table
state objects.

=back

=head1 REQUIRES

HTML::Parser(3), HTML::Entities(3)

=head1 AUTHOR

Matthew P. Sisk, E<lt>F<sisk@mojotoad.com>E<gt>

=head1 COPYRIGHT

Copyright (c) 2000-2002 Matthew P. Sisk.
All rights reserved. All wrongs revenged. This program is free
software; you can redistribute it and/or modify it under the
same terms as Perl itself.

=head1 SEE ALSO

HTML::Parser(3), perl(1).

=cut

In honor of fragmented markup languages and sugar mining:

The Good and The Bad
Ted Hawkins (1936-1994)

Living is good
   when you have someone to share it with
Laughter is bad
   when there is no one there to share it with
Talking is sad 
   if you've got no one to talk to
Dying is good
   when the one you love grows tired of you

Sugar is no good
   once it's cast among the white sand
What the point
   in pulling the gray hairs from among the black strands
When you're old
   you shouldn't walk in the fast lane
Oh ain't it useless
   to keep trying to draw true love from that man

He'll hurt you,
   Yes just for the sake of hurting you
and he'll hate you
   if you try to love him just the same
He'll use you
   and everything you have to offer him
On your way girl
   Get out and find you someone new
