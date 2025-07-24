package App::Configs::Database;
use Mojo::Base -base;
use MongoDB;
use App::Configs::Initializers;
use DateTime;
use Time::HiRes qw(gettimeofday);

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

sub create_mongo_date {
  my ($self, $timestamp) = @_;
  $timestamp //= time;
  
  # Crear objeto DateTime que MongoDB entiende
  my $dt = DateTime->from_epoch(
    epoch => $timestamp,
    time_zone => 'UTC'
  );
  
  return $dt;
}

1;