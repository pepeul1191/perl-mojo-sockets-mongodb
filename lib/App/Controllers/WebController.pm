package App::Controllers::WebController;
use Mojo::Base 'Mojolicious::Controller';

sub index {
  my $c = shift;
  $c->render('site/index', title => 'Inicio');
}

sub demo {
  my $c = shift;
  $c->render('site/demo', title => 'Inicio');
}

sub welcome {
  my $c = shift;
  my $name = $c->param('name') || 'Invitado';
  $c->render('site/welcome', name => $name, title => 'Bienvenido');
}

sub chat {
  my $c = shift;
  $c->render('site/chat', title => 'Inicio');
}

1;