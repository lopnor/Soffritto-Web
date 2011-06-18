package TestApp::View;
use 5.12.0;
use Soffritto::View;

template 'hello' => sub {
    my ($class, $stash) = @_;
    my $str = "hello $stash->{name}!";
    [
        html => [
            head => [ title => $str, ],
            body => [
                h1 => $str,
                p => [
                    { class => 'content' },
                    'brabrabra',
                ]
            ]
        ]
    ];
};

1;
