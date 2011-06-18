package Soffritto::View;
use 5.12.0;

my $templates;

sub import {
    my ($class) = @_;
    my $caller = caller;

    for (qw(render template)) {
        no strict 'refs';
        *{"$caller\::$_"} = \&{$_};
    }
}

sub render {
    my ($class, $name, $stash) = @_;
    my $template = $templates->{$name} or die "Template not found: $name";
    my $obj = $template->($class, $stash);
    return _render($obj);
}

sub _render {
    my ($arg) = @_;
    my $ret = '';
    while (my $tag = shift @$arg) {
        ref($tag) and die 'broken structure: ', ref($tag);
        if (my $obj = shift @$arg) {
            if (ref($obj) eq 'HASH') { $obj = [$obj] }
            unless (ref($obj)) { $obj = [$obj] }
            $ret .= "<$tag";
            my $attr = shift @$obj if ref($obj->[0]) eq 'HASH';
            if ($attr) {
                for my $key (keys %$attr) {
                    $ret .= qq/ $key="$attr->{$key}"/;
                }
            }
            if (scalar @$obj) {
                $ret .= '>';
                $ret .= _render($obj);
                $ret .= qq{</$tag>};
            } else {
                $ret .= '/>';
            }
        } else {
            return $tag;
        }
    }
    return $ret;
}

sub template {
    my ($name, $sub) = @_;
    $templates->{$name} = $sub;
}

1;
