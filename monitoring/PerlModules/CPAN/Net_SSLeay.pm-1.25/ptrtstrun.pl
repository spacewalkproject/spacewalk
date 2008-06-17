use Config;

print "cc: " . $Config{'cc'} . "\n";

if(runptrcasttst()) {
  print "ok\n";
} else {
  print "not ok.\n";
}

sub runptrcasttst {
  if( !($r = system "$Config{'cc'} -o ptrcasttst ptrcasttst.c") ) {
    print "ok\n";
  } else {
    print "not ok\n";
    return 0;
  }
  if( !($r = system "./ptrcasttst") ) {
    print "ok\n";
    return 1;
  } else {
    print "not ok\n";
    return 0;
  }
  return 0;
}
