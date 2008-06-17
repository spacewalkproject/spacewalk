package test::TestPagerContactMethod;

use strict;

use base qw(Test::Unit::TestCase);

use NOCpulse::Notif::PagerContactMethod;
use NOCpulse::Notif::Alert;

my $MODULE = 'NOCpulse::Notif::PagerContactMethod';

my $CONFIG=NOCpulse::Config->new;
my $server  = $CONFIG->get('mail', 'mx');

my $MY_INTERNAL_EMAIL = 'kja@nocpulse.com';
my $MY_EXTERNAL_EMAIL = 'nerkren@yahoo.com';
my $NOWHERE_EMAIL     = 'nobody@nocpulse.com';

$| = 1;

######################
sub test_constructor {
######################
  my $self = shift;
  my $obj = $MODULE->new();

  # Make sure creation succeeded
  $self->assert(defined($obj), "Couldn't create $MODULE object: $@");

  # Make sure we got the right type of object
  $self->assert(qr/$MODULE/, "$obj");
        
}

############
sub set_up {
############
  my $self = shift;
  # This method is called before each test.

my $message = <<EOM;
THE TALE OF CUSTARD THE DRAGON

By Ogden Nash

Copyright Linell Nash Smith and Isabel Nash Eberstadt

Belinda lived in a little white house, 
With a little black kitten and a little gray mouse, 
And a little yellow dog and a little red wagon, 
And a realio, trulio, little pet dragon. 

Now the name of the little black kitten was Ink, 
And the little gray mouse, she called her Blink, 
And the little yellow dog was sharp as Mustard, 
But the dragon was a coward, and she called him Custard. 

Custard the dragon had big sharp teeth, 
And spikes on top of him and scales underneath, 
Mouth like a fireplace, chimney for a nose, 
And realio, trulio, daggers on his toes. 

Belinda was as brave as a barrel full of bears, 
And Ink and Blink chased lions down the stairs, 
Mustard was as brave as a tiger in a rage, 
But Custard cried for a nice safe cage. 

Belinda tickled him, she tickled him unmerciful, 
Ink, Blink and Mustard, they rudely called him Percival, 
They all sat laughing in the little red wagon 
At the realio, trulio, cowardly dragon. 

Belinda giggled till she shook the house, 
And Blink said Week!, which is giggling for a mouse, 
Ink and Mustard rudely asked his age, 
When Custard cried for a nice safe cage. 

Suddenly, suddenly they heard a nasty sound, 
And Mustard growled, and they all looked around. 
Meowch! cried Ink, and Ooh! cried Belinda, 
For there was a pirate, climbing in the winda. 

Pistol in his left hand, pistol in his right, 
And he held in his teeth a cutlass bright, 
His beard was black, one leg was wood; 
It was clear that the pirate meant no good. 

Belinda paled, and she cried, Help! Help! 
But Mustard fled with a terrified yelp, 
Ink trickled down to the bottom of the household, 
And little mouse Blink strategically mouseholed. 

But up jumped Custard, snorting like an engine, 
Clashed his tail like irons in a dungeon, 
With a clatter and a clank and a jangling squirm 
He went at the pirate like a robin at a worm. 

The pirate gaped at Belinda's dragon, 
And gulped some grog from his pocket flagon, 
He fired two bullets but they didn't hit, 
And Custard gobbled him, every bit. 

Belinda embraced him, Mustard licked him, 
No one mourned for his pirate victim 
Ink and Blink in glee did gyrate 
Around the dragon that ate the pyrate. 

Belinda still lives in her little white house, 
With her little black kitten and her little gray mouse, 
And her little yellow dog and her little red wagon, 
And her realio, trulio, little pet dragon. 

Belinda is as brave as a barrel full of bears, 
And Ink and Blink chase lions down the stairs, 
Mustard is as brave as a tiger in a rage, 
But Custard keeps crying for a nice safe cage. 
EOM

  $self->{'one'}=$MODULE->new( 'email' => $MY_INTERNAL_EMAIL );
  $self->{'alert'}=NOCpulse::Notif::Alert->new( 
    'fmt_subject' => 'The Tale of Custard the Dragon',
    'fmt_message' => $message);
  $self->{'smtp'}=test::TestPagerContactMethod::SMTPStub->new();
}

###############
sub tear_down {
###############
  my $self = shift;
  $self->{'smtp'}->quit;
}


# INSERT INTERESTING TESTS HERE

##################
sub test_deliver {
##################
# __multi_short 
  my $self=shift;

  $self->{'alert'}->send_id(1);
  $self->{'one'}->pager_max_message_length(100);
  $self->{'one'}->split_long_messages(1);
  my $value=$self->{'one'}->deliver($self->{'alert'},undef,$self->{'smtp'});
  $self->assert($value == 0, "test_deliver__multi_short");
}

##############################
sub test_deliver__one_short {
##############################
  my $self=shift;

  $self->{'alert'}->send_id(2);
  $self->{'one'}->pager_max_message_length(100);
  $self->{'one'}->split_long_messages(0);
  my $value=$self->{'one'}->deliver($self->{'alert'},undef,$self->{'smtp'});
  $self->assert($value == 0, "test_deliver__one_short");
}

################################
sub test_deliver__one_regular {
################################
  my $self=shift;

  $self->{'alert'}->send_id(3);
  my $value=$self->{'one'}->deliver($self->{'alert'},undef,$self->{'smtp'});
  $self->assert($value == 0, "test_deliver__one_regular");
}

1;

package test::TestPagerContactMethod::SMTPStub;

use Class::MethodMaker
  new_hash_init => 'new';

sub code { }
sub data      { return 1 }
sub datasend  { return 1 }
sub dataend   { return 1 }
sub mail      { return 1 }
sub quit      { return 1 }
sub reset     { return 1 }
sub recipient { return 1 }


1;
