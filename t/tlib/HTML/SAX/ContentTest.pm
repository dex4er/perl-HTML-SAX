package HTML::SAX::ContentTest;

use Test::Unit::Lite;
use Any::Moose;
use if Any::Moose::mouse_is_preferred, 'MouseX::Foreign';
extends 'Test::Unit::TestCase';

with 'HTML::SAX::HandlerTestRole';

use Test::Assert ':all';

use HTML::SAX;

sub test_empty {
    my ($self) = @_;
    $self->handler->mock_expect_never('characters');
    $self->handler->mock_expect_never('start_element');
    $self->handler->mock_expect_never('end_element');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '',
    ) );
};

sub test_simpledata {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ['content']);
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => 'content',
    ) );
};

sub test_preserving_white_space {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => [" content\t\r\n "]);
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => " content\t\r\n ",
    ) );
};

1;
