package App::Controllers::Socket;
use Mojo::Base 'Mojolicious::Controller';
use JSON qw(decode_json encode_json);

sub chat {
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

1;