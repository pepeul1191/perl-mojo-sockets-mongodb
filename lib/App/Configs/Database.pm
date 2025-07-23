package App::Configs::Database;
use Mojo::Base -base;
use MongoDB;
use App::Configs::Initializers;

sub get_db {
  my $self = shift;
  
  # Usar el inicializador para obtener configuración
  my $init = App::Configs::Initializers->new;
  my $config = $init->get_mongo_config;
  
  my $client = MongoDB::MongoClient->new(
      host => $config->{host},
      port => $config->{port}
  );
  
  return $client->get_database($config->{db});
}

1;