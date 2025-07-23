package App::Controllers::Tag;
use Mojo::Base 'Mojolicious::Controller';
use App::Models::Tag;

sub list_all {
  my $c = shift;
  my $tag_model = App::Models::Tag->new;
 
  # Para debugging - temporal
    $c->app->log->debug("Listando todos los tags");
    
  eval {
    my $tag_model = App::Models::Tag->new();
    my $tags = $tag_model->list_all();
    
    $c->render(json => {
        status => 'success',
        data => $tags,
        count => scalar(@$tags)
    });
  };
  
  if ($@) {
    $c->app->log->error("Error listando tags: $@");
    $c->render(json => {
        status => 'error',
        message => 'Error al obtener tags'
    }, status => 500);
  }
}

1;