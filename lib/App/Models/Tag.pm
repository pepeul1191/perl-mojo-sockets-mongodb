# lib/App/Models/User.pm
package App::Models::Tag;
use Mojo::Base -base;
use App::Configs::Database;

sub new {
  my $class = shift;
  my $self = bless {}, $class;
  $self->{db} = App::Configs::Database->new->get_db;
  $self->{collection} = $self->{db}->get_collection('tags');
  return $self;
}

sub list_all {
  my ($self) = @_;
  
  my @tags;
  my $cursor = $self->{collection}->find();
  
  while (my $tag = $cursor->next) {
    push @tags, $tag;
  }
  
  return \@tags;
}

1;