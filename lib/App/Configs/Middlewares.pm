package App::Configs::Middlewares;
use Mojo::Base -base;

sub before_all {
  my ($class, $app) = @_;  # ✅ Corregido: estaba mal la asignación
  # Setear cabecera Server para todas las respuestas
  $app->hook(before_dispatch => sub {
    my $c = shift;
    $c->res->headers->header('Server' => 'Mojolicious (Perl);Ubuntu');
  });
}

1;