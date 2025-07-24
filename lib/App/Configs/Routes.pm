package App::Configs::Routes;
use App::Configs::Middlewares;
use Mojo::Base -base;

sub load_routes {
  my $self = shift;
  my $app = shift;

  # Configurar el middleware
  App::Configs::Middlewares->before_all($app);
  
  $app->routes->get('/')->to('WebController#index');
  $app->routes->get('/welcome')->to('WebController#welcome');
  $app->routes->get('/demo')->to('WebController#demo');
  $app->routes->get('/api/v1/hello')->to('ApiController#hello');
  $app->routes->get('/api/v1/tags')->to('TagController#list_all');
  # session
  $app->routes->get('/sign-in')->to('SessionController#login');
  $app->routes->post('/api/v1/sign-in')->to('SessionController#sign_in');
  # demo
  $app->routes->get('/chat')->to('WebController#chat');
  # Nueva ruta WebSocket
  $app->routes->websocket('/ws/demo')->to('SocketController#demo');
  $app->routes->websocket('/ws/chat')->to('SocketController#chat');

  # Ruta catch-all para 404 - DEBE SER LA ÚLTIMA
  $app->routes->any('/*whatever' => sub {
    my $c = shift;
    
    $c->render(
      status => 404,
      json => {
        error => 'Not Found',
        message => 'API endpoint not found',
        method => $c->req->method,
        path => $c->req->url->path,
        timestamp => time()
      }
    );
  });
}

1;