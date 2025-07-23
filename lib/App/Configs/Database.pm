# lib/App/Configs/Database.pm
package App::Configs::Database;
use Mojo::Base -base;
use MongoDB;

sub get_db {
  my $self = shift;
  my $client = MongoDB::MongoClient->new(
    host => $ENV{MONGO_HOST} || 'localhost',
    port => $ENV{MONGO_PORT} || 27017
  );
  return $client->get_database($ENV{MONGO_DB} || 'tickets');
}

1;