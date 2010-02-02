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
package Dobby::BackupLog;
use RHN::SimpleStruct;
use Storable qw/freeze thaw/;
## Ideally we would use XML::Simple but its not available on a Sat
## so we just use DOM to read/write this object to XML so it can 
## be stored and reloaded from disk in a Perl indpendant format.
use XML::LibXML;

our @ISA = qw/RHN::SimpleStruct/;
our @simple_struct_fields = qw/start finish sid tablespaces archive_logs control_file type cold_files/;

# UGLY HACK for now; use Storable instead of a real data structure.
# ugh.

sub parse {
  my $class = shift;
  my $restore_log = shift;
  
  my $parser = XML::LibXML -> new();
  my $doc = undef;
  my $log = undef;
  
  eval { $doc = $parser->parse_file($restore_log); }; 
  if ($@) {
    open FH, "<$restore_log" or die "open $restore_log: $!";
    my $contents = join("", <FH>);
    close FH;
    $log = thaw($contents);    
  } 
  else
  {
    $log = fromXml($doc);
  }
  
  return $log;
}

#fill out the object with the values
#from the XML Dom.
sub fromXml() {
  my $doc = shift;
  my $log = new Dobby::BackupLog();
  
  $log->sid(getTextValue($doc,'sid'));
  $log->start(getTextValue($doc,'start'));
  $log->type(getTextValue($doc,'type'));
  $log->finish(getTextValue($doc,'finish'));
  
  
  foreach my $fileentry ($doc->getElementsByTagName('fileentry')){
    my $fe = new Dobby::BackupLog::FileEntry();
    $log->add_cold_file($fe->fromXml($fileentry)); 
  }

  foreach my $tablespaceentry ($doc->getElementsByTagName('tablespaceentry')){
    my $te = new Dobby::BackupLog::TablespaceEntry();
    $log->add_tablespace_entry($te->fromXml($tablespaceentry)); 
  }
  
  return $log;
}

# Convert object to XML
sub toXml {
  my $self = shift;
  
  my $doc = XML::LibXML::Document->new( "1.0", "UTF-8");
  my $root = $doc->createElement('backuplog');
  my $sid = $doc->createElement('sid');
  addTextValue($sid, $doc, $self->start);
  my $start = $doc->createElement('start');
  addTextValue($start, $doc, $self->start);
  my $control_file = $doc->createElement('controlfile');
  addTextValue($control_file, $doc, $self->control_file);
  my $type = $doc->createElement('type');
  addTextValue($type, $doc, $self->type);
  my $finish = $doc->createElement('finish');
  addTextValue($finish, $doc, $self->finish);
  
  my $archive_logs = $doc->createElement('archivelogs');
  if (defined($self->archive_logs)) {
    for my $archive_log (@{$self->archive_logs}) {
      my $alog = $doc->createElement('controlfile');
      $archive_logs-> appendChild($alog);
    }  
  }
  
  my $cold_files = $doc->createElement('coldfiles');
  if (defined($self->cold_files)) {
    for my $file_entry (@{$self->cold_files}) {
      $cold_files-> appendChild($file_entry->toXml($doc));
    }  
  }
  
  my $tablespaces =  $doc->createElement('tablespaces');
  if (defined($self->tablespaces)) {
    for my $tablespace_entry (@{$self->tablespaces}) {
      $tablespaces-> appendChild($tablespace_entry->toXml($doc));
    }  
  }
  
  $root->appendChild($cold_files);
  $root->appendChild($tablespaces);
  $root->appendChild($sid);
  $root->appendChild($start); 
  $root->appendChild($control_file); 
  $root->appendChild($type); 
  $root->appendChild($finish); 

  my $retval = $root->toString . "\n";
  return $retval;
  
  
}

## Util functions for XML processing
sub addTextValue {
    my $node = shift;
    my $doc = shift;
    my $value = shift;
    if (!$value) {
      $value = "";
    }
    my $textNode = $doc->createTextNode($value);
    $node->appendChild($textNode);
}
sub getTextValue {
  my $doc = shift;
  my $tag = shift;
  return $doc->getElementsByTagName($tag)->item(0)->getFirstChild->nodeValue; 
}

sub serialize {
  my $self = shift;
  my $dest = shift;

  open FH, ">$dest" or die "open $dest: $!";
  print FH $self->toXml();
  close FH;
}

sub add_tablespace_entry {
  my $self = shift;

  my $tablespaces = $self->tablespaces;
  push @$tablespaces, @_;
  $self->tablespaces($tablespaces);
}

sub add_cold_file {
  my $self = shift;

  my $cold_files = $self->cold_files;
  push @$cold_files, @_;
  $self->cold_files($cold_files);
}

package Dobby::BackupLog::TablespaceEntry;
use RHN::SimpleStruct;

our @ISA = qw/RHN::SimpleStruct/;
our @simple_struct_fields = qw/name files start finish/;

sub add_file_entry {
  my $self = shift;

  my $files = $self->files;
  push @$files, @_;
  $self->files($files);
}

#convert object to XML
sub toXml {
  my $self = shift;
  my $doc = shift;
  
  my $entry = $doc->createElement('tablespaceentry'); 
  my $name = $doc->createElement('name');
  Dobby::BackupLog::addTextValue($name, $doc, $self->name); 
  
  my $start = $doc->createElement('start'); 
  Dobby::BackupLog::addTextValue($start, $doc, $self->start); 
  
  my $finish = $doc->createElement('finish'); 
  Dobby::BackupLog::addTextValue($finish, $doc, $self->finish); 

  $entry->appendChild($name);
  $entry->appendChild($start);
  $entry->appendChild($finish);
  my $files = $doc->createElement('files');
  
  if (defined($self->files)) {
    for my $file_entry (@{$self->files}) {
      my $file = $doc->createElement('file'); 
      Dobby::BackupLog::addTextValue($file, $doc, $file_entry); 
      $files->appendChild($file);
    }
  }  
  $entry->appendChild($files);

  return $entry;
}

#fill out the object with the values
#from the XML Dom.
sub fromXml {
  my $self = shift;
  my $element = shift;  
  
  $self->name(Dobby::BackupLog::getTextValue($element, 'name'));
  $self->start(Dobby::BackupLog::getTextValue($element, 'start'));
  $self->finish(Dobby::BackupLog::getTextValue($element, 'finish'));
  
  foreach my $fileelement ($element->getElementsByTagName('file')){
    $self->add_file_entry($fileelement->getFirstChild->nodeValue); 
  }
  
  return $self;
}



package Dobby::BackupLog::FileEntry;
use RHN::SimpleStruct;

our @ISA = qw/RHN::SimpleStruct/;
our @simple_struct_fields = qw/start finish from to digest compressed_size original_size/;

#convert the object to XML
sub toXml {
  my $self = shift;
  my $doc = shift;
  
  my $entry = $doc->createElement('fileentry'); 
  my $originalsize = $doc->createElement('originalsize');
  Dobby::BackupLog::addTextValue($originalsize, $doc, $self->original_size); 
  
  my $compressedsize = $doc->createElement('compressedsize'); 
  Dobby::BackupLog::addTextValue($compressedsize, $doc, $self->compressed_size); 
  
  my $start = $doc->createElement('start'); 
  Dobby::BackupLog::addTextValue($start, $doc, $self->start); 

  my $digest = $doc->createElement('digest'); 
  Dobby::BackupLog::addTextValue($digest, $doc, $self->digest); 
  
  my $to = $doc->createElement('to');   
  Dobby::BackupLog::addTextValue($to, $doc, $self->to); 
  
  my $from = $doc->createElement('from'); 
  Dobby::BackupLog::addTextValue($from, $doc, $self->from); 
  
  my $finish = $doc->createElement('finish'); 
  Dobby::BackupLog::addTextValue($finish, $doc, $self->finish); 
  
  $entry->appendChild($originalsize);
  $entry->appendChild($compressedsize);
  $entry->appendChild($start);
  $entry->appendChild($digest);  
  $entry->appendChild($to);
  $entry->appendChild($from);
  $entry->appendChild($finish);
     
  return $entry;
}

#fill out the object with the values
#from the XML Dom.
sub fromXml {
  my $self = shift;
  my $element = shift;  
  
  $self->start(Dobby::BackupLog::getTextValue($element, 'start'));
  $self->finish(Dobby::BackupLog::getTextValue($element, 'finish'));
  $self->from(Dobby::BackupLog::getTextValue($element, 'from'));
  $self->to(Dobby::BackupLog::getTextValue($element, 'to'));
  $self->digest(Dobby::BackupLog::getTextValue($element, 'digest'));
  $self->original_size(Dobby::BackupLog::getTextValue($element, 'originalsize'));
  $self->compressed_size(Dobby::BackupLog::getTextValue($element, 'compressedsize'));
  
  return $self;
}

1;
