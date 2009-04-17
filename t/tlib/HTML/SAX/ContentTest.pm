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
    $self->handler->mock_expect_never('startElement');
    $self->handler->mock_expect_never('endElement');
    my $parser = HTML::SAX->new( handler => $self->handler, rawtext => '' );
    assert_isa('HTML::SAX', $parser);
    $parser->parse;  
};

1;
