package HTML::SAX::ReaderElementMarkupTest;

use Test::Unit::Lite;
use Moose;
extends 'Test::Unit::TestCase';

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
    $self->parser->parse;
};

1;__END__
sub test_element_nestedDouble_quote {
    my ($self) = @_;
    $self->handler->mock_expect_once('start_element', args => ('tag', args => ('attribute' => '"')));
    $self->handler->mock_expect_never('characters');
    $self->handler->mock_expect_never('end_element');
    $self->parser->parse('<tag attribute=\'"\'>');
};

sub testAttributes {
    my ($self) = @_;
    $self->handler->mock_expect_once(
            'start_element',
            args => ('tag', args => ("a" => "A", "b" => "B", "c" => "C")));
    $self->handler->mock_expect_never('characters');
    $self->parser->parse('<tag a="A" b=\'B\' c = "C">');
};

sub test_emptyAttributes {
    my ($self) = @_;
    $self->handler->mock_expect_once(
            'start_element',
            args => ('tag', args => ("a" => NULL, "b" => NULL, "c" => NULL)));
    $self->handler->mock_expect_never('characters');
    $self->parser->parse('<tag a b c>');
};

sub testNastyAttributes {
    my ($self) = @_;
    $self->handler->mock_expect_once(
            'start_element',
            args => ('tag', args => ("a" => "&%$'?<>", "b" => "\r\n\t\"", "c" => "")));
    $self->handler->mock_expect_never('characters');
    $self->parser->parse("<tag a=\"&%$'?<>\" b='\r\n\t\"' c = ''>");
};

sub testAttributesPadding {
    my ($self) = @_;
    $self->handler->mock_expect_once(
            'start_element',
            args => ('tag', args => ("a" => "A", "b" => "B", "c" => "C")));
    $self->handler->mock_expect_never('characters');
    $self->parser->parse("<tag\ta=\"A\"\rb='B'\nc = \"C\"\n>");
};

sub testTruncatedOpen {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ('content<'));
    $self->handler->mock_expect_never('start_element');
    $self->parser->parse('content<');
};

sub testTruncated_emptyClose {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ('content</'));
    $self->handler->mock_expect_never('end_element');
    $self->parser->parse('content</');
};

sub testTruncatedClose {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ('content</a'));
    $self->parser->parse('content</a');
    $self->handler->mock_expect_never('end_element');
};

sub testTruncatedOpen_elementChar {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ('content<a'));
    $self->handler->mock_expect_never('start_element');
    $self->parser->parse('content<a');
};

sub testTruncatedOpen_element {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ('content<tag'));
    $self->handler->mock_expect_never('start_element');
    $self->parser->parse('content<tag');
};

sub testTruncatedOpen_elementSpace {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ('content<tag '));
    $self->handler->mock_expect_never('start_element');
    $self->parser->parse('content<tag ');
};

sub testTruncatedOpen_elementMinimizedAttribute {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ('content<tag attribute'));
    $self->handler->mock_expect_never('start_element');
    $self->parser->parse('content<tag attribute');
};

sub testTruncatedOpen_elementMinimizedAttributeSpace {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ('content<tag attribute '));
    $self->handler->mock_expect_never('start_element');
    $self->parser->parse('content<tag attribute ');
};

sub testTruncatedOpen_elementAttribute {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ('content<tag attribute='));
    $self->handler->mock_expect_never('start_element');
    $self->parser->parse('content<tag attribute=');
};

sub testTruncatedOpen_elementAttributeSpace {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ('content<tag attribute= '));
    $self->handler->mock_expect_never('start_element');
    $self->parser->parse('content<tag attribute= ');
};

sub testTruncatedOpen_elementAttributeNo_quote {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ('content<tag attribute=value'));
    $self->handler->mock_expect_never('start_element');
    $self->parser->parse('content<tag attribute=value');
};

sub testTruncatedOpen_elementAttributeDouble_quote {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ('content<tag attribute="'));
    $self->handler->mock_expect_never('start_element');
    $self->parser->parse('content<tag attribute="');
};

sub testTruncatedOpen_elementAttributeDouble_quoteNoClose {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ('content<tag attribute="value'));
    $self->handler->mock_expect_never('start_element');
    $self->parser->parse('content<tag attribute="value');
};

sub testTruncatedOpen_elementAttributeDouble_quoteValue {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ('content<tag attribute="value"'));
    $self->handler->mock_expect_never('start_element');
    $self->parser->parse('content<tag attribute="value"');
};

sub testTruncatedOpen_elementAttribute_single_quote {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ('content<tag attribute=\''));
    $self->handler->mock_expect_never('start_element');
    $self->parser->parse('content<tag attribute=\'');
};

sub testTruncatedOpen_elementAttribute_single_quoteNoClose {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ('content<tag attribute=\'value'));
    $self->handler->mock_expect_never('start_element');
    $self->parser->parse('content<tag attribute=\'value');
};

sub testTruncatedOpen_elementAttribute_single_quoteValue {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ('content<tag attribute=\'value\''));
    $self->handler->mock_expect_never('start_element');
    $self->parser->parse('content<tag attribute=\'value\'');
};

sub testTruncatedOpen_elementClose {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ('content<tag attribute=\'value\'/'));
    $self->handler->mock_expect_never('start_element');
    $self->parser->parse('content<tag attribute=\'value\'/');
};


1;
