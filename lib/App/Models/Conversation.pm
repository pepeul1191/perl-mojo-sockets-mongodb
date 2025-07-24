# lib/App/Models/Conversation.pm
package App::Models::Conversation;
use Mojo::Base -base;
use App::Configs::Database;

sub new {
  my $class = shift;
  my $self = bless {}, $class;
  $self->{db} = App::Configs::Database->new->get_db;
  $self->{collection} = $self->{db}->get_collection('conversations');
  $self->{db_helper} = App::Configs::Database->new; 
  return $self;
}

sub find_conversation_between_users {
  my ($self, $user1_id, $user2_id) = @_;
  
  my $query = {
    'user_ids' => {
      '$all' => [int($user1_id), int($user2_id)],
      '$size' => 2
    }
  };
  
  return $self->{collection}->find_one($query);
}

sub create_personal_conversation {
  my ($self, $user_id1, $user2_id) = @_;

  my $now = $self->{db_helper}->create_mongo_date();
    # Crear estructura de conversación
  my $conversation = {
    name => 'Conversación privada',  # Nombre por defecto
    description => '',
    image_url => '',
    user_ids => [$user_id1, $user2_id],  # Asegurar que sean números
    messages => [],  # Array vacío de mensajes
    created => $now,  # Timestamp actual
    updated => $now   # Timestamp actual
  };
  
  # Insertar en MongoDB
  my $result = $self->{collection}->insert_one($conversation);
  
  # Agregar el ID generado por MongoDB
  $conversation->{_id} = $result->inserted_id;
  
  return $conversation;
}

1;