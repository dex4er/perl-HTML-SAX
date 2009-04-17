package HTML::SAX::HandlerTestRole;

use Moose::Role;

use Test::Assert ':all';
use Test::Mock::Class ':all';

use HTML::SAX;

has 'metamock' => (
    is      => 'rw',
    isa     => 'Test::Mock::Class',
    clearer => 'clear_metamock'
);

has 'handler' => (
    is      => 'rw',
    does    => 'HTML::SAX::Handler',
    clearer => 'clear_handler'
);

around 'set_up' => sub {
    my ($next, $self) = @_;

    $self->metamock(
        Test::Mock::Class->create_mock_anon_class(
            roles => [ 'HTML::SAX::Handler' ],
        )
    );
    $self->handler( $self->metamock->new_object );

    return $self->$next();
};

around 'tear_down' => sub {
    my ($next, $self) = @_;

    $self->handler->mock_tally;

    $self->clear_handler;
    $self->clear_metamock;

    return $self->$next();
};

1;
