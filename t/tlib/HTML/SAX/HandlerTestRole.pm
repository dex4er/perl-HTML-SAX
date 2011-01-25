package HTML::SAX::HandlerTestRole;

use Any::Moose 'Role';

use Test::Assert ':all';
use Test::Mock::Class ':all';
use Exception::Base 'Exception::Fatal';

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

has 'parser' => (
    is      => 'rw',
    isa     => 'HTML::SAX',
    clearer => 'clear_parser',
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

    eval {
        assert_isa('HTML::SAX', $self->parser);
        $self->parser->parse;
        $self->handler->mock_tally;
    };
    my $e = Exception::Fatal->catch;

    $self->clear_handler;
    $self->clear_metamock;

    my $return = $self->$next();

    $e->throw if $e;
};

1;
