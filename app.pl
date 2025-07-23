#!/usr/bin/env perl
use Mojolicious::Lite;
use lib 'lib';

# Cargar módulo de rutas
use App::Configs::Routes;

# Configuración
app->secrets(['mi_secreto_super_seguro_123']);
app->defaults(start_time => time);

# ⚠️ IMPORTANTE: El namespace debe coincidir con la estructura de directorios
app->routes->namespaces(['App::Controllers']);

# Cargar todas las rutas
my $routes = App::Configs::Routes->new;
$routes->load_routes(app);

# Iniciar aplicación
app->start;