# Mail::Alias.pm
#
# Version 1.12 		Date: 21 October 2000 
#
# Copyright (c) 2000 Tom Zeltwanger <perlename.com>. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

#  The format(), expand(), read(), and write() methods are Copyright by
#  Graham Barr, and modified by T. Zeltwanger
#

# PERLDOC documentation is found at the end of this file



##################################
package Mail::Alias;             #
##################################

use Carp;
use vars qw($VERSION);

$VERSION = do { my @r=(q$Revision: 1.1 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r};
sub Version { $VERSION }


# Global variable initialization
	my $alias_error = "";								# String used for returning error messages
	my $aliases_file_default  = "/etc/mail/aliases";	# The default aliases file name	
	my $max_alias_length = "40";						# The max number of characters in aliases
	my $alias_nochar = "@[]";							# Characters not allowed in aliases


#-------------#
# new() method#
#-------------#

sub new {

	my ($class, $object, $filename);
	$class = shift;								# Get the class name

	$filename = $aliases_file_default;			# Use the default filenname
	if (defined($_[0])) {						# Unless a new name was passed as 1st argument
		$filename = $_[0];
	}
	
	$object = 	{	_filename => $filename,
				_errormsg => "no error reported",	
				_usemem => "0",
				_usefile=> "1"
			};
	
	my $self = bless ($object, $class);		
		
	$self->_init($filename);					# Execute the _init method for the calling class 

		
	return $object;

} 


#----------#
# _init()  #
#----------#
sub _init {
 my $self = shift;
 $self->usefile;		# If Alias object, default to file access
				
}



#----------#
# format() #
#----------#
sub format {
 my $me = shift;
 my $fmt = shift;
 my $pkg = "Mail::Alias::" . $fmt;

 croak "Unknown format '$fmt'"
  unless defined @{$pkg . "::ISA"};

 bless $me, $pkg;
}


#----------#
# usemem() # 
#----------#

sub usemem {
 my $self = shift;
 $self->{_usemem} = "1";
 $self->{_usefile} = "0";
 return;
}


#----------#
# usefile()# 
#----------#

sub usefile {
 my $self = shift;
 $self->{_usefile} = "1";
 $self->{_usemem} = "0";
 return;
}



#----------#
# exists() # 
#----------#
sub exists {
	my ($self, $alias) = @_;

	
	if ($self->{_usemem}) {	
 		return defined $self->{$alias};	

	}
	else {						
						
	my ($self, $alias) = @_;	
	my ($text_line) = undef;	# Temp storage of the line from the alias file

	$aliases_file = $self->{_filename};

	open (ALIASES_FILE , $aliases_file)  || die "ERROR: Can't open $aliases_file\n";

	# search till alias is found or EOF
	while (<ALIASES_FILE>)  {
		if (/^$alias:/i)  {
			$text_line = $_;
			chomp($text_line);
			close ALIASES_FILE;
 			return $text_line;
		} 

	} 

	# If you got here, the EOF was hit - returns undefined
	$self->{_errormsg} = "ERROR: There is no alias $alias in $aliases_file";
	close ALIASES_FILE;
	return undef;	

	} 
} 


#----------#
# expand() #
#----------#
sub expand {
 my $me = shift;
 my @result = ();
 my %done = ();
 my $alias;
 my @todo = @_;

 while($alias = shift(@todo)) {
  next if(defined $done{$alias});
  $done{$alias} = 1;
  if(defined $me->{$alias}) {			
   push(@todo,@{$me->{$alias}});
  }
  else {
   push(@result,$alias);
  }
 }
 wantarray ? @result : \@result;	
}



#---------------------------------#
# Alias::append() Method          #
#	Version 1.0		8/19/00   #
#---------------------------------#

sub append {

	my $return_string;
	my ($self, $alias, $address_string) = @_;

	# Die if no alias was passed
	unless ($alias) {
		die "ERROR: Alias::append requires an Alias argument\n";
	}
	
	$aliases_file = $self->{_filename};
	
	if ($self->exists($alias)) {
		$self->{_errormsg} = "ERROR: $alias is already in the file $aliases_file\n";
		undef ($return_string);
	}
	
	else {

	open (ALIASES_FILE ,">>$aliases_file")  || die "ERROR: Can't open $alias_file\n";
	print ALIASES_FILE "$alias: $address_string\n";
	close ALIASES_FILE;
	$return_string = "1";	# Successfully added the alias

	} # ELSE

} 


#------------------------------#
# Alias::delete() Method       #
#	Version 1.0		8/13/00#
#------------------------------#

sub delete {
	
	my ($self, @alias_list) = @_;			
	$filename = $self->{_filename};			
	my $deleted = undef;					
										

	
	
		my $working_file = ($filename . ".tmp");
		rename ("$filename", "$working_file");		
	
	
	open (NEW_FILE ,">$filename")
		|| die "ERROR: Can't open $filename\n";
	
	
	open (EXISTING_FILE , "$working_file")
		|| die "ERROR: Can't open $working_file\n";

	
	

	while (defined ($textline = <EXISTING_FILE>)) {		
		chomp ($textline);
		
		
		if (($textline =~ /^\s*$/) || ($textline =~ /^#/)) {
			print NEW_FILE "$textline\n";
		}

		else {				
			
			
			
			if (!alias_check ($textline , \@alias_list)) {
				print NEW_FILE "$textline\n";
			} 
			
			else {		
				print "DELETING:  $textline\n";
				$deleted = "1";
			}
			
			
		} 
		
	} 

	# Close the files 
	close EXISTING_FILE;
	close NEW_FILE;
	return $deleted;
	
} # end delete


#------------------------------#
# Alias::update() Method       #
#	Version 1.0		8/13/00#
#------------------------------#

sub update {

	my ($self, $alias, $address_string) = @_;
	my ($found_it, $alias_line);

	undef $found_it;						

	# Form the alias line from the passed arguments
	if ($address_string) {					# If there is a second argument passed
		$alias_line = "$alias" . ": " . " $address_string";
	}
	else {
		$alias_line = $alias;					# The whole alias line is in $alias
		$alias_line =~ /^(\S+)\s*:\s*(\S*)$/;	# Extract the alias from the alias_line
		$alias = $1;					
	}
	
	
	$filename = $self->{_filename};				# Get the name of the aliases_file to be updated

	
	
	my $working_file = ($filename . ".tmp");
	rename ("$filename", "$working_file");		
	
	
	open (NEW_FILE ,">$filename")
		|| die "ERROR: Can't open $filename\n";
	
	
	open (EXISTING_FILE , "$working_file")
		|| die "ERROR: Can't open $working_file\n";

	
	
	while (defined ($textline = <EXISTING_FILE>)) {		# For every line
	
		# If line is blank or comment, just write it out
		chomp ($textline);
		
		if (($textline =~ /^\s+$/) || ($textline =~ /^#/)) {
			print NEW_FILE "$textline\n";
		}

		else {				# Process alias lines here
			
			
			if ($textline =~ /^$alias:/i) {
				print NEW_FILE "$alias_line\n";
				$found_it = "1";
			} 
			
			else {	
				
				print NEW_FILE "$textline\n";						
			
			} 


		} 
		
	} 

	
	close EXISTING_FILE;
	close NEW_FILE;

	return $found_it;

} # end update


#-------------------#
# valid_alias Method#
#-------------------#
# valid_alias performs validation of the alias passed as an argument.
# Return 1 if success and UNDEF if the test fails

sub valid_alias {

	my ($self, $alias) = @_;			# Get the alias
	my $return_string = 1;				# Set return for success

	if (($alias =~ /[$alias_nochar]/) || (length($alias) > $max_alias_length)) 
		{ undef($return_string)
		}
	
	return $return_string;

} 


#------------------#
# alias_file Method#
#------------------#
# alias_file returns the complete path to the alias file that is being operated upon
# by the Mail::Alias methods.
# If a filename is passed as an argument, it is set to be the new filename for
# all future operations. The file must exist or nothing is done. 

sub alias_file {

	my ($self, $newname) = @_;			# Get the new name if one was passed

	# If an argument was passed, make it the new $aliases_file value and return
	if ($newname) {

		
		if (-e $newname) {
			$self->{_filename} = $newname;
			return "$newname";		
		}

		else {
		
			$self->{_errormsg} = "ERROR: $newname does not exist\n";
			return undef;			
		}
	
	}
	

  # If no argument, just return the current working aliases file pathname
	else {		

		return $self->{_filename};	
	}
	
} 


#------------#
# error_check#
#------------#
# Returns the last error message in a text string
# This method can be used after any method failed (i.e. returned UNDEF)

sub error_check {

	my $self = shift;
	my $return_string;
	
	
	$return_string = $self->{_errormsg};
	
	
	$self->{_errormsg} = "No error found";
	
	return $return_string;	

} 


#------------#
# alias_check#
#------------#
# Check a line of text to see if it begins with any alias in the alias_list
# Return the matching alias if found or UNDEF if no match exists
# Alias matching is not case sensitive

sub alias_check {
	# Define variables and get arguments
	my ($list_length, $list_index, $text);
	$text = $_[0];			# 1st argument is the line of text
	$list = $_[1];			# 2nd argument is an array reference

	# Extract the first non-whitespace from the text_line
	
	$text =~ /^\s*(\S+)\s+/;
	$text = $1;				
	$text =~ s/://;			# Get rid of trailing :

	# Search for the string
	$list_length = @$list;

	for ($list_index = 0; $list_index < $list_length; $list_index++) {

		# Check each alias for a match with the beginning of the text line
		# to get a match, the alias must be:
		#	the first non-whitespace on the line
		#	followed by whitespace or a : character
		if ($text =~ /^\s*$$list[$list_index]:?\s*$/i) {
			return $$list[$list_index];	# Return the matching string from the list
		} 
		
	} 
	
	
	return undef;
	
} 


#############################################################
package Mail::Alias::Sendmail;                              #
#	Defines the Sendmail alias class read() and write() #
#############################################################

use Carp;
#use Mail::Address;

use vars qw(@ISA);

@ISA = qw(Mail::Alias);


#----------#
# _init()  #
#----------#
sub _init {
 my ($self, $filename) = @_;

 $self->read($filename) if($filename);				
 $self->usemem;				# If Alias::Sendmail object, default to memory access

}


#---------#
# write() #
#---------#

sub write {
 my $me = shift;
 my $file = shift;
 my $alias;
 my $fd;
 local *ALIAS;

 if(ref($file)) {
  $fd = $file;
 }
 else {
  open(ALIAS,$file) || croak "Cannot open $file: $!\n";
  $fd = \*ALIAS;
 }

 foreach $alias (sort keys %$me) {
   unless ($alias =~ /^_/) {	
	my $ln = $alias . ": " . join(", ",@{$me->{$alias}});
	$ln =~ s/(.{55,78},)/$1\n\t/g;
	print $fd $ln,"\n";
   }
 }

 close(ALIAS) if($fd == \*ALIAS);
}

#-----------------------------------------------------------#
# _include_file		Local sub for expanding :include: files #
#-----------------------------------------------------------#
sub _include_file {
 my $file = shift;
 local *INC;
 my @ln;
 local $_;
 open(INC,$file) or carp "Cannot open file '$file'" and return "";
 @ln = grep(/^[^#]/,<INC>);
 close(INC);
 chomp(@ln);
 join(",",@ln);
}

#--------#
# read() #
#--------#
sub read {
 my $me = shift;
 my $file = shift;

 local *ALIAS;
 local $_;
 open(ALIAS,$file) || croak "Cannot open $file: $!\n";

 my $group = undef;
 my $line = undef;

 while(<ALIAS>) {
  chomp;
  if(defined $line && /^\s/) {		
   $line .= $_;
  }
  else {
   if(defined $line) {
    if($line =~ s/^([^:]+)://) {	
     my @resp;
     $group = $1;
     $group =~ s/(\A\s+|\s+\Z)//g;	
     $line =~ s/\"?:include:(\S+)\"?/_include_file($1)/eg;	
     $line =~ s/(\A[\s,]+|[\s,]+\Z)//g;

     while(length($line)) {
      $line =~ s/\A([^\"][^ \t,]+|\"[^\"]+\")(\s*,\s*)*//;
      push(@resp,$1);
     }

     $me->{$group} = \@resp;
    }
    undef $line;
   }
   next if (/^#/ || /^\s*$/);		
   $line = $_;
  }
 }
 close(ALIAS);
}

###############################
package Mail::Alias::Ucbmail; #
###############################

use vars qw(@ISA);

@ISA = qw(Mail::Alias::Binmail);

###############################
package Mail::Alias::Binmail; #
###############################

use Carp;
#use Mail::Address;

use vars qw(@ISA);

@ISA = qw(Mail::Alias);

#----------#
# _init()  #
#----------#
sub _init {
 my ($self, $filename) = @_;

 $self->read($filename) if($filename);				
 $self->usemem;				# If Alias::Binmail object, default to memory access			
}


#--------#
# read() #
#--------#
sub read {
 my $me = shift;
 my $file = shift;

 local *ALIAS;
 local $_;
 open(ALIAS,$file) || croak "Cannot open $file: $!\n";

 while(<ALIAS>) {
  next unless(/^\s*(alias|group)\s+(\S+)\s+(.*)/);
  my($group,$who) = ($2,$3);

  $who =~ s/(\A[\s,]+|[\s,]+\Z)//g;

  my @resp = ();

  while(length($who)) {
#   $who =~ s/\A([^\"]\S*|\"[^\"]*\")\s*//;
#   my $ln = $1;
#   $ln =~ s/\A\s*\"|\"\s*\Z//g;     
 $who =~ s/\A\s*(\"?)([^\"]*)\1\s*//;
   push(@resp,$2);
#   push(@resp,$ln);
  }
  $me->{$group} = [ @resp ];
 }
 close(ALIAS);
}

#---------#
# write() #
#---------#
sub write {
 my $me = shift;
 my $file = shift;
 my $alias;
 my $fd;
 local *ALIAS;

 if(ref($file)) {
  $fd = $file;
 }
 else {
  open(ALIAS,$file) || croak "Cannot open $file: $!\n";
  $fd = \*ALIAS;
 }

 foreach $alias (sort keys %$me) {
  my @a = @{$me->{$alias}};
  map { $_ = '"' . $_ . '"' if /\s/ } @a;
	unless ($alias =~ /^_/) {
	  print $fd "alias $alias ",join(" ",@a),"\n";
	}
 }

 close(ALIAS) if($fd == \*ALIAS);
}


#############################
# Documentation starts here #
#############################

=head1 NAME

Mail::Alias - Maniulates mail alias files of various formats. Works on files directly or loads files into memory and works on the buffer.

=head1 SYNOPSIS

    use Mail::Alias;

=head1 DESCRIPTION

C<Mail::Alias> can read various formats of mail alias. Once an object has been created it can be used to expand aliases and output in another format.


=head1 CONSTRUCTOR

=over 4

=item B<new ()>
Alias objects can be created in two ways;
 With a format specified- Mail::Alias::Sendmail->new([filename])
 Without a format specified- Mail::Alias->new([filename]}. Format defaults to
  SENDMAIL
In either case, the filename is optional and, if supplied, it will be read in
 when the object is created. Available formats are Sendmail, Ucbmail, and
  Binmail.

=back

=head1 METHODS

=over 4

=item B<read ()>
Reads an alias file of the specified format into memory. Comments or blank
 lines are lost upon reading. Due to storage in a hash, ordering of the alias
 lines is also lost.

=item B<write ()>
The current set of aliases contained in the object memory are written to a
 file using the current format.
If a filehandle is passed, data is written to the already opened file. If a
 filename is passed, it is opened and the memory is written to the file.
 Note: if passing a filename, include the mode (i.e. to write to a file named
 aliases pass >aliases). Before writing, the alias lines are sorted
 alphabetically.

=item B<format ()>
Set the current alias file format. 

=item B<exists ()>
Indicates the presence of the passed alias within the object (if using memory
 access), or the current aliases file (if using direct file access). For
 direct file access, the return value is the address string for the alias.
 
=item B<expand ()>
Expands the passed alias into a list of addresses. Expansion properly handles
 :include: files, recursion, and continuation lines.Only works when memory
  access is being used. If the alias is not found in the object, you get back
  what you sent.

=item B<alias_file ()>
Sets or gets the name of the current alias filename for direct access.

=item B<append () *-Sendmail only-*>
Adds an alias to an existing Sendmail alias file. The alias and addresses can
 be passed as two separate arguments (alias, addresses) or as a single line of
 text (alias: addresses)

=item B<delete () *-Sendmail only-*>
Deletes the entry for an alias from the current alias file.

=item B<update () *-Sendmail only-*>
Replaces the address string entry for an alias in the current alias file.

=item B<usemem ()>
Sets the working mode to use memory (indirect access). Use read(), write() and
 format() methods.

=item B<usefile ()>
Sets the working mode to use files (direct access). Use append() and delete()
 methods.


=back

=head1 AUTHOR

Tom Zeltwanger <perl@ename.com> (CPAN author ID: ZELT)

=head1 COPYRIGHT

Copyright (c) 2000 Tom Zeltwanger. All rights reserved. This program is free
software; you can redistribute it and/or modify it under the same terms
as Perl itself.

Versions up to 1.06, Copyright (c) 1995-1997 Graham Barr. All rights reserved.
This program is free software; you can distribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
