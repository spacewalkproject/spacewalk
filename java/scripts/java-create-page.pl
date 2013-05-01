#!/usr/bin/perl

# (c) 2004, Red Hat, Inc
# All rights reserved
#
# Simple util to spit out 

use strict;

my $jsppath = $ARGV[0];
my $jspname = $ARGV[1];
my $classname = $ARGV[2];
my $package = $ARGV[3];

if ($jsppath eq "" || $classname eq "" || $package eq "") {
    my $usage =       "usage:              [jsp path                   ] [jsp name ] [Struts action classname     ]  [package ]\n";
    $usage = $usage . "java-create-page.pl admin/monitoring/notification methods.jsp NotificationMethodsSetupAction  monitoring\n";
    print $usage;
    exit 0;
}

#add a / to the end of the path if we need one
if (rindex($jsppath, "/") != (length($jsppath) -1)) {
    $jsppath = $jsppath . "/";
}

my $strutslocation = "../code/webapp/WEB-INF/struts-config.xml";

my $javaheader = file2string("hbm-templates/javaheader.txt");
my $javabody = file2string("java-templates/actionbody.txt");
my $testbody = file2string("java-templates/testbody.txt");
my $javafooter = file2string("hbm-templates/javafooter.txt");

my $jspbody = file2string("java-templates/jspbody.jsp");
my $strutstemp = file2string("java-templates/struts-template.xml");
my $strutsconfig = file2string($strutslocation);

my $fullpackage = "com.redhat.rhn.frontend.action." . $package;
$fullpackage =~ s/\//\./g;

my $fullclass = $fullpackage . "." . $classname;

#action class vars
my $classdecl = $classname . " extends RhnAction";
my $fulljsp = $jsppath . $jspname;
my $actionname = $classname;
$actionname =~ s/SetupAction//g;
$actionname =~ s/Action//g;
my $actionpath = "/" . $jsppath . $actionname;

#testcase vars
my $testname = $classname . "Test";
my $testpackage = $fullpackage . ".test";

#fill out java header vars
$javaheader =~ s/###PACKAGE###/$fullpackage/g;
$javaheader =~ s/###CLASSNAME###/$classdecl/g;
$testbody =~ s/###CLASSNAME###/$testname/g;
$testbody =~ s/###PACKAGE###/$testpackage/g;
$testbody =~ s/###ACTIONCLASS###/$classname/g;
$testbody =~ s/###ACTIONPACKAGE###/$fullpackage/g;
$testbody =~ s/###ACTIONPATH###/$actionpath/g;

$jspbody =~ s/###JSPNAME###/$jspname/g;
$strutstemp =~ s/###JSPPATH###/$fulljsp/g;
$strutstemp =~ s/###FULLCLASS###/$fullclass/g;
$strutstemp =~ s/###ACTIONPATH###/$actionpath/g;

generate_action();
generate_jsp();
append_struts();

sub generate_action {

  my $import = "import com.redhat.rhn.frontend.struts.RhnAction;\n"; 
  $import = $import . "import com.redhat.rhn.frontend.struts.StrutsDelegate;\n\n";
  $import = $import . "import org.apache.struts.action.ActionForm;\n";
  $import = $import . "import org.apache.struts.action.ActionForward;\n";
  $import = $import . "import org.apache.struts.action.ActionMapping;\n\n";
  $import = $import . "import java.util.Map;\n";
  $import = $import . "import javax.servlet.http.HttpServletRequest;\n";
  $import = $import . "import javax.servlet.http.HttpServletResponse;\n";
  
  $javaheader =~ s/###IMPORT###/$import/;
   
  my $action_file = $javaheader;
  $action_file = $action_file . $javabody;
  $action_file = $action_file . $javafooter;
  
  $package =~ s/\./\//g;
  
  my $srcpath = "../code/src/com/redhat/rhn/frontend/action/" . $package . "/";
  
  my $javaFileName = $srcpath . $classname . ".java";
  insure($srcpath);
  string2file($javaFileName, $action_file);
  
  my $testFileName = $srcpath . "test/" . $classname . "Test.java";
  insure($srcpath . "test/");
  string2file($testFileName, $testbody);
  

}

sub generate_jsp() {
    my $jspFileName = "../code/webapp/WEB-INF/pages/" .  $jsppath . $jspname;
    insure("../code/webapp/WEB-INF/pages/" .  $jsppath);
    string2file($jspFileName, $jspbody);
}


sub append_struts() {
    $strutsconfig = $strutsconfig . "\n" . $strutstemp;
    string2file($strutslocation, $strutsconfig);
    print "Appended struts config block to end of struts-config.xml.  Please move to proper location in file!!\n";
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

sub insure {
  my $dir = shift;

  if (! -e $dir) {
    system("mkdir -p $dir");
  }
}
