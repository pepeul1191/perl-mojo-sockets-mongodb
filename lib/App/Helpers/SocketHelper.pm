package App::Helpers::SocketHelper;
use Mojo::Base -base;
use Data::Dumper; 

sub new {
  my $class = shift;
  my $self = bless {}, $class;
  return $self;
}

sub load_conversation {
  my ($self, $user1_id, $user2_id, $conversations) = @_;

  my $conversation = $conversations->find_conversation_between_users($user1_id, $user2_id);
 
  # Print condicional
  if ($conversation) {
    print STDERR "Conversación encontrada: " . $conversation->{_id} . "\n";
    return {
      json => {
        type => 'old_conversation', 
        message => 'Continuar Convesarción', 
        messages => $conversation->{messages},
        conversation_id => $conversation->{_id},
      }
    };
  } else {
    my $conversation = $conversations->create_personal_conversation($user1_id, $user2_id);
    return {
      json => {
        type => 'new_conversation', 
        message => 'Nueva Convesarción', 
        messages => [],
        conversation_id => $conversation->{_id},
      }
    };
  }
}

1;