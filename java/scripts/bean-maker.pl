#!/usr/bin/perl -w
use strict;
use Getopt::Long;

my $usage = "Usage: $0 [ --interface ] [ --fields ] type field [ type field ] ...\n";
my %opts;
GetOptions(\%opts, "interface", "fields")
  or die $usage;
my @params = @ARGV;
die $usage if @params < 2 or (@params % 2) == 1;

my @copy_params = @params;

if ($opts{fields}) {
  while (@params) {
    my ($type, $name) = splice @params, 0, 2, ();
    my $ucfirst_name = ucfirst $name;

    print <<EOS;
    private $type $name;
EOS
  }
}

@params = @copy_params;
while (@params) {
  my ($type, $name) = splice @params, 0, 2, ();
  my $ucfirst_name = ucfirst $name;

  if ($opts{interface}) {
    print <<EOS;
    /**
     * Getter for $name
     * \@return $type to get
    */
    $type get$ucfirst_name();

    /**
     * Setter for $name
     * \@param ${name}In to set
    */
    void set$ucfirst_name($type ${name}In);

EOS
  }
  else {
      print <<EOS;
    /**
     * Getter for $name
     * \@return $type to get
    */
    public $type get$ucfirst_name() {
        return this.$name;
    }

    /**
     * Setter for $name
     * \@param ${name}In to set
    */
    public void set$ucfirst_name($type ${name}In) {
        this.$name = ${name}In;
    }

EOS
  }
}
