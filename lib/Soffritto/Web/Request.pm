package Soffritto::Web::Request;
use 5.12.0;
use parent 'Plack::Request';
use Plack::Session;
use HTTP::Status;
use Encode ();
use URI::WithBase;

sub uri_for {
    my ($self, $path, $args) = @_;
    my $uri = URI::WithBase->new($path, $self->base);
    if ($args) {
        $uri->query_form(@$args);
    };
    return $uri->abs;
}

sub session { Plack::Session->new(shift->env) }

sub redirect_to {
    my ($self, @args) = @_;
    my $uri = $self->uri_for(@args);
    my $res = $self->new_response;
    $res->redirect($uri);
    return $res;
}

1;
