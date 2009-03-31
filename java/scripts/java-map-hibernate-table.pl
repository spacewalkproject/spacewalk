#!/usr/bin/perl

# (c) 2004, Red Hat, Inc
# All rights reserved
#
# Simple util to spit out 

use lib '/var/www/lib';

package RHN::DB::Package;

use strict;
use RHN::DB;

my $tablename = $ARGV[0];
my $classname = $ARGV[1];
my $package = $ARGV[2];

if ($tablename eq "" || $classname eq "" || $package eq "") {
    my $usage =       "usage:                [table name] [classname  ] [package  ] (com.redhat.rhn.domain is prepended)\n";
    $usage = $usage . "java-create-tables.pl rhnTableName JavaClassName packagename\n";
    print $usage;
    exit 0;
}


my $hbmheader = file2string("hbm-templates/hbmheader.xml");
my $hbmfooter = file2string("hbm-templates/hbmfooter.xml");
my $javaheader = file2string("hbm-templates/javaheader.txt");
my $javafooter = file2string("hbm-templates/javafooter.txt");

my $fullpackage = "com.redhat.rhn.domain." . $package;
my $fullclass = $fullpackage . "." . $classname;

#fill out hib header vars
$hbmheader =~ s/###CLASSNAME###/$fullclass/g;
$hbmheader =~ s/###TABLE###/$tablename/g;

#fill out java header vars
$javaheader =~ s/###PACKAGE###/$fullpackage/g;
$javaheader =~ s/###CLASSNAME###/$classname/g;
$javaheader =~ s/###TABLE###/$tablename/g;

$tablename = uc($tablename);
my @desc = print_desc($tablename);

sub print_desc {
  my $tablename = shift;
  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);

SELECT column_name, data_type, data_length, nullable FROM all_tab_columns WHERE table_name = :tab_name ORDER BY column_id

EOQ

  $sth->execute_h(tab_name => $tablename);

  # print "------CUT HERE------\n\n";
  # loop through the row types and 
  # print out the java code
  my $bean_string = "";
  my $interface_string = "";
  my $hbmtxt = $hbmheader;
  my $rowcount = 0;
  while (my (@pname) = $sth->fetchrow()) {
    my $name = lc($pname[0]);
    my $type = $pname[1];
    my $length = $pname[2];
    my $nullable = $pname[3];
    $rowcount++;

    # figure out what to name the
    # variable for the table
    my @namearr = split /_/,lc($name);
    my $varname = "";
    foreach my $fix (@namearr) {
        my @char = split //,$fix;
        my $len = @char;
        $varname = $varname . uc($char[0]);
        for (my $i = 1; $i < $len; $i++) {
            $varname = $varname . $char[$i]; 
        }
    }
    
    $varname = lcfirst $varname;
    
    if ($nullable eq "N") {
        $nullable = "not-null=\"true\"";
    } else {
        $nullable = "";
    }
    
    # based on column type, print out corresponding
    # java column type
    my $javaType;
    $name = uc($name);
    if ($type eq "VARCHAR2" || $type eq "CHAR") {
        $hbmtxt = $hbmtxt . "        <property name=\"" .$varname . "\" column=\"" . $name . "\" ".$nullable." type=\"string\" length=\"" . $length . "\" />\n";
        $javaType = "String";
    }
    elsif ($type eq "NUMBER") {
        $hbmtxt = $hbmtxt .  "        <property name=\"" .$varname . "\" column=\"" . $name . "\" ".$nullable." type=\"long\" />\n";
        $javaType = "Long";
    }
    elsif ($type eq "DATE") {
        $hbmtxt = $hbmtxt . "        <property name=\"" .$varname . "\" column=\"" . $name . "\" ".$nullable." type=\"timestamp\" insert=\"false\" update=\"false\"/>\n";
        $javaType = "Date";
    }
    elsif ($type eq "BLOB") {
        $hbmtxt = $hbmtxt . "        <property name=\"" .$varname . "\" column=\"" . $name . "\" ".$nullable." type=\"blob\" />\n";
        $javaType = "Blob";
    }
    else {
        $hbmtxt = $hbmtxt . "Unknown type found: $name\n";
    }
    
    $bean_string = $bean_string . "$javaType $varname ";
    
  }
  
  if ($rowcount == 0) { 
    die "Table: [$tablename] not found\n";
  }
  
  $hbmtxt = $hbmtxt . $hbmfooter;

  my $import = $bean_string =~ /Date/ ? 'import java.util.Date;' : ''; 
  $javaheader =~ s/###IMPORT###/$import/;
   
  my $bean_file = $javaheader;
  $bean_file = $bean_file . `perl bean-maker.pl --fields $bean_string`;
  $bean_file = $bean_file . $javafooter;
  
  $package =~ s/\./\//g;
  
  my $srcpath = "../code/src/com/redhat/rhn/domain/" . $package . "/";
  my $hbmFileName = $srcpath . $classname . ".hbm.xml";

  string2file($hbmFileName, $hbmtxt);
  
  
  my $javaFileName = $srcpath . $classname . ".java";
  string2file($javaFileName, $bean_file);

}

sub file2string {
    my $filename = shift;
    open FH, "<$filename" or die "open $filename: $!";
    my $retval = join("", <FH>);
    close FH;
    return $retval;
}

sub string2file {
  my $filename = shift;
  my $contents = shift;
  
  open FH, ">$filename" or die "open $filename: $!";
  
  print FH $contents;
  close FH;
  print "Wrote: $filename\n";

}

