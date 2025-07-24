package App::Controllers::Socket;
use Mojo::Base 'Mojolicious::Controller';
use JSON qw(decode_json encode_json);
use App::Models::Tag;
use Mojo::JWT;

sub demo {
  my $c = shift;
  
  # Agregar esta conexión a las conexiones activas
  my $connections = $c->app->active_connections;
  push @$connections, $c;
  
  # Cuando se establece la conexión WebSocket
  $c->app->log->debug("Nueva conexión WebSocket establecida. Total: " . scalar(@$connections));
  
  # Enviar mensaje de bienvenida
  $c->send({json => {type => 'welcome', message => 'Conectado al chat!', users => scalar(@$connections)}});
  
  # Manejar mensajes entrantes
  $c->on(message => sub {
    my ($c, $msg) = @_;
    
    $c->app->log->debug("Mensaje recibido (raw): $msg");
    
    # Parsear el mensaje JSON con manejo de errores
    my $data;
    eval {
      $data = decode_json($msg);
    };
    
    if ($@) { 
      $c->app->log->error("Error parseando JSON: $@ - Mensaje: $msg");
      # Error al parsear JSON
      $c->send({json => {type => 'error', message => 'Mensaje inválido: ' . $@}});
      return;
    }
    
    $c->app->log->debug("Mensaje parseado: " . encode_json($data));
    
    # Procesar diferentes tipos de mensajes
    if ($data->{type} eq 'message') {
      # Reenviar el mensaje a todos los clientes conectados
      my $response = {
        type => 'broadcast',
        user => $data->{user} || 'Anónimo',
        message => $data->{message},
        timestamp => time
      };
      
      # Enviar a todos los clientes conectados (broadcast)
      $c->app->broadcast_message($response);
      
      # Confirmación al remitente
      $c->send({json => {type => 'ack', message => 'Mensaje recibido'}});
        
    } elsif ($data->{type} eq 'ping') {
      # Responder a ping
      $c->send({json => {type => 'pong', timestamp => time}});
    } else {
      $c->send({json => {type => 'error', message => 'Tipo de mensaje desconocido'}});
    }
  });
  
  # Manejar desconexión
  $c->on(finish => sub {
    my ($c, $code, $reason) = @_;
    
    # Remover esta conexión de las conexiones activas
    my $connections = $c->app->active_connections;
    @$connections = grep { $_ != $c } @$connections;
    
    $c->app->log->debug("Conexión WebSocket cerrada: $code $reason. Restantes: " . scalar(@$connections));
  });
}

sub chat {
  my $c = shift;
  
  # Capturar el parámetro token de la URL
  my $token = $c->param('token');
  
  unless ($token) {
    $c->app->log->debug('WebSocket connection rejected: Missing token');
    $c->tx->finish(4000, 'Missing authentication token');
    return;
  }

  # Validar el token JWT
  my $init = App::Configs::Initializers->new;
  my $config = $init->get_app_config;
  my $jwt = Mojo::JWT->new(secret => $config->{secret});
  #my $jwt = Mojo::JWT->new(secret => '++++++++++++++++++');
  
  my $claims;
  eval {
    $claims = $jwt->decode($token);
  };
  
  if ($@) {
    $c->app->log->debug("WebSocket connection rejected: Invalid token - $@");
    $c->send({json => {type => 'error', message => 'Invalid authentication token'}});
    $c->tx->finish(4001, 'Invalid authentication token');
    return;
  }
  
  # Verificar que el token no haya expirado
  if ($claims->{exp} && $claims->{exp} < time) {
    $c->app->log->debug('WebSocket connection rejected: Token expired');
    $c->tx->finish(4002, 'Token expired');
    return;
  }
  
  # Token válido, aceptar la conexión
  $c->app->log->debug("WebSocket connection accepted for user: $claims->{username}");
  
  # Configurar los handlers del WebSocket
  $c->on(message => sub {
    my ($c, $msg) = @_;
    $c->app->log->debug("Message received: $msg");
    
    # Procesar el mensaje
    eval {
      my $data = Mojo::JSON::decode_json($msg);
      # ... procesar el mensaje ...
      # Procesar diferentes tipos de mensajes
      if ($data->{type} eq 'message') {
        # Reenviar el mensaje a todos los clientes conectados
        my $response = {
          type => 'broadcast',
          user => $data->{user} || 'Anónimo',
          message => $data->{message},
          timestamp => time
        };      
        # Confirmación al remitente
        $c->send({json => {type => 'ack', message => 'Mensaje recibido'}});
      } elsif ($data->{type} eq 'ping') {
        # Responder a ping
        $c->send({json => {type => 'pong', timestamp => time}});
      } else {
        $c->send({json => {type => 'error', message => 'Tipo de mensaje desconocido'}});
      }
    };
    if ($@) {
      $c->send({json => {error => 'Invalid JSON message'}});
    }
  });
  
  $c->on(finish => sub {
    my ($c, $code, $reason) = @_;
    $c->app->log->debug("WebSocket connection finished: $code $reason");
  });
  
  # Enviar mensaje de bienvenida
  my $tag_model = App::Models::Tag->new;
  $c->send({json => {type => 'welcome', message => 'Connected successfully', tag => $tag_model->list_all()}});
}

1;