use strict;
use warnings;
use Test::More;
use Plack::Test;
use HTTP::Request::Common;

BEGIN { use_ok 'Soffritto::Web'; }

{
    my $app = Soffritto::Web->new;
    test_psgi $app, sub {
        my $cb = shift;
        ok my $res = $cb->(GET '/');
        is $res->code, 500;
    };
}
    
{
    {
        package TestApp;
        use parent 'Soffritto::Web';

        sub dispatch {
            my ($self, $req) = @_;
            if ($req->path_info =~ m{^/hello/(?<name>.+)$}) {'hello', $+{name}}
            elsif ($req->path_info =~ m{^/goodbye/(?<name>.+)$}) {
                my $name = $+{name};
                sub { shift->respond("goodbye, $name!") }
            }
        }

        sub hello {
            my ($self, $req, $name) = @_;
            $self->respond("hello, $name!", 'text/plain');
        }
    }
    my $app = TestApp->new;
    test_psgi $app, sub {
        my $cb = shift;
        {
            ok my $res = $cb->(GET '/hello/world');
            is $res->code, 200;
            is $res->content_type, 'text/plain';
            is $res->content, 'hello, world!';
        }
        {
            ok my $res = $cb->(GET '/goodbye/world');
            is $res->code, 200;
            is $res->content_type, 'text/html';
            is $res->content, 'goodbye, world!';
        }
        {
            ok my $res = $cb->(GET '/');
            is $res->code, 404;
            is $res->content, 'Not Found';
        }
    }
}

done_testing;

