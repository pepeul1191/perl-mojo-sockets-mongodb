package App::Configs::Initializers;
use Mojo::Base -base;
use Cwd;

my $loaded = 0;
my $instance;

sub new {
  my $class = shift;
  
  # Singleton: devolver la misma instancia
  return $instance if $instance;
  
  # Debug para ver directorio actual
  warn "Current directory: " . getcwd() . "\n";
  warn "Looking for .env file...\n";
  
  # Cargar .env solo una vez y de forma segura
  unless ($loaded) {
    $class->_load_env();
    $loaded = 1;
  }
  
  # Debug para ver qué hay en ENV después de cargar
  warn "After loading - JWT_SECRET: " . ($ENV{JWT_SECRET} // 'NOT SET') . "\n";
  
  my $self = bless {
    mongo => {
      host => $ENV{MONGO_HOST} // 'localhost',
      port => $ENV{MONGO_PORT} // 27017,
      db   => $ENV{MONGO_DB}   // 'tickets'
    },
    app => {
      secret => $ENV{APP_SECRET} // 'default_secret_' . time,
      debug  => $ENV{DEBUG} // 0,
      xauthtrigger  => $ENV{JWT_SECRET} // 'default_trigger'
    }
  }, $class;
  
  # Debug para ver qué se cargó en el objeto
  warn "Object xauthtrigger: " . ($self->{app}->{xauthtrigger}) . "\n";
  
  $instance = $self;
  return $self;
}

sub _load_env {
  my $class = shift;
  
  # Verificar si el archivo .env existe
  unless (-f '.env') {
    warn "⚠️ Archivo .env NO encontrado\n";
    return;
  }
  
  warn "✅ Archivo .env encontrado\n";
  
  # Cargar manualmente siempre (método más confiable)
  $class->_load_env_manual();
}

sub _load_env_manual {
  my $class = shift;
  
  open my $fh, '<', '.env' or do {
    warn "⚠️ No se pudo abrir .env: $!\n";
    return;
  };
  
  warn "✅ Leyendo variables de .env:\n";
  
  while (my $line = <$fh>) {
    chomp $line;
    next if $line =~ /^\s*#/;  # Comentarios
    next if $line =~ /^\s*$/;  # Líneas vacías
    
    if ($line =~ /^\s*([^#=]+)=(.*)\s*$/) {
      my ($key, $value) = ($1, $2);
      
      # Limpiar valor
      $value =~ s/^["']|["']$//g;  # Quitar comillas
      $value =~ s/^\s+|\s+$//g;    # Quitar espacios al inicio y final
      
      warn "  $key = $value\n";
      $ENV{$key} = $value;
    }
  }
  
  close $fh;
  warn "✅ Variables de entorno cargadas manualmente\n";
  
  # Verificar que se cargó JWT_SECRET
  warn "JWT_SECRET loaded: " . ($ENV{JWT_SECRET} // 'STILL NOT SET') . "\n";
}

sub get_mongo_config { shift->{mongo} }
sub get_app_config { shift->{app} }

# Métodos convenientes
sub get_mongo_uri {
  my $self = shift;
  my $config = $self->get_mongo_config;
  return "mongodb://$config->{host}:$config->{port}/$config->{db}";
}

1;