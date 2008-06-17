# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..4\n"; }
END {print "not ok 1\n" unless $loaded;}
use Newt qw(NEWT_FLAG_BORDER NEWT_ANCHOR_LEFT NEWT_ANCHOR_RIGHT NEWT_GRID_FLAG_GROWX NEWT_GRID_FLAG_GROWY NEWT_FLAG_MULTIPLE NEWT_KEY_F12 NEWT_KEY_F11 NEWT_EXIT_HOTKEY);
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

sub suspend_cb {
  Newt::Suspend();
  kill STOP => $$;
  Newt::Resume();
}

Newt::SetSuspendCallback(\&suspend_cb);

# Panel example
Newt::Init();
Newt::Cls();
Newt::PushHelpLine();
Newt::DrawRootText(0, 0, "Newt v$Newt::VERSION Test Program");
$l1 = Newt::Label("Name:");
$l2 = Newt::Label("Address:");
$name = Newt::Entry(20, NEWT_FLAG_SCROLL);
$address = Newt::Entry(20, NEWT_FLAG_SCROLL);
$ok = Newt::Button("Ok", 0);
$ok->Tag("OK");
$li = Newt::Listbox(5, NEWT_FLAG_SCROLL | NEWT_FLAG_BORDER | NEWT_FLAG_MULTIPLE);
$li->Add('Red', 'Blue', 'Yellow', 'Gray', 'Green');
$panel1 = Newt::Panel(2, 4, "Panel example");
$panel1->AddHotKey(NEWT_KEY_F11);
$panel2 = Newt::Panel(1, 2, "Second panel");
$label = Newt::Label('Now, some options:');
$radio = Newt::VRadiogroup('aa', 'b', 'c', 'd', 'e', 'f');
$panel2->Add(0,0, $label, NEWT_ANCHOR_LEFT);
$panel2->Add(0,1, $radio, NEWT_ANCHOR_LEFT);
$panel1->Add(0, 0, $l1, NEWT_ANCHOR_LEFT);
$panel1->Add(0, 1, $l2, NEWT_ANCHOR_LEFT);
$panel1->Add(1, 0, $name, NEWT_ANCHOR_LEFT);
$panel1->Add(1, 1, $address, NEWT_ANCHOR_LEFT);
$panel1->Add(0, 2, $li, NEWT_ANCHOR_LEFT, 0, 0, 1);
$panel1->Add(1, 2, $ok, NEWT_ANCHOR_RIGHT);
$panel1->Add(0, 3, $panel2, NEWT_ANCHOR_LEFT, 0, 0, 1);
($reason, $data) = $panel1->Run();
Newt::Finished();
if ($reason eq NEWT_EXIT_HOTKEY) {
  if ($data eq NEWT_KEY_F12) {
    print "F12 hotkey was pressed\n";
  } else {
    print "Some hotkey other than F12 was pressed\n";
  }
} else {
  print 'Form terminated by button ', $data->Tag(), "\n";
}
print "Your name is ", $name->Get(), "\n";
print "Your address is ", $address->Get(), "\n";
@li = $li->Get();
print "You selected the following: @li\n";
