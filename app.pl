#!/usr/bin/env perl
use Mojolicious::Lite;
use lib 'lib';

# Cargar inicializadores (esto cargará .env)
use App::Configs::Initializers;
my $init = App::Configs::Initializers->new;

# Obtener configuración
my $app_config = $init->get_app_config;
my $mongo_config = $init->get_mongo_config;

# Debug
say "Mongo Config: " . join(', ', %$mongo_config) if $app_config->{debug};

# Helper para almacenar conexiones WebSocket activas
my @active_connections;

app->helper(active_connections => sub {
  return \@active_connections;
});

# Helper para broadcast (enviar a todos los clientes conectados)
app->helper(broadcast_message => sub {
  my ($c, $message) = @_;
  
  $c->app->log->debug("Broadcasting message to " . scalar(@active_connections) . " connections");
  
  # Enviar mensaje a todas las conexiones activas
  for my $conn (@active_connections) {
    eval {
      $conn->send({json => $message});
    };
    if ($@) {
      $c->app->log->warn("Error enviando mensaje: $@");
    }
  }
});

# Configurar aplicación
app->secrets([$app_config->{secret}]);
app->defaults(start_time => time);
app->mode($app_config->{debug} ? 'development' : 'production');

# Registrar namespaces
app->routes->namespaces(['App::Controllers']);

# Cargar rutas
use App::Configs::Routes;
my $routes = App::Configs::Routes->new;
$routes->load_routes(app);

# Iniciar aplicación
app->start;