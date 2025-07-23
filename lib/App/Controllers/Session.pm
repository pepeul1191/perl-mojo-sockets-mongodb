package App::Controllers::Session;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::JSON qw(encode_json);
use Mojo::JWT;

sub login {
  my $c = shift;

  my $init = App::Configs::Initializers->new;
  my $config = $init->get_app_config;

  $c->app->log->debug($config->{xauthtrigger});

  $c->render('session/sign-in', title => 'Inicio', config=> $config);
}

sub sign_in {
  my $c = shift;
  
  # Obtener los datos
  my $data;
  if ($c->req->headers->content_type =~ /application\/json/) {
    $data = $c->req->json;
  } else {
    $data = $c->req->params->to_hash;
  }
  
  # Extraer los valores
  my $username = $data->{username};
  my $email    = $data->{email};
  my $user_id   = int($data->{user_id});
  my $system_id   = int($data->{system_id});
  
  # Generar el JWT
  my $jwt = Mojo::JWT->new(
    claims => {
      username => $username,
      email    => $email,
      user_id   => $user_id,
      system_id   => $system_id,
      exp      => time + 3600,  # Expira en 1 hora
      iat      => time,         # Issued at
    },
    secret => $c->app->config->{app}->{secret} || 'default_secret'
  );
  
  my $token = $jwt->encode;
  
  # Devolver el token
  $c->render(json => { 
    user_id => $user_id, 
    system_id => $system_id, 
    username => $username, 
    email => $email, 
    token => $token
  });
};

1;
