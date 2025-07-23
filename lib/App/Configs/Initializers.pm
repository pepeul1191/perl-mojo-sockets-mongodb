package App::Configs::Initializers;
use Mojo::Base -base;

my $loaded = 0;
my $instance;

sub new {
    my $class = shift;
    
    # Singleton: devolver la misma instancia
    return $instance if $instance;
    
    # Cargar .env solo una vez y de forma segura
    unless ($loaded) {
        $class->_load_env();
        $loaded = 1;
    }
    
    my $self = bless {
        mongo => {
            host => $ENV{MONGO_HOST} // 'localhost',
            port => $ENV{MONGO_PORT} // 27017,
            db   => $ENV{MONGO_DB}   // 'tickets'
        },
        app => {
            secret => $ENV{APP_SECRET} // 'default_secret_' . time,
            debug  => $ENV{DEBUG} // 0
        }
    }, $class;
    
    $instance = $self;
    return $self;
}

sub _load_env {
    my $class = shift;
    
    # Verificar si el archivo .env existe
    return unless -f '.env';
    
    # Intentar cargar con Dotenv
    eval {
        require Dotenv;
        Dotenv::load();
        warn "✓ Variables de entorno cargadas desde .env\n" if $ENV{DEBUG};
    };
    
    # Si falla Dotenv, cargar manualmente
    if ($@) {
        warn "⚠️ Dotenv falló: $@ - intentando carga manual\n" if $ENV{DEBUG};
        $class->_load_env_manual();
    }
}

sub _load_env_manual {
    my $class = shift;
    
    open my $fh, '<', '.env' or return;
    
    while (my $line = <$fh>) {
        chomp $line;
        next if $line =~ /^\s*#/;  # Comentarios
        next if $line =~ /^\s*$/;  # Líneas vacías
        
        if ($line =~ /^\s*([^#=]+)=(.*)\s*$/) {
            my ($key, $value) = ($1, $2);
            
            # Limpiar valor
            $value =~ s/^["']|["']$//g;  # Quitar comillas
            $value =~ s/^://g;           # Quitar : al inicio si existe
            
            $ENV{$key} = $value;
        }
    }
    
    close $fh;
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