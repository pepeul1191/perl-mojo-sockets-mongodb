package App::Controllers::ApiController;
use Mojo::Base 'Mojolicious::Controller';

sub hello {
  my $c = shift;
  $c->render(json => {message => 'Hola desde Perl!', timestamp => time});
}

sub status {
  my $c = shift;
  $c->render(json => {
    status => 'ok',
    version => '1.0',
    uptime => time - $c->app->defaults->{start_time} || time
  });
}

1;