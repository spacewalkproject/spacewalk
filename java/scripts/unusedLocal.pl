#!/usr/bin/perl

# Remove unused local variables from java files.  To use this, run
# this script as:
#    ./unusedLocal.pl file_name
# The file_name argument is a file with the format:
#
# filename directory line ###

my @args = shift;
my $fname = @args[0];
open FILE, "< $fname" or die "Can't open $fname: $!";

@lines = <FILE>;
while ($line = pop @lines) {
    my $filename;
    my $dirname;
    my $lineNum;

    ($filename, $dirname, $lineNum) = ($line =~ /(\S*) *(\S*) *line (\d*)/);

    next if ($dirname =~ /^$/);

    print "processing: $dirname/$filename\n";

    # load the whole file into memory.
    open javaFile, "< $dirname/$filename" or die "Can't open $dirname/$filename: $!";
    @newFile = <javaFile>;
    close(javaFile);

    # Remove everything before " = " on the line.
    my $currentLine = @newFile[$lineNum - 1];
    print "Replacing: $currentLine\n";
    $currentLine =~ s/(\s*).* = (.*)/\1\2/;
    print "     with: $currentLine\n";
    @newFile[$lineNum - 1] = $currentLine;

    # write out the file.
    open javaFile, ">$dirname/$filename" or die "Can't open $dirname/$filename: $!";
    print javaFile @newFile;
    close(javaFile);
}
