package HTML::SAX::ReaderElementMarkupTest;

use Test::Unit::Lite;

use Any::Moose;

use base 'Test::Unit::TestCase';
with 'HTML::SAX::HandlerTestRole';

use Test::Assert ':all';

use HTML::SAX;

sub test_preserving_white_space {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => [" content\t\r\n "]);
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => " content\t\r\n ",
    ) );
};

sub test_empty_element {
    my ($self) = @_;
    $self->handler->mock_expect_once('start_element', args => ['tag']);
    $self->handler->mock_expect_once('end_element', args => ['tag']);
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<tag></tag>',
    ) );
};

sub test_element_with_content {
    my ($self) = @_;
    $self->handler->mock_expect_once('start_element', args => ['tag']);
    $self->handler->mock_expect_once('characters', args => ['content']);
    $self->handler->mock_expect_once('end_element', args => ['tag']);
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<tag>content</tag>',
    ) );
};

sub test_start_element_with_pre_content {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ['content']);
    $self->handler->mock_expect_once('start_element', args => ['br']);
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => 'content<br>',
    ) );
};

sub test_start_element_with_post_content {
    my ($self) = @_;
    $self->handler->mock_expect_once('start_element', args => ['br']);
    $self->handler->mock_expect_once('characters', args => ['content']);
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<br>content',
    ) );
};

sub test_mismatched_elements {
    my ($self) = @_;
    $self->handler->mock_expect_at(0, 'start_element', args => ['b']);
    $self->handler->mock_expect_at(1, 'start_element', args => ['i']);
    $self->handler->mock_expect_at(0, 'end_element', args => ['b']);
    $self->handler->mock_expect_at(1, 'end_element', args => ['i']);
    $self->handler->mock_expect_call_count('start_element', 2);
    $self->handler->mock_expect_call_count('end_element', 2);
    $self->handler->mock_expect_once('characters', args => ['content']);
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<b><i>content</b></i>',
    ) );
};

sub test_end_element {
    my ($self) = @_;
    $self->handler->mock_expect_once('end_element', args => ['tag']);
    $self->handler->mock_expect_never('characters');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '</tag>',
    ) );
};

sub test_end_element_with_pre_content {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ['a']);
    $self->handler->mock_expect_once('end_element', args => ['tag']);
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => 'a</tag>',
    ) );
};

sub test_end_element_with_post_content {
    my ($self) = @_;
    $self->handler->mock_expect_once('end_element', args => ['tag']);
    $self->handler->mock_expect_once('characters', args => ['a']);
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '</tag>a',
    ) );
};

sub test_end_element_with_space {
    my ($self) = @_;
    $self->handler->mock_expect_once('end_element', args => ['tag']);
    $self->handler->mock_expect_never('characters');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '</tag >',
    ) );
};

sub test_empty_element_self_close {
    my ($self) = @_;
    $self->handler->mock_expect_once('empty_element', args => ['br']);
    $self->handler->mock_expect_never('start_element');
    $self->handler->mock_expect_never('end_element');
    $self->handler->mock_expect_never('characters');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<br/>',
    ) );
};

sub test_empty_element_self_close_with_space {
    my ($self) = @_;
    $self->handler->mock_expect_once('empty_element', args => ['br']);
    $self->handler->mock_expect_never('start_element');
    $self->handler->mock_expect_never('end_element');
    $self->handler->mock_expect_never('characters');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<br/ >',
    ) );
};

sub test_element_nested_single_quote {
    my ($self) = @_;
    $self->handler->mock_expect_once('start_element', args => ['tag', 'attribute', "'"] );
    $self->handler->mock_expect_never('characters');
    $self->handler->mock_expect_never('end_element');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<tag attribute="\'">',
    ) );
};

sub test_element_nested_double_quote {
    my ($self) = @_;
    $self->handler->mock_expect_once('start_element', args => ['tag', 'attribute', '"'] );
    $self->handler->mock_expect_never('characters');
    $self->handler->mock_expect_never('end_element');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<tag attribute=\'"\'>',
    ) );
};

sub test_attributes {
    my ($self) = @_;
    $self->handler->mock_expect_once(
        'start_element',
        args => ['tag', 'a' => 'A', 'b' => 'B', 'c' => 'C'],
    );
    $self->handler->mock_expect_never('characters');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<tag a="A" b=\'B\' c = "C">',
    ) );
};

sub test_empty_attributes {
    my ($self) = @_;
    $self->handler->mock_expect_once(
        'start_element',
        args => ['tag', 'a' => undef, 'b' => undef, 'c' => undef],
    );
    $self->handler->mock_expect_never('characters');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<tag a b c>',
    ) );
};

sub test_nasty_attributes {
    my ($self) = @_;
    $self->handler->mock_expect_once(
        'start_element',
        args => ['tag', 'a' => "&%$'?<>", 'b' => "\r\n\t\"", 'c' => ''],
    );
    $self->handler->mock_expect_never('characters');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => "<tag a=\"&%$'?<>\" b='\r\n\t\"' c = ''>",
    ) );
};

sub test_attributes_padding {
    my ($self) = @_;
    $self->handler->mock_expect_once(
            'start_element',
            args => ['tag', 'a' => 'A', 'b' => 'B', 'c' => 'C'],
    );
    $self->handler->mock_expect_never('characters');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => "<tag\ta=\"A\"\rb='B'\nc = \"C\"\n>",
    ) );
};

sub test_truncated_open {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ['content<']);
    $self->handler->mock_expect_never('start_element');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => 'content<',
    ) );
};

sub test_truncated_empty_close {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ['content</']);
    $self->handler->mock_expect_never('end_element');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => 'content</',
    ) );
};

sub test_truncated_close {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ['content</a']);
    $self->handler->mock_expect_never('end_element');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => 'content</a',
    ) );
};

sub test_truncated_open_element_char {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ['content<a']);
    $self->handler->mock_expect_never('start_element');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => 'content<a',
    ) );
};

sub test_truncated_open_element {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ['content<tag']);
    $self->handler->mock_expect_never('start_element');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => 'content<tag',
    ) );
};

sub test_truncated_open_element_space {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ['content<tag ']);
    $self->handler->mock_expect_never('start_element');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => 'content<tag ',
    ) );
};

sub test_truncated_open_element_minimized_attribute {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ['content<tag attribute']);
    $self->handler->mock_expect_never('start_element');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => 'content<tag attribute',
    ) );
};

sub test_truncated_open_element_minimized_attribute_space {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ['content<tag attribute ']);
    $self->handler->mock_expect_never('start_element');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => 'content<tag attribute ',
    ) );
};

sub test_truncated_open_element_attribute {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ['content<tag attribute=']);
    $self->handler->mock_expect_never('start_element');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => 'content<tag attribute=',
    ) );
};

sub test_truncated_open_element_attribute_space {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ['content<tag attribute= ']);
    $self->handler->mock_expect_never('start_element');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => 'content<tag attribute= ',
    ) );
};

sub test_truncated_open_element_attribute_no_quote {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ['content<tag attribute=value']);
    $self->handler->mock_expect_never('start_element');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => 'content<tag attribute=value',
    ) );
};

sub test_truncated_open_element_attribute_double_quote {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ['content<tag attribute="']);
    $self->handler->mock_expect_never('start_element');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => 'content<tag attribute="',
    ) );
};

sub test_truncated_open_element_attribute_double_quote_no_close {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ['content<tag attribute="value']);
    $self->handler->mock_expect_never('start_element');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => 'content<tag attribute="value',
    ) );
};

sub test_truncated_open_element_attribute_double_quote_value {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ['content<tag attribute="value"']);
    $self->handler->mock_expect_never('start_element');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => 'content<tag attribute="value"',
    ) );
};

sub test_truncated_open_element_attribute_single_quote {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ['content<tag attribute=\'']);
    $self->handler->mock_expect_never('start_element');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => 'content<tag attribute=\'',
    ) );
};

sub test_truncated_open_element_attribute_single_quote_no_close {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ['content<tag attribute=\'value']);
    $self->handler->mock_expect_never('start_element');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => 'content<tag attribute=\'value',
    ) );
};

sub test_truncated_open_element_attribute_single_quote_value {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ['content<tag attribute=\'value\'']);
    $self->handler->mock_expect_never('start_element');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => 'content<tag attribute=\'value\'',
    ) );
};

sub test_truncated_open_element_close {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ['content<tag attribute=\'value\'/']);
    $self->handler->mock_expect_never('start_element');
    $self->parser( HTML::SAX->new(
        handler => $self->handler,
        rawtext => 'content<tag attribute=\'value\'/',
    ) );
};

1;
