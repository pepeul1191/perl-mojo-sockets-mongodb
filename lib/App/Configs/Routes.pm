package App::Configs::Routes;
use Mojo::Base -base;

sub load_routes {
  my $self = shift;
  my $app = shift;
  
  $app->routes->get('/')->to('Web#index');
  $app->routes->get('/welcome')->to('Web#welcome');
  $app->routes->get('/api/v1/hello')->to('Api#hello');
}

1;