package HTML::SAX::HandlerTestRole;

use Moose::Role;

use Test::Assert ':all';
use Test::Mock::Class ':all';

use HTML::SAX;

has 'metamock' => ( is => 'rw', clearer => 'clear_metamock' );
has 'handler'  => ( is => 'rw', clearer => 'clear_handler' );

# Sources of test case material:
#
# http://www.w3.org/XML/Test/
# http://www.hixie.ch/tests/adhoc/html/parsing/
# http://www.w3.org/MarkUp/SGML/sgml-lex/sgml-lex

around 'set_up' => sub {
    my ($next, $self) = @_;

    $self->metamock( Test::Mock::Class->create_mock_anon_class );
    $self->metamock->add_role('HTML::SAX::Handler');
    $self->handler( $self->metamock->new_object );

    return $self->$next();
};

around 'tear_down' => sub {
    my ($next, $self) = @_;

    $self->handler->tally;

    $self->clear_handler;
    $self->clear_metamock;

    return $self->$next();
};

1;
