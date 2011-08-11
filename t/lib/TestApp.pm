package TestApp;
use 5.12.0;
use parent 'Soffritto::Web';

sub dispatch { \&hello }

sub hello {
    my ($self, $req) = @_;
    $self->render('hello', {name => 'world'});
}

1;
