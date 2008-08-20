package Module;
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
#
use strict;

sub load {
   my ($moduleName, $libDir, $fallbackPackage) = @_;

   unless ($moduleName) {
      return ("Module::load(): No module name provided");
   }

   if ((! ref($libDir)) and $libDir ) {
        # Force scalar into array ref
        $libDir = [$libDir];
   } elsif (! ref($libDir)) {
        $libDir = [];
   }
   if ((! ref($fallbackPackage)) and $fallbackPackage ) {
        # Force scalar into array ref
        $fallbackPackage = [$fallbackPackage];
   } elsif (! ref($fallbackPackage)) {
        $fallbackPackage = [];
   }

   my @errors = ();
   my $ok = 0;
   if (! (isLoaded($moduleName) && $moduleName->can('initialize'))) {
      # That "can" above is required for Object's AUTOLOAD to work. Not sure why...

      my $oldHandler = $SIG{__DIE__};
      $SIG{__DIE__} = 'DEFAULT';

      my $cmd = "require $moduleName;";
      push(@INC, @$libDir) if ($libDir);

      if (! eval($cmd)) {
	 push(@errors, $@);
      } else {
	$ok=1;
      }
      if ((scalar(@errors) > 0) && scalar(@$fallbackPackage)) {
         my $package;
         foreach $package (@$fallbackPackage) {
	    if (! eval("require ${package}::$moduleName;")) {
	       push(@errors, $@);
	    } else {
               $ok=1;
	       last;
            }
         }
      } 

      my $junk;
      if ($libDir) {
      	foreach $junk (@$libDir) {
      		pop(@INC);
	}
      }

      $SIG{__DIE__} = $oldHandler;
   } else { # it's already loaded
      $ok = 1;
   }
   return wantarray ? ($ok,\@errors) : $ok;
}

sub isLoaded {
   my $pkg = shift();
   unless ($pkg =~ /^main::.*::$/) {
      $pkg = "main$pkg"       if      $pkg =~ /^::/;
      $pkg = "main::$pkg"     unless  $pkg =~ /^main::/;
      $pkg .= '::'            unless  $pkg =~ /::$/;
   }
   my($stem, $leaf) = $pkg =~ m/(.*::)(\w+::)$/;
   if ($stem) {
      no strict 'refs';
      my $stem_symtab = *{$stem}{HASH};
      return (defined $stem_symtab and exists $stem_symtab->{$leaf})
   }
   return undef;
}

1;

__END__

=head1 NAME

Module - safely loads a Perl module

=head1 SYNOPSIS

    use NOCpulse::Module;
    ...
    my $error = Module::load($moduleName, $libDir);
    if ($error) {
        die "Cannot load $moduleName from $libDir: $error\n";
    }

    my @errors = Module::load($moduleName, $libDir, 'NOCpulse::PlugFrame');
    if (@errors) {
        die "Cannot load $moduleName from $libDir: ".join(' ', @errors)."\n";
    }

=head1 DESCRIPTION

Provides methods to test if a Perl module is loaded, and to attempt
to load one without blowing up if it cannot be found.

=head1 MODULE METHODS

=over

=item load($moduleName [, $libDir [, $fallbackPackage])

First checks if the module has been loaded and returns undef if
so. Otherwise adds $libDir to the library path and tries to "require"
the module ($libDir can be either a scalar or a ref to an array of scalars).
If that fails, and $fallbackPackage is provided (which, again, can be
either a scalar or an ref to an array of scalars), remembers
the first error and tries to "require" the module in the fallback
package. If that also fails, that error and the previous are
returned. If there is no fallback package and there is an error,
returns that error.

=item isloaded($moduleName)

Returns defined if the module named $moduleName is known to Perl,
undef otherwise.

=cut

=back
