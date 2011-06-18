use strict;
use warnings;
use lib 't/lib';
use Test::More;
use Plack::Test;
use HTTP::Request::Common;
BEGIN { use_ok 'TestApp' }

my $app = TestApp->new;

test_psgi $app->to_app, sub {
    my $cb = shift;
    ok my $res = $cb->(GET '/');
    is $res->code, 200;
    like $res->content, qr/hello world!/;
};

done_testing;
