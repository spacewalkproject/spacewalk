package Config::IniFiles;
$Config::IniFiles::VERSION = (qw($Revision: 1.4 $))[1];
use Carp;
use strict;
require 5.004;

@Config::IniFiles::errors = ( );

#	$Header: /tmp/svnmove/cvs-orig/PerlModules/CPAN/Config-IniFiles-2.19/IniFiles.pm,v 1.4 2003-12-05 18:20:12 kdykeman Exp $

=head1 NAME

Config::IniFiles - A module for reading .ini-style configuration files.

=head1 SYNOPSIS

  use Config::IniFiles;
  my $cfg = new Config::IniFiles( -file => "/path/configfile.ini" );
  print "We have parm " . $cfg->val( 'Section', 'Parameter' ) . "."
  	if $cfg->val( 'Section', 'Parameter' );

=head1 DESCRIPTION

Config::IniFiles provides a way to have readable configuration files outside
your Perl script.  Configurations can be imported (inherited, stacked,...), 
sections can be grouped, and settings can be accessed from a tied hash.

=head1 FILE FORMAT

INI files consist of a number of sections, each preceded with the
section name in square brackets.  The first non-blank character of
the line indicating a section must be a left bracket and the last
nonblank character of a line indicating a section must be a right
bracket. The characters making up the section name can be any 
symbols at all. However section names must be unique.

Parameters are specified in each section as Name=Value.  Any spaces
around the equals sign will be ignored, and the value extends to the
end of the line. Parameter names are localized to the namespace of 
the section, but must be unique within a section.

  [section]
  Parameter=Value

Both the hash mark (#) and the semicolon (;) are comment characters.
Lines that begin with either of these characters will be ignored.  Any
amount of whitespace may preceed the comment character.

Multiline or multi-valued parameters may also be defined ala UNIX 
"here document" syntax:

  Parameter=<<EOT
  value/line 1
  value/line 2
  EOT

You may use any string you want in place of "EOT".  Note that what
follows the "<<" and what appears at the end of the text MUST match
exactly, including any trailing whitespace.

=head1 USAGE -- Object Interface

Get a new Config::IniFiles object with the I<new> method:

  $cfg = Config::IniFiles->new( -file => "/path/configfile.ini" );
  $cfg = new Config::IniFiles -file => "/path/configfile.ini";

Optional named parameters may be specified after the configuration
file name.  See the I<new> in the B<METHODS> section, below.

Values from the config file are fetched with the val method:

  $value = $cfg->val('Section', 'Parameter');

If you want a multi-line/value field returned as an array, just
specify an array as the receiver:

  @values = $cfg->val('Section', 'Parameter');

=head1 METHODS

=head2 new ( [-option=>value ...] )

Returns a new configuration object (or "undef" if the configuration
file has an error).  One Config::IniFiles object is required per configuration
file.  The following named parameters are available:

=over 10

=item I<-file>  filename

Specifies a file to load the parameters from. If this option is not specified, (ie:
you are creating a config file from scratch) you must specify a target file
using SetFileName in order to save the parameters.

=item I<-default> section

Specifies a section to be used for default values. For example, if you
look up the "permissions" parameter in the "users" section, but there
is none, Config::IniFiles will look to your default section for a "permissions"
value before returning undef.

=item I<-reloadwarn> 0|1

Set -reloadwarn => 1 to enable a warning message (output to STDERR)
whenever the config file is reloaded.  The reload message is of the
form:

  PID <PID> reloading config file <file> at YYYY.MM.DD HH:MM:SS

Default behavior is to not warn (i.e. -reloadwarn => 0).

=item I<-nocase> 0|1

Set -nocase => 1 to handle the config file in a case-insensitive
manner (case in values is preserved, however).  By default, config
files are case-sensitive (i.e., a section named 'Test' is not the same
as a section named 'test').  Note that there is an added overhead for
turning off case sensitivity.

=item I<-import> object

This allows you to import or inherit existing setting from another 
Config::IniFiles object. When importing settings from another object, 
sections with the same name will be merged and parameters that are 
defined in both the imported object and the I<-file> will take the 
value of given in the I<-file>. 

If a I<-default> section is also given on this call, and it does not 
coincide with the default of the imported object, the new default 
section will be used instead. If no I<-default> section is given, 
then the default of the imported object will be used.

=back

=cut

sub new {
  my $class = shift;
  my %parms = @_;

  my $errs = 0;
  my @groups = ( );

  my $self           = {};
  # Set config file to default value, which is nothing
  $self->{cf}        = '';
  if( ref($parms{-import}) && ($parms{-import}->isa('Config::IniFiles')) ) {
    # Import from the import object by COPYing, so we
	# don't clobber the old object
    %{$self} = %{$parms{-import}};
  } else {
    $self->{firstload} = 1;
    $self->{default}   = '';
    $self->{imported}  = [];
    if( defined $parms{-import} ) {
      carp "Invalid -import value was ignored.";
      delete $parms{-import};
    } # end if
  } # end if

  # Parse options
  my($k, $v);
  local $_;
  while (($k, $v) = each %parms) {
    if( $k eq '-import' ) {
    	# Store the imported object's file parameter for reload
    	push( @{$self->{imported}}, $self->{cf} ) if $self->{cf};
    }
    elsif ($k eq '-file') {
      # Should we be pedantic and check that the file exists?
      $self->{cf} = $v;
    }
    elsif ($k eq '-default') {
      $self->{default} = $v;
    }
    elsif ($k eq '-nocase') {
      $self->{nocase} = $v ? 1 : 0;
    }
    elsif ($k eq '-reloadwarn') {
      $self->{reloadwarn} = $v ? 1 : 0;
    }
    else {
      carp "Unknown named parameter $k=>$v";
      $errs++;
    }
  }

  # Copy the original parameters so we 
  # can use them when we build new sections 
  %{$self->{startup_settings}} = %parms;

  return undef if $errs;

  bless $self, $class;

  # No config file specified, so everything's okay so far.
  if ($self->{cf} eq '') {
    return $self;
  }
  
  if ($self->ReadConfig) {
    return $self;
  } else {
    return undef;
  }
}

=head2 val ($section, $parameter)

Returns the value of the specified parameter (C<$parameter>) in section 
C<$section>, returns undef if no section or no parameter for the given section
section exists.

If you want a multi-line/value field returned as an array, just
specify an array as the receiver:

  @values = $cfg->val('Section', 'Parameter');

=cut

sub val {
  my ($self, $sect, $parm) = @_;

  if ($self->{nocase}) {
    $sect = lc($sect);
    $parm = lc($parm);
  }
  my $val = defined($self->{v}{$sect}{$parm}) ?
    $self->{v}{$sect}{$parm} :
    $self->{v}{$self->{default}}{$parm};
  if( defined ($/) && defined ($val) && $val =~ m#$/#) {
    return wantarray ? split( $/, $val ) : $val;
  } else {
    return $val;
  }
}

=head2 setval ($section, $parameter, $value, [ $value2, ... ])

Sets the value of parameter C<$parameter> in section C<$section> to 
C<$value> (or to a set of values).  See below for methods to write 
the new configuration back out to a file.

You may not set a parameter that didn't exist in the original
configuration file.  B<setval> will return I<undef> if this is
attempted. See B<newval> below to do this. Otherwise, it returns 1.

=cut

sub setval {
  my $self = shift;
  my $sect = shift;
  my $parm = shift;
  my @val  = @_;

# tom@ytram.com +
  if ($self->{nocase}) {
    $sect = lc($sect);
    $parm = lc($parm);
  }
# tom@ytram.com -

  if (defined($self->{v}{$sect}{$parm})) {
    if (@val > 1) {
      $self->{v}{$sect}{$parm} = \@val;
	  $self->{EOT}{$sect}{$parm} = 'EOT';
    } else {
      $self->{v}{$sect}{$parm} = shift @val;
    }
    return 1;
  } else {
    return undef;
  }
}

=head2 newval($setion, $parameter, $value [, $value2, ...])

Assignes a new value, C<$value> (or set of values) to the 
parameter C<$parameter> in section C<$section> in the configuration 
file.

=cut

sub newval {
  my $self = shift;
  my $sect = shift;
  my $parm = shift;
  my @val  = @_;

# tom@ytram.com +
  if ($self->{nocase}) {
    $sect = lc($sect);
    $parm = lc($parm);
  }
# tom@ytram.com -

    push(@{$self->{sects}}, $sect) unless (grep /^\Q$sect\E$/, @{$self->{sects}});
    $self->{v}{$sect} = {} unless ref $self->{v}{$sect} eq 'HASH';
    $self->{parms}{$sect} = [] unless ref($self->{parms}{$sect}) eq 'ARRAY';

    push(@{$self->{parms}{$sect}}, $parm) 
      unless (grep /^\Q$parm\E$/,@{$self->{parms}{$sect}} );

  if (@val > 1) {
    $self->{v}{$sect}{$parm} = \@val;
	$self->{EOT}{$sect}{$parm} = 'EOT' unless defined
				$self->{EOT}{$sect}{$parm};
  } else {
    $self->{v}{$sect}{$parm} = shift @val;
  }
  return 1
}

=head2 delval($section, $parameter)

Deletes the specified parameter from the configuration file

=cut

sub delval {
  my $self = shift;
  my $sect = shift;
  my $parm = shift;

# tom@ytram.com +
  if ($self->{nocase}) {
    $sect = lc($sect);
    $parm = lc($parm);
  }
# tom@ytram.com -

	@{$self->{parms}{$sect}} = grep !/^\Q$parm\E$/, @{$self->{parms}{$sect}};
	delete $self->{v}{$sect}{$parm};
	return 1
}

=head2 ReadConfig

Forces the configuration file to be re-read. Returns undef if the 
file can not be opened, no filename was defined (with the C<-file>
option) when the object was constructed, or an error occurred while 
reading.

If an error occurs while parsinf the INI file the @Config::IniFiles::errors
array will contain messages that might help you figure out where the 
problem is in the file.

=cut

sub ReadConfig {
  my $self = shift;

  local *CF;
  my($lineno, $sect);
  my($group, $groupmem);
  my($parm, $val);
  my @cmts;
  my %loaded_params = ();			# A has to remember which params are loaded vs. imported
  @Config::IniFiles::errors = ( );

  # Initialize (and clear out) storage hashes
  # unless we imported them from another file [JW]
  if( @{$self->{imported}} ) {
    #
    # Run up the import tree to the top, then reload coming
    # back down, maintaining the imported file names and our 
    # file name
    #
    my $cf = $self->{cf};
    $self->{cf} = pop @{$self->{imported}};
    $self->ReadConfig;
    push @{$self->{imported}}, $self->{cf};
    $self->{cf} = $cf;
  } else {
    $self->{sects}  = [];		# Sections
    $self->{group}  = {};		# Subsection lists
    $self->{v}      = {};		# Parameter values
    $self->{sCMT}   = {};		# Comments above section
  } # end if
  
  return undef if (
    (not exists $self->{cf}) or
    (not defined $self->{cf}) or
    ($self->{cf} eq '')
  );
  
  my $nocase = $self->{nocase};

  my ($ss, $mm, $hh, $DD, $MM, $YY) = (localtime(time))[0..5];
  printf STDERR
    "PID %d reloading config file %s at %d.%02d.%02d %02d:%02d:%02d\n",
    $$, $self->{cf}, $YY+1900, $MM+1, $DD, $hh, $mm, $ss
    unless $self->{firstload} || !$self->{reloadwarn};

  $self->{firstload} = 0;

  if (!open(CF, $self->{cf})) {
    carp "Failed to open $self->{cf}: $!";
    return undef;
  }
  my @stats = stat CF;
  $self->{file_mode} = sprintf "%04o", $stats[2];
  local $_;
  my @lines = split /[\015\012]+/, join( '', <CF>);
  close(CF);
  # Store what our line ending char was for output
  ($self->{line_ends}) = $lines[0] =~ /([\015\012]+)/;
  while ( @lines ) {
    $_ = shift @lines;

    s/[\015\012]+$//;				# remove line ending char(s)
    $lineno++;
    if (/^\s*$/) {				# ignore blank lines
      next;
    }
    elsif (/^\s*[\#\;]/) {			# collect comments
      push(@cmts, $_);
      next;
    }
    elsif (/^\s*\[\s*(\S|\S.*\S)\s*\]\s*$/) {		# New Section
      $sect = $1;
      $sect = lc($sect) if $nocase;
      push(@{$self->{sects}}, $sect) unless grep(/^\Q$sect\E$/, @{$self->{sects}});
      if ($sect =~ /(\S+)\s+\S+/) {		# New Group Member
	$group = $1;
	if (!defined($self->{group}{$group})) {
	  $self->{group}{$group} = [];
	}
	push(@{$self->{group}{$group}}, $sect) unless grep(/\Q$sect\E/, @{$self->{group}{$group}});
      }
      if (!defined($self->{v}{$sect})) {
	$self->{sCMT}{$sect} = [@cmts] if @cmts > 0;
	$self->{pCMT}{$sect} = {};		# Comments above parameters
	$self->{parms}{$sect} = [];
	@cmts = ( );
	$self->{v}{$sect} = {};
      }
    }
    elsif (($parm, $val) = /\s*([^=]+?)\s*=\s*(.*)/) {	# new parameter
      $parm = lc($parm) if $nocase;
      $self->{pCMT}{$sect}{$parm} = [@cmts];
      @cmts = ( );
      if ($val =~ /^<<(.*)/) {			# "here" value
	my $eotmark  = $1;
	my $foundeot = 0;
	my $startline = $lineno;
	my @val = ( );
	while ( @lines ) {
	  $_ = shift @lines;
	  s/[\015\012]+$//;				# remove line ending char(s)
	  $lineno++;
	  if ($_ eq $eotmark) {
	    $foundeot = 1;
	    last;
	  } else {
	    push(@val, $_);
	  }
	}
	if ($foundeot) {
	    if (exists $self->{v}{$sect}{$parm} && 
	        exists $loaded_params{$sect} && 
	        grep( /^$parm$/, @{$loaded_params{$sect}}) ) {
	      if (ref($self->{v}{$sect}{$parm}) eq "ARRAY") {
	        # Add to the array
	        push @{$self->{v}{$sect}{$parm}}, @val;
	      } else {
	        # Create array
	        my $old_value = $self->{v}{$sect}{$parm};
	        my @new_value = ($old_value, @val);
	        $self->{v}{$sect}{$parm} = \@new_value;
	      }
	    } else {
		$self->{v}{$sect}{$parm} = \@val;
		$loaded_params{$sect} = [] unless $loaded_params{$sect};
		push @{$loaded_params{$sect}}, $parm;
	    }
	    $self->{EOT}{$sect}{$parm} = $eotmark;
	} else {
	  push(@Config::IniFiles::errors, sprintf('%d: %s', $startline,
			      qq#no end marker ("$eotmark") found#));
	}
      } else {
	if (exists $self->{v}{$sect}{$parm} &&
	    exists $loaded_params{$sect} && 
	    grep( /^$parm$/, @{$loaded_params{$sect}}) ) {
	    if (ref($self->{v}{$sect}{$parm}) eq "ARRAY") {
		# Add to the array
		push @{$self->{v}{$sect}{$parm}}, $val;
	    } else {
		# Create array
		my $old_value = $self->{v}{$sect}{$parm};
		my @new_value = ($old_value, $val);
		$self->{v}{$sect}{$parm} = \@new_value;
	    }
	} else {
	    $self->{v}{$sect}{$parm} = $val;
	    $loaded_params{$sect} = [] unless $loaded_params{$sect};
	    push @{$loaded_params{$sect}}, $parm;
	}
      }
      push(@{$self->{parms}{$sect}}, $parm) unless grep(/^\Q$parm\E$/, @{$self->{parms}{$sect}});
    }
    else {
      push(@Config::IniFiles::errors, sprintf('%d: %s', $lineno, $_));
    }
  }

  #
  # Now convert all the parameter hashes into tied hashes.
  # This is in all uses, because it must be part of ReadConfig.
  #
  my %parms = %{$self->{startup_settings}};
  if( defined $parms{-default} ) {
    # If the default section doesn't exists, create it.
    unless( defined $self->{v}{$parms{-default}} ) {
      $self->{v}{$parms{-default}} = {};
      push(@{$self->{sects}}, $parms{-default}) unless (grep /^\Q$parms{-default}\E$/, @{$self->{sects}});
      $self->{parms}{$parms{-default}} = [];
    } # end unless
    $parms{-default} = $self->{v}{$parms{-default}};
  } # end if
  foreach( keys %{$self->{v}} ) {
    $parms{-_current_value} = $self->{v}{$_};
    $parms{-parms} = $self->{parms}{$_};
    $self->{v}{$_} = {};
    # Add a reference to our {parms} hash for each section
    tie %{$self->{v}{$_}}, 'Config::IniFiles::_section', %parms
  } # end foreach

  @Config::IniFiles::errors ? undef : 1;
}


=head2 Sections

Returns an array containing section names in the configuration file.
If the I<nocase> option was turned on when the config object was
created, the section names will be returned in lowercase.

=cut

sub Sections {
  my $self = shift;
  return @{$self->{sects}} if ref $self->{sects} eq 'ARRAY';
  return ();
}

=head2 Parameters ($section_name)

Returns an array containing the parameters contained in the specified
section.

=cut

sub Parameters {
  my $self = shift;
  my $sect = shift;
  return @{$self->{parms}{$sect}} if ref $self->{parms}{$sect} eq 'ARRAY';
  return ();
}

=head2 Groups

Returns an array containing the names of available groups.
  
Groups are specified in the config file as new sections of the form

  [GroupName MemberName]

This is useful for building up lists.  Note that parameters within a
"member" section are referenced normally (i.e., the section name is
still "Groupname Membername", including the space) - the concept of
Groups is to aid people building more complex configuration files.

=cut

sub Groups	{
  my $self = shift;
  return keys %{$self->{group}} if ref $self->{group} eq 'HASH';
  return ();
}

=head2 GroupMembers ($group)

Returns an array containing the members of specified $group. Each element
of the array is a section name. For example, given the sections

  [Group Element 1]
  ...

  [Group Element 2]
  ...

GroupMembers would return ("Group Element 1", "Group Element 2").

=cut

sub GroupMembers {
  my $self  = shift;
  my $group = shift;
  return @{$self->{group}{$group}} if ref $self->{group}{$group} eq 'ARRAY';
  return ();
}

=head2 WriteConfig ($filename)

Writes out a new copy of the configuration file.  A temporary file
(ending in .new) is written out and then renamed to the specified
filename.  Also see B<BUGS> below.

=cut

sub WriteConfig {
  my $self = shift;
  my $file = shift;

  local(*F);
  open(F, "> $file.new") || do {
    carp "Unable to write temp config file $file: $!";
    return undef;
  };
  my $oldfh = select(F);
  $self->OutputConfig;
  close(F);
  select($oldfh);
  rename "$file.new", $file || do {
    carp "Unable to rename temp config file to $file: $!";
    return undef;
  };
  if (exists $self->{file_mode}) {
    chmod oct($self->{file_mode}), $file;
  }
  return 1;
}

=head2 RewriteConfig

Same as WriteConfig, but specifies that the original configuration
file should be rewritten.

=cut

sub RewriteConfig {
  my $self = shift;
  
  return undef if (
    (not exists $self->{cf}) or
    (not defined $self->{cf}) or
    ($self->{cf} eq '')
  );
  
  # Return whatever WriteConfig returns :)
  $self->WriteConfig($self->{cf});
}

=head2 SetFileName ($filename)

If you created the Config::IniFiles object without initialising from
a file, or if you just want to change the name of the file to use for
ReadConfig/RewriteConfig from now on, use this method.

Returns $filename if that was a valid name, undef otherwise.

=cut

sub SetFileName {
  my $self = shift;
  my $newfile = shift;
  if ((defined $newfile) and ($newfile ne "")) {
    $self->{cf} = $newfile;
    return $self->{cf};
  }
  return undef;
}

# OutputConfig
#
# Writes OutputConfig to STDOUT. Use select() to redirect STDOUT to
# the output target before calling this function

sub OutputConfig {
  my $self = shift;

  my($sect, $parm, @cmts);
  my $ors = $self->{line_ends} || $\ || "\n";		# $\ is normally unset, but use input by default
  my $notfirst = 0;
  local $_;
  foreach $sect (@{$self->{sects}}) {
    next unless defined $self->{v}{$sect};
    print $ors if $notfirst;
    $notfirst = 1;
    if ((ref($self->{sCMT}{$sect}) eq 'ARRAY') &&
	(@cmts = @{$self->{sCMT}{$sect}})) {
      foreach (@cmts) {
	print "$_$ors";
      }
    }
    print "[$sect]$ors";
    next unless ref $self->{v}{$sect} eq 'HASH';

    foreach $parm (@{$self->{parms}{$sect}}) {
      if ((ref($self->{pCMT}{$sect}{$parm}) eq 'ARRAY') &&
	  (@cmts = @{$self->{pCMT}{$sect}{$parm}})) {
	foreach (@cmts) {
	  print "$_$ors";
	}
      }

      my $val = $self->{v}{$sect}{$parm};
      next if ! defined ($val);	# No parameter exists !!
      if (ref($val) eq 'ARRAY') {
        my $eotmark = $self->{EOT}{$sect}{$parm} || 'EOT';
	print "$parm= <<$eotmark$ors";
	foreach (@{$val}) {
	  print "$_$ors";
	}
	print "$eotmark$ors";
      } elsif( $val =~ /[$ors]/ ) {
        # The FETCH of a tied hash is never called in 
        # an array context, so generate a EOT multiline
        # entry if the entry looks to be multiline
        my @val = split /[$ors]/, $val;
        if( @val > 1 ) {
          my $eotmark = $self->{EOT}{$sect}{$parm} || 'EOT';
          print "$parm= <<$eotmark$ors";
          print map "$_$ors", @val;
          print "$eotmark$ors";
        } else {
           print "$parm=$val[0]$ors";
        } # end if
      } else {
        print "$parm=$val$ors";
      }
    }
  }
  return 1;
}

=head2 SetSectionComment($section, @comment)

Sets the comment for section $section to the lines contained in @comment.
Each comment line will be prepended with "#" if it doesn't already have
a comment character (ie: if $line !~ m/^\s*[#;]/)

To clear a section comment, use DeleteSectionComment ($section)

=cut

sub SetSectionComment
{
	my $self = shift;
	my $section = shift;
	my @comment = @_;

	defined($section) || return undef;
	@comment || return undef;
	
	$self->{sCMT}{$section} = [];
	# At this point it's possible to have a comment for a section that
	# doesn't exist. This comment will not get written to the INI file.
	
	foreach my $comment_line (@comment) {
		($comment_line =~ m/^\s*[#;]/) or ($comment_line = "# $comment_line");
		push @{$self->{sCMT}{$section}}, $comment_line;
	}
	return scalar @comment;
}

=head2 GetSectionComment ($section)

Returns a list of lines, being the comment attached to section $section. In 
scalar context, returns a string containing the lines of the comment separated
by newlines.

The lines are presented as-is, with whatever comment character was originally
used on that line.

=cut

sub GetSectionComment
{
	my $self = shift;
	my $section = shift;

	if (exists $self->{sCMT}{$section}) {
		return @{$self->{sCMT}{$section}};
	} else {
		return undef;
	}
}

=head2 DeleteSectionComment ($section)

Removes the comment for the specified section.

=cut

sub DeleteSectionComment
{
	my $self = shift;
	my $section = shift;
	
	delete $self->{sCMT}{$section};
}

=head2 SetParameterComment ($section, $parameter, @comment)

Sets the comment attached to a particular parameter.

Any line of @comment that does not have a comment character will be
prepended with "#".

=cut

sub SetParameterComment
{
	my $self = shift;
	my $section = shift;
	my $parameter = shift;
	my @comment = @_;

	defined($section) || return undef;
	defined($parameter) || return undef;
	@comment || return undef;
	
	if (not exists $self->{pCMT}{$section}) {
		$self->{pCMT}{$section} = {};
	}
	
	$self->{pCMT}{$section}{$parameter} = [];
	# Note that at this point, it's possible to have a comment for a parameter,
	# without that parameter actually existing in the INI file.
	
	foreach my $comment_line (@comment) {
		($comment_line =~ m/^\s*[#;]/) or ($comment_line = "# $comment_line");
		push @{$self->{pCMT}{$section}{$parameter}}, $comment_line;
	}
	return scalar @comment;
}

=head2 GetParameterComment ($section, $parameter)

Gets the comment attached to a parameter.

=cut

sub GetParameterComment
{
	my $self = shift;
	my $section = shift;
	my $parameter = shift;
	
	defined($section) || return undef;
	defined($parameter) || return undef;
	
	exists($self->{pCMT}{$section}) || return undef;
	exists($self->{pCMT}{$section}{$parameter}) || return undef;
	
	my @comment = @{$self->{pCMT}{$section}{$parameter}};
	return (wantarray)?@comment:join " ", @comment;
}

=head2 DeleteParameterComment ($section, $parameter)

Deletes the comment attached to a parameter.

=cut

sub DeleteParameterComment
{
	my $self = shift;
	my $section = shift;
	my $parameter = shift;
	
	defined($section) || return undef;
	defined($parameter) || return undef;
	
	# If the parameter doesn't exist, our goal has already been achieved
	exists($self->{pCMT}{$section}) || return 1;
	exists($self->{pCMT}{$section}{$parameter}) || return 1;
	
	delete $self->{pCMT}{$section}{$parameter};
	return 1;
}

=head2 GetParameterEOT ($section, $parameter)

Accessor method for the EOT text (in fact, style) of the specified parameter. If any text is used as an EOT mark, this will be returned. If the parameter was not recorded using HERE style multiple lines, GetParameterEOT returns undef.

=cut

sub GetParameterEOT
{
	my $self = shift;
	my $section = shift;
	my $parameter = shift;

	defined($section) || return undef;
	defined($parameter) || return undef;

	if (not exists $self->{EOT}{$section}) {
		$self->{EOT}{$section} = {};
	}

	if (not exists $self->{EOT}{$section}{$parameter}) {
		return undef;
	}
	return $self->{EOT}{$section}{$parameter};
}

=head2 SetParameterEOT ($section, $EOT)

Accessor method for the EOT text for the specified parameter. Sets the HERE style marker text to the value $EOT. Once the EOT text is set, that parameter will be saved in HERE style.

To un-set the EOT text, use DeleteParameterEOT ($section, $parameter).

=cut

sub SetParameterEOT
{
	my $self = shift;
	my $section = shift;
	my $parameter = shift;
	my $EOT = shift;

	defined($section) || return undef;
	defined($parameter) || return undef;
	defined($EOT) || return undef;

    if (not exists $self->{EOT}{$section}) {
        $self->{EOT}{$section} = {};
    }

    $self->{EOT}{$section}{$parameter} = $EOT;
}

=head2 DeleteParameterEOT ($section, $parameter)

Removes the EOT marker for the given section and parameter.
When writing a configuration file, if no EOT marker is defined 
then "EOT" is used.

=cut

sub DeleteParameterEOT
{
	my $self = shift;
	my $section = shift;
	my $parameter = shift;
	
	defined($section) || return undef;
	defined($parameter) || return undef;

	delete $self->{EOT}{$section}{$parameter};
}

=head2 DeleteSection ( $section_name )

Completely removes the entire section from the configuration.

=cut

sub DeleteSection {
	my $self = shift;
	my( $section_name ) = @_;

	# This is done, the fast way, change if delval changes!!
	delete $self->{v}{$section_name};
	delete $self->{sCMT}{$section_name};
	delete $self->{pCMT}{$section_name};
	delete $self->{EOT}{$section_name};
	delete $self->{parms}{$section_name};

	@{$self->{sects}} = grep !/\Q$section_name\E$/, @{$self->{sects}};

	if( $section_name =~ /(\S+)\s+\S+/ ) {
		my $group = $1;
		if( defined($self->{group}{$group}) ) {
			@{$self->{group}{$group}} = grep !/\Q$section_name\E/, @{$self->{group}{$group}};
		} # end if
	} # end if

	return 1;
	} # end DeleteSection


=head2 Delete

Deletes the entire configuration file in memory.

=cut

sub Delete {
	my $self = shift;

	# Again, done the fast way, if the data structure changes, change this!
	$self->{sects}  = [];
	$self->{parms}  = {};
	$self->{group}  = {};
	$self->{v}      = {};
	$self->{sCMT}   = {};
	$self->{pCMT}   = {};
	$self->{EOT}    = {};

	return 1;
} # end Delete



=head1 USAGE -- Tied Hash

=head2 tie $ini, 'Config::IniFiles', (-file=>$filename, [-option=>value ...] )

Using C<tie>, you can tie a hash to a B<Config::IniFiles> object. This creates a new
object which you can access through your hash, so you use this instead of the 
B<new> method. This actually creates a hash of hashes to access the values in 
the INI file. The options you provide through C<tie> are the same as given for 
the B<new> method, above.

Here's an example:

  use Config::IniFiles;
  
  my %ini
  tie %ini, 'Config::IniFiles', ( -file => "/path/configfile.ini" );

  print "We have $ini{Section}{Parameter}." if $ini{Section}{Parameter};

Accessing and using the hash works just like accessing a regular hash and 
many of the object methods are made available through the hash interface.

For those methods that do not coincide with the hash paradigm, you can use 
the Perl C<tied> function to get at the underlying object tied to the hash 
and call methods on that object. For example, to write the hash out to a new
ini file, you would do something like this:

  tied( %ini )->WriteConfig( "/newpath/newconfig.ini" ) ||
    die "Could not write settings to new file.";

=head2 $val = $ini{$section}{$parameter}

Returns the value of $parameter in $section. 

Because of limitations in Perl's tie implementation,
multiline values accessed through a hash will I<always> be returned 
as a single value with each line joined by the default line 
separator ($\). To break them apart you can simple do this:

  @lines = split( "$\", $ini{section}{multi_line_parameter} );

=head2 $ini{$section}{$parameter} = $value;

Sets the value of C<$parameter> in C<$section> to C<$value>. 

To set a multiline or multiv-alue parameter just assign an 
array reference to the hash entry, like this:

 $ini{$section}{$parameter} = [$value1, $value2, ...];

If the parameter did not exist in the original file, it will 
be created. However, Perl does not seem to extend autovivification 
to tied hashes. That means that if you try to say

  $ini{new_section}{new_paramters} = $val;

and the section 'new_section' does not exist, then Perl won't 
properly create it. In order to work around this you will need 
to create a hash reference in that section and then assign the
parameter value. Something like this should do nicely:

  $ini{new_section} = {};
  $ini{new_section}{new_paramters} = $val;

=head2 %hash = %{$ini{$section}}

Using the tie interface, you can copy whole sections of the 
ini file into another hash. Note that this makes a copy of 
the entire section. The new hash in no longer tied to the 
ini file, In particular, this means -default and -nocase 
settings will not apply to C<%hash>.


=head2 $ini{$section} = {}; %{$ini{$section}} = %parameters;

Through the hash interface, you have the ability to replace 
the entire section with a new set of parameters. This call
will fail, however, if the argument passed in NOT a hash 
reference. You must use both lines, as shown above so that 
Perl recognizes the section as a hash reference context 
before COPYing over the values from your C<%parameters> hash.

=head2 delete $ini{$section}{$parameter}

When tied to a hash, you can use the Perl C<delete> function
to completely remove a parameter from a section.

=head2 delete $ini{$section}

The tied interface also allows you to delete an entire 
section from the ini file using the Perl C<delete> function.

=head2 %ini = ();

If you really want to delete B<all> the items in the ini file, this 
will do it. Of course, the changes won't be written to the actual
file unless you call B<RewriteConfig> on the object tied to the hash.

=head2 Parameter names

=over 4

=item my @keys = keys %{$ini{$section}}

=item while (($k, $v) = each %{$ini{$section}}) {...}

=item if( exists %{$ini{$section}}, $parameter ) {...}

=back

When tied to a hash, you use the Perl C<keys> and C<each> 
functions to iteratively list the parameters (C<keys>) or 
parameters and their values (C<each>) in a given section.

You can also use the Perl C<exists> function to see if a 
parameter is defined in a given section.

Note that none of these will return parameter names that 
are part if the default section (if set), although accessing
an unknown parameter in the specified section will return a 
value from the default section if there is one.


=head2 Section names

=over 4

=item foreach( keys %ini ) {...}

=item while (($k, $v) = each %ini) {...}

=item if( exists %ini, $section ) {...}

=back

When tied to a hash, you use the Perl C<keys> and C<each> 
functions to iteratively list the sections in the ini file.

You can also use the Perl C<exists> function to see if a 
section is defined in the file.

=cut

############################################################
#
# TIEHASH Methods
#
# Description:
# These methods allow you to tie a hash to the 
# Config::IniFiles object. Note that, when tied, the 
# user wants to look at thinks like $ini{sec}{parm}, but the 
# TIEHASH only provides one level of hash interace, so the 
# root object gets asked for a $ini{sec}, which this 
# implements. To further tie the {parm} hash, the internal 
# class Config::IniFiles::_section, is provided, below.
#
############################################################
# ----------------------------------------------------------
# Date      Modification                              Author
# ----------------------------------------------------------
# 2000May09 Created method                                JW
# ----------------------------------------------------------
sub TIEHASH {
  my $class = shift;
  my %parms = @_;

  # Get a new object
  my $self = $class->new( %parms );

  return $self;
} # end TIEHASH


# ----------------------------------------------------------
# Date      Modification                              Author
# ----------------------------------------------------------
# 2000May09 Created method                                JW
# ----------------------------------------------------------
sub FETCH {
  my $self = shift;
  my( $key ) = @_;

  $key = lc($key) if( $self->{nocase} );

  return $self->{v}{$key};
} # end FETCH

# ----------------------------------------------------------
# Date      Modification                              Author
# ----------------------------------------------------------
# 2000Jun14 Fixed bug where wrong ref was saved           JW
# 2000Oct09 Fixed possible but in %parms with defaults    JW
# 2001Apr04 Fixed -nocase problem in storing              JW
# ----------------------------------------------------------
sub STORE {
  my $self = shift;
  my( $key, $ref ) = @_;

  return undef unless ref($ref) eq 'HASH';

  $key = lc($key) if( $self->{nocase} );

  # Create a new hash and tie it to a _sections object with the ref's data
  $self->{v}{$key} = {};

  # Store the section name in the list
  push(@{$self->{sects}}, $key) unless (grep /^\Q$key\E$/, @{$self->{sects}});

  my %parms = %{$self->{startup_settings}};
  $self->{parms}{$key} = [];
  $parms{-parms} = $self->{parms}{$key};
  $parms{-_current_value} = $ref;
  delete $parms{default};
  $parms{-default} = $self->{v}{$parms{-default}} if defined $parms{-default} && defined $self->{v}{$parms{-default}};
  tie %{$self->{v}{$key}}, 'Config::IniFiles::_section', %parms;
} # end STORE


# ----------------------------------------------------------
# Date      Modification                              Author
# ----------------------------------------------------------
# 2000May09 Created method                                JW
# 2000Dec17 Now removes comments, groups and EOTs too     JW
# 2001Arp04 Fixed -nocase problem                         JW
# ----------------------------------------------------------
sub DELETE {
  my $self = shift;
  my( $key ) = @_;

  $key = lc($key) if( $self->{nocase} );

  delete $self->{sCMT}{$key};
  delete $self->{pCMT}{$key};
  delete $self->{EOT}{$key};
  delete $self->{parms}{$key};

  if( $key =~ /(\S+)\s+\S+/ ) {
    my $group = $1;
    if( defined($self->{group}{$group}) ) {
      @{$self->{group}{$group}} = grep !/\Q$key\E/, @{$self->{group}{$group}};
    } # end if
  } # end if

  @{$self->{sects}} = grep !/^\Q$key\E$/, @{$self->{sects}};
  return delete( $self->{v}{$key} );
} # end DELETE


# ----------------------------------------------------------
# Date      Modification                              Author
# ----------------------------------------------------------
# 2000May09 Created method                                JW
# ----------------------------------------------------------
sub CLEAR {
  my $self = shift;

  foreach (keys %{$self->{v}}) {
     $self->DELETE( $_ );
  } # end foreach
 
} # end CLEAR

# ----------------------------------------------------------
# Date      Modification                              Author
# ----------------------------------------------------------
# 2000May09 Created method                                JW
# ----------------------------------------------------------
sub FIRSTKEY {
  my $self = shift;

  my $a = keys %{$self->{v}};
  return each %{$self->{v}};
} # end FIRSTKEY


# ----------------------------------------------------------
# Date      Modification                              Author
# ----------------------------------------------------------
# 2000May09 Created method                                JW
# ----------------------------------------------------------
sub NEXTKEY {
  my $self = shift;
  my( $last ) = @_;

  return each %{$self->{v}};
} # end NEXTKEY


# ----------------------------------------------------------
# Date      Modification                              Author
# ----------------------------------------------------------
# 2000May09 Created method                                JW
# 2001Apr04 Fixed -nocase bug and false true bug          JW
# ----------------------------------------------------------
sub EXISTS {
  my $self = shift;
  my( $key ) = @_;
  $key = lc($key) if( $self->{nocase} );

  return exists $self->{v}{$key};
} # end EXISTS


# ----------------------------------------------------------
# DESTROY is used by TIEHASH and the Perl garbage collector,
# ----------------------------------------------------------
# Date      Modification                              Author
# ----------------------------------------------------------
# 2000May09 Created method                                JW
# ----------------------------------------------------------
sub DESTROY {
  # my $self = shift;
} # end if





############################################################
#
# INTERNAL PACKAGE: Config::IniFiles::_section
#
# Description:
# This package is used to provide a single-level TIEHASH
# interface to the sections in the IniFile. When tied, the 
# user wants to look at thinks like $ini{sec}{parm}, but the 
# TIEHASH only provides one level of hash interace, so the 
# root object gets asked for a $ini{sec} and must return a 
# has reference that accurately covers the '{parm}' part.
#
# This package is only used when tied and is inter-woven 
# between the sections and their parameters when the TIEHASH
# method is called by Perl. It's a very simple implementation
# of a tied hash object with support for the Config::IniFiles
# -nocase and -default options.
#
############################################################
# Date        Modification                            Author
# ----------------------------------------------------------
# 2000.May.09 Created to excapsulate TIEHASH interface    JW
############################################################
package Config::IniFiles::_section;

use strict;
use Carp;
use vars qw( $VERSION );

$Config::IniFiles::_section::VERSION = 2.16;

# ----------------------------------------------------------
# Sub: Config::IniFiles::_section::TIEHASH
#
# Args: $class, %parms
#	$class	The class that this is being tied to.
#	%parms   Contains named parameters passed from the 
#           constructor plus thes parameters
#	-_current_value	holds the values to be inserted in the hash.
#	-default	should be a hash ref.
#	-parms  	reference to the $self->{parms}{$sect} of the parent
#
# Description: Builds the object that gets tied to the 
# sections name. Inserts the existing hash, defined in the 
# named parameter '-_current_value' into the tied hash.
# ----------------------------------------------------------
# Date      Modification                              Author
# ----------------------------------------------------------
# ----------------------------------------------------------
sub TIEHASH {
  my $proto = shift;
  my $class = ref($proto) || $proto;
  my %parms = @_;
  
  # Make a new object
  my $self = {};
  
  # Put the passed hash into the holder
  $self->{v} = $parms{-_current_value};
  
  # Get all other the parms, removing leading '-', if any
  # Option checking is already handled in the Config::IniFiles contructor
  foreach( keys %parms ) {
    s/^-//g;
    $self->{$_} = $parms{-$_};
  } # end foreach

  return bless( $self, $class );
} # end TIEHASH


# ----------------------------------------------------------
# Sub: Config::IniFiles::_section::FETCH
#
# Args: $key
#	$key	The name of the key whose value to get
#
# Description: Returns the value associated with $key. If the
# value is an array and the context is scalar concatenates the 
# array with the default line separator character.
# ----------------------------------------------------------
# Date      Modification                              Author
# ----------------------------------------------------------
# 2000Jun15 Fixed bugs in -default handler                JW
# 2000Dec07 Fixed another bug in -deault handler          JW
# ----------------------------------------------------------
sub FETCH {
  my $self = shift;
  my $key = shift;

  $key = lc($key) if( $self->{nocase} );

  my $val = $self->{v}{$key};
  
  unless( defined $self->{v}{$key} ) {
    $val = $self->{default}{$key} if ref($self->{default}) eq 'HASH';
  } # end unless

  if( ref($val) eq 'ARRAY' ) {
    # [ The FETCH method is never called in an array context, So 
    # this will always join. This seems like a bug in Perl to me.
    # Nonetheless maintain the wantarray in case this is fixed. -JW]

    return wantarray ? @$val : join($/, @$val);
  } else {
    return $val;
  } # end if
} # end FETCH


# ----------------------------------------------------------
# Sub: Config::IniFiles::_section::STORE
#
# Args: $key, @val
#	$key	The key under which to store the value
#	@val	The value to store, either an array or a scalar
#
# Description: Sets the value for the specified $key
# ----------------------------------------------------------
# Date      Modification                              Author
# ----------------------------------------------------------
# 2001Apr04 Fixed -nocase bug                             JW
# ----------------------------------------------------------
sub STORE {
  my $self = shift;
  my $key = shift;
  my @val = @_;

  $key = lc($key) if( $self->{nocase} );

  # Add the parameter the the parent's list if it isn't there yet
  push(@{$self->{parms}}, $key) unless (grep /^\Q$key\E$/, @{$self->{parms}});

  if (@val > 1) {
    $self->{v}{$key} = \@val;
  } else {
    $self->{v}{$key} = shift @val;
  }

  return $self->{v}{$key};
} # end STORE


# ----------------------------------------------------------
# Sub: Config::IniFiles::_section::DELETE
#
# Args: $key
#	$key	The key to remove from the hash
#
# Description: Removes the specified key from the hash
# ----------------------------------------------------------
# Date      Modification                              Author
# ----------------------------------------------------------
# 2001Apr04 Fixed -nocase bug                              JW
# ----------------------------------------------------------
sub DELETE   {
  my $self = shift;
  my $key = shift;

  $key = lc($key) if( $self->{nocase} );
#	@{$self->{parms}{$sect}} = grep !/^$parm$/, @{$self->{parms}{$sect}};
  return delete $self->{v}{$key};
} # end DELETE

# ----------------------------------------------------------
# Sub: Config::IniFiles::_section::CLEAR
#
# Args: (None)
#
# Description: Empties the entire hash
# ----------------------------------------------------------
# Date      Modification                              Author
# ----------------------------------------------------------
# ----------------------------------------------------------
sub CLEAR    {
  my $self = shift;

  foreach ( keys %{$self->{v}}) {
    $self->DELETE($_);
  } # end foreach

  return $self;
} # end CLEAR

# ----------------------------------------------------------
# Sub: Config::IniFiles::_section::EXISTS
#
# Args: $key
#	$key	The key to look for
#
# Description: Returns whether the key exists
# ----------------------------------------------------------
# Date      Modification                              Author
# ----------------------------------------------------------
# 2001Apr04 Fixed -nocase bug                             JW
# ----------------------------------------------------------
sub EXISTS   {
  my $self = shift;
  my $key = shift;
  $key = lc($key) if( $self->{nocase} );
  return exists $self->{v}{$key};
} # end EXISTS

# ----------------------------------------------------------
# Sub: Config::IniFiles::_section::FIRSTKEY
#
# Args: (None)
#
# Description: Returns the first key in the hash
# ----------------------------------------------------------
# Date      Modification                              Author
# ----------------------------------------------------------
# ----------------------------------------------------------
sub FIRSTKEY {
  my $self = shift;

  # Reset the each() iterator
  my $a = keys %{$self->{v}};

  return each %{$self->{v}};
} # end FIRST KEY

# ----------------------------------------------------------
# Sub: Config::IniFiles::_section::NEXTKEY
#
# Args: $last
#	$last	The last key accessed by the interator
#
# Description: Returns the next key in line
# ----------------------------------------------------------
# Date      Modification                              Author
# ----------------------------------------------------------
# ----------------------------------------------------------
sub NEXTKEY  {
  my $self = shift;
  my $last = shift;

  return each %{$self->{v}};
} # end NEXTKEY


# ----------------------------------------------------------
# Sub: Config::IniFiles::_section::DESTROY
#
# Args: (None)
#
# Description: Called on cleanup
# ----------------------------------------------------------
# Date      Modification                              Author
# ----------------------------------------------------------
# ----------------------------------------------------------
sub DESTROY  {
  # my $self = shift
} # end DESTROY

# Eliminate annoying warnings
if ($^W)	{
	$Config::IniFiles::VERSION = $Config::IniFiles::VERSION;
}

1;

=head1 DIAGNOSTICS

=head2 @Config::IniFiles::errors

Contains a list of errors encountered while parsing the configuration
file.  If the I<new> method returns B<undef>, check the value of this
to find out what's wrong.  This value is reset each time a config file
is read.

=head1 BUGS

=over 3

=item *

The output from [Re]WriteConfig/OutputConfig might not be as pretty as
it can be.  Comments are tied to whatever was immediately below them.
And case is not preserved for Section and Parameter names if the -nocase
option was used.

=item *

No locking is done by [Re]WriteConfig.  When writing servers, take
care that only the parent ever calls this, and consider making your
own backup.

=back

=head1 Data Structure

Note that this is only a reference for the package maintainers - one of the
upcoming revisions to this package will include a total clean up of the
data structure.

  $iniconf->{cf} = "config_file_name"
          ->{startup_settings} = \%orginal_object_parameters
          ->{firstload} = 0
          ->{nocase} = 0
          ->{reloadwarn} = 0
          ->{sects} = \@sections
          ->{sCMT}{$section} = \@comment_lines
          ->{group}{$group} = \@group_members
          ->{parms}{$section} = \@section_parms
          ->{EOT}{$sect}{$parm} = "end of text string"
          ->{pCMT}{$section}{$parm} = \@comment_lines
          ->{v}{$section}{$parm} = $value   OR  \@values

=head1 AUTHOR and ACKNOWLEDGEMENTS

The original code was written by Scott Hutton.
It has since been taken over by Rich Bowen,
with many contributions from various other people.

In particular, special thanks go to (in roughly chronological order):

Bernie Cosell, Alan Young, Alex Satrapa, Mike Blazer, Wilbert van de Pieterman,
Steve Campbell, Robert Konigsberg, Scott Dellinger, R. Bernstein,
Jeremy Wadsack, Daniel Winkelmann, Pires Claudio,  and Adrian Phillips.

Geez, that's a lot of people. And apologies to the folks I missed.

If you want someone to bug about this, that would be:

	Rich Bowen <rbowen at rcbowen dot com>

If you want more information, or want to participate, go to:

	http://sourceforge.net/projects/config-inifiles/

Please send bug reports to config-inifiles-bugs@lists.sourceforge.net

Development discussion occurs on the mailing list
config-inifiles-dev@lists.sourceforge.net, which you can subscribe
to by going to the project web site (link above).

This program is free software; you can redistribute it and/or 
modify it under the same terms as Perl itself.

=head1 Change log

     $Log: not supported by cvs2svn $
     Revision 1.2  2001/08/01 16:46:54  kboomsli
     Removed CTRL-M characters as from IniFiles.pm.  Damn windows programmers!

     Revision 1.1  2001/07/31 18:12:38  kboomsli
     Source of 2.19 from CPAN.

     Revision 2.19  2001/04/04 23:33:40  wadg
     Fixed case sensitivity bug

     Revision 2.18  2001/03/30 04:41:08  rbowen
     Small documentation change in IniFiles.pm - pod2* was choking on misplaces
     =item tags. And I regenerated the README
     The main reason for this release is that the MANIFEST in the 2.17 version was
     missing one of the new test suite files, and that is included in this
     re-release.

     Revision 2.17  2001/03/21 21:05:12  wadg
     Documentation edits

     Revision 2.16  2001/03/21 19:59:09 wadg
     410327 -default not in original; 233255 substring parameters

     Revision 2.15  2001/01/30 11:46:48  rbowen
     Very minor documentation bug fixed.

     Revision 2.14  2001/01/08 18:02:32  wadg
     [Bug #127325] Fixed proken import; changelog; moved

     Revision 2.13  2000/12/18 07:14:41  wadg
     [Bugs# 122441,122437] Alien EOLs and OO delete method

     Revision 2.12  2000/12/18 04:59:37  wadg
     [Bug #125524] Writing multiline of 2 with tied hash

     Revision 2.11  2000/12/16 12:53:13  grail
     [BUG #122455] Problem with File Permissions

     Revision 2.10  2000/12/13 17:40:18  rbowen
     Updated version number so that CPAN will stop being angry with us.

     Revision 1.18  2000/12/08 00:45:35  grail
     Change as requested by Jeremy Wadsack, for Bug 123146

     Revision 1.17  2000/12/07 15:32:36  grail
     Further patch to duplicate sections bug, and replacement of repeated values handling code.

     Revision 1.14  2000/11/29 11:26:03  grail
     Updates for task 22401 (no more reloadsig) and 22402 (Group and GroupMember doco)

     Revision 1.13  2000/11/28 12:41:42  grail
     Added test for being able to add sections with wierd names like section|version2

     Revision 1.11  2000/11/24 21:20:11  rbowen
     Resolved SourceForge bug #122445 - a parameter should be split from its value on the first = sign encountered, not on the last one. Added test suite to test this, and put test case in test.ini

     Revision 1.10  2000/11/24 20:40:58  rbowen
     Updated MANIFEST to have file list of new files in t/
     Updated IniFiles.pm to have mention of sourceforge addresses, rather than rcbowen.com addresses
     Regenerated README from IniFiles.pm

     Revision 1.9  2000/11/23 05:08:08  grail
     Fixed documentation for bug 122443 - Check that INI files can be created from scratch.

     Revision 1.1.1.1  2000/11/10 03:04:01  rbowen
     Initial checkin of the Config::IniFiles source to SourceForge

     Revision 1.8  2000/10/17 01:52:55  rbowen
     Patch from Jeremy. Fixed "defined" warnings.

     Revision 1.7  2000/09/21 11:19:17  rbowen
     Mostly documentation changes. I moved the change log into the POD rather
     than having it in a separate Changes file. This allows people to see the
     changes in the Readme before they download the module. Now I just
     need to make sure I remember to regenerate the Readme every time I do
     a commit.


     1.6 September 19, 2000 by JW, AS
     * Applied several patches submitted to me by Jeremy and Alex.
     * Changed version number to the CVS version number, so that I won't
     have to think about changing it ever again. Big version change
     should not be taken as a huge leap forward.

     0.12 September 13, 2000 by JW/WADG
     * Added documentation to clarify autovivification issues when 
     creating new sections
     * Fixed version number (Oops!)

     0.11 September 13, 2000 by JW/WADG
     * Applied patch to Group and GroupMembers functions to return empty
     list when no groups are present (submitted by John Bass, Sep 13)

     0.10 September 13, 2000 by JW/WADG
     * Fixed reference in POD to ReWriteFile. changes to RewriteConfig
     * Applied patch for failed open bug submitted by Mordechai T. Abzug Aug 18
     * Doc'd behavior of failed open
     * Removed planned SIG testing from test.pl as SIGs have been removed
     * Applied patch from Thibault Deflers to fix bug in parameter list
     when a parameter value is undef

     0.09
     Hey! Where's the change log for 0.09?

     0.08
     2000-07-30  Adrian Phillips  <adrianp@powertech.no>
 
     * test.pl: Fixed some tests which use $\, and made those that try
     to check a non existant val check against ! defined.

     * IniFiles.pm: hopefully fixed use of $\ when this is unset
     (problems found when running tests with -w).  Similar problem with
     $/ which can be undefined and trying to return a val which does
     not exist. Modified val docs section to indicate a undef return
     when this occurs.

     0.07
     Looks like we missed a change log for 0.07. Bummer.

     0.06 Sun Jun 25, 2000 by Daniel Winkelmann
     * Patch for uninitialized value bug in newval and setval
     
     0.05 Sun Jun 18, 2000 by RBOW
     * Added something to shut up -w on VERSIONS
     * Removed unused variables

     0.04 Thu Jun 15 - Fri Jun 16, 2000 by JW/WADG
     * Added support for -import option on ->new
     * Added support for tying a hash
     * Edited POD for grammer, clarity and updates
     * Updated test.pl file
     * Fixed bug in multiline/single line output
     * Fixed bug in default handling with tie interface
     * Added bugs to test.pl for regression
     * Fixed bug in {group} vs. {groups} property (first is valid)
     * Fixed return value for empty {sects} or {parms}{$sect} in
     Sections and Parameters methods

     0.03 Thu Jun 15, 2000 by RBOW
     * Modifications to permit 'use strict', and to get 'make test' working
     again.

     0.02 Tue Jun 13, 2000 by RBOW
     * Fixed bug reported by Bernie Cosell - Sections, Parameters, 
     and GroupMembers return undef if there are no sections,
     parameters, or group members. These functions now return
     () if the particular value is undefined.
     * Added some contributed documentation, from Alex Satrapa, explaining
     how the internal data structure works. 
     * Set up a project on SourceForge. (Not a change, but worth
     noting).
     * Added Groups method to return a list of section groups.

     0.01  Mon Jun 12, 2000 by RBOW
     Some general code cleanup, in preparation for changes to
     come. Put up Majordomo mailing list and sent invitation to
     various people to join it.

=cut
