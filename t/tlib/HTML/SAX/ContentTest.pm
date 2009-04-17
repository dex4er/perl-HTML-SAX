package HTML::SAX::ContentTest;

use Test::Unit::Lite;
use Moose;
extends 'Test::Unit::TestCase';

with 'HTML::SAX::HandlerTestRole';

use Test::Assert ':all';

use HTML::SAX;

sub test_empty {
    my ($self) = @_;
    $self->handler->mock_expect_never('characters');
    $self->handler->mock_expect_never('start_element');
    $self->handler->mock_expect_never('end_element');
    my $parser = HTML::SAX->new( handler => $self->handler, rawtext => '' );
    assert_isa('HTML::SAX', $parser);
    $parser->parse;
};

1;
