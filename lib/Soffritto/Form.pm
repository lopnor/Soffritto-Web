package Soffritto::Form;
use 5.12.3;
use utf8;
use HTML::Shakan;
use Digest::SHA1 'sha1_hex';

sub import {
    my $package = caller();
    no strict 'refs';
    for my $method (qw(
        EmailField URLField PasswordField TextField ChoiceField
    )) {
        *{ $package . '::' . $method } = \&{ 'HTML::Shakan::'.$method };
    }
    *{ $package . '::HiddenField' } = \&HiddenField;

    *HTML::Shakan::delete_nonce = \&delete_nonce;
}

sub HiddenField {
    return HTML::Shakan::Field::Input->new(type => 'hidden', @_);
}

sub form {
    my ($class, $req, $fields) = @_;
    my $session = $req->session;
    my $nonce = $req->param('nonce') || $class->set_nonce($session);
    my $form = HTML::Shakan->new(
        request => $req,
        fields => [
            @$fields,
            HiddenField(name => 'nonce')
        ],
        custom_validation => sub {
            my $form = shift;
            if ($form->submitted) {
                $class->check_nonce($form, $session)
                    or $form->set_error('nonce' => 'regex');
            }
        }
    );
    $form->fillin_params->{nonce} = $nonce;
    $form->load_function_message('ja');
    return $form;
}

sub check_nonce {
    my ($class, $form, $session) = @_;
    my $nonces = $session->get('nonce') || {};
    if ($nonces->{$form->param('nonce')}) {
        return 1;
    }
    return;
}

sub set_nonce {
    my ($class, $session) = @_;
    my $nonce = sha1_hex({}, $session->get('user'), time);
    my $existing = $session->get('nonce') || {};
    $session->set('nonce' => {%$existing, $nonce => 1});
    return $nonce;
}

sub delete_nonce {
    my ($self) = @_;
    my $session = $self->request->session;
    my $nonce = $self->param('nonce');
    my $existing = $session->get('nonce') or return;
    delete $existing->{$nonce};
    $session->set('nonce' => $existing);
}

1;
