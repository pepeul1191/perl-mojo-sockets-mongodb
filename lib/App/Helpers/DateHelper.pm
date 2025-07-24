# En App::Helpers::DateHelper.pm
package App::Helpers::DateHelper;
use Mojo::Base -base;
use POSIX qw(strftime);

sub new {
  my $class = shift;
  my $self = bless {}, $class;
  return $self;
}

sub timestamp_to_iso {
  my ($self, $timestamp) = @_;
  $timestamp //= time;
  return strftime("%Y-%m-%dT%H:%M:%SZ", gmtime($timestamp));
}

sub iso_to_timestamp {
  my ($self, $iso_string) = @_;
  
  if ($iso_string =~ /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})Z$/) {
    use Time::Local;
    return timegm($6, $5, $4, $3, $2 - 1, $1);
  }
  
  return time;
}

1;