package App::Configs::Routes;
use Mojo::Base -base;

sub load_routes {
  my $self = shift;
  my $app = shift;
  
  $app->routes->get('/')->to('Web#index');
  $app->routes->get('/welcome')->to('Web#welcome');
  $app->routes->get('/chat')->to('Web#chat');
  $app->routes->get('/api/v1/hello')->to('Api#hello');
  $app->routes->get('/api/v1/tags')->to('Tag#list_all');
  # ✅ Nueva ruta WebSocket
  $app->routes->websocket('/ws/chat')->to('Socket#chat');
}

1;