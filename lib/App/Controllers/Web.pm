package App::Controllers::Web;
use Mojo::Base 'Mojolicious::Controller';

sub index {
  my $c = shift;
  $c->render('site/index', title => 'Inicio');
}

sub chat {
  my $c = shift;
  $c->render('site/chat', title => 'Inicio');
}

sub welcome {
  my $c = shift;
  my $name = $c->param('name') || 'Invitado';
  $c->render('site/welcome', name => $name, title => 'Bienvenido');
}

1;