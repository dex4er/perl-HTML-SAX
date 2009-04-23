package HTML::SAX::ReaderMalformedTest;

use Test::Unit::Lite;
use Moose;
extends 'Test::Unit::TestCase';

with 'HTML::SAX::HandlerTestRole';

use Test::Assert ':all';

use HTML::SAX;

sub test_empty_close {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ['</>']);
    $self->handler->mock_expect_never('end_element');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '</>',
    ) );
};

sub test_open_element_malformed_close {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ['content<tag attribute=\'value\'/morecontent']);
    $self->handler->mock_expect_never('start_element');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => 'content<tag attribute=\'value\'/morecontent',
    ) );
};

sub test_open_element_malformed_close2 {
    my ($self) = @_;
    $self->handler->mock_expect_once('start_element', args => ['tag', 'attribute' => '\'value\'/morecontent']);
    $self->handler->mock_expect_once('characters', args => ['content']);
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => 'content<tag attribute=\'value\'/morecontent>',
    ) );
};

sub test_element_nested_single_quote {
    my ($self) = @_;
    $self->handler->mock_expect_once('start_element', args => ['tag', 'attribute' => '\'']);
    $self->handler->mock_expect_never('characters');
    $self->handler->mock_expect_never('end_element');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<tag attribute=\'\'\'>',
    ) );
};

sub test_element_nested_double_quote {
    my ($self) = @_;
    $self->handler->mock_expect_once('start_element', args => ['tag', 'attribute' => '"']);
    $self->handler->mock_expect_never('characters');
    $self->handler->mock_expect_never('end_element');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<tag attribute=""">',
    ) );
};

sub test_element_malformed_attribute {
    my ($self) = @_;
    $self->handler->mock_expect_once('start_element', args => ['tag', 'attribute' => '"test"extra']);
    $self->handler->mock_expect_never('characters');
    $self->handler->mock_expect_never('end_element');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<tag attribute="test"extra>',
    ) );
};

sub test_not_an_end_element_with_space {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ['< /tag>']);
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '< /tag>',
    ) );
};

1;
