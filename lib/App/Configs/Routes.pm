package App::Configs::Routes;
use App::Configs::Middlewares;
use Mojo::Base -base;

sub load_routes {
  my $self = shift;
  my $app = shift;

  # Configurar el middleware
  App::Configs::Middlewares->before_all($app);
  
  $app->routes->get('/')->to('Web#index');
  $app->routes->get('/welcome')->to('Web#welcome');
  $app->routes->get('/chat')->to('Web#chat');
  $app->routes->get('/api/v1/hello')->to('Api#hello');
  $app->routes->get('/api/v1/tags')->to('Tag#list_all');
  # session
  $app->routes->get('/sign-in')->to('Session#login');
  $app->routes->post('/api/v1/sign-in')->to('Session#sign_in');
  # demo
  $app->routes->get('/demo')->to('Web#demo');
  # ✅ Nueva ruta WebSocket
  $app->routes->websocket('/ws/chat')->to('Socket#chat');
}

1;