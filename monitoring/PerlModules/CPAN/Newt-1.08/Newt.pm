package Newt;

use strict qw(vars);
use Carp;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $AUTOLOAD @TOP);
use AutoLoader;

require Exporter;
require DynaLoader;

@ISA = qw(Exporter DynaLoader);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
@EXPORT_OK = qw(
	H_NEWT
	NEWT_ANCHOR_BOTTOM
	NEWT_ANCHOR_LEFT
	NEWT_ANCHOR_RIGHT
	NEWT_ANCHOR_TOP
	NEWT_COLORSET_ACTBUTTON
	NEWT_COLORSET_ACTCHECKBOX
	NEWT_COLORSET_ACTLISTBOX
	NEWT_COLORSET_ACTSELLISTBOX
	NEWT_COLORSET_ACTTEXTBOX
	NEWT_COLORSET_BORDER
	NEWT_COLORSET_BUTTON
	NEWT_COLORSET_CHECKBOX
	NEWT_COLORSET_COMPACTBUTTON
	NEWT_COLORSET_DISENTRY
	NEWT_COLORSET_EMPTYSCALE
	NEWT_COLORSET_ENTRY
	NEWT_COLORSET_FULLSCALE
	NEWT_COLORSET_HELPLINE
	NEWT_COLORSET_LABEL
	NEWT_COLORSET_LISTBOX
	NEWT_COLORSET_ROOT
	NEWT_COLORSET_ROOTTEXT
	NEWT_COLORSET_SELLISTBOX
	NEWT_COLORSET_SHADOW
	NEWT_COLORSET_TEXTBOX
	NEWT_COLORSET_TITLE
	NEWT_COLORSET_WINDOW
	NEWT_ENTRY_DISABLED
	NEWT_ENTRY_HIDDEN
	NEWT_ENTRY_RETURNEXIT
	NEWT_ENTRY_SCROLL
	NEWT_FD_READ
	NEWT_FD_WRITE
	NEWT_FLAG_DISABLED
	NEWT_FLAG_BORDER
	NEWT_FLAG_HIDDEN
	NEWT_FLAG_MULTIPLE
	NEWT_FLAG_NOF12
	NEWT_FLAG_NOSCROLL
	NEWT_FLAG_RETURNEXIT
	NEWT_FLAG_SCROLL
	NEWT_FLAG_SELECTED
	NEWT_FLAG_WRAP
	NEWT_FORM_NOF12
	NEWT_GRID_FLAG_GROWX
	NEWT_GRID_FLAG_GROWY
	NEWT_KEY_BKSPC
	NEWT_KEY_DELETE
	NEWT_KEY_DOWN
	NEWT_KEY_END
	NEWT_KEY_ENTER
	NEWT_KEY_EXTRA_BASE
	NEWT_KEY_F1
	NEWT_KEY_F10
	NEWT_KEY_F11
	NEWT_KEY_F12
	NEWT_KEY_F2
	NEWT_KEY_F3
	NEWT_KEY_F4
	NEWT_KEY_F5
	NEWT_KEY_F6
	NEWT_KEY_F7
	NEWT_KEY_F8
	NEWT_KEY_F9
	NEWT_KEY_HOME
	NEWT_KEY_LEFT
	NEWT_KEY_PGDN
	NEWT_KEY_PGUP
	NEWT_KEY_RESIZE
	NEWT_KEY_RETURN
	NEWT_KEY_RIGHT
	NEWT_KEY_SUSPEND
	NEWT_KEY_TAB
	NEWT_KEY_UNTAB
	NEWT_KEY_UP
	NEWT_LISTBOX_RETURNEXIT
	NEWT_TEXTBOX_SCROLL
	NEWT_TEXTBOX_WRAP
	NEWT_EXIT_HOTKEY
	NEWT_EXIT_COMPONENT
	NEWT_EXIT_FOREADY		
        OK_BUTTON
        CANCEL_BUTTON
        QUIT_BUTTON
        BACK_BUTTON
        OK_CANCEL_PANEL
        OK_BACK_PANEL        
);

%EXPORT_TAGS = (exits => [qw(NEWT_EXIT_HOTKEY 
			     NEWT_EXIT_COMPONENT 
			     NEWT_EXIT_FOREADY)],
		keys => [qw(NEWT_KEY_BKSPC 
			    NEWT_KEY_DELETE
			    NEWT_KEY_DOWN
			    NEWT_KEY_END
			    NEWT_KEY_ENTER
			    NEWT_KEY_EXTRA_BASE
			    NEWT_KEY_F1
			    NEWT_KEY_F10
			    NEWT_KEY_F11
			    NEWT_KEY_F12
			    NEWT_KEY_F2
			    NEWT_KEY_F3
			    NEWT_KEY_F4
			    NEWT_KEY_F5
			    NEWT_KEY_F6
			    NEWT_KEY_F7
			    NEWT_KEY_F8
			    NEWT_KEY_F9
			    NEWT_KEY_HOME
			    NEWT_KEY_LEFT
			    NEWT_KEY_PGDN
			    NEWT_KEY_PGUP
			    NEWT_KEY_RESIZE
			    NEWT_KEY_RETURN
			    NEWT_KEY_RIGHT
			    NEWT_KEY_SUSPEND
			    NEWT_KEY_TAB 
			    NEWT_KEY_UNTAB
			    NEWT_KEY_UP)],
		anchors => [qw(	NEWT_ANCHOR_BOTTOM
				NEWT_ANCHOR_LEFT
				NEWT_ANCHOR_RIGHT
				NEWT_ANCHOR_TOP)],
		colorsets => [qw(NEWT_COLORSET_ACTBUTTON
				 NEWT_COLORSET_ACTCHECKBOX
				 NEWT_COLORSET_ACTLISTBOX
				 NEWT_COLORSET_ACTSELLISTBOX
				 NEWT_COLORSET_ACTTEXTBOX
				 NEWT_COLORSET_BORDER
				 NEWT_COLORSET_BUTTON
				 NEWT_COLORSET_CHECKBOX
				 NEWT_COLORSET_COMPACTBUTTON
				 NEWT_COLORSET_DISENTRY
				 NEWT_COLORSET_EMPTYSCALE
				 NEWT_COLORSET_ENTRY
				 NEWT_COLORSET_FULLSCALE
				 NEWT_COLORSET_HELPLINE
				 NEWT_COLORSET_LABEL
				 NEWT_COLORSET_LISTBOX
				 NEWT_COLORSET_ROOT
				 NEWT_COLORSET_ROOTTEXT
				 NEWT_COLORSET_SELLISTBOX
				 NEWT_COLORSET_SHADOW
				 NEWT_COLORSET_TEXTBOX
				 NEWT_COLORSET_TITLE
				 NEWT_COLORSET_WINDOW)],
		flags => [qw(NEWT_FLAG_DISABLED
			     NEWT_FLAG_BORDER
			     NEWT_FLAG_HIDDEN
			     NEWT_FLAG_MULTIPLE
			     NEWT_FLAG_NOF12
			     NEWT_FLAG_NOSCROLL
			     NEWT_FLAG_RETURNEXIT
			     NEWT_FLAG_SCROLL
			     NEWT_FLAG_SELECTED
			     NEWT_FLAG_WRAP)],
		entry => [qw(NEWT_ENTRY_DISABLED
			     NEWT_ENTRY_HIDDEN
			     NEWT_ENTRY_RETURNEXIT
			     NEWT_ENTRY_SCROLL)],
		fd => [qw(NEWT_FD_READ
			  NEWT_FD_WRITE)],
		grid => [qw(NEWT_GRID_FLAG_GROWX
			    NEWT_GRID_FLAG_GROWY)],
		other => [qw(NEWT_FORM_NOF12
			     NEWT_LISTBOX_RETURNEXIT)],
		textbox => [qw(NEWT_TEXTBOX_SCROLL
			       NEWT_TEXTBOX_WRAP)],
		macros => [qw(OK_BUTTON
			      CANCEL_BUTTON
			      QUIT_BUTTON
			      BACK_BUTTON
			      OK_CANCEL_PANEL
			      OK_BACK_PANEL)],
	       );

$VERSION = do { my @r=(q$Revision: 1.1.1.1 $=~/\d+/g); sprintf "%d."."%02d"x$#r,@r };

@TOP = (); # Window stack;

sub AUTOLOAD {
  # This AUTOLOAD is used to 'autoload' constants from the constant()
  # XS function.  If a constant is not found then control is passed
  # to the AUTOLOAD in AutoLoader.


  my $constname;
  ($constname = $AUTOLOAD) =~ s/.*:://;
  croak "& not defined" if $constname eq 'constant';
  my $val = constant($constname, @_ ? $_[0] : 0);
  if ($! != 0) {
    if ($! =~ /Invalid/) {
      $AutoLoader::AUTOLOAD = $AUTOLOAD;
      goto &AutoLoader::AUTOLOAD;
    }
    else {
      croak "Your vendor has not defined Newt macro $constname";
    }
  }
  *$AUTOLOAD = sub { $val };
  goto &$AUTOLOAD;
}

bootstrap Newt $VERSION;

# Preloaded methods go here.

sub NEWT_EXIT_HOTKEY () {
  0;
}

sub NEWT_EXIT_COMPONENT () {
  1;
}

sub NEWT_EXIT_FOREADY () {
  2;
}

sub Newt::Form {
  my $self = {};

  $self->{co} = newtForm(); 
  bless $self, "Newt::Form";
}

sub Newt::Button {
  my ($caption, $compact) = @_;
  my $self = {};
  
  if($compact) {
    $self->{co} = newtCompactButton(-1, -1, $caption);    
  } else {
    $self->{co} = newtButton(-1, -1, $caption);    
  }
  bless $self, "Newt::Button";
}

sub Newt::Label {
  my $caption = "@_";
  my $self = {};
  
  $self->{co} = newtLabel(-1, -1, $caption);    
  bless $self, "Newt::Label";
}

sub Newt::Entry {
  my ($width, $flags, $default) = @_;
  my $self = {};

  $self->{co} = newtEntry(-1, -1, $default ? $default : '', $width, $flags);
  bless $self, "Newt::Entry";
}

sub Newt::Checkbox {
  my ($caption, $default, $valid) = @_;
  my $self = {};
  
  $self->{co} = newtCheckbox(-1, 
			     -1, 
			     $caption,
			     $default ? $default : ' ',
			     $valid ? $valid : ' *');
  bless $self, "Newt::Checkbox";
}

sub Newt::Listbox {
  my ($height, $flags) = @_;
  my $self = {};

  $self->{flags} = $flags ? $flags : 0;
  $self->{co} = newtListbox(-1, -1, $height, $self->{flags});
  $self->{items} = {};
  bless $self, "Newt::Listbox";
}

sub Newt::Scale {
  my ($width, $fullvalue) = @_;
  my $self = {};

  $self->{co} = newtScale(-1, -1, $width, $fullvalue);
  bless $self, "Newt::Scale";
}

sub Newt::Textbox {
  my ($width, $height, $flags, @rest) = @_;
  my $self = {};

  $self->{co} = newtTextbox(-1, -1, $width, $height, $flags ? $flags : 0);
  bless $self, "Newt::Textbox";
  $self->Set(@rest) if @rest;
  $self;
}

sub Newt::TextboxReflowed {
  my ($width, $flexdown, $flexup, $flags, @text) = @_;
  my $text = "@text";
  my $self = {};

  $self->{co} = newtTextboxReflowed(-1, -1, $text, $width, $flexdown, $flexup, 
				    $flags ? $flags : 0);
  bless $self, "Newt::Textbox";
}

sub Newt::VScrollbar {
  my ($height, $normalColorset, $thumbColorset) = @_;
  my $self = {};

  $self->{co} = newtVerticalScrollbar(-1, -1, $height, $normalColorset, $thumbColorset);
}

sub Newt::Panel {
  my ($cols, $rows, $title) = @_;
  
  my $self = Newt::Form();
  $self->{g} = newtCreateGrid($cols, $rows);
  $self->{refs} = {};
  $self->{title} = $title if $title;
  bless $self, "Newt::Panel";
}

sub Newt::HRadiogroup {
  my $self = {};
  my $radio;
  my $pos = 0;

  $self =  {};
  $self->{g} = newtCreateGrid(scalar(@_), 1);

  foreach(@_) {
    if ($radio) {
      $radio = newtRadiobutton(-1, -1, $_, 0, $radio);
    } else {
      $radio = newtRadiobutton(-1, -1, $_, 1);
    }
    push @{$self->{'components'}}, $radio;
    Newt::newtGridSetField($self->{g}, $pos, 0, 1, $radio, 1, 0, 0, 0,0, 0);
    $pos++;
  }

  Newt::newtGridPlace($self->{g}, 1, 1);
  bless $self, "Newt::Radiogroup";
}

sub Newt::VRadiogroup {
  my $self = {};
  my $radio;
  my $pos = 0;

  $self = {};
  $self->{g} = newtCreateGrid(1, scalar(@_));

  foreach(@_) {
    if ($radio) {
      $radio = newtRadiobutton(-1, -1, $_, 0, $radio);
    } else {
      $radio = newtRadiobutton(-1, -1, $_, 1);
    }
    push @{$self->{'components'}}, $radio;
    Newt::newtGridSetField($self->{g}, 0, $pos, 1, $radio, 0, 0, 0, 0,0, 0);
    $pos++;
  }
  
  Newt::newtGridPlace($self->{g}, 1, 1);  
  bless $self, "Newt::Radiogroup";
}

# Macro facilities

sub Newt::OK_BUTTON () {
  Newt::Button('OK')->Tag('OK');
}

sub Newt::CANCEL_BUTTON () {
  Newt::Button('Cancel')->Tag('CANCEL');
}

sub Newt::QUIT_BUTTON () {
  Newt::Button('Quit')->Tag('QUIT');
}

sub Newt::BACK_BUTTON () {
  Newt::Button('Back')->Tag('BACK');
}

sub Newt::OK_CANCEL_PANEL () {
  Newt::Panel(2, 1)
    ->Add(0, 0, OK_BUTTON(), NEWT_ANCHOR_RIGHT(), 0, 1, 1, 0)
      ->Add(1, 0, CANCEL_BUTTON(), NEWT_ANCHOR_LEFT(), 1, 1, 0, 0);
}

sub Newt::OK_BACK_PANEL () {
  Newt::Panel(2, 1)
    ->Add(0, 0, OK_BUTTON, NEWT_ANCHOR_RIGHT, 0, 0, 1, 0)
      ->Add(1, 0, BACK_BUTTON, NEWT_ANCHOR_LEFT, 1, 0, 0, 0);
}

@Newt::Component::ISA = qw(Newt);
@Newt::Form::ISA = qw(Newt::Component);
@Newt::Button::ISA = qw(Newt::Component);
@Newt::Entry::ISA = qw(Newt::Component);
@Newt::Label::ISA = qw(Newt::Component);
@Newt::Checkbox::ISA = qw(Newt::Component);
@Newt::Scale::ISA = qw(Newt::Component);
@Newt::Textbox::ISA = qw(Newt::Component);
@Newt::VScrollbar::ISA = qw(Newt::Component);
@Newt::Listbox::ISA = qw(Newt::Component);
@Newt::Panel::ISA = qw(Newt::Form);
@Newt::Radiogroup::ISA = qw(Newt::Component);

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__

########################### Newt::Component

sub Newt::Component::AddCallback {
  my ($self, $cb) = @_;

  Newt::newtComponentAddCallback($self->{co}, $cb);
  $self;
}

sub Newt::Component::TakesFocus {
  my ($self, $yesorno) = @_;

  Newt::newtComponentTakesFocus(self->{co}, $yesorno);
  $self;
}

sub Newt::Component::GetComponent {
  my $self = shift;

  return (1, $self->{co});
}

sub Newt::Component::Tag {
  my ($self, $tag) = @_;
  
  if ($tag) {
    $self->{tag} = $tag;
    return $self;
  } else {
    return $self->{tag};
  }
}

########################### Newt::Form

sub Newt::Form::AddHotKey {
  my ($self, $key) = @_;

  Newt::newtFormAddHotKey($self->{co}, $key);
  $self;
}

sub Newt::Form::Add {
  my $self = shift;

  foreach (@_) {
    Newt::newtFormAddComponent($self->{co}, $_->{co});
  }
  $self;
}

sub Newt::Form::SetBackground {
  my ($self, $color) = @_;

  Newt::newtFormSetBackground($self->{co}, $color);
  $self;
}

sub Newt::Form::SetHeight {
  my ($self, $height) = @_;

  Newt::newtFormSetHeight($self->{co}, $height);
  $self;
}

sub Newt::Form::Draw {
  my $self = shift;

  Newt::newtDrawForm($self->{co});
  $self;
}

sub Newt::Form::Run {
  my $self = shift;

  return Newt::newtFormRun($self->{co});
}

sub Newt::Form::DESTROY {
  my $self = shift;
  
  Newt::newtFormDestroy($self->{co});
}

########################### Newt::Label

sub Newt::Label::Set {
  my ($self, @text) = @_;

  Newt::newtLabelSetText($self->{co}, "@text");
  $self;
}

########################### Newt::Entry

sub Newt::Entry::Get {
  my $self = shift;

  return Newt::newtEntryGetValue($self->{co});
}

sub Newt::Entry::Set {
  my ($self, $text, $atEnd) = @_;
  
  Newt::newtEntrySet($self->{co}, 
			    $text || "", 
			    $atEnd ? $atEnd : 0);
  $self;
}

sub Newt::Entry::SetFilter {
  my ($self, $filter) = @_;
  
  Newt::newtEntrySetFilter($self->{co}, $filter);
  $self;
}

########################### Newt::Checkbox

sub Newt::Checkbox::Get {
  my $self = shift;
  
  return Newt::newtCheckboxGetValue($self->{co});
}

sub Newt::Checkbox::Checked {
  my $self = shift;

  return $self->Get() ne " ";
}

########################### Newt::Radiogroup

sub Newt::Radiogroup::Get {
  my $self = shift;
  my $index = 0;

  foreach (@{$self->{components}}) {
    return $index if ${Newt::newtRadioGetCurrent($_)} eq ${$_};
    $index++;
  }
}

sub Newt::Radiogroup::GetComponent {
  my $self = shift;

  return (2, $self->{g});
}

########################### Newt::Listbox

sub Newt::Listbox::Add {
  my $self = shift;

  foreach (@_) {
    $self->{items}{$_} = $_;
    Newt::newtListboxAppendEntry($self->{co}, $_, $self->{items}{$_});
  }
  $self;
}

sub Newt::Listbox::Insert {
  my $self = shift;
  my $before = shift;

  foreach (@_) {
    $self->{items}{$_} = $_;
    Newt::newtListboxInsertEntry($self->{co}, $_,
				 $self->{items}{$_}, 
				 $self->{items}{$before});
  }
  $self;
}

sub Newt::Listbox::Delete {
  my $self = shift;
  
  foreach (@_) {
    Newt::newtListboxDeleteEntry($self->{co}, $self->{items}{$_});
  }
  $self;
}

sub Newt::Listbox::Clear {
  my $self = shift;

  Newt::newtListboxClear($self->{co});
  $self;
}

sub Newt::Listbox::Select {
  my $self = shift;

  foreach (@_) {
    Newt::newtListboxSelectItem($self->{co}, $self->{items}{$_}, 0)
  }
  $self;
}

sub Newt::Listbox::Unselect {
  my $self = shift;

  foreach (@_) {
    Newt::newtListboxSelectItem($self->{co}, $self->{items}{$_}, 1)
  }
  $self;
}

sub Newt::Listbox::Get {
  my $self = shift;
  
  if ($self->{flags} & Newt::constant(NEWT_FLAG_MULTIPLE, 0)) {
    return Newt::newtListboxGetSelection($self->{co});
  } else {
    return Newt::newtListboxGetCurrent($self->{co});    
  }
}

########################### Newt::Scale

sub Newt::Scale::Set {
  my ($self, $amount) = @_;

  Newt::newtScaleSet($self->{co}, $amount || 0);
  $self;
}

########################### Newt::Textbox

sub Newt::Textbox::Set {
  my $self = shift;

  Newt::newtTextboxSetText($self->{co}, "@_");
  $self;
}

########################### Newt::Panel

sub Newt::Panel::Move {
  my ($self, $left, $top) = @_;

  $self->{left} = $left;
  $self->{top} = $top;
  if($self->{drawed}) {
    $self->Hide;
    $self->Draw;
  }
  $self;
}

sub Newt::Panel::Add {
  my ($self, $col, $row, $comp, $anchor, $padLeft, $padTop, 
      $padRight, $padBottom, $flags) = @_;

  Carp::croak "Can only add components!" if ! UNIVERSAL::isa($comp, 'Newt::Component');
  Newt::newtGridSetField($self->{g}, 
			 $col, 
			 $row, 
			 ($comp->GetComponent()),
			 $padLeft ? $padLeft : 0,
			 $padTop ? $padTop : 0,
			 $padRight ? $padRight : 0,
			 $padBottom ? $padBottom : 0,
			 $anchor ? $anchor : 0,
			 $flags ? $flags : 0);
  $self->{refs}{${$comp->{co}}} = $comp  if exists $comp->{co};
  $self;
}

sub Newt::Panel::GetComponent {
  my $self = shift;
  
  return (2, $self->{g});
}

sub Newt::Panel::Pack {
  my $self = shift;
  
  Newt::newtGridAddComponentsToForm($self->{g}, $self->{co}, 1) if ! $self->{packed};
  $self->{packed} = 1;
}

sub Newt::Panel::Draw {
  my ($self) = @_;
  
  $self->Pack();
  $self->Hide if(@TOP && $TOP[-1] ne $self);
  if(!$self->{drawed}) {
      if(exists($self->{left}) and  exists($self->{top})) {
	Newt::newtGridWrappedWindowAt($self->{g}, $self->{title}, 
				      $self->{left}, $self->{top}); 
      } else {
	Newt::newtGridWrappedWindow($self->{g}, $self->{title});  
      }
      $self->SUPER::Draw();
      $self->{drawed} = 1;
      push(@TOP,$self);
  }
  $self;
}

sub Newt::Panel::_upgrade {
    my $self = shift;
    my @upgraded = ();
    for my $k (keys(%{$self->{refs}})) {
	my $comp = $self->{refs}{$k};
	if(UNIVERSAL::isa($comp,'Newt::Panel')) {
	    push(@upgraded,$comp->_upgrade);
	    %{$comp->{refs}} = ();
	} else {
	    push(@upgraded,($k=>$comp));
	}
    }
    return @upgraded;
}

sub Newt::Panel::upgrade {
    my $self = shift;
    %{$self->{refs}} = $self->_upgrade;
}

sub Newt::Panel::Run {
  my ($self,$tr) = @_;
  my ($reason, $data);

  $self->Draw;
  $self->upgrade;
  ($reason, $data) = $self->SUPER::Run();
  $self->Hide if($tr);
  if (ref($data)) {
    $data = $self->{refs}{$$data};
  }
  return wantarray ? ($reason, $data) : $data;
}


sub Newt::Panel::Hide {
    my $self = shift;
    my @tops = ();
    return unless $self->{drawed};
    while(my $top = pop(@TOP)) {
	Newt::PopWindow();
	$top->{drawed} = 0;
	last if($top eq $self);
	unshift @tops,$top;
    }
    for(@tops) {
	$_->Draw;
    }
    $self;
}

# Below is the stub of documentation for your module. You better edit it!

=head1 NAME

Newt - Perl bindings for RedHat newt library

=head1 SYNOPSIS

  use Newt;

  Newt::Init();
  Newt::Cls();

  #A lot of Newt operations...

  Newt::Finished();

=head1 DESCRIPTION

The Newt module implements perl bindings for the RedHat newt windowing
system, a terminal-based window and widget library for writing
applications with a simple, but user friendly, interface.

=head1 Basic Newt functions

=over

=item C<Newt::Init()>

Starts Newt services. You must use this command first.

=item C<Newt::Finished()>

Ends Newt services.

=item C<Newt::Cls()>

Clears the background.

=item C<Newt::Refresh()>

Foreces an inmediate update of the modified portions of the screen.

=item C<Newt::Bell()>

Sends a beep to the terminal.

=item C<Newt::GetScreenSize()>

Returns a tuple containing the screen dimensions.

=head1 Keyboard input

=over

=item C<Newt::WaitForKey()>

Stops program execution until a key is pressed.

=item C<Newt::ClearKeyBuffer()>

Discards the contents of the terminal's input buffer without waiting
for additional input.

=back

=head1 Drawing text on the root window

=over

=item C<Newt::DrawRootText($left, $top, $text)>

Displays the text in the indicated position.

=item C<Newt::PushHelpLine($text)>

Saves the current help line on a stack and displays the new line. If
the text is null, Newt's default help line is displayed. If text is a
string of length 0, the help line is cleared.

=item C<Newt::PopHelpLine()>

Replaces the current help line with the previous one. It is important
not to pop more lines than the ones pushed.

=back

=head1 Suspending Newt applications

By default, Newt programs cannot be suspended by the user. Instead,
programs can specify a callback function which gets invoked whe the
user presses the suspend key. To register such function, you can do
something like this:

    sub my_cb {
      ...
    }	

    Newt::SetSuspendCallback(\&my_cb);

If the application should suspend and continue like most user
applications, the suspend callback needs two other newt functions:

    Newt::Suspend();
    Newt::Resume();

The first one tells Newt to return the terminal to its initial
state. Once this is done, the application can suspend itself by
sending SIGSTP, fork a child program or whatever. When it wants to
resume using the Newt interface, is must call C<Newt::Resume()> before
doing so.

For more information on suspending newt applications, read the
original newt documentation.

=head1 Components

Components are the basic blocks for construction of Newt interfaces.
They all are created in a similar manner. You just have to
call the constructor to receive a blessed object of the specified
class:

    $object = Newt::Foo();

Once you have a component, you can add it to a panel to create a
complex user input interface.

=head2 General component manipulation

You can attach a callback for a component like this:

    sub comp_cb {
        ...
    }

    $component->AddCallback(\%comp_cb);

Exactly when (if ever) the callback is invoked depens on the type of
the component.

Yo can tell if a component takes or not focus when traversing a form
with the following function:

    $component->TakesFocus($true_or_false);

It is handy to set some arbitrary information on a component for later
retrieval. You do this by setting its tag:

    $button->Tag("OK");

If you call this function without an argument, it replies with the
actual tag for that component.

In general when the return value of any method of a component isn't
described the method returns the component itself to allow contructions
like:

    $panel
	->Add(0,0, $componet1->Set( .... ) )
	->Add(0,1, Newt::Label( .... ) )
	->Add(0,2, Newt::Panel( .... )
	    ->Add( .... )
	    ->Add( .... ) )
	->Add( .... );

=head2 Buttons

There are two kinds of buttons: full and compact:

    $normal_button = Newt::Button($text);
    $compact_button = Newt::CompactButton($text);

=head2 Labels

Labels are quite simple:

    $label = Newt::Label($text);

You can set the text of an existing label like this:

    $label->Set($text);

=head2 Entry boxes

Entry boxes are used to enter text:

    $entry = Newt::Entry($width, $flags, $initial_text);

The initial text is optional. After an entry has been created, it's
contents can be set by using:

    $entry->Set($text, $cursor_at_end);

The last parameter is optional, and signals if the cursor should be
moved to the end of the new value.

To get the current value of the entry box, you do this:

    $entry->Get();

You can filter the characters that may be entered by using a callback
filter like this:

    sub my_filter {
      my ($proposed_char, $cursor_position) = @_;

      ...

      return(0) if $char_shoud_be_ignored;
      return($proposed_char)	# Accept the char
    }

    $entry->SetFilter(\&my_filter);

As can be seen, filter callbacks receive a char and an integer which
indicates the position that the proposed char would take on the entry.
The filter function can return the very same char to indicate that it
was accepted, but it can also return another char, to actually
substitute the original one. If the filter wants to simply reject the
keystroke, it only returns 0.

When an entry is created, some flags may be specified. The flags are
the following and may be C<OR>ed: 

=over

=item C<NEWT::NEWT_ENTRY_SCROLL>

If not specified, the user cannot enter text into the entry box which
is wider than the entry box itself. This flag removes this limitation,
and lets the user enter data of an arbitrary length.

=item C<NEWT::NEWT_FLAG_HIDDEN>

If specified, the value of the entry is not displayed. Useful when an
applications needs a password.

=item C<NEWT::NEWT_FLAG_RETURNEXIT>

When specified, the entry will cause the form to stop running if the
user pressed return inside the entry box. Nice shortcut for users.

=back

=head2 Checkboxes

Newt checkboxes are peculiar, since may have more than two
states. To create a normal one (checked or unchecked), do this:

    $check = Newt::Checkbox("Normal checkbox");

But you can create, for example, a checkbox that switches form not
checked to checked with an asterisk and then to checked with an 'M':

    $check = Newt::Checkbox("Normal checkbox", " ", " *M");

As you can see, you can use the two optional parameters to tell the
default char first and then the possible chars.

To know if a checkbox is checked after the for is ran, you use the following:

    print "Is checked\n" if $check->Checked();

And you can always get the actual state like this:

    $state = $check->Get();

=head2 Radio groups

You create two kinds of radio button groups, vertical and horizontal,
by doing this:

    $radio_group1 = Newt::VRadiogroup('Red', 'Green', 'Blue');
    $radio_group2 = Newt::HRadiogroup('Red', 'Green', 'Blue');

You can put any number of options and the first one will always be
preselected. To know the index of the selected option after the form
has run, you do this:

    $index = $radio_group->Get();

=head2 Listboxes

Listboxes are the most complicated components Newt provides. They can
allow single or multiple selection, and are easy to update. They are
created as follows:

    $listbox = Newt::Listbox($height, $flags);

A listbox is created at a certain position and a given height. The
C<$height> is used for two things. First of all, it is the minimum
height the listbox will use. If there are less items in the listbox
then the height, suggests the listbox will still take up that minimum
amount of space. Secondly, if the listbox is set to be scrollable (by
setting the C<NEWT_FLAG_SCROLL> flag, C<$height> is also the maximum
height of the listbox. If the listbox may not scroll, it increases its
height to display all of its items.

The following flags may be used when creating a listbox:

=over

=item C<NEWT_FLAG_SCROLL> 

The listbox should scroll to display all of the items it contains.

=item C<NEWT_FLAG_RETURNEXIT> 

When the user presses return on an item in the list, the form should
return.

=item C<NEWT_FLAG_BORDER> 

A frame is drawn around the listbox, which can make it easier to see
which listbox has the focus when a form contains multiple listboxes.

=item C<NEWT_FLAG_MULTIPLE> 

By default, a listbox only lets the user select one item in the list
at a time. When this flag is specified, they may select multiple items
from the list.

=back

=head2

Once a listbox has been created, items are appended to the bottom like
this:

    $listbox->Append($item1, $item2, ...);

Appending is not the only way to add items to the list. You can insert
items in any position by telling the item that should be before with
the following command:

    $listbox->Insert($before, $item1, $item2, ...);

And you can change any item just by telling:

    $listbox->Set($original, $new);

Of course you can delete entries:

    $listbox->Delete($item1, $item2, ...);

Or just clear out the listbox:

    $listbox->Clear();

You can select and unselect items, with the following:

    $listbox->Select($item1, $item2, ...);

    $listbox->Unselect($item1, $item2, ...);

    $listbox->ClearSelection();

but if you did not sepecify the flag C<NEWT_FLAG_MULTIPLE> when
constructing your listbox, only the last item on the argument list of
C<Unselect()> will remain selected.

To get a list of the selected items, just issue:

    @selected_items = $listbox->Get();

=head2 Scales

Scales provide an easy way for telling the user the advance on some
lengthy operation. It is a horizontal bar graph which the application
updates as the operation continues:

    $scale = Newt::Scale($width, $fullvalue);

It is set as expected:

    $scale->Set($amount);

=head2 Textboxes

A text box is used for displaying large amounts of text. They are
created as follows:

    $textbox = Newt::Textbox($width, $height, $flags, $text, ...);

The $text parameter is optional, and if not supplied, the textbox
is created only, but it does not fill it with data. To do so, use:

    $textbox->Set($text, ...);

All the arguments are simply concatenated using the double quote
operator.

The flags that can be passed to the cronstuctor are the following:

=over

=item C<NEWT_FLAG_WRAP>

All text in the textbox should be wrapped to fit the width of the
textbox. If this flag is not specified, each newline delimited line in
the text is truncated if it is too long to fit.

When Newt wraps text, it tries not to break lines on spaces or
tabs. Literal newline characters are respected, and may be used to
force line breaks.

=item C<NEWT_FLAG_SCROLL>

The text shoud be scrollable. When this option is used, the scrollbar
which is added increases the width of the area used by the textbox by
2 characters.

=back

=head2 Reflowing text

When applications need to display large amounts of text, it is common
not to know exactly where the linebreaks should go. While textboxes
are quite willing to scroll the text, the programmer still must know
what width the text will look ``best'' at (where ``best'' means most
exactly rectangular; no lines much shorter or much longer then the
rest). This common is specially prevalent in internationalized
programs, which need to make a wide variety of message string look
good on a screen.

To help with this, Newt provides routines to reformat text to look
good. It tries different widths to figure out which one will look
``best'' to the user. As these commons are almost always used to
format text for textbox components, Newt makes it easy to
construct a textbox with reflowed text.

The following function reflows the provided text to a target
width. the actual width of the longest line in the returned text is
between C<$width - $flexdown> and C<$width + $flexup>; the actual
maximum line length is chosen to make displayed text look
rectangular. The function returns a tuple consisting of the reflowed
text and the actual width and height of it.

    ($r_text, $width, $height) = Newt::ReflowText($width,
                                                  $flexdown,
                                                  $flexup,
						  $text);

When the reflowed text is being placed in a textbox it may be easier
to use the following:

    $textbox = Newt::TextboxReflowed($width, $flexdown, 
                                     $flexup, $flags,
				     $text, ...);

which creates a textbox, reflows the text, and places the reflowed
text in the listbox. Its parameters consist of the position of the
final textbox, the width and flex values for the text (which are
identical to the parameters passed to C<Newt::Reflow()>, and the flags
for the textbox (which are the same as the flags for
C<Newt::Textbox(). This function does not let you limit the height of
the textbox, however, making limiting its use to contructing
textboxes which do not need to scroll.

To find out how tall the textbox created by C<Newt::TextboxReflowed()> is, 
use C<Newt::GetNumLines()>, which returns the number of lines in the
textbox. For textboxes created by C<Newt::TextboxReflowed()>/, this is
always the same as the height of the textbox.

Please note that the order of the parameters of Newt::ReflowText and 
Newt::TextboxReflowed differs from the C API to allow lists of text but
currently only TextboxReflowed allows this.

=head2 Scrollbars

Scrollbars may be attached to forms to let them contain more data than
they have space for. Currently, there can only be vertical scrollbars:

    $scroll = Newt::VScrollbar($height, 
                               $normalColorset, 
                               $thumbColorset);

When a scrollbar is created, it is given a position on the screen, a
height, and two colors. The first color is the color used for drawing
the scrollbar, and the second color is used for drawing the
thumb. This is the only place in newt where an application
specifically sets colors for a component. It s done here to let the
colors a scrollbar use match the colors of the component the scrollbar
is mated too. When a scrollbar is being used with a form,
C<$normalColorset> is often C<NEWT_COLORSET_WINDOW> and
C<$thumbColorset> C<NEWT_COLORSET_ACTCHECKBOX>.

If you do not want to bother with colors, you can ommit the last two
parameters and let Newt use the defaults.

As the scrollbar is normally updated by the component it is mated with,
there is no public interface for moving the thumb.

=head1 Panels

Panels are high level grid-like constructs that are used to group
components. You create them by specifying the number of columns and
rows you want, as well as a caption to be used when the panel is
displayed as a toplevel:

    $panel = Newt::Panel(2, 3, "Panel example");

When run, panesl are centered by default, but you can specify a
position relative to the topleft corner of the screen by appending two
optional integers:

    $panel = Newt::Panel(2, 3, "Panel example", 5, 5);

Adding components to a panel is straightforward, you just have to
indicate the position the component will take in the grid:

   $panel1->Add(0, 0, $mycomponent);

Several optional parameters my however be used when adding components:

    $panel1->Add($col, 
                 $row, 
                 $mycomponent,
                 $anchor,
                 $padleft, 
                 $padtop,
                 $padright,
                 $padbottom,
                 $flag);

You can specify the side of the cell to which the component will be
aligned by specifying an anchor. The anchor values avalaible are
C<NEWT_ANCHOR_LEFT>, C<NEWT_ANCHOR_RIGHT>, C<NEWT_ANCHOR_TOP>,
C<NEWT_ANCHOR_BOTTOM>.

You can ask for more space on the sides of the component, perhaps to
get a cleaner, less cluttered presentation using the padding
parameters, and specifiying an integer value.

Panels may be nested. For this to be done you only have to add a panel
to another as you would with any other component.

To run a panel as a toplevel and get user input, you may do the
following:

    ($reason, $data) = $panel->Run();

    if ($reason eq NEWT_EXIT_HOTKEY) {
      if ($data eq NEWT_KEY_F12) {
        print "F12 hotkey was pressed\n";
      } else {
        print "Some hotkey other than F12 was pressed\n";
      }
    } else {
      print 'Form terminated by button ', $data->Tag(), "\n";
    }

As can be seen on the example, when called in a list context
C<Run()> returns two values, one is the reason why the form terminated
and the other is an associated data. In a scalar context only the data
is returned. Posible values for the reason are:

=over

=item C<NEWT_EXIT_HOTKEY>

The form exited because a hotkey was pressed. The associated data
contains the key pressed, that is, one of NEWT_KEY_* values. See
Hotkeys later for more information.

=item C<NEWT_EXIT_COMPONENT>

The form exited because a component was activated, a button, for
instance a button. The associated data is a reference to the
component involved.

=back

=head2 Hotkeys

Normally, a panel terminates when the user presses a button, but you
can define some keys as "hotkeys" that will make the C<Run()> function
return with C<NEWT_EXIT_HOTKEY>. Yo do this by issuing the folowing:

   $panel->AddHotKey(NEWT_KEY_F11);

F12 is always defined to be a hotkey.

=head2 Drawing panels instead uf running them

When you run a panel the terminal is blocked until the user presses a
component or a key that causes the panel to exit. Sometimes is useful
to present the interface to the user without blocking the execution of
code. This can be done by only drawing the panel, not running it. It
is easy to show an advance status for a lengthy operation liek this:

   $i = 1;
   foreach (@items) {
      $label->Set("Processing item $i");
      $panel->Draw();
      $scale->Set($i);
      process_item($_);
      $i++
   }

=head2 Hiding panels

Panels can be hidden in case you want by using the following:

    $panel->Hide()

=head1 Constants

You can import all the constants exported by this package as needed
qor using several predefined tags, with the folowing syntax:

    use Newt qw(:exits :keys);

=over

=item exits NEWT_EXIT_* constants

=item keys NEWT_KEY_* constants

=item anchors NEWT_ANCHOR_* constants

=item colorsets NEWT_COLORSET_* constanst

=item flags NEWT_FLAG_* constants

=item entry NEWT_ENTRY_* constants

=item fd NEWT_FD_* constants

=item grid NEWT_GRID_* constants

=item textbox NEWT_TEXTBOX_* constants

=item macros 

macros to make useful buttons and panels: OK_BUTTON, CANCEL_BUTTON,
QUIT_BUTTON, BACK_BUTTON, OK_CANCEL_PANEL, OK_BACK_PANEL. this macros
only create componetnts which are properly tagged.

=back

=head1 TO DO

=over

=item Scrollable panels.

=item Some forms stuff, like watching file descriptors.

=back

=head1 SEE ALSO

I<Writing programs using Newt>, by Eric Troan.

=head1 THANKS TO

Eric Troan, for writing this useful library. Thanks for his tutorial,
too, from where I stole complete paragraphs for this documentation,
I'm afraid.

=head1 AUTHOR

The original author of the RedHat newt library is Erik Troan,
<I<ewt@redhat.com>> The author of this Perl bindings is Alejandro
Escalante Medina, <I<amedina@msg.com.mx>>

=head1 DATE

Version 0.1, 5th Nov 1998

=cut
