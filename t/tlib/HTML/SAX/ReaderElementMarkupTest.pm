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
    my $parser = HTML::SAX->new(
        handler => $self->handler,
        rawtext => " content\t\r\n ",
    );
    assert_isa('HTML::SAX', $parser);
    $parser->parse;
};

sub test_empty_element {
    my ($self) = @_;
    $self->handler->mock_expect_once('start_element', args => ['tag']);
    $self->handler->mock_expect_once('end_element', args => ['tag']);
    my $parser = HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<tag></tag>',
    );
    assert_isa('HTML::SAX', $parser);
    $parser->parse;
};

sub test_element_with_content {
    my ($self) = @_;
    $self->handler->mock_expect_once('start_element', args => ['tag']);
    $self->handler->mock_expect_once('characters', args => ['content']);
    $self->handler->mock_expect_once('end_element', args => ['tag']);
    my $parser = HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<tag>content</tag>',
    );
    assert_isa('HTML::SAX', $parser);
    $parser->parse;
};

sub test_start_element_with_pre_content {
    my ($self) = @_;
    $self->handler->mock_expect_once('characters', args => ['content']);
    $self->handler->mock_expect_once('start_element', args => ['br']);
    my $parser = HTML::SAX->new(
        handler => $self->handler,
        rawtext => 'content<br>',
    );
    assert_isa('HTML::SAX', $parser);
    $parser->parse;
};

sub test_start_element_with_post_content {
    my ($self) = @_;
    $self->handler->mock_expect_once('start_element', args => ['br']);
    $self->handler->mock_expect_once('characters', args => ['content']);
    my $parser = HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<br>content',
    );
    assert_isa('HTML::SAX', $parser);
    $parser->parse;
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
    my $parser = HTML::SAX->new(
        handler => $self->handler,
        rawtext => '<b><i>content</b></i>',
    );
    assert_isa('HTML::SAX', $parser);
    $parser->parse;
#    use YAML;die Dump $self->handler;
};

1;__END__
sub testend_element {
    $self->handler->mock_expect_once('end_element', args => ('tag'));
    $self->handler->mock_expect_never('characters');
    $self->parser->parse('</tag>');
};

sub testend_element_withPre_content {
    $self->handler->mock_expect_once('characters', args => ('a'));
    $self->handler->mock_expect_once('end_element', args => ('tag'));
    $self->parser->parse('a</tag>');
};

sub testend_element_with_post_content {
    $self->handler->mock_expect_once('end_element', args => ('tag'));
    $self->handler->mock_expect_once('characters', args => ('a'));
    $self->parser->parse('</tag>a');
};

sub testend_element_withSpace {
    $self->handler->mock_expect_once('end_element', args => ('tag'));
    $self->handler->mock_expect_never('characters');
    $self->parser->parse('</tag >');
};

sub testEmptyElementSelfClose {
    $self->handler->mock_expect_once('emptyElement', args => ['br']);
    $self->handler->mock_expect_never('start_element');
    $self->handler->mock_expect_never('end_element');
    $self->handler->mock_expect_never('characters');
    $self->parser->parse('<br/>');
};

sub testEmptyElementSelfClose_withSpace {
    $self->handler->mock_expect_once('emptyElement', args => ['br']);
    $self->handler->mock_expect_never('start_element');
    $self->handler->mock_expect_never('end_element');
    $self->handler->mock_expect_never('characters');
    $self->parser->parse('<br />');
};

sub testElementNestedSingleQuote {
    $self->handler->mock_expect_once('start_element', args => ('tag', args => ('attribute' => '\'')));
    $self->handler->mock_expect_never('characters');
    $self->handler->mock_expect_never('end_element');
    $self->parser->parse('<tag attribute="\'">');
};

sub testElementNestedDoubleQuote {
    $self->handler->mock_expect_once('start_element', args => ('tag', args => ('attribute' => '"')));
    $self->handler->mock_expect_never('characters');
    $self->handler->mock_expect_never('end_element');
    $self->parser->parse('<tag attribute=\'"\'>');
};

sub testAttributes {
    $self->handler->mock_expect_once(
            'start_element',
            args => ('tag', args => ("a" => "A", "b" => "B", "c" => "C")));
    $self->handler->mock_expect_never('characters');
    $self->parser->parse('<tag a="A" b=\'B\' c = "C">');
};

sub testEmptyAttributes {
    $self->handler->mock_expect_once(
            'start_element',
            args => ('tag', args => ("a" => NULL, "b" => NULL, "c" => NULL)));
    $self->handler->mock_expect_never('characters');
    $self->parser->parse('<tag a b c>');
};

sub testNastyAttributes {
    $self->handler->mock_expect_once(
            'start_element',
            args => ('tag', args => ("a" => "&%$'?<>", "b" => "\r\n\t\"", "c" => "")));
    $self->handler->mock_expect_never('characters');
    $self->parser->parse("<tag a=\"&%$'?<>\" b='\r\n\t\"' c = ''>");
};

sub testAttributesPadding {
    $self->handler->mock_expect_once(
            'start_element',
            args => ('tag', args => ("a" => "A", "b" => "B", "c" => "C")));
    $self->handler->mock_expect_never('characters');
    $self->parser->parse("<tag\ta=\"A\"\rb='B'\nc = \"C\"\n>");
};

sub testTruncatedOpen {
    $self->handler->mock_expect_once('characters', args => ('content<'));
    $self->handler->mock_expect_never('start_element');
    $self->parser->parse('content<');
};

sub testTruncatedEmptyClose {
    $self->handler->mock_expect_once('characters', args => ('content</'));
    $self->handler->mock_expect_never('end_element');
    $self->parser->parse('content</');
};

sub testTruncatedClose {
    $self->handler->mock_expect_once('characters', args => ('content</a'));
    $self->parser->parse('content</a');
    $self->handler->mock_expect_never('end_element');
};

sub testTruncatedOpenElementChar {
    $self->handler->mock_expect_once('characters', args => ('content<a'));
    $self->handler->mock_expect_never('start_element');
    $self->parser->parse('content<a');
};

sub testTruncatedOpenElement {
    $self->handler->mock_expect_once('characters', args => ('content<tag'));
    $self->handler->mock_expect_never('start_element');
    $self->parser->parse('content<tag');
};

sub testTruncatedOpenElementSpace {
    $self->handler->mock_expect_once('characters', args => ('content<tag '));
    $self->handler->mock_expect_never('start_element');
    $self->parser->parse('content<tag ');
};

sub testTruncatedOpenElementMinimizedAttribute {
    $self->handler->mock_expect_once('characters', args => ('content<tag attribute'));
    $self->handler->mock_expect_never('start_element');
    $self->parser->parse('content<tag attribute');
};

sub testTruncatedOpenElementMinimizedAttributeSpace {
    $self->handler->mock_expect_once('characters', args => ('content<tag attribute '));
    $self->handler->mock_expect_never('start_element');
    $self->parser->parse('content<tag attribute ');
};

sub testTruncatedOpenElementAttribute {
    $self->handler->mock_expect_once('characters', args => ('content<tag attribute='));
    $self->handler->mock_expect_never('start_element');
    $self->parser->parse('content<tag attribute=');
};

sub testTruncatedOpenElementAttributeSpace {
    $self->handler->mock_expect_once('characters', args => ('content<tag attribute= '));
    $self->handler->mock_expect_never('start_element');
    $self->parser->parse('content<tag attribute= ');
};

sub testTruncatedOpenElementAttributeNoQuote {
    $self->handler->mock_expect_once('characters', args => ('content<tag attribute=value'));
    $self->handler->mock_expect_never('start_element');
    $self->parser->parse('content<tag attribute=value');
};

sub testTruncatedOpenElementAttributeDoubleQuote {
    $self->handler->mock_expect_once('characters', args => ('content<tag attribute="'));
    $self->handler->mock_expect_never('start_element');
    $self->parser->parse('content<tag attribute="');
};

sub testTruncatedOpenElementAttributeDoubleQuoteNoClose {
    $self->handler->mock_expect_once('characters', args => ('content<tag attribute="value'));
    $self->handler->mock_expect_never('start_element');
    $self->parser->parse('content<tag attribute="value');
};

sub testTruncatedOpenElementAttributeDoubleQuoteValue {
    $self->handler->mock_expect_once('characters', args => ('content<tag attribute="value"'));
    $self->handler->mock_expect_never('start_element');
    $self->parser->parse('content<tag attribute="value"');
};

sub testTruncatedOpenElementAttributeSingleQuote {
    $self->handler->mock_expect_once('characters', args => ('content<tag attribute=\''));
    $self->handler->mock_expect_never('start_element');
    $self->parser->parse('content<tag attribute=\'');
};

sub testTruncatedOpenElementAttributeSingleQuoteNoClose {
    $self->handler->mock_expect_once('characters', args => ('content<tag attribute=\'value'));
    $self->handler->mock_expect_never('start_element');
    $self->parser->parse('content<tag attribute=\'value');
};

sub testTruncatedOpenElementAttributeSingleQuoteValue {
    $self->handler->mock_expect_once('characters', args => ('content<tag attribute=\'value\''));
    $self->handler->mock_expect_never('start_element');
    $self->parser->parse('content<tag attribute=\'value\'');
};

sub testTruncatedOpenElementClose {
    $self->handler->mock_expect_once('characters', args => ('content<tag attribute=\'value\'/'));
    $self->handler->mock_expect_never('start_element');
    $self->parser->parse('content<tag attribute=\'value\'/');
};


1;
