package Soffritto::Web::View;
use 5.12.0;

sub new {
    my ($class, %args) = @_;
    bless \%args, $class;
}

1;
