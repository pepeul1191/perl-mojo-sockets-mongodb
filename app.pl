#!/usr/bin/env perl
use Mojo::Base -strict;
use Mojolicious::Lite;

# Ruta principal
get '/' => sub {
    my $c = shift;
    $c->render('site/index');
};

get '/welcome' => sub {
    my $c = shift;
    my $name = $c->param('name') || 'Invitado';
    $c->render('site/welcome', name => $name, title => 'Bienvenido');
};

# API de ejemplo
get '/api/hello' => sub {
    my $c = shift;
    $c->render(json => {message => 'Hola desde Perl!'});
};

# Iniciar aplicación
app->start;
