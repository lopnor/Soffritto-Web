package Soffritto::Web;
use 5.12.0;
use parent 'Plack::Component';
use Encode;
use Plack::Response;
use Plack::Util;
use Plack::Util::Accessor qw(dsn db view);
use Scalar::Util 'blessed';
use Soffritto::DB;
use Soffritto::Web::Request;

our $VERSION = 0.01;

sub prepare_app {
    my $self = shift;
    if ($self->dsn) {
        my $db = Soffritto::DB->new($self->dsn)
            or die;
        $self->db($db);
    }
    unless ($self->view) {
        my $basename = blessed($self);
        if (my $class = eval {Plack::Util::load_class('View', $basename)}) {
            $self->view($class->new);
        }
    }
    $self->prepare;
}

sub prepare {}

sub call {
    my ($self, $req) = @_;
    unless (blessed($req)) {
        $req = Soffritto::Web::Request->new($req);
    }
    my ($handler, @args) = $self->dispatch($req);
    my $res;
    if (! $handler) {
        $res = $self->error(404);
    } elsif (ref($handler) eq 'CODE') {
        $res = $self->$handler($req, @args);
    } elsif (!ref($handler)) {
        Plack::Util::load_class($handler);
        $res = $handler->new(
            db => $self->db,
            view => $self->view,
        )->call($req);
    } elsif (blessed($handler) eq 'Plack::Response') {
        $res = $handler;
    } else {
        $res = $self->error(500);
    }
    if (blessed($res) eq 'Plack::Response') {
        return $res->finalize;
    } else {
        return $res;
    }
}

sub dispatch { ... }

sub error {
    my ($self, $code) = @_;
    my $body = HTTP::Status::status_message($code);
    return Plack::Response->new(
        $code,
        [ 
            'Content-Type' => 'text/plain',
            'Content-Length' => Plack::Util::content_length([$body]),
        ],
        [$body]
    );
}

sub render {
    my ($self, @args) = @_;
    my $body = $self->view->render(@args);
    $self->respond(Encode::encode_utf8($body));
}

sub respond {
    my ($self, $body, $ct) = @_;
    $ct ||= 'text/html; charset=utf8';
    return Plack::Response->new(
        200,
        [
            'Content-Type' => $ct,
            'Content-Length' => Plack::Util::content_length([$body]),
        ],
        [$body]
    );
}

1;
__END__

=head1 NAME

Soffritto::Web - simple web framework for Soffritto Inc.

=head1 SYNOPSIS

  use Soffritto::Web;

=head1 DESCRIPTION

Soffritto::Web is simple web framework for Soffritto Inc.

=head1 AUTHOR

Nobuo Danjou E<lt>nobuo.danjou@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
