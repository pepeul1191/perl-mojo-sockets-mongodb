#!/usr/bin/env perl
use Mojo::Base -strict;
use Mojolicious::Lite;

# Ruta principal
get '/' => sub {
    my $c = shift;
    $c->render('index');
};

# API de ejemplo
get '/api/hello' => sub {
    my $c = shift;
    $c->render(json => {message => 'Hola desde Perl!'});
};

# Iniciar aplicación
app->start;

__DATA__

@@ index.html.ep
<!DOCTYPE html>
<html>
<head>
    <title>Mi App Mojolicious</title>
    <meta charset="utf-8">
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
    </style>
</head>
<body>
    <div class="container">
        <h1>¡Bienvenido a tu app Mojolicious!</h1>
        <p>Esta es una aplicación básica creada con Mojolicious::Lite.</p>
        <a href="/api/hello">Prueba la API</a>
    </div>
</body>
</html>