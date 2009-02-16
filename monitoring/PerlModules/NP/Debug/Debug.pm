package NOCpulse::Debug;
#
# Copyright (c) 2008 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
#
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation.

use vars qw($VERSION);
$VERSION = 1.23;


use strict;
use IO::Handle;
use Data::Dumper;

#####################################################
# Accessor methods (stolen from LWP::MemberMixin)
#####################################################
sub _streams     { shift->_elem('_streams', @_); }
sub _maxlevel    { shift->_elem('_maxlevel', @_); }
#####################################################



#########
sub new {
#########
    my $class = shift;
    my $self  = {};
    bless $self, $class;

    # Set up empty streams array
    $self->_streams([]);

    # Set up null max level
    $self->_maxlevel(0);

    return $self;
}



###############
sub addstream {
###############
    my ($self, %paramHash) = @_;

    # Add a stream to the debug object

    # Pick up input params
    my $level      = $paramHash{LEVEL}      || 0;
    my $context    = $paramHash{CONTEXT}    || 'literal';
    my $linenum    = $paramHash{LINENUM}    || 0;
    my $append     = $paramHash{APPEND}     || 0;
    my $buffering  = $paramHash{BUFFERING}  || 0;
    my $timestamps = defined($paramHash{TIMESTAMPS}) ? $paramHash{TIMESTAMPS} : 1;
    my $fh         = $paramHash{FILE};
    my $fhRef      = ref $fh;
    my $filename;

    # Do we append output to existing filehandle?
    if ($append) { $append = '>>' }
    else         { $append = '>'  }

    # What kind of file handling do we do?
    my $newfh = new IO::Handle;

    if (! defined($fh)) {

        # No fh passed, so output defaults to STDOUT
        $newfh->fdopen(\*STDOUT, 'w');
	$newfh->autoflush(1);

    } elsif ($fhRef eq 'GLOB') {

        # fh is an opened filehandle
        $newfh->fdopen($fh, 'w');

    } else {

        # Assume fh is a filename
	($filename) = $fh =~ /(.*)/;
	($append) = $append =~ /(.*)/;
        unless (open($newfh, "$append $filename")) {
	  $@ = "Can't write to file '$filename': $!";
	  return undef;
	}

    }

    $self->_maxlevel($level) if ($level > $self->_maxlevel);

    # Create a new stream object based on context type
    my $class = "NOCpulse::Debug::Stream::$context";
    my $stream;
    eval {
        $stream = $class->new($newfh);
    };

    if (defined $stream) {

	# Set parameters
        $stream->level($level);
        $stream->linenumbers($linenum);
        $stream->buffering($buffering);
        $stream->timestamps($timestamps);
        $stream->active(1);

        if ($buffering) {
            $stream->contents([]);
        }

	# Save some values for file rotation
	$stream->filename($filename) if (defined($filename));
	$stream->append($append);

	# Add the stream
        push (@{$self->_streams}, $stream);

    } else {

        $@ = "Undefined debug output stream type '$context'";
	return undef;

    }

    return $stream;
}



###############
sub delstream {
###############
    my ($self, $delstream) = @_;

    # Delete a stream from the debug object
    my($stream, @keepstreams, $deleted);

    foreach $stream ($self->streams) {
      if ($stream eq $delstream) {
        $deleted = 1;
      } else {
        push(@keepstreams, $stream);
      }
    }

    $self->_streams(\@keepstreams);

    return $deleted;

}


#############
sub streams {
#############
  my $self = shift;

  return @{$self->_streams};

}



#########################
# Delegation functions
#


###########
sub flush {
###########
    my ($self) = @_;

    my $stream;
    foreach $stream ($self->streams) {
        $stream->flush;
    }
}


###########
sub clear_contents {
###########
    my ($self) = @_;

    my $stream;
    foreach $stream ($self->streams) {
        $stream->clear_contents;
    }
}


###########
sub close {
###########
    my ($self) = @_;

    my $stream;
    foreach $stream ($self->streams) {
        $stream->close;
    }
}


############
sub dprint {
############
    my ($self, $level, @msg) = @_;

    foreach my $stream ($self->streams) {
        $stream->dprint($level, @msg) if ($stream->active());
    }
}


############
sub print {
############
    my ($self, @msg) = @_;

    foreach my $stream ($self->streams) {
        $stream->dprint(0, @msg) if ($stream->active());
    }
}


############
sub dump {
############
    my ($self, $level, $prefix, $ref, $suffix) = @_;

    if ($self->willprint($level)) {
       my @msg = ($prefix, Dumper($ref), $suffix);
       foreach my $stream ($self->streams) {
	  $stream->dprint($level, @msg) if ($stream->active());
       }
    }
}



############
sub active {
############
    my($self, $val) = @_;
    my $stream;
    foreach $stream ($self->streams) {
        $stream->active($val);
    }
}

###########
sub level {
###########
    my($self, $level) = @_;
    $self->_maxlevel($level) if ($level > $self->_maxlevel);
    foreach my $stream ($self->streams) {
        $stream->level($level);
    }
}

###########
sub willprint {
###########
    my($self, $level) = @_;
    return $self->_maxlevel >= $level;
}

#################
sub linenumbers {
#################
    my($self, $val) = @_;
    my $stream;
    foreach $stream ($self->streams) {
        $stream->linenumbers($val);
    }
}

#############
sub postfix {
#############
    my($self, $val) = @_;
    my $stream;
    foreach $stream ($self->streams) {
        $stream->postfix($val);
    }
}

############
sub prefix {
############
    my($self, $val) = @_;
    my $stream;
    foreach $stream ($self->streams) {
        $stream->prefix($val);
    }
}

#############
sub stamper {
#############
    my($self, $val) = @_;
    my $stream;
    foreach $stream ($self->streams) {
        $stream->stamper($val);
    }
}

#############
sub suffix  {
#############
    my($self, $val) = @_;
    my $stream;
    foreach $stream ($self->streams) {
        $stream->suffix($val);
    }
}





###########
sub _elem {
###########
  # Taken from the LWP::MemberMixin module
  my($self, $elem, $val) = @_;
  my $old = $self->{$elem};
  $self->{$elem} = $val if defined $val;
  return $old;
}

1;




################################
package NOCpulse::Debug::Stream;
################################

# This is a virtual base class for building output streams

#####################################################
# Accessor methods (stolen from LWP::MemberMixin)
#####################################################
sub active      { shift->_elem('active',      @_); }
sub append      { shift->_elem('append',      @_); }
sub fh          { shift->_elem('fh',          @_); }
sub filename    { shift->_elem('filename',    @_); }
sub level       { shift->_elem('level',       @_); }
sub linenumbers { shift->_elem('linenumbers', @_); }
sub postfix     { shift->_elem('postfix',     @_); }
sub prefix      { shift->_elem('prefix',      @_); }
sub stamper     { shift->_elem('stamper',     @_); }
sub suffix      { shift->_elem('suffix',      @_); }
sub buffering   { shift->_elem('buffering',   @_); }
sub contents    { shift->_elem('contents',    @_); }
#####################################################

############
sub dprint {
############
    my ($self, $dprintLevel, @msg) = @_;

    if ($self->level() >= $dprintLevel) {
        my $msg = join '', @msg;

	# Add line numbers if required
	if ($self->linenumbers()) {
          my $linenum = (caller(1))[2];
          $msg = "$linenum: $msg" 
	}


	# Add prefix, timestamp, postfix, and suffix (if required)
	my $timestamp='';
	$timestamp  = $self->stamper->() if ($self->timestamps());

	my $prefix  = $self->prefix() ||"";
	my $postfix = $self->postfix() ||"";
	my $suffix  = $self->suffix() ||"";
	$msg = join("", $prefix, $timestamp, $postfix, $msg, $suffix);

	# Modify the message for stream-specific output
	$msg = $self->prepare($msg);

	# Print the message
        if ($self->buffering) {
            $self->contents([]) unless $self->contents;
            push(@{$self->contents}, $msg);
        } else {
            my $fh = $self->fh();
            print $fh $msg;
        }
    }
}


#############
sub suspend {
#############
    my ($self)          = @_;
    $self->active(0);
}


############
sub resume {
############
    my ($self)          = @_;
    $self->active(1);
}


###########
sub flush {
###########
    my ($self) = @_;

    if ($self->buffering) {
        my $fh = $self->fh();
        print $fh join("", @{$self->contents});
        $self->contents([]);
    }
    $self->fh->flush;
}


###########
sub clear_contents {
###########
    my ($self) = @_;
    $self->contents([]);
}


###########
sub close {
###########
    my ($self) = @_;
    $self->flush;
    $self->fh->close;
}



################
sub timestamps {
################
    my ($self, $tsfn) = @_;

    if (ref($tsfn)) {

      # Enable timestamps using the user-supplied function
      $self->{'timestamps'} = 1;
      $self->stamper($tsfn);

    } elsif ($tsfn) {

      # Enable timestamps using the existing (or default) function
      $self->{'timestamps'} = 1;
      $self->stamper(\&timestamp) unless(ref($self->stamper()));
      

    } elsif (defined($tsfn)) {

      # Disable timestamps
      $self->{'timestamps'} = undef;

    } else {
      
      # Return the current value
      return $self->{'timestamps'};

    }
}


###############
sub timestamp {
###############
  my @date = localtime();
  return sprintf("%04d-%02d-%02d %02d:%02d:%02d ", 
        $date[5]+1900, $date[4]+1, $date[3], $date[2], $date[1], $date[0]);
}



###############
sub autoflush {
###############
  my($self, $value) = @_;

  $self->buffering(0) if $value;
  $self->fh->autoflush($value);
}



############
sub rotate {
############
  my($self, $rotfile) = @_;

  # Rotate a logfile.

  # We can only rotate a named file
  my $oldname = $self->filename;
  unless(defined($oldname)) {
    $@ = "Can't rotate an unnamed file";
    return undef;
  }

  # Preserve autoflush
  my $af = $self->autoflush();

  # Rotate the file
  $self->close;
  unless (rename($oldname, $rotfile)) {
    $@ = "Can't rename $oldname => $rotfile: $!";
    return undef;
  }

  # Reopen the file
  my $append = $self->append;
  unless (open($self->fh, "$append $oldname")) {
    $@ = "Can't create file '$oldname': $!";
    return undef;
  }

  $self->fh->autoflush($af);

  return 1;

}


###########
sub _elem {
###########
  # Taken from the LWP::MemberMixin module
  my($self, $elem, $val) = @_;
  my $old = $self->{$elem};
  $self->{$elem} = $val if defined $val;
  return $old;
}

1;



##########################################
package NOCpulse::Debug::Stream::literal;
##########################################

use vars qw(@ISA);
@ISA = qw(NOCpulse::Debug::Stream);

#########
sub new {
#########

    my ($class, $fh) = @_;
    my $self  = {};
    bless $self, $class;

    $self->fh($fh);

    return $self;
}

#############
sub prepare {
#############
  my($self, $msg) = @_;
  return $msg;
}


1;



######################################
package NOCpulse::Debug::Stream::html;
######################################

use vars qw(@ISA);
@ISA = qw(NOCpulse::Debug::Stream);

#########
sub new {
#########

    my ($class, $fh) = @_;
    my $self  = {};
    bless $self, $class;

    $self->fh($fh);

    return $self;
}

#############
sub prepare {
#############

    my ($self, $msg) = @_;
    return "<pre>$msg</pre>\n";
}

1;



##############################################
package NOCpulse::Debug::Stream::html_comment;
##############################################

use vars qw(@ISA);
@ISA = qw(NOCpulse::Debug::Stream);

#########
sub new {
#########

    my ($class, $fh) = @_;
    my $self  = {};
    bless $self, $class;

    $self->fh($fh);

    return $self;
}

#############
sub prepare {
#############

    my ($self, $msg) = @_;
    return "<!--$msg-->\n";
}

1;

##############################################
package NOCpulse::Debug::Stream::stdout;
##############################################

use vars qw(@ISA);
@ISA = qw(NOCpulse::Debug::Stream);

#########
sub new {
#########
 
    my ($class, $fh) = @_;
    my $self  = {};
    bless $self, $class;

    $self->fh(\*STDOUT);

    return $self;
}

###########
sub flush {
###########
}


###########
sub close {
###########          
  close(\*STDOUT);
}

###############
sub autoflush {
###############
}

############
sub rotate {
############
}

#############
sub prepare {
#############
  my($self, $msg) = @_;
  return $msg;
}


1;

__END__

=pod

=head1 NAME

NOCpulse::Debug - custom Perl debug module

=head1 SYNOPSIS

 use NOCpulse::Debug;

 my $debug   = new NOCpulse::Debug;
 my $literal = $debug->addstream(CONTEXT => 'literal',
                                 LEVEL   => 1);

 open(LOG, "> /tmp/junklog") or die "Can't open file /tmp/junklog:$!\n";
 my $html = $debug->addstream(FILE     => \*LOG,
                              CONTEXT  => 'html',
                              LEVEL    => 2);

 my $hcomment = $debug->addstream(FILE    => '/tmp/junklog2',
                                  CONTEXT => 'html_comment',
                                  LEVEL   => 1,
                                  LINENUM => 1,
                                  APPEND  => 1);

 #- Output text to all streams with debug level <= 2
 $debug->dprint(2, "This is a level 2 debugging message");


=head1 DESCRIPTION

This module provides methods for debug output that can ultimately
be used in place of standard print statements. The two primary
advantages of this module over standard print are debug "streams"
and the implementation of multiple debug levels. Limited formatted
output is available for HTML applications.

=over

=item I<Debug Streams>

A Debug Stream is a stream of output that is connected to a file.
The file can be STDOUT, an already opened file handle, or a
filename. Although not recommended, it is possible to have 
multiple streams printing to the same file.

=item I<Debug Levels>

Debug levels allow control over the level of detail of the Debug output.

=back

=head1 CONSTRUCTOR

=over

=item C<new NOCpulse::Debug>

Creates a new Debug object.

=back

=head1 METHODS

=over

 addstream   dprint       
 flush       buffering    close
 suspend     resume       active
 prefix      postfix      suffix
 timestamps  linenumbers  level
 contents    clear_contents

=item $stream = $debug->addstream( [PARAMS] )

Create a debug output stream to a file.

Optional parameters:

I<FILE> - A filename or open filehandle.  Defaults to STDOUT.

I<LEVEL> - The minimum level for this output stream. Only 'dprint'
statements that specify a level greater than or equal to this level 
will generate output.  (Defaults to 0.  Can be adjusted at run-time 
with the 'level' method.)

I<CONTEXT> - format of text to be output. The currently supported
contexts are:

  'literal'     - unformatted text (default)
  'html'        - literal text surrounded by HTML <pre> tags
  'html_comment - literal text surrounded by HTML comment tags

I<APPEND> - When set to non-zero value, output from a debug stream will be
appended to the the specified file.  Default is 0.

(Note: This parameter is only effective when the FILE parameter is a filename.
Modes of filehandles opened outside the module are determined by the opener.)


=item $stream->dprint( LEVEL, @message )

=item $debug->dprint(  LEVEL, @message )

Print @message to an individual stream or to all active streams in a
debug object.  Output will only occur if LEVEL is less than or equal to
each stream's debug level (set with 'addstream' or 'level').


=item $stream->flush

=item $debug->flush

Flush the file buffer of a stream or all streams in a debug object.
(Useful when 'tail'ing a file to monitor output.)


=item $stream->clear_contents

=item $debug->clear_contents

Clears buffered contents of a stream or all streams in a debug object.
Only meaningful when buffering. 


=item $stream->close

=item $debug->close

Close an individual stream or all streams in a debug object.  



=item $stream->resume

=item $stream->suspend

=item $stream->active

Suspend or resume output to a particular stream, or check to see 
if a stream is active.



=item $stream->prefix($str)

=item $stream->postfix($str)

=item $stream->suffix($str)

Fixed output.  An output line is composed of:

  ${prefix}${timestamp}${postfix}${lineno}${message}${suffix}

where any of the above may be undefined or empty.  (See 'linenumbers'
below for a description of ${lineno}.)


=item $stream->level($level)

Read or change a debug level at run time.  For example, you can do:

  $SIG{'USR1'} = sub { $stream->level($stream->level() + 1);
  $SIG{'USR2'} = sub { $stream->level($stream->level() - 1);

to allow the users to dynamically change the level of output.



=item $stream->linenumbers({0|1})

Enable/disable line numbers.  If enabled, each output line will include
the line number of the dprint() statement that generated the output line.



=item $stream->timestamps( [{0|1|<function>}] )

Prepend each output line with a timestamp.  <function>, if supplied,
should be a reference to a function that returns a scalar timestamp.  
If called with a function reference, timestamps are enabled.  If called
with no arguments, timestamps are enabled with a default timestamp
function (which generates timestamps in the form 'DD-MM-YY HH24:MI:SS').
Calling 'timestamps' with a 0 or 1 suspends or resumes timestamps without
changing the timestamp function.



=item $stream->contents

Returns the buffered contents of a stream, all of the output that has
not yet been flushed.



=back


=head1 Example


  #!/usr/bin/perl

  use strict;
  use NOCpulse::Debug;

  my $verboselogfile = '/var/adm/verboselog';

  my $debug         = new NOCpulse::Debug;

  # Set up a verbose, timestamped stream to a log file
  my $verbosestream = $debug->addstream( FILE    => $verboselogfile,
					 APPEND  => 1, 
					 CONTEXT => 'literal', 
					 LEVEL   => 9);
  $verbosestream->timestamps(1);
  $verbosestream->suffix("\n");  # End each statement with a newline

  # Set up a less verbose stream with line numbers for the user
  my $stdout        = $debug->addstream( LEVEL => 1 );

  # ... stuff happens
  $debug->dprint(1, "This is an informative message\n");
  $debug->dprint(4, "This is too detailed for the screen:", @debug_info);



